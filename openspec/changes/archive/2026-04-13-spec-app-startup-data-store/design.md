## Context

`MemryApp` is the composition root for the application. On launch it attempts to construct a `ModelContainer` configured for the app's private CloudKit database, then chooses between two user-visible startup states:

1. Successful initialization, which builds the `ViewNumbers` screen with a `ViewNumbersViewModel` backed by `SwiftDataNumberCompositionRepository`
2. Failed initialization, which shows an unavailable-state view instead of entering the feature flow

This change does not introduce new runtime behavior. The goal is to document the existing startup contract so changes to app wiring, persistence setup, or shell navigation can be evaluated against an explicit spec.

## Goals / Non-Goals

**Goals:**
- Document the current launch-time data-store initialization behavior at the app boundary
- Capture the user-visible outcomes for both successful and failed initialization
- Keep the contract aligned with the existing architecture, where the app shell owns infrastructure setup and feature screens receive ready-to-use dependencies

**Non-Goals:**
- Changing the persistence engine, CloudKit container, or model schema
- Adding onboarding, splash, or recovery flows beyond the current unavailable state
- Specifying every SwiftUI layout detail or exact implementation of dependency construction

## Decisions

### Treat startup as its own capability instead of folding it into `view-numbers`
The startup contract begins before any feature screen is created. It belongs to the app shell because it decides whether `ViewNumbers` can be constructed at all.

**Alternative considered:** Extending `view-numbers` to describe launch behavior. Rejected because the Numbers feature should assume its dependencies are already available; startup failure happens before the feature boundary.

### Specify user-visible routing outcomes rather than low-level framework calls
The stable behavior is that the app attempts to initialize a private CloudKit-backed SwiftData container, then routes to either the Numbers experience or an unavailable state. The spec should lock down those outcomes without overfitting to the exact `ModelConfiguration` or `ModelContainer` call sites.

**Alternative considered:** Writing the spec directly around SwiftData constructor details. Rejected because framework wiring may evolve while the startup contract remains the same.

### Keep failure handling narrow and non-crashing
On initialization failure, the app currently surfaces the localized error description when available and otherwise falls back to static guidance. The important contract is that startup fails safely and communicates the issue instead of crashing or presenting partial feature UI.

**Alternative considered:** Specifying retry, diagnostics, or alternate offline startup modes. Rejected because none of those flows exist today and this change is documentation-only.

## Risks / Trade-offs

- **[Risk] Future shell changes may route to a different initial screen** → Mitigation: Update this capability when startup routing changes instead of silently leaving the spec behind
- **[Risk] Literal copy may evolve independently of the startup behavior** → Mitigation: Specify the error-state outcome and message source, not every exact string
- **[Risk] Framework-specific wording could become brittle** → Mitigation: Keep the requirement focused on the private CloudKit-backed SwiftData data store as the user-visible dependency boundary, not incidental implementation syntax
