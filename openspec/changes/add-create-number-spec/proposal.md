## Why

The `CreateNumber` feature already exists in the app, but its behavior is only implicit in the SwiftUI and view-model implementation. Adding an OpenSpec spec makes the composition flow explicit so future changes can be made against a stable contract instead of reverse-engineering the screen from code.

## What Changes

- Add a new `create-number` capability spec documenting the existing `CreateNumber` flow
- Define the user-visible behavior for loading the major index, entering digits, showing matching mnemonic groups, building breadcrumbs, and saving a composition
- Capture the current error and retry behavior for failed major index loads and failed saves
- Record the feature boundaries impacted by the documented behavior without changing runtime implementation

## Capabilities

### New Capabilities
- `create-number`: Creates a number composition from digit input and mnemonic word selections, then saves it back to the caller

### Modified Capabilities
<!-- none -->

## Impact

- `Features/CreateNumber/` presentation, domain, and data layers
- Shared domain types used by the feature, especially `NumberComposition` and `Breadcrumb`
- No API or persistence schema changes; this change documents existing behavior only
