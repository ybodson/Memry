import SwiftUI

@main
struct MemryApp: App {
    private let repository: SwiftDataNumberCompositionRepository?
    private let initializationError: String?

    init() {
        do {
            repository = try SwiftDataNumberCompositionRepository()
            initializationError = nil
        } catch {
            repository = nil
            initializationError = error.localizedDescription
        }
    }

    var body: some Scene {
        WindowGroup {
            if let repository {
                ViewNumbers(
                    viewModel: ViewNumbersViewModel(
                        repository: repository
                    )
                )
            } else {
                ContentUnavailableView(
                    "Unable to Load Data",
                    systemImage: "exclamationmark.triangle",
                    description: Text(
                        initializationError
                            ?? "The app's database could not be initialized. Please restart the app or reinstall if the problem persists."
                    )
                )
            }
        }
    }
}
