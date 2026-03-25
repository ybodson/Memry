import Foundation

struct Breadcrumb: Identifiable, Hashable, Sendable {
    let id: UUID
    let word: String
    let code: String

    init(id: UUID = UUID(), word: String, code: String) {
        self.id = id
        self.word = word
        self.code = code
    }
}
