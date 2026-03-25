import Foundation
import Observation

@Observable
final class NumbersViewModel {
    private(set) var compositions: [NumberComposition] = []
    var errorMessage: String?

    private let repository: any NumberCompositionRepository

    init(repository: any NumberCompositionRepository) {
        self.repository = repository
    }

    func loadCompositions() {
        do {
            compositions = try repository.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ composition: NumberComposition) {
        do {
            try repository.save(composition)
            loadCompositions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
