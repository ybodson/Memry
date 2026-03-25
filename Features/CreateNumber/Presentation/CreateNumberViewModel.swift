import Foundation
import Observation

@Observable
final class CreateNumberViewModel {
    var textInput: String = ""
    private(set) var breadcrumbs: [Breadcrumb] = []
    var isLoading = true
    var errorMessage: String?

    private var entriesByCode: [String: [MnemonicEntry]] = [:]
    private let repository: any MajorIndexRepository

    init(repository: any MajorIndexRepository) {
        self.repository = repository
    }

    var matchingEntryGroups: [MatchingEntryGroup] {
        currentComposition.matchingEntryGroups(entriesByCode: entriesByCode)
    }

    func loadEntriesIfNeeded() async {
        guard isLoading, entriesByCode.isEmpty else {
            return
        }

        do {
            entriesByCode = try repository.loadEntriesByCode()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func select(_ entry: MnemonicEntry, in group: MatchingEntryGroup) {
        apply(currentComposition.selectingEntry(entry, in: group))
    }

    func removeLastBreadcrumb() {
        apply(currentComposition.removingLastBreadcrumb())
    }

    private var currentComposition: NumberComposition {
        NumberComposition(textInput: textInput, breadcrumbs: breadcrumbs)
    }

    private func apply(_ composition: NumberComposition) {
        textInput = composition.textInput
        breadcrumbs = composition.breadcrumbs
    }
}
