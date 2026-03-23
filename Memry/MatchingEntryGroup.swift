import Foundation
import MajorSystemKit

struct MatchingEntryGroup: Identifiable {
    let code: String
    let entries: [MajorEntry]

    var id: String {
        code
    }
}
