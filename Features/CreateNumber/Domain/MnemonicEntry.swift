import Foundation

struct MnemonicEntry: Identifiable, Equatable, Sendable {
    let code: String
    let word: String
    let score: Double

    var id: String {
        "\(code)_\(word)"
    }
}
