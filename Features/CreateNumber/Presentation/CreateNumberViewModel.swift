import Foundation
import Observation

@Observable @MainActor final class CreateNumberViewModel {
    var textInput: String = "" {
        didSet {
            let normalized = textInput.filter(\.isNumber)
            if textInput != normalized {
                textInput = normalized
            }
        }
    }
    private(set) var breadcrumbs: [Breadcrumb] = []
    var isLoading = true
    var errorMessage: String?

    private var entriesByCode: [String: [MnemonicEntry]] = [:]
    private let repository: any MajorIndexRepository
    private let onSave: (NumberComposition) throws -> Void

    init(repository: any MajorIndexRepository, onSave: @escaping (NumberComposition) throws -> Void) {
        self.repository = repository
        self.onSave = onSave
    }

    var canSave: Bool {
        !breadcrumbs.isEmpty && textInput.isEmpty
    }

    var matchingEntryGroups: [MatchingEntryGroup] {
        currentComposition.matchingEntryGroups(entriesByCode: entriesByCode)
            .map { group in
                MatchingEntryGroup(
                    code: group.code,
                    entries: group.entries.sorted { $0.score > $1.score }
                )
            }
    }

    func load() async {
        guard entriesByCode.isEmpty else { return }
        isLoading = true
        finishLoading(with: Result(catching: repository.loadEntriesByCode))
    }

    func retry() async {
        await load()
    }

    func select(_ entry: MnemonicEntry, in group: MatchingEntryGroup) {
        apply(currentComposition.selectingEntry(entry, in: group))
    }

    func pop() {
        apply(currentComposition.removingLastBreadcrumb())
    }

    func save() -> Bool {
        guard canSave else { return false }
        return save(currentComposition)
    }

    private func save(_ composition: NumberComposition) -> Bool {
        do {
            try onSave(composition)
            return true
        } catch {
            setError(error)
            return false
        }
    }

    private var currentComposition: NumberComposition {
        NumberComposition(textInput: textInput, breadcrumbs: breadcrumbs)
    }

    private func apply(_ composition: NumberComposition) {
        textInput = composition.textInput
        breadcrumbs = composition.breadcrumbs
    }

    private func finishLoading(with result: Result<[String: [MnemonicEntry]], Error>) {
        switch result {
        case .success(let entries): set(entries)
        case .failure(let error): setError(error)
        }
        isLoading = false
    }

    private func set(_ entries: [String: [MnemonicEntry]]) {
        entriesByCode = entries
        errorMessage = nil
    }

    private func setError(_ error: any Error) {
        errorMessage = error.localizedDescription
    }
}
