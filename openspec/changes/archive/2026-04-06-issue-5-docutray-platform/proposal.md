## Why

The `docutray-platform` skill skeleton exists but contains only TODO placeholders. AI agents cannot use DocuTray's core document processing commands (convert, identify, types, steps) without concrete instructions. This blocks the primary value proposition of the skills repository. Closes #5.

## What Changes

- Populate `skills/docutray-platform/SKILL.md` with complete instructions for all four core CLI commands
- Add CLI, Python SDK, Node SDK, and REST API usage examples for each command
- Add error handling documentation for common errors across all commands
- Add common patterns section (identify → convert chaining, batch processing)
- Create three reference files for detailed documentation that exceeds SKILL.md's 500-line limit

## Capabilities

### New Capabilities
- `docutray-platform-content`: Complete instructional content for the four core CLI commands (convert, identify, types, steps) with multi-SDK examples, error handling, and common workflow patterns

### Modified Capabilities
- `docutray-platform-skill`: The existing skeleton spec requires updating to reflect that the skill now has full content and reference documents, not just a skeleton

## Impact

- `skills/docutray-platform/SKILL.md` — replace skeleton TODOs with complete content
- `skills/docutray-platform/references/convert-reference.md` — new file
- `skills/docutray-platform/references/types-reference.md` — new file
- `skills/docutray-platform/references/steps-reference.md` — new file
- Must be consistent with `docutray-setup` skill patterns (auth, base URL, response format)
