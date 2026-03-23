import MajorSystemKit

struct PrefixMajorEntryMatcher: MajorEntryMatching {
    func matchingGroups(
        for textInput: String,
        entriesByCode: [String: [MajorEntry]]
    ) -> [MatchingEntryGroup] {
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
