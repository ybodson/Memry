import Foundation
import SwiftData

struct SwiftDataNumberCompositionRepository: NumberCompositionRepository {
    let modelContext: ModelContext

    func fetchAll() throws -> [NumberComposition] {
        let descriptor = FetchDescriptor<PersistedNumberComposition>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let persisted = try modelContext.fetch(descriptor)
        return persisted.map { $0.toDomain() }
    }

    func save(_ composition: NumberComposition) throws {
        let persisted = PersistedNumberComposition.fromDomain(composition)
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
}
