## 1. Update the detailed playbook (custom-types-workflow.md)

- [x] 1.1 Stage 1: make the example document **required** (not "if available"); instruct the agent to read it with its native file/vision tool to understand structure and content before any schema work.
- [x] 1.2 Stage 3: reframe from "ask the user to enumerate 3–5 fields" to "agent proposes the fields/structure it detected from the document → user confirms/adjusts".
- [x] 1.3 Add the no-sample escape hatch: warn the schema is tentative and validate later; allow fallback to verbal description without hard-blocking.
- [x] 1.4 Update the example agent–user dialog to show read-first → propose → refine.

## 2. Update the canonical path (SKILL.md §6)

- [x] 2.1 Rewrite step 3 ("Gather progressively") to lead with requesting + reading the sample, then propose-then-refine.
- [x] 2.2 Keep the escape-hatch note brief; defer detail to the reference file.

## 3. Consistency & validation

- [x] 3.1 Cross-check wording between SKILL.md §6 and custom-types-workflow.md.
- [x] 3.2 Confirm SKILL.md stays ≤ 500 lines.
- [x] 3.3 Run `openspec validate require-and-read-example-document --strict`.
