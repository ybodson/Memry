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
}
