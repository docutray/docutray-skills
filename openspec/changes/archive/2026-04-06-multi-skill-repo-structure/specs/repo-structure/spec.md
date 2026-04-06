## ADDED Requirements

### Requirement: Skills directory structure follows Agent Skills spec
The repository SHALL have a `skills/` directory containing one subdirectory per skill, each with a `SKILL.md` file.

#### Scenario: Three skill directories exist
- **WHEN** the `skills/` directory is listed
- **THEN** it SHALL contain exactly `docutray-setup/`, `docutray-platform/`, and `docutray-advanced/` subdirectories

#### Scenario: Each directory contains SKILL.md
- **WHEN** any skill subdirectory is listed
- **THEN** it SHALL contain a `SKILL.md` file

### Requirement: README lists all skills
The `README.md` SHALL contain a table listing all three skills with their names and descriptions.

#### Scenario: Skill table is complete
- **WHEN** the `README.md` is read
- **THEN** it SHALL contain a table with entries for `docutray-setup`, `docutray-platform`, and `docutray-advanced`

### Requirement: Skill names use valid format
All skill names SHALL be lowercase, use hyphens as separators, and be between 1-64 characters.

#### Scenario: Name format validation
- **WHEN** each skill's `name` frontmatter field is checked
- **THEN** it SHALL match the pattern `^[a-z][a-z0-9-]{0,63}$`
