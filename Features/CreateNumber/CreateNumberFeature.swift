import Foundation

enum CreateNumberFeature {
    static func makeView() -> CreateNumber {
        CreateNumber(viewModel: makeViewModel())
    }

    static func makeViewModel() -> CreateNumberViewModel {
        CreateNumberViewModel(repository: BundledMajorIndexRepository())
    }
}
