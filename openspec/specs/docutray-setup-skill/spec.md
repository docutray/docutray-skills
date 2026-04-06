## Purpose

Defines requirements for the docutray-setup skill skeleton — installation, configuration, and authentication guidance for docutray-cli and SDKs.

## Requirements

### Requirement: Setup skill skeleton exists
The repository SHALL contain a `skills/docutray-setup/SKILL.md` file with valid YAML frontmatter including `name` and `description` fields.

#### Scenario: Valid frontmatter
- **WHEN** the file `skills/docutray-setup/SKILL.md` is parsed
- **THEN** the YAML frontmatter contains `name: docutray-setup` and a non-empty `description` field

#### Scenario: Name matches directory
- **WHEN** the `name` field in the frontmatter is read
- **THEN** it MUST match the parent directory name `docutray-setup`

### Requirement: Setup skill has references directory
The skill SHALL have a `skills/docutray-setup/references/` directory for future detailed documentation.

#### Scenario: References directory exists
- **WHEN** the `skills/docutray-setup/` directory is listed
- **THEN** a `references/` subdirectory SHALL exist

### Requirement: Setup skill description includes trigger phrases
The `description` field SHALL include phrases related to installation, configuration, and authentication to enable agent activation matching.

#### Scenario: Trigger phrase coverage
- **WHEN** the `description` field is read
- **THEN** it MUST mention installing or configuring docutray-cli and authentication setup
