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
}
