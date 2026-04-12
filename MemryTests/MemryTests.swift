//
//  MemryTests.swift
//  MemryTests
//
//  Created by Yann Bodson on 16/3/2026.
//

import CoreData
import Foundation
import SwiftData
import Testing
@testable import Memry

struct MemryTests {
    @MainActor @Test func createNumberViewModelNormalizesTextInputToDigitsOnly() {
        let viewModel = CreateNumberViewModel(repository: StubMajorIndexRepository(result: .success([:])), onSave: { _ in })

        viewModel.textInput = "12a 3-4b"

        #expect(viewModel.textInput == "1234")
    }

    @MainActor @Test func createNumberViewModelRetriesAfterLoadFailure() async {
        let repository = RetryingMajorIndexRepository()
        let viewModel = CreateNumberViewModel(repository: repository, onSave: { _ in })
        viewModel.textInput = "12"

        await viewModel.loadEntriesIfNeeded()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == RetryingMajorIndexRepository.testError.localizedDescription)
        #expect(viewModel.matchingEntryGroups.isEmpty)
        #expect(repository.loadAttempts == 1)

        await viewModel.retryLoading()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.matchingEntryGroups.map(\.code) == ["12"])
        #expect(repository.loadAttempts == 2)
    }

    @Test func findMatchingEntryGroupsReturnsDescendingPrefixes() {
        let entriesByCode = [
            "12": [MnemonicEntry(code: "12", word: "tin", score: 1.0)],
            "1": [MnemonicEntry(code: "1", word: "toe", score: 1.0)]
        ]
        let composition = NumberComposition(textInput: "12", breadcrumbs: [])

        let groups = composition.matchingEntryGroups(entriesByCode: entriesByCode)

        #expect(groups.map(\.code) == ["12", "1"])
    }

    @Test func selectEntryAppendsBreadcrumbAndConsumesDigits() {
        let entry = MnemonicEntry(code: "12", word: "tin", score: 1.0)
        let group = MatchingEntryGroup(code: "12", entries: [entry])
        let composition = NumberComposition(textInput: "1234", breadcrumbs: [])

        let result = composition.selectingEntry(entry, in: group)

        #expect(result.textInput == "34")
        #expect(result.breadcrumbs.count == 1)
        #expect(result.breadcrumbs[0].word == "tin")
        #expect(result.breadcrumbs[0].code == "12")
    }

    @Test func removeLastBreadcrumbRestoresDigits() {
        let composition = NumberComposition(
            textInput: "34",
            breadcrumbs: [Breadcrumb(word: "tin", code: "12")]
        )

        let result = composition.removingLastBreadcrumb()

        #expect(result.textInput == "1234")
        #expect(result.breadcrumbs.isEmpty)
    }
}

// MARK: - ViewNumbersViewModel Tests

