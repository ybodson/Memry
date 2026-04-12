## 1. Rename Files and Directory

- [ ] 1.1 Rename `Features/Numbers/` directory to `Features/ViewNumbers/` in Xcode (to update `.pbxproj` references)
- [ ] 1.2 Rename `Features/ViewNumbers/Presentation/Numbers.swift` to `ViewNumbers.swift`
- [ ] 1.3 Rename `Features/ViewNumbers/Presentation/NumbersViewModel.swift` to `ViewNumbersViewModel.swift`

## 2. Update Type Names

- [ ] 2.1 Rename the `Numbers` SwiftUI view struct to `ViewNumbers` in `ViewNumbers.swift`
- [ ] 2.2 Rename the `NumbersViewModel` class to `ViewNumbersViewModel` in `ViewNumbersViewModel.swift`
- [ ] 2.3 Update the `@State var viewModel: NumbersViewModel` property inside `ViewNumbers` to use `ViewNumbersViewModel`

## 3. Update Call Sites

- [ ] 3.1 Search the project for all references to `Numbers` view and `NumbersViewModel` (e.g., app entry point, tab container, root view)
- [ ] 3.2 Update each reference to use `ViewNumbers` and `ViewNumbersViewModel`

## 4. Verify Build and Tests

- [ ] 4.1 Build the project and confirm zero compile errors
- [ ] 4.2 Run the app and verify the ViewNumbers screen loads, lists compositions, supports delete, and opens CreateNumber sheet

## 5. Add Spec to openspec/specs

- [ ] 5.1 Create directory `openspec/specs/view-numbers/`
- [ ] 5.2 Copy `openspec/changes/rename-numbers-to-view-numbers/specs/view-numbers/spec.md` to `openspec/specs/view-numbers/spec.md`
