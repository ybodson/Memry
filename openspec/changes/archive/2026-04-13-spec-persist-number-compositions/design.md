## Context

Saved number compositions are persisted through `SwiftDataNumberCompositionRepository`, which maps between domain-level `NumberComposition` values and SwiftData model types. The current implementation already defines several important data integrity rules:

1. Fetch returns persisted compositions ordered by descending creation time
2. Breadcrumbs are normalized into explicit positional order when written
3. Reading reconstructs breadcrumb order from the stored `order` field rather than raw relationship order
4. Saving the same composition id updates the existing persisted composition instead of creating a duplicate
5. Deleting a composition removes every persisted row with the matching composition id

These behaviors are stable enough to treat as part of the product contract, even though they currently live only in code and tests.

## Goals / Non-Goals

**Goals:**
- Document the current persistence semantics that protect composition identity and ordering
- Make the repository contract explicit at the domain-to-storage boundary
- Anchor persistence-oriented tests to requirements that describe what the system must preserve

**Non-Goals:**
- Changing the storage engine, SwiftData schema, or repository interface
- Defining UI behavior for listing, editing, or deleting compositions beyond the storage guarantees they depend on
- Introducing migration, deduplication, or repair flows for malformed historical data beyond the current read and delete semantics

## Decisions

### Treat repository semantics as a separate capability from `view-numbers`
The Numbers feature depends on persistence, but the persistence rules are broader than the screen itself. They concern data integrity and ordering at the storage boundary, not just one presentation flow.

**Alternative considered:** Extending `view-numbers` to mention newest-first ordering and delete behavior. Rejected because it would leave mapping and upsert semantics undocumented and would couple storage rules too tightly to one screen.

### Specify domain-level outcomes instead of raw SwiftData implementation details
The stable contract is that compositions round-trip with preserved breadcrumb order, fetch newest first, update by id, and delete by composition id. The spec should not lock itself to one specific `FetchDescriptor` or relationship implementation.

**Alternative considered:** Writing the spec directly around SwiftData model fields and queries. Rejected because storage internals may change while the persistence contract stays the same.

### Preserve identity through composition id rather than append-only saves
The existing repository treats `composition.id` as the stable identity for updates and deletes. That is the rule consumers depend on when they save an edited composition or remove one from the list.

**Alternative considered:** Treating every save as a new record. Rejected because it would change current behavior and break the repository's existing identity semantics.

## Risks / Trade-offs

- **[Risk] Future schema changes could alter how ordering is represented** → Mitigation: Keep the spec focused on preserved breadcrumb order and newest-first fetch outcomes, not the internal storage shape
- **[Risk] Consumers may assume stronger data-repair guarantees than the repository provides** → Mitigation: Limit the spec to the current round-trip, update, and delete behaviors that are actually implemented
- **[Risk] Overlap with `view-numbers` could create duplicate documentation for deletion** → Mitigation: Keep `view-numbers` focused on screen behavior and keep this capability focused on storage semantics that the screen relies on
