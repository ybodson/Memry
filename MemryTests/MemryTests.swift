//
//  MemryTests.swift
//  MemryTests
//
//  Created by Yann Bodson on 16/3/2026.
//

import Testing
@testable import Memry

struct MemryTests {
    @MainActor @Test func findMatchingEntryGroupsReturnsDescendingPrefixes() async throws {
        let useCase = FindMatchingEntryGroupsUseCase()
        let entriesByCode = [
            "12": [MnemonicEntry(code: "12", word: "tin")],
            "1": [MnemonicEntry(code: "1", word: "toe")]
        ]

        let groups = useCase.execute(for: "12", entriesByCode: entriesByCode)

        #expect(groups.map(\.code) == ["12", "1"])
    }

    @MainActor @Test func selectEntryAppendsBreadcrumbAndConsumesDigits() async throws {
        let useCase = SelectEntryUseCase()
        let entry = MnemonicEntry(code: "12", word: "tin")
        let group = MatchingEntryGroup(code: "12", entries: [entry])
        let composition = NumberComposition(textInput: "1234", breadcrumbs: [])

        let updatedComposition = useCase.execute(entry: entry, in: group, composition: composition)

        #expect(updatedComposition.textInput == "34")
        #expect(updatedComposition.breadcrumbs == [Breadcrumb(word: "tin", code: "12")])
    }

    @MainActor @Test func removeLastBreadcrumbRestoresDigits() async throws {
        let useCase = RemoveLastBreadcrumbUseCase()
        let composition = NumberComposition(
            textInput: "34",
            breadcrumbs: [Breadcrumb(word: "tin", code: "12")]
        )

        let updatedComposition = useCase.execute(composition: composition)

        #expect(updatedComposition.textInput == "1234")
        #expect(updatedComposition.breadcrumbs.isEmpty)
    }
}
