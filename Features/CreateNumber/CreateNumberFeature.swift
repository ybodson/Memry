import Foundation

enum CreateNumberFeature {
    static func makeView() -> CreateNumber {
        CreateNumber(viewModel: makeViewModel())
    }

    static func makeViewModel() -> CreateNumberViewModel {
        CreateNumberViewModel(
            loadMajorIndexUseCase: LoadMajorIndexUseCase(repository: BundledMajorIndexRepository()),
            findMatchingEntryGroupsUseCase: FindMatchingEntryGroupsUseCase(),
            selectEntryUseCase: SelectEntryUseCase(),
            removeLastBreadcrumbUseCase: RemoveLastBreadcrumbUseCase()
        )
    }
}
