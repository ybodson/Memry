## ADDED Requirements

### Requirement: Load mnemonic index before composition
The system SHALL load the mnemonic entries needed for number composition when the CreateNumber screen opens. While the entries are loading, the screen SHALL present a loading state instead of the composition UI.

#### Scenario: Screen opens before entries are available
- **WHEN** the user opens the CreateNumber screen and the mnemonic index has not finished loading
- **THEN** the screen shows a loading indicator

#### Scenario: Mnemonic index loads successfully
- **WHEN** the mnemonic index finishes loading successfully
- **THEN** the system shows the composition UI with number input and any derived suggestions

### Requirement: Show load failure and allow retry
The system SHALL show an error state when the mnemonic index cannot be loaded, and SHALL allow the user to retry loading it.

#### Scenario: Initial load fails
- **WHEN** the mnemonic index load throws an error
- **THEN** the screen shows an error state with the failure message and a Retry action

#### Scenario: Retry succeeds after a load failure
- **WHEN** the user taps Retry after a failed mnemonic index load and a later load succeeds
- **THEN** the error state is cleared and matching mnemonic groups are shown for the current digit input

### Requirement: Normalize number input to digits only
The system SHALL treat the CreateNumber input as numeric-only text and remove any non-digit characters entered or pasted by the user.

#### Scenario: User enters mixed characters
- **WHEN** the user types or pastes text containing digits and non-digit characters
- **THEN** the input is normalized to contain only the digit characters in their original order

### Requirement: Show matching mnemonic groups for remaining digits
The system SHALL derive matching mnemonic groups from the remaining unassigned digits in the composition. Matching groups SHALL be ordered from the longest matching prefix to the shortest, and entries within each group SHALL be ordered by descending score.

#### Scenario: Multiple prefix lengths match the remaining digits
- **WHEN** the remaining input begins with several codes that exist in the mnemonic index
- **THEN** the screen shows one group per matching prefix, ordered from longest code to shortest code

#### Scenario: A matching group contains several entries
- **WHEN** a matching code has multiple mnemonic entries
- **THEN** the entries for that code are shown in descending score order

### Requirement: Build a composition by selecting mnemonic entries
The system SHALL let the user build a number composition by selecting a mnemonic entry from a matching group. Selecting an entry SHALL append a breadcrumb for the matched code and remove that code's digits from the remaining input.

#### Scenario: User selects a matching entry
- **WHEN** the user selects an entry from a matching mnemonic group
- **THEN** the selected word is appended to the breadcrumb trail and the matched digits are removed from the remaining input

#### Scenario: Breadcrumbs exist in the current composition
- **WHEN** the composition contains one or more selected mnemonic entries
- **THEN** the screen shows the breadcrumb trail for the current composition

### Requirement: Allow undo of the most recent breadcrumb
The system SHALL allow the user to remove the most recently selected breadcrumb. Removing the last breadcrumb SHALL restore that breadcrumb's digits to the front of the remaining input.

#### Scenario: User removes the latest breadcrumb
- **WHEN** the user triggers deletion for the most recent breadcrumb
- **THEN** that breadcrumb is removed and its code is restored to the beginning of the remaining input

#### Scenario: No breadcrumbs have been selected
- **WHEN** the composition has no breadcrumbs
- **THEN** the breadcrumb section is not shown

### Requirement: Save only completed compositions
The system SHALL enable saving only when the composition contains at least one breadcrumb and no unassigned digits remain. Saving SHALL pass the assembled `NumberComposition` to the feature's save callback.

#### Scenario: Composition is incomplete
- **WHEN** the user still has remaining digits in the input or has not selected any breadcrumbs
- **THEN** the save action is disabled

#### Scenario: Composition is complete
- **WHEN** the user has selected one or more breadcrumbs and the remaining digit input is empty
- **THEN** the save action is enabled and saving passes the completed composition to the caller

### Requirement: Dismiss on successful completion and stay open on failure
The system SHALL allow the user to dismiss the screen without saving, and SHALL dismiss the CreateNumber screen after a successful save. If saving fails, the system SHALL surface the error and SHALL NOT dismiss the screen.

#### Scenario: User cancels creation
- **WHEN** the user taps the cancel action
- **THEN** the CreateNumber screen is dismissed without saving

#### Scenario: Save succeeds
- **WHEN** the user triggers save for a completed composition and the save callback succeeds
- **THEN** the CreateNumber screen is dismissed

#### Scenario: Save fails
- **WHEN** the user triggers save for a completed composition and the save callback throws an error
- **THEN** the error is shown and the CreateNumber screen remains open
