# Changelog

All notable changes to the `docutray` agent skill in this repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

_No changes yet._

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