struct ViewNumbersViewModelTests {
    @MainActor @Test func loadCompositionsPopulatesList() {
        let composition = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "tin", code: "12")])
        let repository = StubNumberCompositionRepository(compositions: [composition])
        let viewModel = ViewNumbersViewModel(repository: repository)

        viewModel.loadCompositions()

        #expect(viewModel.compositions.count == 1)
        #expect(viewModel.compositions[0].number == "12")
        #expect(viewModel.compositions[0].phrase == "tin")
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showsLoadingSkeleton == false)
    }

    @MainActor @Test func loadCompositionsSetsErrorOnFailure() {
        let repository = StubNumberCompositionRepository(fetchError: StubNumberCompositionRepository.testError)
        let viewModel = ViewNumbersViewModel(repository: repository)

        viewModel.loadCompositions()

        #expect(viewModel.compositions.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }

    @MainActor @Test func saveAddsCompositionToFrontOfList() throws {
        let existing = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "moon", code: "32")])
        let repository = StubNumberCompositionRepository(compositions: [existing])
        let viewModel = ViewNumbersViewModel(repository: repository)
        viewModel.loadCompositions()

        let newComposition = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "tin", code: "12")])
        try viewModel.save(newComposition)

        #expect(repository.savedCompositions.count == 1)
        #expect(viewModel.compositions.count == 2)
        #expect(viewModel.compositions[0].number == "12")
        #expect(viewModel.compositions[1].number == "32")
    }

    @MainActor @Test func deleteRemovesCompositionFromList() {
        let composition = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "tin", code: "12")])
        let repository = StubNumberCompositionRepository(compositions: [composition])
        let viewModel = ViewNumbersViewModel(repository: repository)
        viewModel.loadCompositions()

        #expect(viewModel.compositions.count == 1)

        viewModel.delete(composition)

        #expect(viewModel.compositions.isEmpty)
    }

    @MainActor @Test func emptyFetchKeepsSkeletonVisibleUntilInitialSyncSettles() {
        let repository = StubNumberCompositionRepository(compositions: [])
        let viewModel = ViewNumbersViewModel(repository: repository)

        viewModel.loadCompositions()

        #expect(viewModel.compositions.isEmpty)
        #expect(viewModel.showsLoadingSkeleton)

        viewModel.finishInitialCloudSyncIfStillEmpty()

        #expect(viewModel.showsLoadingSkeleton == false)
    }

    @MainActor @Test func saveThrowsOnFailure() {
        let repository = StubNumberCompositionRepository(saveError: StubNumberCompositionRepository.testError)
        let viewModel = ViewNumbersViewModel(repository: repository)
        let composition = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "tin", code: "12")])

        #expect(throws: StubNumberCompositionRepository.testError) {
            try viewModel.save(composition)
        }
    }

    @MainActor @Test func deleteSetsErrorOnFailure() {
        let composition = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "tin", code: "12")])
        let repository = StubNumberCompositionRepository(compositions: [composition], deleteError: StubNumberCompositionRepository.testError)
        let viewModel = ViewNumbersViewModel(repository: repository)
        viewModel.loadCompositions()

        viewModel.delete(composition)

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.compositions.count == 1)
    }
}

// MARK: - CloudKit Sync State Machine Tests

struct CloudSyncTests {
    @MainActor @Test func showsSkeletonBeforeFirstLoad() {
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: []))

        #expect(viewModel.showsLoadingSkeleton)
        #expect(viewModel.hasLoaded == false)
        #expect(viewModel.isAwaitingInitialCloudSync)
    }

    @MainActor @Test func showsSkeletonAfterEmptyLoadWhileAwaitingSync() {
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: []))

        viewModel.loadCompositions()

        #expect(viewModel.hasLoaded)
        #expect(viewModel.compositions.isEmpty)
        #expect(viewModel.isAwaitingInitialCloudSync)
        #expect(viewModel.showsLoadingSkeleton)
    }

    @MainActor @Test func hidesSkeletonWhenCompositionsLoadedEvenDuringSync() {
        let composition = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "tin", code: "12")])
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: [composition]))

        viewModel.loadCompositions()

        #expect(viewModel.showsLoadingSkeleton == false)
        #expect(viewModel.isAwaitingInitialCloudSync == false)
    }

    @MainActor @Test func handleCloudSyncEventIgnoresExportEvents() {
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: []))
        viewModel.loadCompositions()

        let event = FakeCloudKitEvent(type: .export, endDate: Date(), error: nil)
        viewModel.handleCloudSyncEvent(event)

        #expect(viewModel.hasObservedCloudSyncEvent == false)
    }

    @MainActor @Test func handleCloudSyncEventTracksImportStart() {
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: []))
        viewModel.loadCompositions()

        let event = FakeCloudKitEvent(type: .import, endDate: nil, error: nil)
        viewModel.handleCloudSyncEvent(event)

        #expect(viewModel.hasObservedCloudSyncEvent)
        #expect(viewModel.isAwaitingInitialCloudSync)
    }

    @MainActor @Test func handleCloudSyncEventFinishesSyncOnImportEnd() {
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: []))
        viewModel.loadCompositions()

        let event = FakeCloudKitEvent(type: .import, endDate: Date(), error: nil)
        viewModel.handleCloudSyncEvent(event)

        #expect(viewModel.hasObservedCloudSyncEvent)
        #expect(viewModel.isAwaitingInitialCloudSync == false)
    }

    @MainActor @Test func handleCloudSyncEventCapturesSyncError() {
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: []))
        viewModel.loadCompositions()

        let syncError = NSError(domain: "CloudKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sync failed"])
        let event = FakeCloudKitEvent(type: .setup, endDate: Date(), error: syncError)
        viewModel.handleCloudSyncEvent(event)

        #expect(viewModel.errorMessage == "Sync failed")
    }

    @MainActor @Test func finishInitialCloudSyncDoesNothingIfSyncEventObserved() {
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: []))
        viewModel.loadCompositions()

        let event = FakeCloudKitEvent(type: .import, endDate: nil, error: nil)
        viewModel.handleCloudSyncEvent(event)

        viewModel.finishInitialCloudSyncIfStillEmpty()

        #expect(viewModel.isAwaitingInitialCloudSync)
    }

    @MainActor @Test func finishInitialCloudSyncDoesNothingIfCompositionsExist() {
        let composition = NumberComposition(textInput: "", breadcrumbs: [Breadcrumb(word: "tin", code: "12")])
        let viewModel = ViewNumbersViewModel(repository: StubNumberCompositionRepository(compositions: [composition]))
        viewModel.loadCompositions()

        viewModel.finishInitialCloudSyncIfStillEmpty()

        // isAwaitingInitialCloudSync was already set to false by loadCompositions since compositions exist
        #expect(viewModel.isAwaitingInitialCloudSync == false)
    }
}

