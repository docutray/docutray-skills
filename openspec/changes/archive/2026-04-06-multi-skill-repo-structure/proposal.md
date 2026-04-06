## Why

DocuTray needs agent skills split by use case so agents load only what's relevant. A single monolithic skill forces agents to ingest setup, core usage, and advanced features together. Three focused skills enable progressive disclosure and faster context loading across Claude Code, Cursor, Codex, and other compatible agents.

Closes #1.

## What Changes

- Create `skills/` directory with three skill subdirectories
- Add skeleton `SKILL.md` files with valid frontmatter for each skill
- Add `references/` directories for future detailed documentation
- Update `README.md` to list all three skills with descriptions

## Capabilities

### New Capabilities

- `docutray-setup-skill`: Skill skeleton for CLI installation, SDK setup, and authentication
- `docutray-platform-skill`: Skill skeleton for core platform usage (convert, identify, types, steps)
- `docutray-advanced-skill`: Skill skeleton for advanced features (document type creation, schema design, pipelines)
- `repo-structure`: Directory layout and README following Agent Skills spec conventions

### Modified Capabilities

(none)

## Impact

- New `skills/` directory tree with three subdirectories
- Modified `README.md` with updated skill table
- No dependencies or breaking changes — this is the foundational structure
