## MODIFIED Requirements

### Requirement: Platform skill skeleton exists
The repository SHALL contain a `skills/docutray-platform/SKILL.md` file with valid YAML frontmatter including `name` and `description` fields, populated with complete instructional content for all four core CLI commands.

#### Scenario: Valid frontmatter
- **WHEN** the file `skills/docutray-platform/SKILL.md` is parsed
- **THEN** the YAML frontmatter contains `name: docutray-platform` and a non-empty `description` field

#### Scenario: Name matches directory
- **WHEN** the `name` field in the frontmatter is read
- **THEN** it MUST match the parent directory name `docutray-platform`

#### Scenario: Content is populated
- **WHEN** the SKILL.md is read
- **THEN** it SHALL contain instructional content (not TODO placeholders) for convert, identify, types, and steps commands

### Requirement: Platform skill has references directory
The skill SHALL have a `skills/docutray-platform/references/` directory containing detailed documentation files for convert, types, and steps commands.

#### Scenario: References directory exists
- **WHEN** the `skills/docutray-platform/` directory is listed
- **THEN** a `references/` subdirectory SHALL exist

#### Scenario: Reference files present
- **WHEN** the `skills/docutray-platform/references/` directory is listed
- **THEN** it SHALL contain `convert-reference.md`, `types-reference.md`, and `steps-reference.md`

### Requirement: Platform skill description includes trigger phrases
The `description` field SHALL include phrases related to core CLI operations to enable agent activation matching.

#### Scenario: Trigger phrase coverage
- **WHEN** the `description` field is read
- **THEN** it MUST mention convert, identify, types, and steps commands
