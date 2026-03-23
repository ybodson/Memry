import Foundation

struct Breadcrumb: Identifiable, Equatable {
    let id: String
    let word: String
    let code: String

    init(word: String, code: String) {
        self.word = word
        self.code = code
        self.id = "\(code)_\(word)"
    }
}
