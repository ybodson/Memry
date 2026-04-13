## 1. Capture Persistence Scope

- [x] 1.1 Review the SwiftData repository and persisted model files to identify the current storage and mapping behavior
- [x] 1.2 Cross-check existing persistence tests to confirm the documented ordering, update, and delete semantics

## 2. Author OpenSpec Artifacts

- [x] 2.1 Write `proposal.md` describing why the number-composition persistence contract needs an explicit spec
- [x] 2.2 Write `design.md` documenting repository identity, ordering, and mapping boundaries
- [x] 2.3 Write `specs/persist-number-compositions/spec.md` covering newest-first fetches, breadcrumb order preservation, update-by-id saves, and delete-by-id behavior

## 3. Verify Change Readiness

- [x] 3.1 Confirm the change is apply-ready with proposal, design, spec, and tasks artifacts present
- [x] 3.2 Archive the change once the persistence contract documentation is accepted
