## ADDED Requirements

### Requirement: SDK snippets match the installed SDK surface

Every Python and Node SDK snippet in `skills/docutray/SKILL.md` and under `skills/docutray/references/` SHALL be valid against the published `docutray` packages — Node **0.1.5** and Python **0.2.1** or later. A snippet SHALL NOT name a client property, resource method, parameter, exception module, or exported type that the installed package does not provide.

Verification SHALL be by **installing the package and probing the documented call paths**, not by reading the SDK source or its README. The README is not authoritative: the Node README documents `steps.runAsync('id', {...})` while the source takes a single params object carrying `stepId`.

Each reference file containing SDK snippets SHALL state the SDK versions its snippets were verified against.

#### Scenario: Resources are namespaced
- **WHEN** any SDK snippet invokes convert, identify, document types, or steps
- **THEN** it SHALL go through the resource namespace — `client.convert.run()`, `client.identify.run()`, `client.documentTypes` / `client.document_types`, `client.steps.runAsync()` / `run_async()` — and SHALL NOT call the client property directly (`client.convert(...)`) or use `client.types`

#### Scenario: Only real methods are documented
- **WHEN** an SDK document-type snippet is read
- **THEN** the method SHALL be one of `list`, `get`, `create`, `update`, `validate`; `export()` SHALL NOT appear, because neither SDK provides it

#### Scenario: Identifier arguments are correct
- **WHEN** an SDK snippet fetches a single document type
- **THEN** it SHALL pass the internal `id` and SHALL note that the `codeType` does not resolve, since only the CLI performs code→id resolution

#### Scenario: Pagination shape is correct
- **WHEN** an SDK snippet calls `list()`
- **THEN** it SHALL treat the return value as a page object whose items are on `.data`, and SHALL NOT iterate or take `.length` / `len()` of the return value directly

#### Scenario: Exceptions and types import from real paths
- **WHEN** an SDK snippet imports an error class or a type
- **THEN** the import SHALL resolve against the installed package — Python exceptions from `docutray` (there is no `docutray.exceptions` module), and Node types limited to what the package exports (`ConversionResult` / `ConversionStatus` exist; `ConvertResult` and `DocumentTypeSchema` do not)

#### Scenario: Python field casing is not invented
- **WHEN** a Python snippet reads a field off a returned model
- **THEN** it SHALL use the API's camelCase names (`codeType`, `jsonSchema`, `isDraft`), because the Python SDK preserves them; only method and argument names are snake_case

### Requirement: REST paths, field names, and envelopes match the live API

Every REST example in `skills/docutray/references/` SHALL use a path, multipart field name, and response envelope confirmed against the live API. Examples SHALL NOT be extrapolated from the CLI's output shape, which differs from the wire format.

#### Scenario: Document-type path is correct
- **WHEN** a REST example addresses document types
- **THEN** it SHALL use `/api/document-types`; `/api/types` SHALL NOT appear anywhere, because it returns `404`

#### Scenario: Per-type endpoint takes an id
- **WHEN** the single-document-type REST endpoint is documented
- **THEN** it SHALL be shown as `/api/document-types/{id}` and SHALL state that passing a `codeType` returns `404`

#### Scenario: File uploads use the `image` part
- **WHEN** a REST example uploads a document as multipart form data
- **THEN** the file part SHALL be named `image`; a part named `file` SHALL NOT appear, because the API rejects it with `Validation error` / `Image file is required`

#### Scenario: Envelopes are stated per endpoint, not assumed uniform
- **WHEN** a REST response example is shown
- **THEN** it SHALL reflect that endpoint's actual envelope — document-type reads wrap the object in `data`, while `identify` returns its fields at the top level with no wrapper — and SHALL NOT present one envelope as applying to all endpoints

#### Scenario: CLI-versus-REST envelope difference is called out
- **WHEN** the document-type REST response is documented alongside the CLI equivalent
- **THEN** it SHALL note that the CLI unwraps the `data` envelope and prints the object flat, so the extraction path differs (`jq .data.jsonSchema` over REST, `jq .jsonSchema` via the CLI)

#### Scenario: Unverified examples are marked
- **WHEN** a REST example has not been checked against the live API
- **THEN** it SHALL be labeled as unverified and SHALL name the authoritative source to trust instead, rather than being presented as confirmed

### Requirement: The organization code prefix is documented wherever a created code is reused

The skill SHALL state that the API namespaces org-owned document types: the value passed to `types create --code` is not necessarily the stored `codeType`, and the un-prefixed code does not resolve. Every place the skill creates a type and then uses its code SHALL take the code from the create response rather than reusing the requested value. Public catalog types SHALL be described as unprefixed.

#### Scenario: Create-then-use flows read the real code
- **WHEN** guidance creates a document type and subsequently references it (`convert -t`, `types get`, `types update`)
- **THEN** it SHALL obtain the code from the create response (e.g. `--json | jq -r .codeType`) rather than reusing the `--code` argument

#### Scenario: The 404 symptom is findable
- **WHEN** the troubleshooting tables are read
- **THEN** at least one row SHALL map `Document type "<code>" not found` immediately after a successful create to the org-prefix cause, with reading `.codeType` as the fix

#### Scenario: Duplicate code failure is documented
- **WHEN** guidance covers scripting `types create`
- **THEN** it SHALL note that reusing an existing code fails with a generic `500 Error processing request` rather than a conflict status, so the error does not identify its own cause

## MODIFIED Requirements

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

#### Scenario: Identify response shape is consistent across surfaces
- **WHEN** an `identify` response is shown anywhere in the skill, whether CLI or REST
- **THEN** it SHALL have no `data` wrapper, `document_type` SHALL be an object with `code`, `name`, and `confidence`, and each entry of `alternatives` SHALL carry the same three fields

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

### Requirement: Round-trip and `--schema` carry-over asymmetry are documented
The skill SHALL document that `docutray types create --schema <types export payload>` carries the embedded `conversionSpec` over, so that re-creating an exported type reproduces its export mapping, and that an explicit `--conversion-spec` takes precedence over the embedded value. It SHALL document that `docutray types update --schema <types export payload>` deliberately does **not** carry the embedded spec over, because an update only touches the fields the user named.

#### Scenario: Round-trip preserves the spec
- **WHEN** the `types export` → `types create` round-trip is documented
- **THEN** it SHALL state that both `jsonSchema` and `conversionSpec` from the exported payload are sent, with no extra flags required

#### Scenario: Explicit flag wins
- **WHEN** both `--schema` (a full export payload) and `--conversion-spec` are documented together on `create`
- **THEN** the documentation SHALL state that `--conversion-spec` takes precedence over the spec embedded in `--schema`, while `jsonSchema` still comes from `--schema` in the same call

#### Scenario: Update does not carry the spec over
- **WHEN** `docutray types update --schema` is documented
- **THEN** the documentation SHALL state that a `conversionSpec` embedded in the schema payload is ignored, and SHALL direct the user to `--conversion-spec` to change it

#### Scenario: Version-control snapshot claim stays accurate
- **WHEN** the "pin org types in version control" pattern claims an exported file is sufficient to recreate a type
- **THEN** the surrounding text SHALL include `conversionSpec` in the list of what the export captures
