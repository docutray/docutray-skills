## Context

The custom-type workflow lives in two markdown files: `skills/docutray/SKILL.md` (§6, the concise canonical path) and `skills/docutray/references/advanced/custom-types-workflow.md` (the detailed playbook with progressive-disclosure Stages 1–8 and an example dialog). Today both build the schema from the user's verbal field description; the sample document is optional and only used for `docutray identify`. This change makes reading a real sample the entry point. Markdown-only; no code or build.

## Goals / Non-Goals

**Goals:**
- Make requesting + reading an example document a required precondition to schema generation.
- Flip field-gathering to read-first: agent proposes detected fields, user refines.
- Keep the guidance portable across coding agents and keep `SKILL.md` ≤ 500 lines.

**Non-Goals:**
- Prescribing a specific agent tool or using `docutray convert`/`identify` as the document reader.
- Changing CLI flags, schema-design rules, or any other workflow stage beyond Stages 1/3.
- Hard-blocking schema creation when no sample exists.

## Decisions

- **Reading mechanism: agent's native file/vision capability**, phrased generically ("read the document with your file/vision tool"). Rationale: Claude Code's `Read` reads PDFs/images, and the issue explicitly asks for "the tools available in the agent coder." Alternative considered — route through `docutray convert/identify` — rejected as more indirect and because the agent reads the raw document better than a pre-extracted blob for *schema design*.
- **Mandatory with escape hatch.** Always ask for the sample; if absent, warn the schema is tentative and fall back to verbal description. Rationale: honors "siempre" without trapping users who are bootstrapping a brand-new type with no example yet.
- **Flow inversion in Stage 3.** Replace "list your 3–5 most important fields" with "I read the document and detected these fields — confirm or adjust." Rationale: accurate, lower-friction; the agent leads with a concrete draft.

## Risks / Trade-offs

- [Some agents lack native PDF/vision reading] → Generic phrasing degrades gracefully; the user can paste/describe content and the escape hatch covers the no-read case.
- [SKILL.md length creep] → Keep §6 edit to a short reordering of step 3, push detail into the reference file; re-check line count before PR.
- [Drift between SKILL.md and the reference] → Edit both in the same change and cross-check wording.
