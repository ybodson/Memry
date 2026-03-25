import Foundation

struct NumberComposition: Equatable, Sendable {
    var textInput: String
    var breadcrumbs: [Breadcrumb]

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
