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
        if let persisted = try persistedCompositions(matching: composition.id).first {
            persisted.update(from: composition)
        } else {
            let persisted = PersistedNumberComposition.fromDomain(composition)
            modelContext.insert(persisted)
        }
        try modelContext.save()
    }

    func delete(_ composition: NumberComposition) throws {
        for persisted in try persistedCompositions(matching: composition.id) {
            modelContext.delete(persisted)
        }
        try modelContext.save()
    }

    private func persistedCompositions(matching id: UUID) throws -> [PersistedNumberComposition] {
        let descriptor = FetchDescriptor<PersistedNumberComposition>(
            predicate: #Predicate { $0.compositionID == id }
        )
        return try modelContext.fetch(descriptor)
    }
}
