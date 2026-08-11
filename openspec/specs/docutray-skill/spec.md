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
- `advanced/` SHALL contain `custom-types-workflow.md`, `schema-design.md`, `conversion-spec.md`.

#### Scenario: Setup references present
- **WHEN** `skills/docutray/references/setup/` is listed
- **THEN** it SHALL contain `cli.md`, `python.md`, `node.md`, `rest.md`, and `troubleshooting.md`

#### Scenario: Platform references present
- **WHEN** `skills/docutray/references/platform/` is listed
- **THEN** it SHALL contain `convert.md`, `identify.md`, `types.md`, and `steps.md`

#### Scenario: Advanced references present
- **WHEN** `skills/docutray/references/advanced/` is listed
- **THEN** it SHALL contain `custom-types-workflow.md`, `schema-design.md`, and `conversion-spec.md`

### Requirement: Progressive disclosure to references
The root SKILL.md SHALL link to the matching `references/` file from each top-level section, so depth content is loaded on demand rather than embedded.

#### Scenario: Each operation links out
- **WHEN** the convert / identify / types / steps / custom-types / setup-per-language sections of `skills/docutray/SKILL.md` are read
- **THEN** each SHALL contain at least one cross-reference to its corresponding file under `references/`

### Requirement: Documented commands match the live CLI
Every `docutray` command, subcommand, flag, and argument shown in `skills/docutray/SKILL.md` and any file under `skills/docutray/references/` SHALL match the help output of `docutray <command> --help` for `@docutray/cli/0.4.0` or later.

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

#### Scenario: Types create and update flags are real
- **WHEN** the `types create` and `types update` flag tables are read
- **THEN** the documented flags SHALL be a subset of the `0.4.0` help output — for `create`: `{--code, --conversion-mode, --conversion-spec, --description, --draft, --identify-hints, --json, --keep-ordering, --name, --prompt-hints, --publish, --schema}`; for `update`: the same set plus `--no-conversion-spec` and minus `--code` (which is positional and cannot be changed)

#### Scenario: Login non-interactive forms documented
- **WHEN** the setup section or `references/setup/cli.md` documents `docutray login`
- **THEN** it SHALL warn that the bare `docutray login` form requires a TTY and SHALL document at least one non-interactive alternative drawn from: `docutray login --oauth`, `docutray login --api-key <key>`, the positional `docutray login <key>`, or the `DOCUTRAY_API_KEY` env var

#### Scenario: OAuth is the recommended agent path
- **WHEN** the setup section in `SKILL.md` and the Authentication section in `references/setup/cli.md` document agent or non-interactive login
- **THEN** they SHALL present `docutray login --oauth` first as the recommended path for AI coding agents, with a brief rationale that the API key never enters the agent's conversation context (the CLI prints the auth URL to stderr, opens the browser, waits for the callback, writes the key to `~/.config/docutray/config.json`, and returns a JSON success payload on stdout whose `apiKey` field is masked)

#### Scenario: OAuth flags documented
- **WHEN** `docutray login --oauth` is documented
- **THEN** the documentation SHALL also document the related flags `--no-browser` (skip auto-opening the browser) and `--timeout=<seconds>` (default 180), and SHALL note the stdout/stderr split (success JSON on stdout, auth URL and progress on stderr)

#### Scenario: Documented CLI floor is consistent
- **WHEN** the Technical Reference table in `SKILL.md` and the "verified against" lines in `references/` files that document `types` behavior are read
- **THEN** they SHALL name `@docutray/cli/0.4.0` and SHALL NOT claim verification against a version older than the behavior they describe

### Requirement: Convert response shape is schema-driven
Documentation of the `docutray convert` response SHALL describe the body as `{ "data": { ...keys defined by the active document-type schema... } }` and SHALL NOT include a fabricated `"success"` boolean wrapper or a `"document_type"` / `"fields"` envelope around the extracted data.

Documentation of the `docutray types get` and `docutray types export` response SHALL list `conversionSpec` among the returned fields, described as the stored spec verbatim or `null` when none is stored, and SHALL note that it is absent from `types list` responses. Documentation of the human-readable (non-JSON) output of `types get` SHALL show the `Export spec` summary line, whose three forms are a sheet-and-column count for a multi-sheet spec, a column count for a single-table spec, and `(none)` when no spec is stored.

#### Scenario: No fabricated wrapper
- **WHEN** any convert response example is read
- **THEN** it SHALL NOT contain a `"success"` boolean key or a `"fields"` wrapper inside `data`, and any extracted fields SHALL appear at the top level of `data` (not wrapped in a `"document_type"` envelope)

#### Scenario: Schema-driven keys called out
- **WHEN** a convert response example is shown
- **THEN** the surrounding text SHALL note that the keys inside `data` come from the active document type's schema and that example values are illustrative

#### Scenario: Conversion spec listed in the get/export response
- **WHEN** the `types get` / `types export` response shape is documented in `SKILL.md` §4 or `references/platform/types.md`
- **THEN** `conversionSpec` SHALL appear among the documented fields, and the documentation SHALL state that it is returned verbatim (or `null`) and is not present on `types list` items

#### Scenario: Export spec summary line documented
- **WHEN** the human-readable output of `docutray types get` is documented
- **THEN** it SHALL show the `Export spec` line and its three forms: `N sheets, M columns`, `M columns`, and `(none)`

