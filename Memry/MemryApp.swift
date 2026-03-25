import SwiftData
import SwiftUI

@main
struct MemryApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let configuration = ModelConfiguration(
                cloudKitDatabase: .private("iCloud.frogmojo.Memry")
            )
            modelContainer = try ModelContainer(
                for: PersistedNumberComposition.self, PersistedBreadcrumb.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Numbers(
                viewModel: NumbersViewModel(
                    repository: SwiftDataNumberCompositionRepository(
                        modelContext: modelContainer.mainContext
                    )
                )
            )
        }
    }
}
