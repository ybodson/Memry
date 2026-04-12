import Foundation
import SwiftData

@Model
final class PersistedBreadcrumb {
    var word: String = ""
    var code: String = ""
    var order: Int = 0
    var composition: PersistedNumberComposition?

    init(word: String, code: String, order: Int) {
        self.word = word
        self.code = code
        self.order = order
    }
}
