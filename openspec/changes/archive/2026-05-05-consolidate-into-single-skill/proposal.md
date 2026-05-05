## Why

A real Claude Code session (`8db64bf3...jsonl`) showed that the three-skill split (`docutray-setup` / `docutray-platform` / `docutray-advanced`) is artificial: every real "convert this PDF" flow crosses setup → platform within seconds, forcing the agent to load multiple SKILL.md files for one task. The same review surfaced documentation drift now spread across three skills (broken `--output` flag on `convert`, fake response shape, no TTY caveat on `docutray login`). Consolidating to a single `docutray` skill with a tight root SKILL.md and a domain-organized `references/` tree gives a single source of truth, eliminates artificial boundaries, and lets us correct the verified-CLI drift in one pass.

## What Changes

- **BREAKING**: Remove `skills/docutray-setup/`, `skills/docutray-platform/`, and `skills/docutray-advanced/`. Replace with a single `skills/docutray/`.
- Add `skills/docutray/SKILL.md` (≤500 lines) covering install/auth, convert, identify, types (read-only), steps, custom types pointer, and troubleshooting. CLI is the canonical example; SDKs and REST are referenced.
- Add `skills/docutray/references/` with nested layout: `setup/{cli,python,node,rest,troubleshooting}.md`, `platform/{convert,identify,types,steps}.md`, `advanced/{custom-types-workflow,schema-design}.md`.
- Apply verified-CLI corrections inline during the relocation: remove non-existent `--output`/`--format` flags from `convert`, fix the fabricated `{success, data:{document_type, fields}}` response shape, document `docutray login` non-interactive forms (`--api-key`, positional, env var), purge non-existent `types view`/`types delete` subcommands, enumerate real flags for `identify` (`--types`, `--async`, `--json`) and `steps run/status`.
- Update `repo-structure` spec to describe a single skill.
- Update `README.md` skill table.
- Update `CLAUDE.md` "Repository Structure" section.

## Capabilities

### New Capabilities
- `docutray-skill`: Single unified `docutray` skill. Defines requirements for the root SKILL.md (frontmatter, sections, line cap, progressive disclosure) and the `references/` tree (layout, per-file scope, verified CLI correctness).

### Modified Capabilities
- `repo-structure`: Update to require a single `skills/docutray/` directory and matching README table.

### Removed Capabilities
- `docutray-setup-skill`, `docutray-setup-content`: subsumed by `docutray-skill` and `references/setup/`.
- `docutray-platform-skill`, `docutray-platform-content`: subsumed by `docutray-skill` and `references/platform/`.
- `docutray-advanced-skill`, `document-type-workflow`, `schema-design`, `prompt-hints`: subsumed by `docutray-skill` and `references/advanced/`.

## Impact

- `skills/docutray/` — new directory tree (1 SKILL.md + 11 reference files).
- `skills/docutray-setup/`, `skills/docutray-platform/`, `skills/docutray-advanced/` — removed.
- `openspec/specs/` — 8 specs removed, 1 modified, 1 added (after archive).
- `README.md` — skill table updated.
- `CLAUDE.md` — Repository Structure section updated.
- Downstream consumers running `npx skills add docutray/docutray-skills` will see one skill instead of three after the next publish.
