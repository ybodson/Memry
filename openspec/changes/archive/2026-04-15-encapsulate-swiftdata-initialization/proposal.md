## Why

`MemryApp` currently owns the SwiftData/CloudKit `ModelContainer` setup, leaking infrastructure concerns into the app entry point and requiring `MemryApp` to import `SwiftData`. Moving initialization into `SwiftDataNumberCompositionRepository` keeps the app layer free of data-layer dependencies and puts lifecycle ownership where it belongs.

## What Changes

- `SwiftDataNumberCompositionRepository` gains a failable initializer (or static factory) that sets up the `ModelContainer` and `ModelContext` internally using the CloudKit configuration.
- `MemryApp` drops its `ModelContainer` property and SwiftData init block; it creates a repository directly and delegates all data-layer concerns to it.
- `import SwiftData` is removed from `MemryApp.swift`.
- The CloudKit container ID constant moves out of `MemryApp` and into `SwiftDataNumberCompositionRepository`.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `app-startup-data-store`: The startup data store is now initialized inside the repository rather than in the app entry point. External behavior (success/failure routing, error display) is unchanged; only the locus of initialization moves.

## Impact

- `Memry/MemryApp.swift` — simplified; no SwiftData import
- `Features/ViewNumbers/Data/SwiftDataNumberCompositionRepository.swift` — gains init-time setup logic
- No API or protocol changes; `NumberCompositionRepository` interface is unaffected