#### Scenario: JSON output is unsummarized
- **WHEN** the documentation contrasts human and JSON output of `types get`
- **THEN** it SHALL state that `--json` (and piped) output carries `conversionSpec` verbatim, with no summary or derived fields

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

### Requirement: Drift sweep grep is clean
The repository SHALL contain none of the broken patterns enumerated in the corrections table at the time `consolidate-into-single-skill` is archived.

#### Scenario: Broken patterns absent
- **WHEN** `grep -RE 'convert.*--output|convert.*--format|types view|types delete|"success"\s*:\s*true|"fields"\s*:\s*\{' skills/docutray/` is run
- **THEN** it SHALL exit with no matches

### Requirement: Conversion spec is documented across the document-type lifecycle

The skill SHALL document a document type's `conversionSpec` — the mapping from extracted JSON to CSV/Excel columns used by tray export — as a supported part of the document-type lifecycle: setting it at creation, replacing it, clearing it, and inspecting it. `conversionSpec` SHALL NOT be listed as out of scope.

The documentation SHALL cover both shapes of the spec and the fields of a column, so an agent can author a spec rather than only pass an existing file through.

#### Scenario: Both spec shapes documented
- **WHEN** the conversion-spec documentation is read
- **THEN** it SHALL describe both the single-table shape (top-level `columns`) and the multi-sheet shape (top-level `sheets`, each sheet having `name` and `columns`), with at least one JSON example of each

#### Scenario: Column fields documented
- **WHEN** the structure of a conversion-spec column is documented
- **THEN** it SHALL document `header` as required, and `jsonPath`, `type` (`data` | `formula`, defaulting to `data`), and `formula` as optional, noting that a column without a `jsonPath` is valid (formula columns and placeholder columns that export as empty cells)

#### Scenario: Not marked out of scope
- **WHEN** `skills/docutray/SKILL.md` states what the skill does not cover
- **THEN** `conversionSpec` SHALL NOT appear in that list

#### Scenario: Setting a spec at creation
- **WHEN** the `docutray types create` guidance is read
- **THEN** it SHALL document `--conversion-spec <file|json>`, stating that the value is accepted as inline JSON, as a path to a file holding a bare spec, or as a path to a full `types export` payload from which the `conversionSpec` key is extracted

#### Scenario: Replacing and clearing a spec
- **WHEN** the `docutray types update` guidance is read
- **THEN** it SHALL document `--conversion-spec <file|json>` with the same parsing semantics as `create`, and `--no-conversion-spec` as the flag that clears the stored spec, and SHALL state that the two flags are mutually exclusive

#### Scenario: Authoring guidance is anchored to the schema
- **WHEN** the guidance explains how to write a `jsonPath` for a column
- **THEN** it SHALL state that the path selects from the document type's own extraction schema (`jsonSchema`), so the spec is written against the fields that type actually extracts

### Requirement: Round-trip and `--schema` carry-over asymmetry are documented

The skill SHALL document that `docutray types create --schema <types export payload>` carries the embedded `conversionSpec` over, so that re-creating an exported type reproduces its export mapping, and that an explicit `--conversion-spec` takes precedence over the embedded value. It SHALL document that `docutray types update --schema <types export payload>` deliberately does **not** carry the embedded spec over, because an update only touches the fields the user named.

#### Scenario: Round-trip preserves the spec
- **WHEN** the `types export` → `types create` round-trip is documented
- **THEN** it SHALL state that both `jsonSchema` and `conversionSpec` from the exported payload are sent, with no extra flags required

#### Scenario: Explicit flag wins
- **WHEN** both `--schema` (a full export payload) and `--conversion-spec` are documented together on `create`
- **THEN** the documentation SHALL state that `--conversion-spec` takes precedence over the spec embedded in `--schema`

#### Scenario: Update does not carry the spec over
- **WHEN** `docutray types update --schema` is documented
- **THEN** the documentation SHALL state that a `conversionSpec` embedded in the schema payload is ignored, and SHALL direct the user to `--conversion-spec` to change it

#### Scenario: Version-control snapshot claim stays accurate
- **WHEN** the "pin org types in version control" pattern claims an exported file is sufficient to recreate a type
- **THEN** the surrounding text SHALL include `conversionSpec` in the list of what the export captures

### Requirement: Silent-drop failure mode is documented

The skill SHALL warn that against a DocuTray API deployment predating `conversionSpec` support, the field is accepted and silently discarded — no error is returned and the CLI cannot detect it — and SHALL name `docutray types get <code>` as the way to confirm the spec was actually stored.

#### Scenario: Warning present
- **WHEN** the conversion-spec documentation is read
- **THEN** it SHALL contain a note that an older API deployment accepts and ignores the field without error

#### Scenario: Verification step named
- **WHEN** the silent-drop warning is given
- **THEN** it SHALL name `docutray types get <code>` (or its `Export spec` output line) as the confirmation step

#### Scenario: Troubleshooting entry exists
- **WHEN** the troubleshooting tables in `skills/docutray/SKILL.md` and `skills/docutray/references/setup/troubleshooting.md` are read
- **THEN** at least one SHALL carry a row whose symptom is a conversion spec that does not appear after a create or update, with the outdated-API-deployment cause and the `types get` verification fix

