## Purpose

Defines requirements for the document type creation and modification workflow in the docutray-advanced skill.

## Requirements

### Requirement: SKILL.md contains document type creation workflow
The SKILL.md SHALL include a workflow section that guides agents through creating a new document type, starting with checking existing types and ending with CLI execution.

#### Scenario: Workflow starts with existing type check
- **WHEN** an agent reads the document type creation workflow
- **THEN** the first step SHALL instruct the agent to run `docutray types list` and `docutray identify` to check for existing types before creating a new one

#### Scenario: Agent confirms create vs modify
- **WHEN** existing types have been checked
- **THEN** the workflow SHALL instruct the agent to confirm with the user whether they want to create a new type or modify an existing one

### Requirement: Progressive field discovery
The workflow SHALL instruct agents to gather document type fields progressively, not all at once.

#### Scenario: Progressive disclosure stages
- **WHEN** an agent follows the workflow to create a new document type
- **THEN** it SHALL ask for information in stages: (1) name and code, (2) main fields, (3) additional fields, (4) tabular/repeating data, (5) prompt hints

#### Scenario: User confirms before execution
- **WHEN** all field information has been gathered
- **THEN** the agent SHALL present the complete schema to the user for review before executing the CLI command

### Requirement: CLI commands for type management documented
The SKILL.md SHALL document the CLI commands for creating, updating, listing, and getting document types.

#### Scenario: Create command documented
- **WHEN** the agent needs to create a document type
- **THEN** the skill SHALL document `docutray types create` with flags: `--name`, `--code`, `--description`, `--schema`, `--prompt-hints`, `--identify-hints`

#### Scenario: Update command documented
- **WHEN** the agent needs to modify an existing document type
- **THEN** the skill SHALL document `docutray types update <code>` with flags: `--schema`, `--prompt-hints`, `--identify-hints`

### Requirement: Multi-document-type file handling
The SKILL.md SHALL address files that contain multiple document types (e.g., a PDF with both an invoice and a packing slip).

#### Scenario: Multi-document guidance
- **WHEN** a user describes a file containing multiple document types
- **THEN** the workflow SHALL instruct the agent to create separate document types for each and explain how to handle them

### Requirement: Detailed workflow in references
A `references/document-type-workflow-reference.md` file SHALL contain the detailed decision tree, step-by-step flow, and example interactions.

#### Scenario: Reference file exists and is cross-referenced
- **WHEN** the SKILL.md workflow section is read
- **THEN** it SHALL include a cross-reference to `@references/document-type-workflow-reference.md`

#### Scenario: Reference contains detailed steps
- **WHEN** the reference file is read
- **THEN** it SHALL contain a detailed decision tree and progressive disclosure steps with example agent-user interactions
