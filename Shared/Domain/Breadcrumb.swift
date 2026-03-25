import Foundation

struct Breadcrumb: Identifiable, Hashable, Sendable {
    let id: UUID
    let word: String
    let code: String

    init(word: String, code: String) {
        self.id = UUID()
        self.word = word
        self.code = code
    }

    static func == (lhs: Breadcrumb, rhs: Breadcrumb) -> Bool {
        lhs.word == rhs.word && lhs.code == rhs.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(code)
    }
}
