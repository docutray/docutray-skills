## Why

The `docutray-setup` skill exists as a skeleton with TODO placeholders. AI agents that install this skill get no actionable instructions — they cannot help users set up DocuTray. This blocks adoption of all three skills since setup is the prerequisite for platform and advanced usage. Closes #3.

## What Changes

- Replace SKILL.md skeleton with complete setup instructions covering context detection, API key creation, four integration paths (Python SDK, Node SDK, REST API, CLI), verification, and troubleshooting
- Add four reference documents in `references/` for detailed per-path documentation (`python-sdk-setup.md`, `node-sdk-setup.md`, `rest-api-setup.md`, `cli-setup.md`)
- Update SKILL.md frontmatter description if needed for better trigger phrase coverage

## Capabilities

### New Capabilities

- `docutray-setup-content`: Complete setup instructions for the docutray-setup skill, including context detection logic, integration path selection, authentication configuration, and verification steps across all supported SDKs and CLI

### Modified Capabilities

- `docutray-setup-skill`: The existing skeleton spec requires updating to reflect that the skill now contains full content (not just a skeleton), with requirements for context detection, multi-path setup, verification, and reference documents

## Impact

- `skills/docutray-setup/SKILL.md` — full rewrite replacing skeleton
- `skills/docutray-setup/references/` — four new reference files
- No code dependencies, no build changes — content-only change
