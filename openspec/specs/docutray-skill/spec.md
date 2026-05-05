# docutray-skill Specification

## Purpose
TBD - created by archiving change consolidate-into-single-skill. Update Purpose after archive.
## Requirements
### Requirement: Single unified skill directory
The repository SHALL contain exactly one skill directory `skills/docutray/` with a `SKILL.md` and a `references/` subdirectory.

#### Scenario: Single SKILL.md exists
- **WHEN** `find skills -name SKILL.md` is run from the repo root
- **THEN** it SHALL return exactly one path: `skills/docutray/SKILL.md`

#### Scenario: References directory exists
- **WHEN** `skills/docutray/` is listed
- **THEN** it SHALL contain a `references/` subdirectory

### Requirement: SKILL.md frontmatter
The `skills/docutray/SKILL.md` file SHALL have valid YAML frontmatter with `name: docutray` and a non-empty `description` field that mentions setup, convert, identify, types, steps, and custom document types.

#### Scenario: Valid frontmatter parses
- **WHEN** the YAML frontmatter of `skills/docutray/SKILL.md` is parsed
- **THEN** it SHALL contain `name: docutray` and a non-empty `description`

#### Scenario: Description trigger phrases
- **WHEN** the `description` field is read
- **THEN** it SHALL mention installation/authentication, document conversion, document type identification, schema/types management, and custom document type creation

### Requirement: SKILL.md sections cover full workflow
The `skills/docutray/SKILL.md` SHALL contain top-level sections that cover, in order: when to use the skill, setup, convert, identify, types (read-only listing/inspection), steps, custom types, troubleshooting, and a technical reference summary.

#### Scenario: Required section headings present
- **WHEN** H2 headings of `skills/docutray/SKILL.md` are listed
- **THEN** they SHALL include sections for setup, convert, identify, types, steps, custom types, and troubleshooting

#### Scenario: CLI is the canonical example
- **WHEN** an operation (convert, identify, types, steps) is shown in `skills/docutray/SKILL.md`
- **THEN** the primary code example SHALL be a `docutray` CLI invocation; SDK and REST equivalents SHALL be deferred to the relevant `references/` file

### Requirement: SKILL.md line cap
The `skills/docutray/SKILL.md` file SHALL contain at most 500 lines.

#### Scenario: Line count within cap
- **WHEN** `wc -l skills/docutray/SKILL.md` is run
- **THEN** the result SHALL be ≤ 500

### Requirement: References tree organized by domain
The `skills/docutray/references/` directory SHALL contain three subdirectories — `setup/`, `platform/`, `advanced/` — populated as follows:
- `setup/` SHALL contain `cli.md`, `python.md`, `node.md`, `rest.md`, `troubleshooting.md`.
- `platform/` SHALL contain `convert.md`, `identify.md`, `types.md`, `steps.md`.
- `advanced/` SHALL contain `custom-types-workflow.md`, `schema-design.md`.

#### Scenario: Setup references present
- **WHEN** `skills/docutray/references/setup/` is listed
- **THEN** it SHALL contain `cli.md`, `python.md`, `node.md`, `rest.md`, and `troubleshooting.md`

#### Scenario: Platform references present
- **WHEN** `skills/docutray/references/platform/` is listed
- **THEN** it SHALL contain `convert.md`, `identify.md`, `types.md`, and `steps.md`

#### Scenario: Advanced references present
- **WHEN** `skills/docutray/references/advanced/` is listed
- **THEN** it SHALL contain `custom-types-workflow.md` and `schema-design.md`

### Requirement: Progressive disclosure to references
The root SKILL.md SHALL link to the matching `references/` file from each top-level section, so depth content is loaded on demand rather than embedded.

#### Scenario: Each operation links out
- **WHEN** the convert / identify / types / steps / custom-types / setup-per-language sections of `skills/docutray/SKILL.md` are read
- **THEN** each SHALL contain at least one cross-reference to its corresponding file under `references/`

### Requirement: Documented commands match the live CLI
Every `docutray` command, subcommand, flag, and argument shown in `skills/docutray/SKILL.md` and any file under `skills/docutray/references/` SHALL match the help output of `docutray <command> --help` for `@docutray/cli/0.2.1` or later.

#### Scenario: Convert flags are real
- **WHEN** the convert section in `SKILL.md` or `references/platform/convert.md` is read
- **THEN** the documented flags SHALL be a subset of `{-t, --type, --async, --json, --metadata, --timeout, --webhook-url}` plus the positional `SOURCE` argument; `--output` and `--format` SHALL NOT appear on `convert`

#### Scenario: Save-to-file uses shell redirection
- **WHEN** an example shows saving convert output to a file
- **THEN** it SHALL use shell redirection (e.g. `> result.json`) rather than a non-existent `--output` flag

#### Scenario: Identify flags are real
- **WHEN** the identify section is read
- **THEN** the documented flags SHALL be a subset of `{--async, --json, --types}`

#### Scenario: Types subcommands are real
- **WHEN** the types section is read
- **THEN** the documented subcommands SHALL be a subset of `{list, get, export, create, update}`; `view` and `delete` SHALL NOT appear

#### Scenario: Login non-interactive forms documented
- **WHEN** the setup section or `references/setup/cli.md` documents `docutray login`
- **THEN** it SHALL warn that `docutray login` requires a TTY and SHALL document at least one non-interactive alternative (`docutray login --api-key <key>`, the positional `docutray login <key>`, or `DOCUTRAY_API_KEY` env var)

### Requirement: Convert response shape is schema-driven
Documentation of the `docutray convert` response SHALL describe the body as `{ "data": { ...keys defined by the active document-type schema... } }` and SHALL NOT include a fabricated `"success"` boolean wrapper or a `"document_type"` / `"fields"` envelope around the extracted data.

#### Scenario: No fabricated wrapper
- **WHEN** any convert response example is read
- **THEN** it SHALL NOT contain a `"success"` boolean key or a `"fields"` wrapper inside `data`, and any extracted fields SHALL appear at the top level of `data` (not wrapped in a `"document_type"` envelope)

#### Scenario: Schema-driven keys called out
- **WHEN** a convert response example is shown
- **THEN** the surrounding text SHALL note that the keys inside `data` come from the active document type's schema and that example values are illustrative

### Requirement: Drift sweep grep is clean
The repository SHALL contain none of the broken patterns enumerated in the corrections table at the time `consolidate-into-single-skill` is archived.

#### Scenario: Broken patterns absent
- **WHEN** `grep -RE 'convert.*--output|convert.*--format|types view|types delete|"success"\s*:\s*true|"fields"\s*:\s*\{' skills/docutray/` is run
- **THEN** it SHALL exit with no matches

