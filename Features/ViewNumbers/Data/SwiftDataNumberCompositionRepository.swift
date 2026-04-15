import Foundation
import SwiftData

struct SwiftDataNumberCompositionRepository: NumberCompositionRepository {
    private static let cloudKitContainerID = "iCloud.frogmojo.Memry"
    private let modelContainer: ModelContainer

    init() throws {
        let configuration = ModelConfiguration(
            cloudKitDatabase: .private(Self.cloudKitContainerID)
        )
        modelContainer = try ModelContainer(
            for: PersistedNumberComposition.self, PersistedBreadcrumb.self,
            configurations: configuration
        )
    }

    func fetchAll() throws -> [NumberComposition] {
        let descriptor = FetchDescriptor<PersistedNumberComposition>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let persisted = try modelContainer.mainContext.fetch(descriptor)
        return persisted.map { $0.toDomain() }
    }

    func save(_ composition: NumberComposition) throws {
        if let persisted = try persistedCompositions(matching: composition.id).first {
            persisted.update(from: composition)
        } else {
            let persisted = PersistedNumberComposition.fromDomain(composition)
            modelContainer.mainContext.insert(persisted)
        }
        try modelContainer.mainContext.save()
    }

    func delete(_ composition: NumberComposition) throws {
        for persisted in try persistedCompositions(matching: composition.id) {
            modelContainer.mainContext.delete(persisted)
        }
        try modelContainer.mainContext.save()
    }

    private func persistedCompositions(matching id: UUID) throws -> [PersistedNumberComposition] {
        let descriptor = FetchDescriptor<PersistedNumberComposition>(
            predicate: #Predicate { $0.compositionID == id }
        )
        return try modelContainer.mainContext.fetch(descriptor)
    }
}
