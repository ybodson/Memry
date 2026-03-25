import Foundation

enum CreateNumberFeature {
    static func makeView(onSave: @escaping (NumberComposition) -> Void) -> CreateNumber {
        CreateNumber(viewModel: makeViewModel(onSave: onSave))
    }

    static func makeViewModel(onSave: @escaping (NumberComposition) -> Void) -> CreateNumberViewModel {
        CreateNumberViewModel(repository: BundledMajorIndexRepository(), onSave: onSave)
    }
}
