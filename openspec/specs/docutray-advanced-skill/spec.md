## Purpose

Defines requirements for the docutray-advanced skill — document type creation, schema design, and processing pipelines.

## Requirements

### Requirement: Advanced skill skeleton exists
The repository SHALL contain a `skills/docutray-advanced/SKILL.md` file with valid YAML frontmatter including `name` and `description` fields, populated with complete document type configuration workflow content.

#### Scenario: Valid frontmatter
- **WHEN** the file `skills/docutray-advanced/SKILL.md` is parsed
- **THEN** the YAML frontmatter contains `name: docutray-advanced` and a non-empty `description` field

#### Scenario: Name matches directory
- **WHEN** the `name` field in the frontmatter is read
- **THEN** it MUST match the parent directory name `docutray-advanced`

#### Scenario: SKILL.md has complete content
- **WHEN** the SKILL.md is read
- **THEN** it SHALL contain workflow sections for document type creation, schema design, type modification, and prompt hints (no TODO placeholders)

#### Scenario: SKILL.md stays under 500 lines
- **WHEN** the SKILL.md line count is measured
- **THEN** it SHALL be under 500 lines

### Requirement: Advanced skill has references directory
The skill SHALL have a `skills/docutray-advanced/references/` directory containing detailed documentation files.

#### Scenario: References directory has content files
- **WHEN** the `skills/docutray-advanced/references/` directory is listed
- **THEN** it SHALL contain `schema-design-reference.md` and `document-type-workflow-reference.md`

#### Scenario: No .gitkeep file
- **WHEN** the `skills/docutray-advanced/references/` directory is listed
- **THEN** the `.gitkeep` file SHALL NOT be present

### Requirement: Advanced skill description includes trigger phrases
The `description` field SHALL include phrases related to advanced features to enable agent activation matching.

#### Scenario: Trigger phrase coverage
- **WHEN** the `description` field is read
- **THEN** it MUST mention document type creation, schema design, and prompt hints or extraction rules
