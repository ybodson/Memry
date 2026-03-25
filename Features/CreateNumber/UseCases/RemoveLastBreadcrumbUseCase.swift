import Foundation

struct RemoveLastBreadcrumbUseCase: Sendable {
    func execute(composition: NumberComposition) -> NumberComposition {
        var updatedComposition = composition

        guard let breadcrumb = updatedComposition.breadcrumbs.popLast() else {
            return updatedComposition
        }

        updatedComposition.textInput = breadcrumb.code + updatedComposition.textInput
        return updatedComposition
    }
}
