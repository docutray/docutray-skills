## Why

When designing a custom document type, the skill currently builds the JSON Schema from what the user *verbally describes* — field names, locations, and table structure are guesses. Reading the actual sample document first produces accurate field descriptions (where each value sits, real formats, real columns), which `schema-design.md` calls the single biggest driver of extraction quality. It also lets the agent lead with a concrete draft instead of an open-ended questionnaire. (GitHub issue #13 / Linear DOC-89, Urgent.)

## What Changes

- The custom-type workflow SHALL **always request an example document** before generating a JSON Schema.
- The agent SHALL **read the document with its own native file/vision capability** to understand structure and content before drafting the schema. Phrased generically so it applies across agents (Claude Code, Cursor, Codex), without prescribing a specific tool or `docutray convert/identify` as the reader.
- The field-gathering stage flips from *"ask the user to enumerate fields"* to **"agent proposes the fields it detected → user confirms/adjusts"** (read-first).
- **Escape hatch:** if the user genuinely has no sample, the agent warns the schema is tentative ("validate against a real document later") and may fall back to the verbal-description flow — it does **not** hard-block.
- The iterative refinement loop (draft → test with `docutray convert` → refine) is preserved.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `docutray-skill`: the custom-type creation guidance gains a requirement that an example document is requested and read before a JSON Schema is generated, with the read-first / propose-then-refine flow and a no-sample escape hatch.

## Impact

- `skills/docutray/references/advanced/custom-types-workflow.md` — Stage 1 (sample becomes required + read natively) and Stage 3 (reframed to propose-then-refine); example dialog updated.
- `skills/docutray/SKILL.md` — §6 Custom Types, step 3 leads with reading the sample. Must stay ≤ 500 lines.
- `openspec/specs/docutray-skill/spec.md` — new requirement (added via this change's delta on sync).
- Markdown-only; no code, build, or runtime impact.
