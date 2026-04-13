## Why

The app already persists number compositions through SwiftData, but the rules that protect ordering and identity are only implied by repository code and tests. Capturing those rules in OpenSpec makes the storage contract explicit so future persistence changes do not silently corrupt composition ordering, duplicate saved entries, or break deletion behavior.

## What Changes

- Add a new `persist-number-compositions` capability spec documenting the current persistence contract for saved number compositions
- Define the fetch behavior that returns saved compositions newest first
- Define the mapping behavior that preserves breadcrumb order when reading from and writing to persistence
- Define the save behavior that updates an existing composition by id instead of duplicating it, and the delete behavior that removes all persisted rows for a composition id

## Capabilities

### New Capabilities
- `persist-number-compositions`: Stores, retrieves, updates, and deletes saved number compositions while preserving identity and breadcrumb ordering

### Modified Capabilities
<!-- none -->

## Impact

- `Features/ViewNumbers/Data/SwiftDataNumberCompositionRepository.swift`
- `Features/ViewNumbers/Data/PersistedNumberComposition.swift`
- `Features/ViewNumbers/Data/PersistedBreadcrumb.swift`
- Shared `NumberComposition` and `Breadcrumb` persistence expectations
- No schema or runtime behavior changes; this change documents the existing persistence contract only
