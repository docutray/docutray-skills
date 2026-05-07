# Changelog

All notable changes to the `docutray` agent skill in this repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- **Bumped CLI floor to `@docutray/cli >= 0.3.2`** (was 0.3.1 in the previous unreleased entry). 0.3.2 closes the schema-exposure gap on `docutray types get` and `docutray types export`: both commands now return the full type definition — `jsonSchema`, `promptHints`, `identifyPromptHints`, `conversionMode`, and `keepPropertyOrdering` — as a flat object (no `data` envelope). SKILL.md §4 and `references/platform/types.md` updated: removed the "Schema not currently exposed" caveat, added the new fields to the response table, switched examples from `jq .data.…` to `jq .jsonSchema`, and updated the "pin in version control" pattern to note that the snapshot is now sufficient for reconstruction. CLI version references (frontmatter, technical reference table, spec) bumped 0.3.1 → 0.3.2.

### Fixed

- **Bumped CLI floor to `@docutray/cli >= 0.3.1`** (was 0.3.0 in the previous unreleased entry). 0.3.1 fixes a bug where `docutray types list --json` exposed the user's API key in plain text under `pageOptions.client.apiKey`. The current docs assume 0.3.1+ where that block is absent. If you're still on 0.3.0, do not pipe `types list --json` to logs or shared destinations — upgrade first.
- **`docutray identify`** — the previous documentation showed `docutray identify <file>` as the basic invocation form; in practice the API rejects requests without `--types` and returns `{"error":"Validation error","status":400}`. SKILL.md §3 and `references/platform/identify.md` now lead with the `--types` requirement. The response shape was also wrong: documented as `{"data":{"document_type":"<string>","confidence":<number>,"alternatives":[...]}}`; the real shape is `{"document_type":{"code","name","confidence"},"alternatives":[{"code","name","confidence"}]}` — no `data` envelope, `document_type` is an object. The "identify, then convert" chain now uses `jq -r '.document_type.code'` (was `.data.document_type`). Verified against `@docutray/cli/0.3.1`. ([previous commit](#))
- **`docutray types list` / `get` / `export`** — the documented response item shape (`{"code","name","description"}`) is wrong. Real fields: `id`, **`codeType`** (not `code`), `name`, `description`, `isPublic`, `isDraft`, `status`, `createdAt`, `updatedAt`. `list` adds a `pagination` block (`total`, `page`, `limit`). `get` and `export` currently return only metadata — the actual JSON Schema is **not** exposed by either command in 0.3.1, despite the CLI's own `--help` for `export` claiming it returns "the document type definition." Doc now records this gap and points users to the dashboard for schema inspection. SKILL.md §4, `references/platform/types.md`, and example pipes (`jq -r '.data[].codeType'`) updated accordingly.

### Added

- **Recommend `docutray login --oauth` as the canonical agent auth path.** Requires `@docutray/cli >= 0.3.1`. The CLI prints the OAuth authorization URL to stderr, opens the user's browser, blocks on the local callback (default `http://localhost:9876/callback`), and writes the resulting API key to `~/.config/docutray/config.json`. The agent only ever sees the masked form (`<first-4>****<last-4>`) of the key in the success JSON on stdout. SKILL.md §1.3 now leads with `--oauth`; `DOCUTRAY_API_KEY`, `--api-key`, and the positional form remain as fallbacks for browserless environments. References and troubleshooting tables document `--no-browser`, `--timeout`, the multi-org auto-select behavior, and the port-9876 callback. Verified end-to-end against `@docutray/cli/0.3.1`.

### Changed — **BREAKING**

- **Consolidated three skills into one.** `docutray-setup`, `docutray-platform`, and `docutray-advanced` are merged into a single `docutray` skill. Downstream consumers running `npx skills add docutray/docutray-skills` will see one skill instead of three after re-publishing.
- Root `SKILL.md` (310 lines) covers install/auth, convert, identify, types (read-only), steps, custom types pointer, and troubleshooting. CLI is the canonical example.
- Depth content moved to `references/` with a domain-organized layout:
  - `references/setup/{cli,python,node,rest,troubleshooting}.md`
  - `references/platform/{convert,identify,types,steps}.md`
  - `references/advanced/{custom-types-workflow,schema-design}.md`

### Fixed

Verified against `@docutray/cli/0.2.1` `--help` output and a real session transcript:

- **`docutray convert`** — removed the documented `--output, -o` and `--format json|csv` flags. They do not exist on the CLI; calling them produces `Error: Nonexistent flag: --output`. The real flag set is `-t, --type` (required), `--async`, `--json`, `--metadata`, `--timeout` (default 300s), `--webhook-url`. Save-to-file is shell redirection (`> result.json`).
- **`docutray login`** — added the non-interactive caveat. The bare `docutray login` form requires a TTY and errors out in agent shells / CI with `Non-interactive mode requires --api-key flag or api-key argument`. Documented forms now include `docutray login --api-key dt_live_...`, the positional form, and the `DOCUTRAY_API_KEY` env var. Also documented `--base-url` for staging.
- **Convert response shape** — replaced fabricated `{ "success": true, "data": { "document_type": ..., "fields": {...} } }` with the real shape `{ "data": { ...schema-driven keys... } }`. No `success` wrapper, no `document_type` envelope, no `fields` wrapper. Field keys come from the active document type's schema (DocuTray's default org schemas often use Spanish keys like `moneda`, `detalle`, `fecha_pago`).
- **`docutray types` subcommands** — purged references to non-existent `types view` and `types delete`. The real subcommands are `list`, `get`, `export`, `create`, `update`. Lifecycle is managed via `--draft` / `--publish` on `update`, or via the dashboard.
- **`docutray identify`** — enumerated the real flag set: `--async`, `--json`, `--types <comma-separated codes>`. There is no `--output`.
- **`docutray steps run` / `steps status`** — verified flags. `steps run` accepts `--no-wait`, `--json`, `--metadata`, `--webhook-url`; `steps status` accepts `--json`. `SOURCE` is positional (file or URL); there is no `--input` flag.
- **`docutray types create` / `update`** — full flag set documented (`--name`, `--code`, `--description`, `--schema`, `--prompt-hints`, `--identify-hints`, `--conversion-mode {json|toon|multi_prompt}`, `--keep-ordering`, `--publish`/`--draft`).

### Removed

- `skills/docutray-setup/`, `skills/docutray-platform/`, `skills/docutray-advanced/` directories.
- 8 obsoleted OpenSpec capability specs subsumed into the new `docutray-skill` capability: `docutray-setup-skill`, `docutray-setup-content`, `docutray-platform-skill`, `docutray-platform-content`, `docutray-advanced-skill`, `document-type-workflow`, `schema-design`, `prompt-hints`.

### Added

- New OpenSpec capability `docutray-skill` covering the unified SKILL.md and references layout, including verified-CLI correctness requirements.
- `references/setup/troubleshooting.md` — extracted into its own file (previously inline in setup SKILL.md §8).
- `references/platform/identify.md` — extracted into its own file (previously inline in platform SKILL.md §2).

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
