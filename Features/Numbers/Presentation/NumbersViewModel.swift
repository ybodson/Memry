import CoreData
import Foundation
import Observation

protocol CloudSyncEvent {
    var type: NSPersistentCloudKitContainer.EventType { get }
    var endDate: Date? { get }
    var error: (any Error)? { get }
}

extension NSPersistentCloudKitContainer.Event: CloudSyncEvent {}

@Observable
final class NumbersViewModel {
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

    func loadCompositions() {
        do {
            compositions = try repository.fetchAll()
            errorMessage = nil
            if compositions.isEmpty == false {
                isAwaitingInitialCloudSync = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        hasLoaded = true
    }

    func handleCloudSyncEvent(_ event: some CloudSyncEvent) {
        guard event.type == .setup || event.type == .import else { return }

        hasObservedCloudSyncEvent = true

        if event.endDate == nil {
            if compositions.isEmpty {
                isAwaitingInitialCloudSync = true
            }
            return
        }

        if let error = event.error {
            errorMessage = error.localizedDescription
        }

        if compositions.isEmpty {
            isAwaitingInitialCloudSync = false
        }
    }

    func finishInitialCloudSyncIfStillEmpty() {
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
            compositions.removeAll { $0.id == composition.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startObservingCloudSync() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                for await _ in NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange) {
                    await MainActor.run { [weak self] in
                        self?.loadCompositions()
                    }
                }
            }

            group.addTask { [weak self] in
                for await notification in NotificationCenter.default.notifications(
                    named: NSPersistentCloudKitContainer.eventChangedNotification
                ) {
                    guard
                        let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                            as? NSPersistentCloudKitContainer.Event
                    else {
                        continue
                    }

                    await MainActor.run { [weak self] in
                        self?.handleCloudSyncEvent(event)

                        if event.endDate != nil {
                            self?.loadCompositions()
                        }
                    }
                }
            }

            group.addTask { [weak self] in
                try? await Task.sleep(for: .seconds(5))
                await MainActor.run { [weak self] in
                    self?.finishInitialCloudSyncIfStillEmpty()
                }
            }
        }
    }
}
