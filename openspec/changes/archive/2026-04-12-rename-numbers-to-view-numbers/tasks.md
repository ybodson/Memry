## 1. Rename Files and Directory

- [x] 1.1 Rename `Features/Numbers/` directory to `Features/ViewNumbers/` in Xcode (to update `.pbxproj` references)
- [x] 1.2 Rename `Features/ViewNumbers/Presentation/Numbers.swift` to `ViewNumbers.swift`
- [x] 1.3 Rename `Features/ViewNumbers/Presentation/NumbersViewModel.swift` to `ViewNumbersViewModel.swift`

## 2. Update Type Names

- [x] 2.1 Rename the `Numbers` SwiftUI view struct to `ViewNumbers` in `ViewNumbers.swift`
- [x] 2.2 Rename the `NumbersViewModel` class to `ViewNumbersViewModel` in `ViewNumbersViewModel.swift`
- [x] 2.3 Update the `@State var viewModel: NumbersViewModel` property inside `ViewNumbers` to use `ViewNumbersViewModel`

## 3. Update Call Sites

- [x] 3.1 Search the project for all references to `Numbers` view and `NumbersViewModel` (e.g., app entry point, tab container, root view)
- [x] 3.2 Update each reference to use `ViewNumbers` and `ViewNumbersViewModel`

## 4. Verify Build and Tests

- [x] 4.1 Build the project and confirm zero compile errors
- [x] 4.2 Run the app and verify the ViewNumbers screen loads, lists compositions, supports delete, and opens CreateNumber sheet

## 5. Add Spec to openspec/specs

- [x] 5.1 Create directory `openspec/specs/view-numbers/`
- [x] 5.2 Copy `openspec/changes/rename-numbers-to-view-numbers/specs/view-numbers/spec.md` to `openspec/specs/view-numbers/spec.md`
