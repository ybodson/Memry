# ARCHITECTURE.md

This repository uses **Clean Architecture** for Swift and iOS development.

These instructions are for any human or coding agent making changes in this repo.

---

## Goals

- Keep **business rules independent** from UI, networking, persistence, and frameworks.
- Prefer **simple, explicit, testable code** over clever abstractions.
- Keep dependencies **pointing inward**.
- Treat SwiftUI, UIKit, URLSession, SwiftData, Core Data, GraphQL, Firebase, analytics, and third-party SDKs as **outer-layer details**.
- Optimize for **maintainability, clarity, and safe refactoring**.

---

## Architectural Rule

Follow the **dependency rule**:

> Source-code dependencies must point inward, toward policies and domain logic.

Inner layers must not import or depend on outer layers.

### Allowed direction

```text
View / App Layer
    ↓
Presentation
    ↓
Use Cases
    ↓
Domain
```

Runtime calls may involve concrete implementations from outer layers, but compile-time dependencies must still point inward through protocols or boundaries.

---

## Layer Definitions

### 1. Domain

The domain layer contains the most stable business concepts.

**Contains:**
- Entities
- Value objects
- Domain rules
- Domain errors
- Small pure helpers tightly related to domain behavior

**Rules:**
- Must be pure Swift.
- Must not import SwiftUI, UIKit, Combine, Observation, CoreData, SwiftData, Firebase, or networking frameworks.
- Prefer `struct`, `enum`, and immutable data.
- Do not use DTOs, persistence models, or view data here.
- Avoid framework-specific annotations and storage concerns.

**Examples:**
- `Issue`
- `Project`
- `UserPermission`
- `IssueStatus`

---

### 2. Use Cases

Use cases contain application-specific business actions.

**Contains:**
- Interactors / use-case types
- Application coordination logic
- Business workflows
- Validation that belongs to app behavior rather than UI widgets

**Rules:**
- One use case should do one thing well.
- Use cases should depend on domain types and repository/gateway protocols.
- Use cases must not know about SwiftUI, UIKit, screens, navigation, or storage engines.
- Use cases should return domain models or use-case output models, not view-specific types.
- Side effects must go through abstractions.

**Naming:**
- Prefer verb-oriented names like:
  - `FetchIssuesUseCase`
  - `AssignIssueUseCase`
  - `CreateCommentUseCase`

---

### 3. Presentation

Presentation adapts application/domain state for UI rendering.

**Contains:**
- SwiftUI views
- UIKit view controllers if still used
- View models
- Presenters
- Screen state
- UI-only mapping from domain to display data

**Rules:**
- Views render state and forward user intents.
- Keep SwiftUI views thin.
- Put business logic in use cases, not in views.
- View models may coordinate UI state, but should not become god objects.
- Presentation models are allowed if they simplify rendering.
- UI-specific formatting belongs here unless it is a reusable domain concept.

**Presentation state examples:**
- loading
- empty
- error
- selected tab
- sheet visibility
- alert content

**Do not place here:**
- raw networking
- database access
- direct SDK orchestration
- business rules that are reused across screens

---

### 4. Data / Infrastructure

This layer contains concrete implementations and framework details.

**Contains:**
- Repository implementations
- API clients
- Persistence stores
- SDK wrappers
- DTOs
- Mappers
- Cache implementations
- Analytics implementations

**Rules:**
- This is where framework code belongs.
- Convert DTOs/persistence models into domain models at the boundary.
- Do not leak transport or storage models inward.
- Keep third-party SDK usage isolated.
- Prefer small adapters around SDKs rather than spreading SDK calls across features.

**Examples:**
- `DefaultIssueRepository`
- `IssueDTO`
- `IssueMapper`
- `GraphQLIssueService`
- `SwiftDataProjectStore`

---

## Dependency Rules by Type

### Domain must not depend on
- SwiftUI
- UIKit
- Observation
- Combine
- URLSession
- Core Data / SwiftData
- GraphQL generated types
- Firebase types
- Analytics SDKs
- Persistence annotations
- OS logging details that are framework-coupled

### Use cases may depend on
- Domain types
- Repository/gateway protocols
- Small shared abstractions that are framework-independent

### Presentation may depend on
- Use cases
- Domain types
- UI frameworks
- Presentation-specific models

### Data/Infrastructure may depend on
- Domain types
- Use-case-owned protocols
- Apple frameworks
- Third-party libraries

---

## SwiftUI Guidance

### Views

SwiftUI views should:
- Render state
- Send user intents
- Own ephemeral UI details only

SwiftUI views should not:
- Perform business decisions
- Contain networking logic
- Contain database logic
- Know about DTOs
- Construct infrastructure directly except at clearly defined composition roots/previews/tests

### View Models

View models should:
- Expose screen state
- Trigger use cases
- Map domain models into presentation models
- Coordinate loading/error/empty/success flows

View models should not:
- Contain persistence code directly
- Depend on concrete API implementations when a protocol boundary exists
- Mix unrelated feature responsibilities

### State placement

Use this rule of thumb:

- **Domain state** → Domain / Use Cases
- **Screen state** → ViewModel / Presenter
- **Visual-only state** → SwiftUI View

---

## Repositories and Gateways

Repository protocols define boundaries inward.

**Rules:**
- Declare repository protocols in the inner layer that needs them.
- Implement repositories in outer layers.
- Repository APIs should speak in domain language.
- Repositories should return domain models, not DTOs or framework models.

