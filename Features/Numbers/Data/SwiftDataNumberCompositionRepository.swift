import Foundation
import SwiftData

struct SwiftDataNumberCompositionRepository: NumberCompositionRepository {
    let modelContext: ModelContext

    func fetchAll() throws -> [NumberComposition] {
        let descriptor = FetchDescriptor<PersistedNumberComposition>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let persisted = try modelContext.fetch(descriptor)
        return persisted.map { toDomain($0) }
    }

    func save(_ composition: NumberComposition) throws {
        let persisted = toPersistedModel(composition)
        modelContext.insert(persisted)
        try modelContext.save()
    }

    func delete(_ composition: NumberComposition) throws {
        let id = composition.id
        let descriptor = FetchDescriptor<PersistedNumberComposition>(
            predicate: #Predicate { $0.compositionID == id }
        )
        guard let persisted = try modelContext.fetch(descriptor).first else { return }
        modelContext.delete(persisted)
        try modelContext.save()
    }

    private func toDomain(_ persisted: PersistedNumberComposition) -> NumberComposition {
        let breadcrumbs = (persisted.breadcrumbs ?? [])
            .sorted { $0.order < $1.order }
            .map { Breadcrumb(word: $0.word, code: $0.code) }
        return NumberComposition(id: persisted.compositionID, textInput: "", breadcrumbs: breadcrumbs)
    }

    private func toPersistedModel(_ composition: NumberComposition) -> PersistedNumberComposition {
        let breadcrumbs = composition.breadcrumbs.enumerated().map { index, breadcrumb in
            PersistedBreadcrumb(word: breadcrumb.word, code: breadcrumb.code, order: index)
        }
        return PersistedNumberComposition(compositionID: composition.id, breadcrumbs: breadcrumbs, createdAt: Date())
    }
}
