import Foundation

struct NumberComposition: Identifiable, Equatable, Sendable {
    let id: UUID
    var textInput: String
    var breadcrumbs: [Breadcrumb]

    init(id: UUID = UUID(), textInput: String, breadcrumbs: [Breadcrumb]) {
        self.id = id
        self.textInput = textInput
        self.breadcrumbs = breadcrumbs
    }

    var number: String {
        breadcrumbs.map(\.code).joined()
    }

    var phrase: String {
        breadcrumbs.map(\.word).joined(separator: " ")
    }

    func selectingEntry(_ entry: MnemonicEntry, in group: MatchingEntryGroup) -> NumberComposition {
        guard textInput.hasPrefix(group.code) else {
            return self
        }

        var result = self
        result.breadcrumbs.append(Breadcrumb(word: entry.word, code: group.code))
        result.textInput.removeFirst(group.code.count)
        return result
    }

    func removingLastBreadcrumb() -> NumberComposition {
        var result = self

        guard let breadcrumb = result.breadcrumbs.popLast() else {
            return result
        }

        result.textInput = breadcrumb.code + result.textInput
        return result
    }

    func matchingEntryGroups(entriesByCode: [String: [MnemonicEntry]]) -> [MatchingEntryGroup] {
        var groups: [MatchingEntryGroup] = []
        var currentCode = textInput

        while currentCode.isEmpty == false {
            if let entries = entriesByCode[currentCode], entries.isEmpty == false {
                groups.append(MatchingEntryGroup(code: currentCode, entries: entries))
            }

            currentCode.removeLast()
        }

        return groups
    }
}
