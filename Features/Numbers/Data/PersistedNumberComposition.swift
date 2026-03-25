import Foundation
import SwiftData

@Model
final class PersistedNumberComposition {
    @Relationship(deleteRule: .cascade)
    var breadcrumbs: [PersistedBreadcrumb]
    var createdAt: Date

    init(breadcrumbs: [PersistedBreadcrumb], createdAt: Date) {
        self.breadcrumbs = breadcrumbs
        self.createdAt = createdAt
    }
}
