# Spec Delta

## ADDED Requirements

### Requirement: OAuth organization choice is documented on the consent screen
Wherever the skill documents `docutray login --oauth` for users with several organizations, it SHALL say that the organization is chosen on the DocuTray consent screen (CLI ≥ 0.5.0), and SHALL NOT present creating a dashboard API key as the way to pick an organization, only as a fallback for headless setups.

#### Scenario: Wrong-organization troubleshooting row
- **WHEN** `SKILL.md` §8 or `references/setup/troubleshooting.md` lists the symptom of an OAuth login into the wrong organization
- **THEN** the fix SHALL be to re-run `docutray login --oauth` and pick the organization on the consent screen, upgrading the CLI first if it is older than 0.5.0

#### Scenario: Observed login output matches 0.5.0
- **WHEN** `references/setup/cli.md` shows the stderr of `docutray login --oauth`
- **THEN** it SHALL NOT include the removed `Multiple organizations found, using: …` line, and SHALL explain the `Organization was not chosen in the browser; using: …` line and the `OAuth error (invalid_scope)` failure against a deployment without the `docutray:cli` scope
