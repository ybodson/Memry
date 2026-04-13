import CoreData
import Foundation
import Observation

protocol CloudSyncEvent {
    var type: NSPersistentCloudKitContainer.EventType { get }
    var endDate: Date? { get }
    var error: (any Error)? { get }
}

extension NSPersistentCloudKitContainer.Event: CloudSyncEvent {}

@Observable @MainActor final class ViewNumbersViewModel {
    private(set) var compositions: [NumberComposition] = []
    private(set) var hasLoaded = false
    private(set) var isAwaitingInitialCloudSync = true
    private(set) var hasObservedCloudSyncEvent = false
    var errorMessage: String?

    private let repository: any NumberCompositionRepository

    init(repository: any NumberCompositionRepository) {
        self.repository = repository
    }

    var showsLoadingSkeleton: Bool {
        !hasLoaded || (compositions.isEmpty && isAwaitingInitialCloudSync)
    }

    func load() {
        do {
            apply(try repository.fetchAll())
        } catch {
            fail(error)
        }
        hasLoaded = true
    }

    func sync(_ event: some CloudSyncEvent) {
        guard tracks(event) else { return }
        hasObservedCloudSyncEvent = true
        guard event.endDate != nil else { return startSyncWait() }
        finishSync(with: event)
    }

    func endSyncWait() {
        guard hasObservedCloudSyncEvent == false, compositions.isEmpty else { return }
        isAwaitingInitialCloudSync = false
    }

    func save(_ composition: NumberComposition) throws {
        try repository.save(composition)
        compositions.insert(composition, at: 0)
        errorMessage = nil
    }

    func delete(_ composition: NumberComposition) {
        do {
            try repository.delete(composition)
            remove(composition)
        } catch {
            fail(error)
        }
    }

    func observeSync() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in await self?.watchRemoteChanges() }
            group.addTask { [weak self] in await self?.watchCloudEvents() }
            group.addTask { [weak self] in await self?.watchSyncTimeout() }
        }
    }

    private func apply(_ compositions: [NumberComposition]) {
        self.compositions = compositions
        errorMessage = nil
        if compositions.isEmpty == false { isAwaitingInitialCloudSync = false }
    }

    private func tracks(_ event: some CloudSyncEvent) -> Bool {
        event.type == .setup || event.type == .import
    }

    private func startSyncWait() {
        if compositions.isEmpty { isAwaitingInitialCloudSync = true }
    }

    private func finishSync(with event: some CloudSyncEvent) {
        if let error = event.error { errorMessage = error.localizedDescription }
        if compositions.isEmpty { isAwaitingInitialCloudSync = false }
    }

    private func remove(_ composition: NumberComposition) {
        compositions.removeAll { $0.id == composition.id }
    }

    private func fail(_ error: any Error) {
        errorMessage = error.localizedDescription
    }

    private func watchRemoteChanges() async {
        for await _ in NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange) {
            await MainActor.run { [weak self] in self?.load() }
        }
    }

    private func watchCloudEvents() async {
        for await notification in NotificationCenter.default.notifications(named: NSPersistentCloudKitContainer.eventChangedNotification) {
            guard let event = event(from: notification) else { continue }
            await apply(event)
        }
    }

    private func event(from notification: Notification) -> NSPersistentCloudKitContainer.Event? {
        notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
            as? NSPersistentCloudKitContainer.Event
    }

    private func apply(_ event: NSPersistentCloudKitContainer.Event) async {
        await MainActor.run { [weak self] in
            self?.sync(event)
            if event.endDate != nil { self?.load() }
        }
    }

    private func watchSyncTimeout() async {
        try? await Task.sleep(for: .seconds(5))
        await MainActor.run { [weak self] in self?.endSyncWait() }
    }
}
