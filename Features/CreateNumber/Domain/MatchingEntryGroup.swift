import Foundation

struct MatchingEntryGroup: Identifiable, Equatable, Sendable {
    let code: String
    let entries: [MnemonicEntry]

    var id: String {
        code
    }
}
