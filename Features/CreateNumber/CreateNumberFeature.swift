import Foundation

enum CreateNumberFeature {
    static func makeView(onSave: @escaping (NumberComposition) throws -> Void) -> CreateNumber {
        CreateNumber(viewModel: makeViewModel(onSave: onSave))
    }

    static func makeViewModel(onSave: @escaping (NumberComposition) throws -> Void) -> CreateNumberViewModel {
        CreateNumberViewModel(repository: BundledMajorIndexRepository(), onSave: onSave)
    }
}
