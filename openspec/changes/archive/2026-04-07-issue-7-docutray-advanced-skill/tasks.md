## 1. SKILL.md — Core Content

- [x] 1.1 Rewrite SKILL.md frontmatter and introduction (replace placeholder, keep description with trigger phrases)
- [x] 1.2 Write "Document Type Workflow" section — decision tree: check existing types (`types list`, `identify`) → confirm create vs modify
- [x] 1.3 Write "Creating Document Types" section — progressive interaction flow (name/code → main fields → additional fields → tabular data → prompt hints → review → execute `types create`)
- [x] 1.4 Write "Schema Design" section — JSON schema best practices (required+nullable, descriptive descriptions, date/enum, arrays for tabular data) with cross-reference to schema-design-reference.md
- [x] 1.5 Write "Modifying Document Types" section — `types get` to retrieve current, `types update` CLI command, workflow for changes
- [x] 1.6 Write "Prompt Hints" section — promptHints and identifyPromptHints usage with examples (date formats, decimal separators, locale conventions)
- [x] 1.7 Write "Multi-Document Files" section — handling files with multiple document types
- [x] 1.8 Verify SKILL.md is under 500 lines and YAML frontmatter parses correctly

## 2. Reference Files

- [x] 2.1 Create `references/schema-design-reference.md` — detailed JSON schema patterns: field types (string, number, date, enum), nullable/required combinations, array/object nesting, complex examples
- [x] 2.2 Create `references/document-type-workflow-reference.md` — detailed decision tree, step-by-step progressive disclosure flow, multi-document handling details, example agent-user interactions

## 3. Cleanup

- [x] 3.1 Remove `.gitkeep` from `skills/docutray-advanced/references/`
- [x] 3.2 Verify all cross-references use `@references/filename.md` pattern
