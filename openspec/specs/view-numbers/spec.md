## ADDED Requirements

### Requirement: Display list of number compositions
The system SHALL display a scrollable list of all saved number compositions. Each row SHALL show the number (monospaced headline) and its associated mnemonic phrase (secondary subheadline).

#### Scenario: Compositions exist
- **WHEN** the user opens the ViewNumbers screen and compositions are available
- **THEN** each composition is displayed as a row with its number and phrase

#### Scenario: No compositions saved
- **WHEN** the user opens the ViewNumbers screen and no compositions exist
- **THEN** a "No Numbers Yet" empty state is shown with a prompt to tap + to add the first number

### Requirement: Loading skeleton during CloudKit sync
The system SHALL display a redacted placeholder list during the initial load of the ViewNumbers screen, and continue displaying it while waiting for the initial CloudKit sync to complete if no compositions are available yet.

#### Scenario: Initial load has not completed
- **WHEN** the user opens the ViewNumbers screen and the first composition fetch has not yet completed
- **THEN** a skeleton list of three placeholder rows is shown in a redacted state

#### Scenario: Sync completes or times out
- **WHEN** a CloudKit import event finishes OR 5 seconds elapse without a sync event
- **THEN** the skeleton is replaced by the actual composition list (or empty state)

### Requirement: Delete a number composition
The system SHALL allow the user to delete a composition via swipe-to-delete. The composition SHALL be removed from both the list and persistent storage.

#### Scenario: User swipes to delete
- **WHEN** the user performs the swipe-to-delete action on a composition row
- **THEN** the composition is removed from the list and deleted from the repository

#### Scenario: Deletion fails
- **WHEN** the repository throws an error during deletion
- **THEN** an error message is displayed and the composition remains in the list

### Requirement: Navigate to CreateNumber
The system SHALL provide a toolbar button that presents the CreateNumber sheet. After saving a new composition, the list SHALL be refreshed.

#### Scenario: User taps the + button
- **WHEN** the user taps the + toolbar button
- **THEN** the CreateNumber sheet is presented

#### Scenario: User saves a new composition
- **WHEN** the user saves a composition in the CreateNumber sheet
- **THEN** the sheet is dismissed and the new composition appears at the top of the list

### Requirement: Error state for failed loads
The system SHALL display an error view with a Retry button when compositions cannot be loaded.

#### Scenario: Repository fetch fails
- **WHEN** the repository throws an error during fetch
- **THEN** a "Unable to Load Numbers" error view is shown with the error description and a Retry button

#### Scenario: User taps Retry
- **WHEN** the user taps the Retry button after a failed load
- **THEN** the system attempts to reload compositions from the repository

### Requirement: Reload on app foreground and remote store changes
The system SHALL reload compositions whenever the app returns to the foreground or a remote CloudKit store change notification is received.

#### Scenario: App enters foreground
- **WHEN** the scene phase transitions to `.active`
- **THEN** compositions are reloaded from the repository

#### Scenario: Remote store change received
- **WHEN** an `NSPersistentStoreRemoteChange` notification is posted
- **THEN** compositions are reloaded from the repository
