import Foundation

protocol NumberCompositionRepository {
    func fetchAll() throws -> [NumberComposition]
    func save(_ composition: NumberComposition) throws
}
