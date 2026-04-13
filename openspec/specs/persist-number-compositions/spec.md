## ADDED Requirements

### Requirement: Fetch saved compositions newest first
The system SHALL return saved number compositions in descending creation order when fetching persisted compositions.

#### Scenario: Several compositions are saved at different times
- **WHEN** the repository fetches persisted number compositions
- **THEN** the returned compositions are ordered from newest created composition to oldest created composition

### Requirement: Preserve breadcrumb order across persistence mapping
The system SHALL preserve breadcrumb order when writing a number composition to persistence and when reconstructing a composition from persisted data.

#### Scenario: Writing a composition with multiple breadcrumbs
- **WHEN** a number composition with several breadcrumbs is saved
- **THEN** the persisted breadcrumb data records each breadcrumb in its original positional order

#### Scenario: Reading persisted breadcrumbs with unordered storage relationships
- **WHEN** a persisted composition is reconstructed from breadcrumb records that are not returned in positional order
- **THEN** the resulting domain composition restores the breadcrumbs in their stored order positions

### Requirement: Save by composition identity
The system SHALL treat a number composition's id as its persistence identity. Saving a composition whose id already exists in storage SHALL update the existing persisted composition instead of creating a duplicate persisted composition.

#### Scenario: Saving a composition with a new id
- **WHEN** a composition is saved and no persisted composition exists with that id
- **THEN** the system creates a new persisted composition for that id

#### Scenario: Saving a composition with an existing id
- **WHEN** a composition is saved and a persisted composition already exists with that id
- **THEN** the system updates the existing persisted composition and leaves only one persisted composition for that id

### Requirement: Delete all persisted rows for a composition id
The system SHALL remove every persisted composition row that matches a composition id when deleting that composition.

#### Scenario: Deleting a composition whose id appears in multiple persisted rows
- **WHEN** the repository deletes a composition by id
- **THEN** all persisted rows with that composition id are removed
