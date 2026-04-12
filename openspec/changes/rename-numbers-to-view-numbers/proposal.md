## Why

The `Numbers` feature is named too generically and doesn't reflect its role as the screen that *views* saved number compositions. Renaming it to `ViewNumbers` aligns with the `CreateNumber` naming convention already in use and makes the feature's intent explicit. Adding a spec formalizes the feature's requirements, enabling future changes to be made against a clear contract.

## What Changes

- Rename the `Features/Numbers/` directory to `Features/ViewNumbers/`
- Rename `Numbers.swift` → `ViewNumbers.swift` and the `Numbers` SwiftUI view struct → `ViewNumbers`
- Rename `NumbersViewModel.swift` → `ViewNumbersViewModel.swift` and the `NumbersViewModel` class → `ViewNumbersViewModel`
- Update all call sites that reference `Numbers`, `NumbersViewModel`, or the old directory path
- Add a spec at `openspec/specs/view-numbers/spec.md` documenting the feature's requirements

## Capabilities

### New Capabilities
- `view-numbers`: Displays the list of saved number compositions, supports delete, shows loading skeleton during CloudKit sync, and navigates to CreateNumber

### Modified Capabilities
<!-- none -->

## Impact

- `Features/Numbers/` directory and all files within it
- Any Swift file that instantiates or references `Numbers` view or `NumbersViewModel` (e.g., app entry point, tab container)
- No API or data model changes; purely a rename and spec addition
