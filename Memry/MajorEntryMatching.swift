import MajorSystemKit

protocol MajorEntryMatching {
    func matchingGroups(
        for textInput: String,
        entriesByCode: [String: [MajorEntry]]
    ) -> [MatchingEntryGroup]
}
