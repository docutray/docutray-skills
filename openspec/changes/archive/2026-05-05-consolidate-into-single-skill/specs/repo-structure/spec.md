## MODIFIED Requirements

### Requirement: Skills directory structure follows Agent Skills spec
The repository SHALL have a `skills/` directory containing exactly one subdirectory — `docutray/` — with a `SKILL.md` file and a `references/` subdirectory.

#### Scenario: Single skill directory exists
- **WHEN** the `skills/` directory is listed
- **THEN** it SHALL contain a `docutray/` subdirectory and no other skill directories

#### Scenario: Skill directory contains SKILL.md
- **WHEN** the `skills/docutray/` directory is listed
- **THEN** it SHALL contain a `SKILL.md` file

### Requirement: README lists all skills
The `README.md` SHALL contain a table or section listing every distributable skill with its description. After this change, that means a single entry for the unified `docutray` skill.

#### Scenario: Skill table is current
- **WHEN** the `README.md` is read
- **THEN** it SHALL contain an entry for the `docutray` skill and SHALL NOT contain entries for the legacy `docutray-setup`, `docutray-platform`, or `docutray-advanced` skills
