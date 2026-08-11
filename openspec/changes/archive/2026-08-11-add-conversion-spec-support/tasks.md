## 1. New reference: conversion spec

- [x] 1.1 Create `skills/docutray/references/advanced/conversion-spec.md` with a provenance line naming `@docutray/cli/0.4.0` and the upstream PR as the source, and inviting `docutray types create --help` to confirm (design Decision 6).
- [x] 1.2 In that file, document both spec shapes — single-table (`{"columns":[…]}`) and multi-sheet (`{"sheets":[{"name":…,"columns":[…]}]}`) — with a JSON example of each.
- [x] 1.3 Add a column-field table: `header` (required), `jsonPath`, `type` (`data` | `formula`, default `data`), `formula` (formula columns only); note that a column may omit `jsonPath` (formula and placeholder columns, the latter exporting as empty cells), citing the SDK types as the source.
- [x] 1.4 Add a "writing `jsonPath`" subsection anchoring paths to the type's own `jsonSchema`, with a worked example that maps a schema (scalar field + array of line items) to a matching spec.
- [x] 1.5 Document full flag semantics for `--conversion-spec` (inline JSON, bare-spec file, or full `types export` payload from which `conversionSpec` is extracted) and `--no-conversion-spec` (clears the spec; mutually exclusive with `--conversion-spec`).
- [x] 1.6 Document the CLI's minimal validation — object with `columns` or `sheets`, everything beyond that is the API's call and surfaces as an API error (design Decision 4).
- [x] 1.7 Document the create/update `--schema` carry-over asymmetry with its reason stated inline, and the `--conversion-spec`-wins-over-embedded precedence rule.
- [x] 1.8 Add the silent-drop warning (older API deployment accepts and discards the field with no error) and name `docutray types get <code>` as the confirmation step.
- [x] 1.9 Add SDK/REST parity notes: `docutray@0.1.5` exports `ConversionSpec`, `ConversionSpecColumn`, `ConversionSpecSheet`, `LegacyConversionSpec`, `MultiSheetConversionSpec`, and the `isMultiSheetConversionSpec()` guard (accepts `null`/`undefined`, returns `false`).

## 2. SKILL.md

- [x] 2.1 §4 Types: add `conversionSpec` to the documented `get` / `export` response fields (verbatim or `null`), noting it is absent from `list` items, and show the human-output `Export spec` line with its three forms (`N sheets, M columns` / `M columns` / `(none)`).
- [x] 2.2 §6 Custom Types: add a compact conversion-spec block (~30 lines) covering the three flags, one example of each shape, the create/update asymmetry in one sentence, and the silent-drop warning; add `--conversion-spec` to the create/update flag prose in step 5.
- [x] 2.3 §6: remove `conversionSpec` from the out-of-scope line, keeping `dslRules` / `validationRules` / pipeline design.
- [x] 2.4 §6: add the `references/advanced/conversion-spec.md` pointer to the existing **Depth** callout.
- [x] 2.5 §8 Troubleshooting: add a row for a conversion spec that does not appear after create/update → outdated API deployment → verify with `docutray types get <code>`.
- [x] 2.6 Technical Reference: change the CLI package row to `verified against 0.4.0`.
- [x] 2.7 Frontmatter: bump `metadata.version` to `1.2.0`.
- [x] 2.8 Verify `SKILL.md` is still ≤ 500 lines (`wc -l`).

## 3. Existing references

- [x] 3.1 `references/platform/types.md`: add `conversionSpec` to the `get`/`export` field table with its `null` and absent-from-`list` semantics; update the "verified against" line to `0.4.0`.
- [x] 3.2 `references/platform/types.md`: add `conversionSpec` to the example `get` response JSON, document the human-output `Export spec` line and its three forms, and state that `--json` output stays verbatim with no derived fields.
- [x] 3.3 `references/platform/types.md`: update the "pin org types in version control" pattern so its recreate claim names `conversionSpec` among what the export captures.
- [x] 3.4 `references/advanced/custom-types-workflow.md`: add `--conversion-spec` to the `types create` flag table and both `--conversion-spec` and `--no-conversion-spec` to the `types update` flag table, with the `--schema` carry-over note on each; refresh the stale `0.2.1` version line to `0.4.0`.
- [x] 3.5 `references/advanced/custom-types-workflow.md`: add a round-trip example (`types export -o` → `types create --schema`) noting schema and spec are both carried, and an update-workflow step for replacing or clearing a spec; link `conversion-spec.md`.
- [x] 3.6 `references/advanced/schema-design.md`: add a closing pointer that the schema being designed is what a conversion spec's `jsonPath` selects from, linking `conversion-spec.md`.
- [x] 3.7 `references/setup/node.md` and `references/setup/python.md`: note the `conversionSpec` field on document-type create/update params and, for Node, the exported conversion-spec types and `isMultiSheetConversionSpec()` guard from `docutray@0.1.5`.
- [x] 3.8 `references/setup/rest.md`: add `conversionSpec` to the per-type response description alongside `jsonSchema` and the other fields.
- [x] 3.9 `references/setup/troubleshooting.md`: add the silent-drop row (symptom / outdated API deployment / verify with `types get`).

## 4. Release and verification

- [x] 4.1 Add the `1.2.0` entry to `CHANGELOG.md` under a new heading, moving the conversion-spec work out of `[Unreleased]`, with links to docutray-cli#36.
- [x] 4.2 Drift sweep: grep the tree for `conversionSpec` / `conversion-spec` and confirm no file still calls it out of scope, no flag name is misspelled, and the `Export spec` output forms are stated identically everywhere.
- [x] 4.3 Cross-file consistency check: the create/update asymmetry, the flag mutual exclusion, and the silent-drop caveat read the same in `SKILL.md`, `conversion-spec.md`, and `custom-types-workflow.md`.
- [x] 4.4 Run `openspec validate --strict add-conversion-spec-support` and fix any reported issues.
