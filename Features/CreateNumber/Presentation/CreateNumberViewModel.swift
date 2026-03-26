import Foundation
import Observation

@Observable
final class CreateNumberViewModel {
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
            .compactMap { group in
                let filtered = group.entries.sorted(by: { $0.score > $1.score }) //.filter { $0.score >= 0.0 }
                guard filtered.isEmpty == false else { return nil }
                return MatchingEntryGroup(code: group.code, entries: filtered)
            }
    }

    func loadEntriesIfNeeded() async {
        guard entriesByCode.isEmpty else {
            return
        }

        isLoading = true

        do {
            entriesByCode = try repository.loadEntriesByCode()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func retryLoading() async {
        guard entriesByCode.isEmpty else {
            return
        }

        await loadEntriesIfNeeded()
    }

    func select(_ entry: MnemonicEntry, in group: MatchingEntryGroup) {
        apply(currentComposition.selectingEntry(entry, in: group))
    }

    func removeLastBreadcrumb() {
        apply(currentComposition.removingLastBreadcrumb())
    }

    func save() -> Bool {
        guard canSave else { return false }
        do {
            try onSave(currentComposition)
            return true
        } catch {
            errorMessage = error.localizedDescription
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
}
