import Foundation

struct SelectEntryUseCase: Sendable {
    func execute(
        entry: MnemonicEntry,
        in group: MatchingEntryGroup,
        composition: NumberComposition
    ) -> NumberComposition {
        guard composition.textInput.hasPrefix(group.code) else {
            return composition
        }

        var updatedComposition = composition
        updatedComposition.breadcrumbs.append(Breadcrumb(word: entry.word, code: group.code))
        updatedComposition.textInput.removeFirst(group.code.count)
        return updatedComposition
    }
}
