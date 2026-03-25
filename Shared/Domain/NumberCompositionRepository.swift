import Foundation

@MainActor
protocol NumberCompositionRepository {
    func fetchAll() throws -> [NumberComposition]
    func save(_ composition: NumberComposition) throws
    func delete(_ composition: NumberComposition) throws
}
