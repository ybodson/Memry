import SwiftData
import SwiftUI

@main
struct MemryApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: PersistedNumberComposition.self, PersistedBreadcrumb.self
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
