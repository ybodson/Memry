import Foundation
import SwiftData

@Model
final class PersistedNumberComposition {
    @Relationship(deleteRule: .cascade, inverse: \PersistedBreadcrumb.composition)
    var breadcrumbs: [PersistedBreadcrumb]?
    var createdAt: Date = Date()

    init(breadcrumbs: [PersistedBreadcrumb], createdAt: Date) {
        self.breadcrumbs = breadcrumbs
        self.createdAt = createdAt
    }
}