// MARK: - Persistence Mapping Tests

struct PersistenceMappingTests {
    @Test func persistedNumberCompositionMapsToCorrectDomain() {
        let breadcrumb1 = PersistedBreadcrumb(word: "tin", code: "12", order: 0)
        let breadcrumb2 = PersistedBreadcrumb(word: "moon", code: "32", order: 1)
        let compositionID = UUID()
        let persisted = PersistedNumberComposition(
            compositionID: compositionID,
            breadcrumbs: [breadcrumb2, breadcrumb1],  // Intentionally out of order
            createdAt: Date()
        )

        let domain = persisted.toDomain()

        #expect(domain.id == compositionID)
        #expect(domain.textInput == "")
        #expect(domain.breadcrumbs.count == 2)
        #expect(domain.breadcrumbs[0].word == "tin")
        #expect(domain.breadcrumbs[0].code == "12")
        #expect(domain.breadcrumbs[1].word == "moon")
        #expect(domain.breadcrumbs[1].code == "32")
    }

    @Test func persistedNumberCompositionWithNilBreadcrumbsMapsToEmpty() {
        let compositionID = UUID()
        let persisted = PersistedNumberComposition(
            compositionID: compositionID,
            breadcrumbs: [],
            createdAt: Date()
        )
        persisted.breadcrumbs = nil

        let domain = persisted.toDomain()

        #expect(domain.id == compositionID)
        #expect(domain.breadcrumbs.isEmpty)
    }

    @Test func numberCompositionMapsToCorrectPersistedModel() {
        let id = UUID()
        let composition = NumberComposition(
            id: id,
            textInput: "",
            breadcrumbs: [
                Breadcrumb(word: "tin", code: "12"),
                Breadcrumb(word: "moon", code: "32")
            ]
        )

        let persisted = PersistedNumberComposition.fromDomain(composition)

        #expect(persisted.compositionID == id)
        #expect(persisted.breadcrumbs?.count == 2)
        let sortedBreadcrumbs = (persisted.breadcrumbs ?? []).sorted { $0.order < $1.order }
        #expect(sortedBreadcrumbs[0].word == "tin")
        #expect(sortedBreadcrumbs[0].code == "12")
        #expect(sortedBreadcrumbs[0].order == 0)
        #expect(sortedBreadcrumbs[1].word == "moon")
        #expect(sortedBreadcrumbs[1].code == "32")
        #expect(sortedBreadcrumbs[1].order == 1)
    }

    @Test func numberAndPhraseDerivedCorrectlyFromBreadcrumbs() {
        let composition = NumberComposition(
            textInput: "56",
            breadcrumbs: [
                Breadcrumb(word: "tin", code: "12"),
                Breadcrumb(word: "moon", code: "32")
            ]
        )

        #expect(composition.number == "1232")
        #expect(composition.phrase == "tin moon")
    }

