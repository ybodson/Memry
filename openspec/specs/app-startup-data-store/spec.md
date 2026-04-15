## ADDED Requirements

### Requirement: Initialize the startup data store before presenting feature content
The system SHALL attempt to initialize the app's private CloudKit-backed SwiftData data store during app startup before presenting feature content. Initialization SHALL occur inside the repository layer, not in the app entry point.

#### Scenario: Startup data store initializes successfully
- **WHEN** the app launches and the data store initialization succeeds
- **THEN** the app proceeds to construct the initial feature flow using that initialized data store

#### Scenario: Startup data store initialization fails
- **WHEN** the app launches and the data store initialization throws an error
- **THEN** the app SHALL NOT present feature content that depends on the data store

### Requirement: Route successful startup into the Numbers experience
The system SHALL present the Numbers screen as the initial app experience after the startup data store initializes successfully.

#### Scenario: Launch succeeds
- **WHEN** the startup data store is available
- **THEN** the app shows the Numbers experience backed by the initialized repository dependencies

### Requirement: Show a safe unavailable state when startup fails
The system SHALL show a non-crashing unavailable state when startup data store initialization fails. The unavailable state SHALL display the underlying initialization error message when one is available, and SHALL otherwise display fallback guidance telling the user that the app database could not be initialized.

#### Scenario: Failure exposes a localized message
- **WHEN** startup data store initialization fails and the failure provides a localized description
- **THEN** the unavailable state shows that failure message to the user

#### Scenario: Failure does not expose a localized message
- **WHEN** startup data store initialization fails and no specific error message is available
- **THEN** the unavailable state shows fallback guidance explaining that the app database could not be initialized
