## Context

`MemryApp` currently creates the `ModelContainer` with a CloudKit configuration and passes the resulting `mainContext` into `SwiftDataNumberCompositionRepository`. This means the app entry point must import `SwiftData`, hold the container, and handle initialization failure. The repository is a passive recipient of a context it did not set up.

## Goals / Non-Goals

**Goals:**
- `SwiftDataNumberCompositionRepository` owns and performs its own `ModelContainer` + `ModelContext` setup
- `MemryApp` creates the repository and responds to success/failure, but imports no SwiftData symbols
- The CloudKit container ID lives with the data layer, not the app layer

**Non-Goals:**
- Changing the user-visible behavior on startup success or failure
- Modifying the `NumberCompositionRepository` protocol
- Supporting multiple storage backends or configurations

## Decisions

### Failable initializer on `SwiftDataNumberCompositionRepository`

`SwiftDataNumberCompositionRepository.init() throws` sets up the `ModelContainer` and `ModelContext` internally.

**Alternatives considered:**
- `static func make() throws -> Self` — equivalent ergonomics; `init throws` is more idiomatic Swift.
- Async init — unnecessary; `ModelContainer` init is synchronous.

`MemryApp` calls `try SwiftDataNumberCompositionRepository()` inside a `do/catch` and stores either the repository or an error string, mirroring the current pattern without requiring a SwiftData import.

### CloudKit container ID moves into the repository

The constant `"iCloud.frogmojo.Memry"` is a data-layer concern; it belongs in `SwiftDataNumberCompositionRepository`, not `MemryApp`.

### `MemryApp` stores `SwiftDataNumberCompositionRepository?`

The app stores an optional repository (nil on failure) and the initialization error string. The `body` logic is unchanged: show `ViewNumbers` when the repository is available, show `ContentUnavailableView` otherwise.

## Risks / Trade-offs

- [Coupling] The repository is now responsible for its own container lifecycle — this is the desired outcome, but means the container cannot be shared with other repositories if one is added later. → Acceptable for now; a shared container can be introduced at that time.
- [Testability] Tests that previously injected a `ModelContext` still work; the new `init throws` path is an additional initializer, not a replacement for the existing one. → Keep `init(modelContext:)` for tests.
