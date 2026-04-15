## 1. Repository: Add failable initializer

- [x] 1.1 Add `static let cloudKitContainerID = "iCloud.frogmojo.Memry"` constant to `SwiftDataNumberCompositionRepository`
- [x] 1.2 Add `init() throws` to `SwiftDataNumberCompositionRepository` that creates the `ModelContainer` with CloudKit configuration and assigns `mainContext` to `self.modelContext`

## 2. App Entry Point: Remove SwiftData dependency

- [x] 2.1 Replace `private let modelContainer: ModelContainer?` and `private let modelContainerInitializationError: String?` with `private let repository: SwiftDataNumberCompositionRepository?` and `private let initializationError: String?` in `MemryApp`
- [x] 2.2 Update `MemryApp.init()` to call `try SwiftDataNumberCompositionRepository()` inside a `do/catch`, storing the repository or the error string
- [x] 2.3 Update `MemryApp.body` to pass `repository` directly to `ViewNumbersViewModel` (removing the `modelContainer.mainContext` indirection)
- [x] 2.4 Remove `import SwiftData` from `MemryApp.swift`
- [x] 2.5 Remove the `cloudKitContainerID` constant from `MemryApp`
