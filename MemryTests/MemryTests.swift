//
//  MemryTests.swift
//  MemryTests
//
//  Created by Yann Bodson on 16/3/2026.
//

import Testing
@testable import Memry

struct MemryTests {
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
