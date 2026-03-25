import Foundation

struct FindMatchingEntryGroupsUseCase: Sendable {
    func execute(
        for textInput: String,
        entriesByCode: [String: [MnemonicEntry]]
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
