import SwiftData
import SwiftUI

@main
struct MemryApp: App {
    static let cloudKitContainerID = "iCloud.frogmojo.Memry"

    private let modelContainer: ModelContainer?

    init() {
        do {
            let configuration = ModelConfiguration(
                cloudKitDatabase: .private(Self.cloudKitContainerID)
            )
            modelContainer = try ModelContainer(
                for: PersistedNumberComposition.self, PersistedBreadcrumb.self,
                configurations: configuration
            )
        } catch {
            modelContainer = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                ViewNumbers(
                    viewModel: ViewNumbersViewModel(
                        repository: SwiftDataNumberCompositionRepository(
                            modelContext: modelContainer.mainContext
                        )
                    )
                )
            } else {
                ContentUnavailableView(
                    "Unable to Load Data",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The app's database could not be initialized. Please restart the app or reinstall if the problem persists.")
                )
            }
        }
    }
}
