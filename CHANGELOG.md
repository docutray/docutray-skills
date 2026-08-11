# Changelog

All notable changes to the `docutray` agent skill in this repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and from `1.1.0` onward the skill is versioned with [Semantic Versioning](https://semver.org/). The skill version is also declared in `skills/docutray/SKILL.md` frontmatter (`metadata.version`). The `2026-05-07` consolidation release is the `1.0.0` baseline.

## [Unreleased]

### Fixed

- **Every SDK snippet in the skill was wrong and is now verified against the SDK sources** (`docutray` Node **0.1.5**, Python **0.2.1**). A code review of the conversion-spec work surfaced one bad call site; checking the rest found the same class of error throughout — an agent following any SDK example would have hit `TypeError` / `undefined is not a function` rather than a working call. Corrections:
  - **Resources are namespaced.** `client.convert(...)` → `client.convert.run(...)`, `client.identify(...)` → `client.identify.run(...)`, `client.steps.run(...)` → `client.steps.run_async()` / `runAsync()`, `client.steps.status()` → `get_status()` / `getStatus()`.
  - **Document types live on `documentTypes` / `document_types`**, never `client.types`. `get()` takes the internal **id**, not the `codeType` — the CLI resolves code→id, the SDKs do not; a lookup pattern is now documented.
  - **Neither SDK has `export()`.** The surface is `list`, `get`, `create`, `update`, `validate`. Use the CLI's `types export`.
  - **`list()` returns a `Page`**, not a bare array/list — items are on `.data` (plus `hasNextPage()`/`autoPagingIter()` in Node, `iter_pages()`/`auto_paging_iter()` in Python).
  - **Parameter names**: `document_type` → `document_type_code` / `documentTypeCode`; `file_path` / `filePath` → `file` (or `url` / `base64`); `types` → `document_type_code_options` / `documentTypeCodeOptions` (the `--types` spelling is CLI-only); `no_wait` / `noWait` do not exist.
  - **Type and import names**: `ConvertResult` and `DocumentTypeSchema` don't exist (`ConversionResult` / `ConversionStatus` do); exceptions come from `docutray`, not `docutray.exceptions`.
  - **Python keeps the API's camelCase field names** (`codeType`, `jsonSchema`, `isDraft`) rather than converting to snake_case — the previous note claiming the opposite was wrong.
- **`types create` failure modes an agent will hit when scripting**: a code that is already taken returns a bare `{"error":"Error processing request","status":500}` with no conflict status and no mention of the code, and the command's output is not reliably a single JSON object (a second object with `isDraft`/`status` nulled has been observed). Documented with a defensive `| head -1` in the capture idiom.
- **Org-owned document types are namespaced by the API, and the skill's custom-type workflow ignored it.** Creating with `--code acme-purchase-order` in an org named *Acme* stores `codeType` `acme_acme-purchase-order`; the un-prefixed code returns `Document type "…" not found`. The documented flow (`types create --code X` → `convert -t X`) therefore 404s. `SKILL.md` §6, `custom-types-workflow.md` Stage 8, and both troubleshooting tables now say to read `.codeType` from the create response. Public catalog types are not prefixed.
- **REST: `/api/types` does not exist** — every occurrence (verification snippet plus the Go, Ruby, and PHP examples) returned `404`; the endpoint is `/api/document-types`. Also corrected in `troubleshooting.md`.
- **REST: the per-type endpoint takes the internal `id`, not the `codeType`** (a code returns `404`), and it wraps the type in a `data` envelope — unlike the CLI, which unwraps it and prints the object flat. Documented the difference (`jq .data.jsonSchema` vs `jq .jsonSchema`), with the now-verified full payload including `conversionSpec`.
- **Two more broken SDK snippets** in `troubleshooting.md`'s verification commands (`Client().types.list()`, `new m.DocuTray().types.list()`), missed by the first sweep because the call prefix differed.
- **Corrected the REST `identify` example, now verified against the live API.** It previously showed a `data` envelope and `document_type` as a string; the real response has **no** envelope and `document_type` is an object (`{code, name, confidence}`), byte-for-byte identical to what `docutray identify --json` prints. Also documented that the candidate list travels as `document_type_code_options` (a JSON-encoded array), not the CLI's `types` spelling.
- **The multipart file part is `image`, not `file`** — for every document type including PDFs. A part named `file` is rejected with `{"message":"Validation error","errors":["Image file is required"]}`. Fixed across all six REST examples (`rest.md` convert/identify, `platform/{convert,identify,steps}.md`), with a troubleshooting row keyed to the error text.
- **REST `steps` paths were wrong.** The documented `POST /api/steps` with a `step_id` form field does not exist in either SDK; the endpoints are `/api/steps-async/{stepId}` and `/api/steps-async/status/{executionId}`, with the step id in the path. Corrected from SDK source and marked as not live-verified.
- **Envelopes are not uniform across the API**, and `rest.md` previously asserted they were — which is what produced the wrong `identify` example. Document-type reads wrap in `data`; `identify` does not. Now stated per endpoint.
- **Corrected the `identify` → `convert` chaining examples** in `references/platform/convert.md`, which used `jq -r '.data.document_type'` against a response that has no `data` wrapper and whose `document_type` is an object. Now `jq -r '.document_type.code'`, with the required `--types` flag included.

## [1.2.0] - 2026-08-11

### Added

- **Conversion spec (`conversionSpec`) is now covered end-to-end**, tracking `@docutray/cli@0.4.0` ([docutray-cli#36](https://github.com/docutray/docutray-cli/pull/36), SDK `docutray@0.1.5`). The export mapping — extracted JSON → CSV/Excel columns used by tray export — was previously listed as *out of scope*, so an agent following the skill would silently drop a type's mapping when recreating it and had no way to read or edit one. New `references/advanced/conversion-spec.md` documents both spec shapes (single-table `columns`, multi-sheet `sheets`), the column fields (`header`, `jsonPath`, `type`, `formula`), `jsonPath` authoring against the type's own `jsonSchema`, and full flag semantics. `SKILL.md` §6 gains a compact block with the three flags and one example of each shape.
- **`types create --conversion-spec` / `types update --conversion-spec` / `types update --no-conversion-spec`** documented, including the three accepted input forms (inline JSON, bare-spec file, full `types export` payload) and the mutual exclusion of the two update flags. Added to the flag tables in `references/advanced/custom-types-workflow.md`.
- **The `--schema` carry-over asymmetry** is documented at every point of use: `create --schema <export payload>` carries the embedded `conversionSpec` (completing the `types export` → `types create` round-trip with no extra flags), while `update --schema` deliberately does not, because an update only touches the fields you name. An explicit `--conversion-spec` wins over an embedded one.
- **Silent-drop warning and troubleshooting rows.** Against an API deployment predating `conversionSpec` support the field is accepted and discarded with no error and no client-side way to detect it — `docutray types get <code>` after every write is the only confirmation. Rows added to both troubleshooting tables, alongside entries for the mutually exclusive flags, the ignored-on-update schema spec, and pre-API parse failures.
- **Documented the two easily-misread `Export spec` states**, both observed on live types: `0 columns` (an empty `{"columns": []}` spec — stored, exports a column-less file) is *not* `(none)` (no spec at all), and `(present)` is a real fallback that appears when `conversionSpec` is `{}`. Stored-spec checks are framed as "not `(none)`" rather than matching a count form.
- **Added a real-world authoring pattern** to `conversion-spec.md`: detail sheets commonly repeat the identifying root-level scalars before the array projections, so each exported row stands alone when filtered or pasted elsewhere.
- **SDK/REST coverage**: `docutray@0.1.5` exports `ConversionSpec`, `ConversionSpecColumn`, `ConversionSpecSheet`, `LegacyConversionSpec`, `MultiSheetConversionSpec`, and the `isMultiSheetConversionSpec()` guard (accepts `null`/`undefined`, returns `false`) — documented in `references/setup/node.md`, with field notes in `python.md` and `rest.md`.

### Changed

- **`types get` / `types export` response documentation now includes `conversionSpec`** — returned verbatim or `null`, and **absent from `types list` items**. The human-readable `Export spec` summary line and all five of its forms (`N sheets, M columns` / `M columns` / `0 columns` / `(none)` / `(present)`) are documented in `SKILL.md` §4 and `references/platform/types.md`, along with the note that `--json` output is never summarized.
- **Documented CLI floor raised to `@docutray/cli/0.4.0`** in the `SKILL.md` Technical Reference and on the files this change touches (`references/platform/types.md`, `references/advanced/custom-types-workflow.md` — the latter was stale at `0.2.1`). Files not re-verified by this change keep their existing markers rather than claiming a verification that did not happen.
- The "pin org types in version control" pattern now names `conversionSpec` among what an export captures, so its recreate claim stays accurate.
- `references/advanced/schema-design.md` closes with a pointer that the schema being designed is what a conversion spec's `jsonPath` selects from.

> **Provenance:** verified end-to-end against `@docutray/cli/0.4.0` and a live organization (23 document types), including the write paths — the export → create round-trip, the `update` clear, the `--schema` carry-over asymmetry, and that an explicit `--conversion-spec` beats a spec embedded in `--schema` while `jsonSchema` still comes from `--schema`. Confirmed: `list` omits `conversionSpec`; `get`/`export` return byte-identical payloads carrying both `jsonSchema` and `conversionSpec`; the `create`/`update` flag sets match the documented tables exactly; and all five `Export spec` forms were observed on real types — `2 sheets, 13 columns`, `13 columns`, `0 columns`, `(none)`, and `(present)` (a `conversionSpec` of `{}`). Write paths (`create`/`update`) were not exercised against the live org.

## [1.1.0] - 2026-06-09

### Changed

- **Custom-type design now reads an example document first.** The custom-type workflow always requests a sample document and the agent reads it with its own native file/vision tool before generating a JSON Schema, then **proposes** the fields it detected and refines with the user — instead of building the schema from a verbal field description. Phrased generically for portability across agents (Claude Code, Cursor, Codex); no-sample escape hatch warns the schema is tentative and falls back to verbal description without hard-blocking. Updates `skills/docutray/SKILL.md` §6 and `references/advanced/custom-types-workflow.md` (Stages 1 and 3, example dialog). New OpenSpec requirement *"Custom-type design reads an example document first"* synced into `openspec/specs/docutray-skill/spec.md`. ([#14](https://github.com/docutray/docutray-skills/pull/14))

### Fixed

- **Corrected the DocuTray docs base URL.** The docs site serves all content under `/docs`, so `docs.docutray.com/cli` returned 404. Remapped the README and `CLAUDE.md` links to `/docs/cli`, and the command-reference deep links in `references/setup/cli.md` to `/docs/cli/commands/<cmd>` (all verified 200). ([#12](https://github.com/docutray/docutray-skills/pull/12))

## 2026-05-07 — Single-skill consolidation, OAuth login, CLI 0.3.2 floor

Major restructure plus correctness sweep verified end-to-end against `@docutray/cli/0.3.2`.

### Changed — **BREAKING**

- **Consolidated three skills into one.** `docutray-setup`, `docutray-platform`, and `docutray-advanced` are merged into a single `docutray` skill. Downstream consumers running `npx skills add docutray/docutray-skills` will see one skill instead of three.
- Root `SKILL.md` covers install/auth, convert, identify, types (read-only), steps, custom types pointer, and troubleshooting; CLI is the canonical example. Depth moved to `references/` with a domain-organized layout:
  - `references/setup/{cli,python,node,rest,troubleshooting}.md`
  - `references/platform/{convert,identify,types,steps}.md`
  - `references/advanced/{custom-types-workflow,schema-design}.md`
- **Bumped CLI floor to `@docutray/cli >= 0.3.2`** (from `0.2.1`). Older versions are missing OAuth login (0.3.1), the API-key-leak fix on `types list` (0.3.1), and full schema exposure on `types get` / `export` (0.3.2).

### Added

- **`docutray login --oauth` as the canonical agent auth path.** The CLI prints the auth URL to **stderr**, opens the user's browser, blocks on the local callback (`http://localhost:9876/callback`), and writes the resulting API key to `~/.config/docutray/config.json`. The agent only ever sees the masked form (`<first-4>****<last-4>`) in the success JSON on stdout. SKILL.md §1.3 leads with `--oauth`; `DOCUTRAY_API_KEY`, `--api-key`, and the positional form remain as fallbacks for browserless environments. `--no-browser`, `--timeout` (default 180s), the multi-org auto-select behavior, and the port-9876 callback are documented in references and troubleshooting tables.
- **`types get` / `types export` now return the full type definition** (CLI 0.3.2+). Both commands return a flat object (no `data` envelope) including `jsonSchema`, `promptHints`, `identifyPromptHints`, `conversionMode` (`json` \| `toon` \| `multi_prompt`), and `keepPropertyOrdering`. The "pin in version control" pattern (loop `types export -o`) is now sufficient for full reconstruction; previously only metadata was captured.
- New OpenSpec capability `docutray-skill` covering the unified SKILL.md and references layout, including verified-CLI correctness requirements.
- `references/setup/troubleshooting.md` and `references/platform/identify.md` extracted into their own files.

### Fixed

Documentation now matches live CLI behavior verified against `@docutray/cli/0.3.2`.

- **`docutray identify`** — `--types` is required in practice (the API rejects bare `identify <file>` with `{"error":"Validation error","status":400}` even though `--help` lists `--types` as optional). The response shape was also wrong: documented as `{"data":{"document_type":"<string>",…}}`; real shape is `{"document_type":{"code","name","confidence"},"alternatives":[…]}` — no `data` envelope, `document_type` is an object. The "identify → convert" chain now uses `jq -r '.document_type.code'` (was `.data.document_type`).
- **`docutray types list`** — item shape corrected from `{"code","name","description"}` to `{id, codeType, name, description, isPublic, isDraft, status, createdAt, updatedAt}` with a `pagination` block (`total`, `page`, `limit`). The identifier field is **`codeType`**, not `code`.
- **`docutray convert`** — removed non-existent `--output, -o` and `--format json|csv` flags. Real flags: `-t/--type` (required), `--async`, `--json`, `--metadata`, `--timeout` (default 300s), `--webhook-url`. Save-to-file uses shell redirection (`> result.json`).
- **Convert response shape** — replaced fabricated `{"success":true,"data":{"document_type":…,"fields":{…}}}` with the real `{"data":{…schema-driven keys…}}`. No `success` wrapper, no `document_type`/`fields` envelope. Keys come from the active document type's schema (DocuTray's default org schemas often use Spanish keys like `moneda`, `detalle`, `fecha_pago`).
- **`docutray login`** — added the non-interactive caveat: bare `login` requires a TTY and errors out in agent shells / CI with `Non-interactive mode requires --api-key flag or api-key argument`. Documented forms: `--oauth`, `--api-key dt_live_…`, the positional form, the `DOCUTRAY_API_KEY` env var, and `--base-url` for staging.
- **`docutray types` subcommands** — purged references to non-existent `types view` and `types delete`. Real subcommands: `list`, `get`, `export`, `create`, `update`. Lifecycle is managed via `--draft` / `--publish` on `update`, or via the dashboard.
- **`docutray identify` flag set** — `--async`, `--json`, `--types <comma-separated codes>`. No `--output`.
- **`docutray steps run` / `steps status`** — verified flags. `steps run`: `--no-wait`, `--json`, `--metadata`, `--webhook-url`. `steps status`: `--json`. `SOURCE` is positional (file or URL); no `--input` flag.
- **`docutray types create` / `update`** — full flag set documented (`--name`, `--code`, `--description`, `--schema`, `--prompt-hints`, `--identify-hints`, `--conversion-mode {json|toon|multi_prompt}`, `--keep-ordering`, `--publish`/`--draft`).
- **CLI 0.3.0 API-key leak** — `docutray types list --json` exposed the user's API key in plain text under `pageOptions.client.apiKey`. Fixed upstream in CLI 0.3.1; the new floor (0.3.2) inherits the fix. If you're still on 0.3.0, do not pipe `types list --json` to logs or shared destinations — upgrade first.

### Removed

- `skills/docutray-setup/`, `skills/docutray-platform/`, `skills/docutray-advanced/` directories.
- 8 obsoleted OpenSpec capability specs subsumed into the new `docutray-skill` capability: `docutray-setup-skill`, `docutray-setup-content`, `docutray-platform-skill`, `docutray-platform-content`, `docutray-advanced-skill`, `document-type-workflow`, `schema-design`, `prompt-hints`.

## 2026-04-07 — `docutray-advanced` skill populated

- Implemented document-type configuration flow: decision tree, progressive disclosure stages, schema design, modify workflow, prompt hints, multi-document handling. ([#7](https://github.com/docutray/docutray-skills/pull/8))
- Added `references/document-type-workflow-reference.md` and `references/schema-design-reference.md`.

## 2026-04-06 — `docutray-platform` skill populated

- Implemented core CLI commands documentation: convert, identify, types (list/get/export), steps (run/status). ([#5](https://github.com/docutray/docutray-skills/pull/6))
- Added `references/{convert,types,steps}-reference.md`.
- Subsequent fix: switched Python SDK example from undocumented `result.json()` to `json.dumps(result.data)`.

## 2026-04-06 — `docutray-setup` skill populated

- Implemented installation, authentication, and verification for CLI, Python SDK, Node SDK, and REST API paths. ([#3](https://github.com/docutray/docutray-skills/pull/4))
- Added `references/{cli,python-sdk,node-sdk,rest-api}-setup.md`.
- Subsequent fix: corrected REST API base URL and response-format description.

## 2026-04-06 — Multi-skill repo structure

- Set up the three-skill skeleton (`docutray-setup`, `docutray-platform`, `docutray-advanced`) following the Agent Skills specification. ([#1](https://github.com/docutray/docutray-skills/pull/2))
- Added `CLAUDE.md` with project guidance.

## 2026-04-06 — Initial commit

- Repository scaffolding for docutray-cli agent skills.
