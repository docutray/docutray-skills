## ADDED Requirements

### Requirement: Custom-type design reads an example document first

When guiding a user to create a custom document type, the skill SHALL instruct the agent to request an example document and read it before generating a JSON Schema. The guidance in `skills/docutray/SKILL.md` (§6 Custom Types) and `skills/docutray/references/advanced/custom-types-workflow.md` SHALL be consistent on this behavior.

The instruction SHALL be phrased generically — "read the document with your file/vision tool" — so it applies across coding agents (Claude Code, Cursor, Codex) without prescribing a specific tool name or relying on `docutray convert`/`identify` as the reader.

#### Scenario: Sample requested before schema generation

- **WHEN** the custom-type workflow reaches the point of building a JSON Schema
- **THEN** the guidance SHALL direct the agent to first ask the user for an example document and read it with the agent's native file/vision capability before drafting any schema

#### Scenario: Agent proposes detected fields, user refines

- **WHEN** the agent has read the example document
- **THEN** the guidance SHALL direct the agent to propose the fields and structure it detected from the document and have the user confirm or adjust them, rather than asking the user to enumerate fields from scratch

#### Scenario: No-sample escape hatch

- **WHEN** the user has no example document available
- **THEN** the guidance SHALL direct the agent to warn that the resulting schema is tentative and must be validated against a real document later, and MAY fall back to building the schema from the user's verbal description — it SHALL NOT hard-block schema creation

#### Scenario: Iterative refinement preserved

- **WHEN** an initial schema has been drafted from the example document
- **THEN** the guidance SHALL retain the iterative loop of testing with `docutray convert <sample> -t <code>` and refining the schema with the user
