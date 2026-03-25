import Foundation

struct LoadMajorIndexUseCase: Sendable {
    private let repository: any MajorIndexRepository

    init(repository: any MajorIndexRepository) {
        self.repository = repository
    }

    func execute() throws -> [String: [MnemonicEntry]] {
        try repository.loadEntriesByCode()
    }
}
