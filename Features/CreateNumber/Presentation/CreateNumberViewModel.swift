import Foundation
import Observation

@Observable
final class CreateNumberViewModel {
    var textInput: String = ""
    private(set) var breadcrumbs: [Breadcrumb] = []
    var isScrollGestureActive = false
    var isLoading = true
    var errorMessage: String?

    private var entriesByCode: [String: [MnemonicEntry]] = [:]
    private let loadMajorIndexUseCase: LoadMajorIndexUseCase
    private let findMatchingEntryGroupsUseCase: FindMatchingEntryGroupsUseCase
    private let selectEntryUseCase: SelectEntryUseCase
    private let removeLastBreadcrumbUseCase: RemoveLastBreadcrumbUseCase

    init(
        loadMajorIndexUseCase: LoadMajorIndexUseCase,
        findMatchingEntryGroupsUseCase: FindMatchingEntryGroupsUseCase,
        selectEntryUseCase: SelectEntryUseCase,
        removeLastBreadcrumbUseCase: RemoveLastBreadcrumbUseCase
    ) {
        self.loadMajorIndexUseCase = loadMajorIndexUseCase
        self.findMatchingEntryGroupsUseCase = findMatchingEntryGroupsUseCase
        self.selectEntryUseCase = selectEntryUseCase
        self.removeLastBreadcrumbUseCase = removeLastBreadcrumbUseCase
    }

    var matchingEntryGroups: [MatchingEntryGroup] {
        findMatchingEntryGroupsUseCase.execute(for: textInput, entriesByCode: entriesByCode)
    }

    func loadEntriesIfNeeded() async {
        guard isLoading, entriesByCode.isEmpty else {
            return
        }

        do {
            entriesByCode = try loadMajorIndexUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func select(_ entry: MnemonicEntry, in group: MatchingEntryGroup) {
        apply(
            selectEntryUseCase.execute(
                entry: entry,
                in: group,
                composition: currentComposition
            )
        )
    }

    func removeLastBreadcrumb() {
        apply(removeLastBreadcrumbUseCase.execute(composition: currentComposition))
    }

    func beginScrollGesture() {
        isScrollGestureActive = true
    }

    func endScrollGesture() async {
        try? await Task.sleep(for: .milliseconds(150))
        isScrollGestureActive = false
    }

    private var currentComposition: NumberComposition {
        NumberComposition(textInput: textInput, breadcrumbs: breadcrumbs)
    }

    private func apply(_ composition: NumberComposition) {
        textInput = composition.textInput
        breadcrumbs = composition.breadcrumbs
    }
}
