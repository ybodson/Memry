import Foundation
import MajorSystemKit
import Observation

@Observable
final class CreateNumberViewModel {
    var entriesByCode: [String: [MajorEntry]] = [:]
    var textInput: String = ""
    var breadcrumbs: [Breadcrumb] = []
    var isScrollGestureActive = false
    var isLoading = true
    var errorMessage: String?

    private let indexProvider: any MajorIndexProviding
    private let matcher: any MajorEntryMatching

    init(
        indexProvider: any MajorIndexProviding = BundledMajorIndexProvider(),
        matcher: any MajorEntryMatching = PrefixMajorEntryMatcher()
    ) {
        self.indexProvider = indexProvider
        self.matcher = matcher
    }

    var matchingEntryGroups: [MatchingEntryGroup] {
        matcher.matchingGroups(for: textInput, entriesByCode: entriesByCode)
    }

    func loadEntriesIfNeeded() async {
        guard isLoading, entriesByCode.isEmpty else {
            return
        }

        do {
            entriesByCode = try indexProvider.loadEntriesByCode()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func select(_ entry: MajorEntry, in group: MatchingEntryGroup) {
        guard textInput.hasPrefix(group.code) else {
            return
        }

        breadcrumbs.append(Breadcrumb(word: entry.word, code: group.code))
        textInput.removeFirst(group.code.count)
    }

    func removeLastBreadcrumb() {
        guard let breadcrumb = breadcrumbs.popLast() else {
            return
        }

        textInput = breadcrumb.code + textInput
    }

    func beginScrollGesture() {
        isScrollGestureActive = true
    }

    func endScrollGesture() async {
        try? await Task.sleep(for: .milliseconds(150))
        isScrollGestureActive = false
    }
}
