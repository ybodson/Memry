//
//  MemryTests.swift
//  MemryTests
//
//  Created by Yann Bodson on 16/3/2026.
//

import Foundation
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
            "12": [MnemonicEntry(code: "12", word: "tin")],
            "1": [MnemonicEntry(code: "1", word: "toe")]
        ]
        let composition = NumberComposition(textInput: "12", breadcrumbs: [])

        let groups = composition.matchingEntryGroups(entriesByCode: entriesByCode)

        #expect(groups.map(\.code) == ["12", "1"])
    }

    @Test func selectEntryAppendsBreadcrumbAndConsumesDigits() {
        let entry = MnemonicEntry(code: "12", word: "tin")
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
            "12": [MnemonicEntry(code: "12", word: "tin")]
        ]
    }
}
