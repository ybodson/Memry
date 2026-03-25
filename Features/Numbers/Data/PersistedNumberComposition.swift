import Foundation
import SwiftData

@Model
final class PersistedNumberComposition {
    var compositionID: UUID = UUID()
    @Relationship(deleteRule: .cascade, inverse: \PersistedBreadcrumb.composition)
    var breadcrumbs: [PersistedBreadcrumb]?
    var createdAt: Date = Date()

    init(compositionID: UUID, breadcrumbs: [PersistedBreadcrumb], createdAt: Date) {
        self.compositionID = compositionID
        self.breadcrumbs = breadcrumbs
        self.createdAt = createdAt
    }

    func toDomain() -> NumberComposition {
        let breadcrumbs = (breadcrumbs ?? [])
            .sorted { $0.order < $1.order }
            .map { Breadcrumb(word: $0.word, code: $0.code) }
        return NumberComposition(id: compositionID, textInput: "", breadcrumbs: breadcrumbs)
    }

    static func fromDomain(_ composition: NumberComposition) -> PersistedNumberComposition {
        let breadcrumbs = composition.breadcrumbs.enumerated().map { index, breadcrumb in
            PersistedBreadcrumb(word: breadcrumb.word, code: breadcrumb.code, order: index)
        }
        return PersistedNumberComposition(compositionID: composition.id, breadcrumbs: breadcrumbs, createdAt: Date())
    }
}
