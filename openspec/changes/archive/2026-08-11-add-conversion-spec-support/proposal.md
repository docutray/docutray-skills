## Why

`@docutray/cli@0.4.0` ([docutray-cli#36](https://github.com/docutray/docutray-cli/pull/36), backed by SDK `docutray@0.1.5`) exposes a document type's **conversion spec** — the mapping from extracted JSON to CSV/Excel columns used by tray export — through `types create --conversion-spec`, `types update --conversion-spec` / `--no-conversion-spec`, and an `Export spec` summary line on `types get`. The skill currently declares `conversionSpec` **out of scope** (`SKILL.md` §6) and pins its guidance to `0.3.2`, so an agent following it will:

- create or recreate a document type that silently loses its export mapping — the round-trip `types export → types create` now carries the spec, but the skill never mentions it;
- never surface or edit a spec the user asks about, because none of the three new flags are documented anywhere in the skill;
- describe the `types get` / `export` response as not containing `conversionSpec`, which is now wrong.

## What Changes

- **Lift `conversionSpec` out of the "out of scope" list** in `SKILL.md` §6 and cover it as a first-class part of the document-type lifecycle: create, update, and inspect.
- **Document the spec format** — the two shapes (`{"columns":[…]}` single-table and `{"sheets":[{"name":…,"columns":[…]}]}` multi-sheet) and the column fields (`header`, optional `jsonPath`, optional `type: data|formula`, optional `formula`) — so an agent can author one, not just pass a file through.
- **Document the three new CLI flags** and their semantics: `--conversion-spec <file|json>` on `create` and `update` (accepts a bare spec, a file, or a full `types export` payload from which `conversionSpec` is extracted), and `--no-conversion-spec` on `update` to clear the stored spec (mutually exclusive with `--conversion-spec`).
- **Document the deliberate create/update asymmetry**: `create --schema <export.json>` carries the embedded `conversionSpec` over (completing the round-trip), while `update --schema <export.json>` does *not* — an update only touches fields the user named.
- **Update the `types get` / `export` response documentation** to include `conversionSpec` (verbatim in JSON output; summarized as `Export spec: 2 sheets, 14 columns` / `5 columns` / `(none)` in human output), and note it is **absent from `list` responses**.
- **Raise the documented CLI floor to `@docutray/cli >= 0.4.0`** in the technical reference and the per-file "verified against" lines that this change touches, and refresh the stale `0.2.1` markers on `custom-types-workflow.md`.
- **Add a troubleshooting entry** for the silent-drop failure mode: against an API deployment predating `conversionSpec` support the field is accepted and discarded without error — the only way to confirm it stored is `docutray types get <code>`.
- **Add SDK/REST coverage**: `docutray@0.1.5` exports `ConversionSpec`, `ConversionSpecColumn`, `ConversionSpecSheet`, and the `isMultiSheetConversionSpec()` type guard for narrowing the union.
- Bump the skill to **`1.2.0`** (`SKILL.md` frontmatter `metadata.version`) and record the release in `CHANGELOG.md`.

No breaking changes to the skill's existing guidance: every documented flag is optional and no previously documented behavior is retracted.

## Capabilities

### New Capabilities
<!-- none — conversion-spec guidance is content within the existing skill capability -->

### Modified Capabilities
- `docutray-skill`: gains requirements that the skill (a) documents the conversion spec across the document-type lifecycle — create, update, clear, and inspect — with its two shapes and column fields, (b) documents the create/update `--schema` carry-over asymmetry and the round-trip guarantee, and (c) reflects `conversionSpec` in the documented `types get` / `export` response shape. The existing *"Documented commands match the live CLI"* requirement is extended to `@docutray/cli/0.4.0`.

## Impact

- `skills/docutray/SKILL.md` — §4 Types (response shape, `Export spec` line), §6 Custom Types (create/update flags, out-of-scope note), §8 Troubleshooting (silent-drop row), Technical Reference (CLI version), frontmatter version. Must stay ≤ 500 lines (currently 351).
- `skills/docutray/references/platform/types.md` — response-shape table, `get` / `export` examples, version line.
- `skills/docutray/references/advanced/custom-types-workflow.md` — `create` and `update` flag tables, workflow, round-trip pattern, stale `0.2.1` version line.
- `skills/docutray/references/advanced/schema-design.md` — pointer from schema design to the export mapping (`jsonPath` selects from the schema being designed).
- `skills/docutray/references/setup/{node,python,rest,troubleshooting}.md` — SDK types and guard, REST field, silent-drop entry.
- `openspec/specs/docutray-skill/spec.md` — updated on sync from this change's delta.
- `CHANGELOG.md` — `1.2.0` entry.
- Markdown and YAML only; no code, build, or runtime impact.
