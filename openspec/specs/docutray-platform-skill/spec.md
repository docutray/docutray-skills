## Purpose

Defines requirements for the docutray-platform skill skeleton — core CLI operations including convert, identify, types, and steps.

## Requirements

### Requirement: Platform skill skeleton exists
The repository SHALL contain a `skills/docutray-platform/SKILL.md` file with valid YAML frontmatter including `name` and `description` fields.

#### Scenario: Valid frontmatter
- **WHEN** the file `skills/docutray-platform/SKILL.md` is parsed
- **THEN** the YAML frontmatter contains `name: docutray-platform` and a non-empty `description` field

#### Scenario: Name matches directory
- **WHEN** the `name` field in the frontmatter is read
- **THEN** it MUST match the parent directory name `docutray-platform`

### Requirement: Platform skill has references directory
The skill SHALL have a `skills/docutray-platform/references/` directory for future detailed documentation.

#### Scenario: References directory exists
- **WHEN** the `skills/docutray-platform/` directory is listed
- **THEN** a `references/` subdirectory SHALL exist

### Requirement: Platform skill description includes trigger phrases
The `description` field SHALL include phrases related to core CLI operations to enable agent activation matching.

#### Scenario: Trigger phrase coverage
- **WHEN** the `description` field is read
- **THEN** it MUST mention convert, identify, types, and steps commands
