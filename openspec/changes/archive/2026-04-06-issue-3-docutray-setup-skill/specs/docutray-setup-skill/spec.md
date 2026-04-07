## MODIFIED Requirements

### Requirement: Setup skill skeleton exists
The repository SHALL contain a `skills/docutray-setup/SKILL.md` file with valid YAML frontmatter including `name` and `description` fields. The file SHALL contain complete setup instructions (not skeleton TODOs).

#### Scenario: Valid frontmatter
- **WHEN** the file `skills/docutray-setup/SKILL.md` is parsed
- **THEN** the YAML frontmatter contains `name: docutray-setup` and a non-empty `description` field

#### Scenario: Name matches directory
- **WHEN** the `name` field in the frontmatter is read
- **THEN** it MUST match the parent directory name `docutray-setup`

#### Scenario: Content is complete
- **WHEN** the file `skills/docutray-setup/SKILL.md` is read
- **THEN** it SHALL NOT contain TODO placeholders and SHALL contain actionable setup instructions

### Requirement: Setup skill has references directory
The skill SHALL have a `skills/docutray-setup/references/` directory containing detailed documentation files for each integration path.

#### Scenario: References directory exists
- **WHEN** the `skills/docutray-setup/` directory is listed
- **THEN** a `references/` subdirectory SHALL exist

#### Scenario: References directory has content
- **WHEN** the `skills/docutray-setup/references/` directory is listed
- **THEN** it SHALL contain reference files for Python SDK, Node SDK, REST API, and CLI setup

### Requirement: Setup skill description includes trigger phrases
The `description` field SHALL include phrases related to installation, configuration, and authentication to enable agent activation matching.

#### Scenario: Trigger phrase coverage
- **WHEN** the `description` field is read
- **THEN** it MUST mention installing or configuring docutray-cli and authentication setup
