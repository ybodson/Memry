## Context

`CreateNumber` is already implemented as a SwiftUI screen backed by `CreateNumberViewModel`, `NumberComposition`, and a bundled major-system index repository. The feature lets users turn a string of digits into a saved composition by selecting mnemonic words that match descending prefixes of the remaining input.

This change does not introduce new runtime behavior. The design work is to capture the existing screen contract in OpenSpec so future UI or domain changes can distinguish between intentional behavior changes and incidental implementation details.

## Goals / Non-Goals

**Goals:**
- Document the feature's real behavior across loading, composition, breadcrumb editing, and save flows
- Anchor the spec in the current separation of concerns between presentation (`CreateNumberViewModel`), domain (`NumberComposition`), and data (`MajorIndexRepository`)
- Make the existing tests and screen behavior traceable back to explicit requirements

**Non-Goals:**
- Changing the feature's UI layout, copy, or control structure
- Refactoring the domain model, repository abstraction, or save callback
- Introducing new validation rules, persistence behavior, or navigation flows

## Decisions

### Document the implemented state model instead of an idealized flow
The spec should mirror the state transitions already present in `CreateNumberViewModel`: loading the index, normalizing text input to digits, deriving matching entry groups from the current composition, appending/removing breadcrumbs, and saving only when all digits are consumed.

This avoids a common documentation failure mode where the spec describes how the screen ought to work rather than how it actually works today.

**Alternative considered:** Writing a higher-level UX spec that omits view-model details such as descending-prefix matches and score ordering. Rejected because those behaviors are central to the feature's usefulness and already verified in tests.

### Treat the save path as a callback boundary
`CreateNumber` does not persist compositions directly. It delegates save to an injected `onSave` callback after assembling a `NumberComposition`. The spec should therefore define save in terms of "pass the composition to the caller" and "dismiss on success" rather than binding the feature to a specific persistence implementation.

**Alternative considered:** Specifying direct persistence from `CreateNumber`. Rejected because persistence belongs outside the feature boundary and would violate the current architecture.

### Separate load failures from composition behavior
The feature has two materially different failure modes:
1. Failing to load the bundled major index, which blocks composition and exposes a retry path
2. Failing to save the completed composition, which leaves the sheet open and surfaces the error

Capturing both keeps the spec aligned with the current screen contract while preserving the distinction between repository-read and save-callback failures.

**Alternative considered:** Folding all failures into a single generic error requirement. Rejected because it obscures which actions are retryable and what part of the flow is blocked.

## Risks / Trade-offs

- **[Risk] UI copy may change independently of behavior** → Mitigation: Keep requirements focused on user-visible states and outcomes, not incidental styling or every literal string.
- **[Risk] The current save-failure presentation may be refined later** → Mitigation: Specify the stable contract (error is surfaced and dismissal does not occur) without overfitting to one exact rendering detail.
- **[Risk] Documentation could drift from tests over time** → Mitigation: Phrase scenarios so they map cleanly to existing tests for normalization, prefix matching, breadcrumb removal, retry, and save gating.
