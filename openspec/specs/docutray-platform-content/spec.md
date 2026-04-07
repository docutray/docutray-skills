## Purpose

Defines requirements for the instructional content of the docutray-platform skill — complete documentation for all four core CLI commands (convert, identify, types, steps) with multi-SDK examples.

## Requirements

### Requirement: Convert command documentation
The SKILL.md SHALL include a Convert section documenting basic usage, file format support, document type selection, and output handling via CLI, Python SDK, Node SDK, and REST API.

#### Scenario: CLI convert usage
- **WHEN** an agent reads the Convert section
- **THEN** it SHALL find a CLI example showing `docutray convert <file> --type <type>` with output options

#### Scenario: SDK convert usage
- **WHEN** an agent reads the Convert section
- **THEN** it SHALL find Python (`client.convert()`) and Node (`client.convert()`) SDK examples

#### Scenario: REST API convert usage
- **WHEN** an agent reads the Convert section
- **THEN** it SHALL find a `POST /api/convert` curl example with multipart/form-data

### Requirement: Identify command documentation
The SKILL.md SHALL include an Identify section documenting automatic document type detection, confidence scores, and how to use results to feed into convert.

#### Scenario: CLI identify usage
- **WHEN** an agent reads the Identify section
- **THEN** it SHALL find a CLI example showing `docutray identify <file>`

#### Scenario: Confidence score explanation
- **WHEN** an agent reads the Identify section
- **THEN** it SHALL find documentation explaining the `confidence` field in the response

#### Scenario: Identify-to-convert chaining
- **WHEN** an agent reads the Identify section or Common Patterns section
- **THEN** it SHALL find an example of using identify output to select the document type for convert

### Requirement: Types command documentation
The SKILL.md SHALL include a Types section documenting `list`, `get`, and `export` subcommands via CLI, Python SDK, Node SDK, and REST API.

#### Scenario: Types list usage
- **WHEN** an agent reads the Types section
- **THEN** it SHALL find examples for listing all available document types across all integration paths

#### Scenario: Types get usage
- **WHEN** an agent reads the Types section
- **THEN** it SHALL find examples for retrieving a single document type with its schema

#### Scenario: Types export usage
- **WHEN** an agent reads the Types section
- **THEN** it SHALL find a CLI example for `docutray types export <name>` and equivalent REST/SDK calls

### Requirement: Steps command documentation
The SKILL.md SHALL include a Steps section documenting `run` and `status` subcommands via CLI, Python SDK, Node SDK, and REST API.

#### Scenario: Steps run usage
- **WHEN** an agent reads the Steps section
- **THEN** it SHALL find examples for running a processing pipeline with `docutray steps run`

#### Scenario: Steps status usage
- **WHEN** an agent reads the Steps section
- **THEN** it SHALL find examples for checking pipeline status with `docutray steps status`

### Requirement: Common patterns section
The SKILL.md SHALL include a Common Patterns section showing practical workflow combinations.

#### Scenario: Identify then convert pattern
- **WHEN** an agent reads Common Patterns
- **THEN** it SHALL find a complete example chaining identify → convert

#### Scenario: Batch processing pattern
- **WHEN** an agent reads Common Patterns
- **THEN** it SHALL find an example processing multiple files

### Requirement: Error handling section
The SKILL.md SHALL include an Error Handling section covering common errors across all commands.

#### Scenario: Error table present
- **WHEN** an agent reads the Error Handling section
- **THEN** it SHALL find a table mapping error symptoms to causes and fixes

#### Scenario: Reference to detailed errors
- **WHEN** an agent needs more error detail
- **THEN** the section SHALL reference the REST API setup reference for the full error code table

### Requirement: Reference files for detailed documentation
The skill SHALL include reference files in `references/` for convert, types, and steps advanced documentation.

#### Scenario: Convert reference exists
- **WHEN** the `skills/docutray-platform/references/` directory is listed
- **THEN** a `convert-reference.md` file SHALL exist with advanced convert options and batch processing details

#### Scenario: Types reference exists
- **WHEN** the `skills/docutray-platform/references/` directory is listed
- **THEN** a `types-reference.md` file SHALL exist with schema structure and export format details

#### Scenario: Steps reference exists
- **WHEN** the `skills/docutray-platform/references/` directory is listed
- **THEN** a `steps-reference.md` file SHALL exist with pipeline configuration and error recovery details

### Requirement: SKILL.md line count limit
The SKILL.md SHALL stay under 500 lines, using `@references/` directives for progressive disclosure.

#### Scenario: Line count validation
- **WHEN** `skills/docutray-platform/SKILL.md` is measured
- **THEN** it SHALL contain fewer than 500 lines

#### Scenario: Reference directives present
- **WHEN** the SKILL.md is read
- **THEN** it SHALL contain `> **Details:** @references/` directives pointing to reference files