**Good:**

```swift
protocol IssueRepository {
    func fetchIssues() async throws -> [Issue]
    func transitionIssue(id: Issue.ID, to status: IssueStatus) async throws
}
```

**Bad:**

```swift
protocol IssueRepository {
    func fetchIssues() async throws -> [IssueDTO]
}
```

---

## Mapping Rules

Map at boundaries.

### Required mappings
- DTO → Domain
- Persistence Model → Domain
- Domain → View Data
- SDK Error → App/Domain Error where useful

### Avoid
- Passing GraphQL-generated models into domain
- Passing `NSManagedObject` or `@Model` types into use cases
- Using API field names directly throughout the app

### Notes
- Mapping code is not waste.
- Mapping protects the domain from churn in API, DB, and UI layers.

---

## Protocol Guidance

Use protocols deliberately, not everywhere.

### Use a protocol when
- Defining a boundary between layers
- Enabling substitution for tests
- Decoupling a stable policy from an unstable detail

### Avoid a protocol when
- There is only one obvious implementation and no architectural boundary
- It adds indirection without testability or modularity benefits

Prefer concrete types inside a layer unless abstraction is buying something real.

---

## Error Handling

- Prefer typed errors where they improve clarity.
- Convert low-level infrastructure errors into app-meaningful errors at boundaries.
- Presentation should show user-appropriate messages, not raw backend/debug text.
- Do not leak transport-layer terminology into domain unless it is truly part of the business model.

---

## Concurrency

- Use Swift concurrency (`async/await`) by default.
- Keep concurrency boundaries explicit.
- Make cross-layer APIs `async` when they involve IO.
- Prefer `Sendable` where appropriate for inner-layer types.
- Avoid mixing legacy callback styles in new code unless required by an SDK boundary.
- Keep actor isolation decisions local and intentional.

---

## Testing Expectations

### Domain tests
- Must be fast and framework-light.
- Test business rules directly.

### Use case tests
- Mock repository protocols.
- Verify workflows, branching, validation, and error propagation.

### Presentation tests
- Test view models/presenters for state transitions.
- Prefer deterministic tests.

### UI tests
- Cover key user journeys.
- Do not rely on UI tests to validate business logic already testable at lower layers.

When adding business logic, prefer adding or updating unit tests in the inner layers first.

---

## File and Type Organization

Prefer feature-oriented structure with clear layers inside each feature, or separate modules when the repo supports it.

### Example feature layout

```text
Features/
  IssueList/
    Presentation/
      IssueListView.swift
      IssueListViewModel.swift
      IssueRowViewData.swift
    Domain/
      Issue.swift
      IssueRepository.swift
      FetchIssuesUseCase.swift
    Data/
      DefaultIssueRepository.swift
      IssueDTO.swift
      IssueMapper.swift
      IssueAPI.swift
```

For larger codebases, separate Swift packages/modules are encouraged.

---

## Dependency Injection

- Construct concrete infrastructure at the composition root.
- Inject dependencies through initializers.
- Avoid hidden singletons.
- Avoid service locators unless already established and carefully constrained.
- Previews and tests should be able to swap dependencies easily.

**Composition root examples:**
- App entry point
- Scene setup
- Feature assembler/factory
- Dependency container module

---

## Naming Conventions

Use clear names that reveal architectural role.

### Preferred suffixes
- `UseCase`
- `Repository`
- `Presenter`
- `ViewModel`
- `Mapper`
- `Store`
- `Client`

### Avoid vague names
- `Manager`
- `Helper`
- `Service` when the role is unclear
- `Model` unless it is specifically a presentation model or domain model with context

---

## Rules for Agents Making Changes

When modifying code in this repo:

1. Do not put business rules in SwiftUI views.
2. Do not introduce framework dependencies into domain or use-case layers.
3. Do not return DTOs or persistence models from repository protocols.
4. Add mapping code instead of leaking outer-layer models inward.
5. Prefer extending existing architectural patterns over introducing a parallel pattern.
6. Keep changes local and incremental where possible.
7. Preserve testability.
8. When in doubt, move policy inward and details outward.
9. Do not add abstraction without a clear boundary reason.
10. Avoid large refactors unless required by the task.

---

## Review Checklist

Before submitting a change, verify:

- Is business logic in the correct layer?
- Are dependencies still pointing inward?
- Did any framework type leak into domain/use cases?
- Are repository boundaries returning domain types?
- Are mappings explicit at boundaries?
- Is the SwiftUI view thin?
- Is new code testable without UI or real network/database access?
- Are names clear and role-specific?

---

## Practical Interpretation

This repo follows **pragmatic clean architecture**, not maximalist ceremony.

That means:
- Keep the core ideas strict.
- Keep file count and indirection reasonable.
- Combine roles when it improves clarity and does not violate dependency direction.
- In SwiftUI, a view model may absorb some presenter/controller responsibilities.
- Prefer readability over dogma.

---

## Preferred End State

A typical feature should look roughly like this:

```text
SwiftUI View
   ↓
ViewModel / Presenter
   ↓
UseCase
   ↓
Repository Protocol
   ↑
Repository Implementation
   ↑
API / DB / SDK
```

The UI should be replaceable.
The storage should be replaceable.
The network layer should be replaceable.
The business rules should remain.
