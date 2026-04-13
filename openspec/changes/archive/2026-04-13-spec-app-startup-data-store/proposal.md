## Why

The app's launch behavior currently depends on `MemryApp` creating a CloudKit-backed SwiftData container before any feature UI is shown, but that contract only exists in code. Capturing it in OpenSpec makes the startup path explicit so future app-shell, persistence, or onboarding changes do not accidentally break the first-run experience or failure handling.

## What Changes

- Add a new `app-startup-data-store` capability spec documenting the launch-time data-store initialization contract
- Define the success path that routes the user into the Numbers screen when the model container initializes correctly
- Define the failure path that keeps the app from crashing and shows an unavailable state with the underlying error message or fallback guidance
- Record the current boundary between the app composition root and feature screens without changing runtime behavior

## Capabilities

### New Capabilities
- `app-startup-data-store`: Initializes the app's CloudKit-backed SwiftData container at launch and routes the user to either the Numbers experience or a startup error state

### Modified Capabilities
<!-- none -->

## Impact

- [MemryApp.swift](/Users/ybodson/Developer/Memry/Memry/MemryApp.swift:1) app composition and startup flow
- SwiftData and CloudKit initialization at the app boundary
- The initial transition into `ViewNumbers` when startup succeeds
- No persistence schema, repository contract, or feature runtime changes; this change documents existing behavior only
