## Context

The app has two features: `CreateNumber` and `Numbers`. The `Numbers` feature handles listing, deleting, and syncing number compositions. Its current name is too generic — it doesn't describe *what* the user is doing with numbers. `CreateNumber` already uses an action-oriented naming convention; `Numbers` should follow suit and become `ViewNumbers`.

No business logic changes. This is a mechanical rename across the `Features/Numbers/` directory, with a spec added to formalize existing behavior.

## Goals / Non-Goals

**Goals:**
- Rename the `Numbers` feature directory, Swift files, view struct, and view model class to use the `ViewNumbers` prefix
- Update all references to the old names throughout the codebase
- Add `openspec/specs/view-numbers/spec.md` documenting the feature's requirements

**Non-Goals:**
- Changing any feature behavior
- Modifying data models, repositories, or the CloudKit sync strategy
- Renaming `CreateNumber` or any other feature

## Decisions

### Rename approach: flat find-and-replace within the feature boundary
Since this is a pure rename with no logic changes, the safest path is:
1. Rename the directory `Features/Numbers/` → `Features/ViewNumbers/`
2. Rename each file within it
3. Update type names (`Numbers` → `ViewNumbers`, `NumbersViewModel` → `ViewNumbersViewModel`)
4. Update all import/reference sites (app entry point, tab views, etc.)

**Alternative considered**: Keeping `NumbersViewModel` as-is to reduce diff size. Rejected — consistency with the `ViewNumbers` naming is more important than a smaller diff, and the class is only referenced in a handful of places.

### No protocol or module boundary changes
`NumbersViewModel` is a concrete `@Observable` class, not behind a protocol. Renaming it does not affect the `CloudSyncEvent` protocol or `NumberCompositionRepository` — those stay unchanged.

## Risks / Trade-offs

- **[Risk] Missed reference sites** → Mitigation: Search the entire project for `NumbersViewModel` and `struct Numbers` before marking the task complete; CI build will catch any stragglers.
- **[Risk] Xcode project file (.pbxproj) references** → Mitigation: Rename files via Xcode (or update `.pbxproj` references manually) so the build system tracks the new paths correctly.
