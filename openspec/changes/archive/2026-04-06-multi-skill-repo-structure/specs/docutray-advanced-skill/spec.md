## ADDED Requirements

### Requirement: Advanced skill skeleton exists
The repository SHALL contain a `skills/docutray-advanced/SKILL.md` file with valid YAML frontmatter including `name` and `description` fields.

#### Scenario: Valid frontmatter
- **WHEN** the file `skills/docutray-advanced/SKILL.md` is parsed
- **THEN** the YAML frontmatter contains `name: docutray-advanced` and a non-empty `description` field

#### Scenario: Name matches directory
- **WHEN** the `name` field in the frontmatter is read
- **THEN** it MUST match the parent directory name `docutray-advanced`

### Requirement: Advanced skill has references directory
The skill SHALL have a `skills/docutray-advanced/references/` directory for future detailed documentation.

#### Scenario: References directory exists
- **WHEN** the `skills/docutray-advanced/` directory is listed
- **THEN** a `references/` subdirectory SHALL exist

### Requirement: Advanced skill description includes trigger phrases
The `description` field SHALL include phrases related to advanced features to enable agent activation matching.

#### Scenario: Trigger phrase coverage
- **WHEN** the `description` field is read
- **THEN** it MUST mention document type creation, schema design, and processing pipelines
