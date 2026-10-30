## 1. Skill and references

- [x] 1.1 Update SKILL.md with CLI/MCP dry-run and conversion semantics; verify against CLI 0.6.0 and MCP source.
- [x] 1.2 Add validation-rules.md with authoring and SDK/REST examples; verify against monorepo guide and Node 0.2.0/Python 0.3.0 source.
- [x] 1.3 Update convert/types/custom workflow/setup references and release metadata; check internal links and synchronized versions.

## 2. Integration validation

- [x] 2.1 Validate skill, line cap, CLI help and OpenSpec deltas; review diff for unsupported claims and report inherited spec failures.

## Workflow follow-up

- Archive with spec synchronization and open a reviewable PR closing #19, linked to docutray/docutray#1111.

## Review evidence

- Astra adversarial review completed before PR creation; no outstanding findings after fixes for test-only exit codes and separate DSL restoration from exported types.
- Passed skill validator, release-version consistency, CLI 0.6.0 help comparison, internal Markdown links, diff whitespace and strict change validation.
- Existing main-spec strict warnings: three requirements exceed 500 characters. Purpose placeholder corrected in the touched skill spec.
- No live API writes or document conversions were performed.