    @MainActor @Test func repositorySaveUpdatesExistingCompositionInsteadOfDuplicating() throws {
        let container = try makeInMemoryModelContainer()
        let repository = SwiftDataNumberCompositionRepository(modelContext: container.mainContext)
        let id = UUID()

        try repository.save(
            NumberComposition(
                id: id,
                textInput: "",
                breadcrumbs: [Breadcrumb(word: "tin", code: "12")]
            )
        )
        try repository.save(
            NumberComposition(
                id: id,
                textInput: "",
                breadcrumbs: [Breadcrumb(word: "moon", code: "32")]
            )
        )

        let persisted = try container.mainContext.fetch(FetchDescriptor<PersistedNumberComposition>())
        let compositions = try repository.fetchAll()

        #expect(persisted.count == 1)
        #expect(compositions.count == 1)
        #expect(compositions[0].phrase == "moon")
        #expect(compositions[0].number == "32")
    }

    @MainActor @Test func repositoryDeleteRemovesAllRowsForCompositionID() throws {
        let container = try makeInMemoryModelContainer()
        let compositionID = UUID()
        let duplicateOne = PersistedNumberComposition(
            compositionID: compositionID,
            breadcrumbs: [PersistedBreadcrumb(word: "tin", code: "12", order: 0)],
            createdAt: Date(timeIntervalSince1970: 0)
        )
        let duplicateTwo = PersistedNumberComposition(
            compositionID: compositionID,
            breadcrumbs: [PersistedBreadcrumb(word: "moon", code: "32", order: 0)],
            createdAt: Date(timeIntervalSince1970: 1)
        )
        container.mainContext.insert(duplicateOne)
        container.mainContext.insert(duplicateTwo)
        try container.mainContext.save()

        let repository = SwiftDataNumberCompositionRepository(modelContext: container.mainContext)
        try repository.delete(NumberComposition(id: compositionID, textInput: "", breadcrumbs: []))

        let persisted = try container.mainContext.fetch(FetchDescriptor<PersistedNumberComposition>())
        #expect(persisted.isEmpty)
    }
}

@MainActor
private final class StubNumberCompositionRepository: NumberCompositionRepository {
    static let testError = NSError(domain: "MemryTests", code: 2, userInfo: [NSLocalizedDescriptionKey: "Repository error"])

    private(set) var savedCompositions: [NumberComposition] = []
    private var compositions: [NumberComposition]
    private let fetchError: Error?
    private let saveError: Error?
    private let deleteError: Error?

    init(compositions: [NumberComposition] = [], fetchError: Error? = nil, saveError: Error? = nil, deleteError: Error? = nil) {
        self.compositions = compositions
        self.fetchError = fetchError
        self.saveError = saveError
        self.deleteError = deleteError
    }

    func fetchAll() throws -> [NumberComposition] {
        if let fetchError { throw fetchError }
        return compositions
    }

    func save(_ composition: NumberComposition) throws {
        if let saveError { throw saveError }
        savedCompositions.append(composition)
        compositions.append(composition)
    }

    func delete(_ composition: NumberComposition) throws {
        if let deleteError { throw deleteError }
        compositions.removeAll { $0.id == composition.id }
    }
}

// MARK: - Test Helpers

private struct StubMajorIndexRepository: MajorIndexRepository {
    let result: Result<[String: [MnemonicEntry]], Error>

    func loadEntriesByCode() throws -> [String: [MnemonicEntry]] {
        try result.get()
    }
}

private final class RetryingMajorIndexRepository: MajorIndexRepository, @unchecked Sendable {
    static let testError = NSError(domain: "MemryTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Initial load failed"])

    private(set) var loadAttempts = 0

    func loadEntriesByCode() throws -> [String: [MnemonicEntry]] {
        loadAttempts += 1

        if loadAttempts == 1 {
            throw Self.testError
        }

        return [
            "12": [MnemonicEntry(code: "12", word: "tin", score: 1.0)]
        ]
    }
}

private struct FakeCloudKitEvent: CloudSyncEvent {
    let type: NSPersistentCloudKitContainer.EventType
    let endDate: Date?
    let error: (any Error)?
}

@MainActor
private func makeInMemoryModelContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(
        for: PersistedNumberComposition.self,
        PersistedBreadcrumb.self,
        configurations: configuration
    )
}
