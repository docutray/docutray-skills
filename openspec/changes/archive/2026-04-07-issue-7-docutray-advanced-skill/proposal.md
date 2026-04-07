## Why

The `docutray-advanced` skill is currently a placeholder with TODO comments. Users working with documents not covered by public types need to create custom document types with extraction schemas. Coding agents have no guidance on how to lead users through this interactive process — analyzing documents, checking existing types, designing JSON schemas, configuring prompt hints, and executing the CLI commands.

## What Changes

- Rewrite `skills/docutray-advanced/SKILL.md` from placeholder to complete document type configuration workflow (under 500 lines)
- Create `references/schema-design-reference.md` with detailed JSON schema patterns and field type examples
- Create `references/document-type-workflow-reference.md` with detailed decision tree and progressive disclosure steps
- Remove `.gitkeep` from references directory (replaced by real content)

## Capabilities

### New Capabilities
- `document-type-workflow`: Interactive workflow for creating and modifying custom document types — decision tree (identify existing vs create new), progressive field discovery, multi-document handling, and CLI command execution (`types create`, `types update`, `types list`, `types get`)
- `schema-design`: JSON schema best practices for document extraction — field types, nullable/required patterns, array/object nesting, enum usage, and LLM-friendly descriptions
- `prompt-hints`: Usage of `promptHints` and `identifyPromptHints` for document-wide extraction instructions (date formats, decimal separators, locale conventions)

### Modified Capabilities
- `docutray-advanced-skill`: Existing skeleton spec will be extended with requirements for complete content, workflow sections, and reference files

## Impact

- `skills/docutray-advanced/SKILL.md` — Full rewrite from placeholder
- `skills/docutray-advanced/references/` — Two new reference files, `.gitkeep` removed
- No code changes, no dependencies affected — content-only change
