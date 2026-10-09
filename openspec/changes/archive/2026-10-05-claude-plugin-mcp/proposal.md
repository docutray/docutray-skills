## Why

DocuTray now runs a remote MCP server (`https://app.docutray.com/api/mcp`). The Claude and ChatGPT directories accept plugin bundles from a GitHub repository, and Anthropic recommends publishing a plugin next to the MCP connector. This repository already holds the `docutray` skill, so turning it into a plugin that also wires the MCP server gives agents both the tools and the workflow knowledge in one install (docutray/docutray#1067).

## What Changes

- Add `.claude-plugin/plugin.json` so the repository root is a Claude Code plugin; the existing `skills/docutray` is discovered automatically.
- Declare the remote server over HTTP with OAuth (no API key) inline in `plugin.json`.
- Add `.claude-plugin/marketplace.json` so users can install with `claude plugin marketplace add docutray/docutray-skills`.
- Document the plugin install in the README and the CHANGELOG.

## Capabilities

### New Capabilities
- `claude-plugin`: the repository is a valid Claude Code / OpenAI plugin bundle that ships the `docutray` skill and the DocuTray MCP server.

### Modified Capabilities
<!-- None. `npx skills add` keeps working unchanged. -->

## Impact

- New files: `.claude-plugin/plugin.json` (with the MCP server inline under `mcpServers`) and `.claude-plugin/marketplace.json`. No root `.mcp.json`, which would also act as project configuration for this repository.
- README and CHANGELOG.
- `skills/docutray/SKILL.md`: `metadata.version` aligned with the release (1.3.0), and routing to the DocuTray MCP tools when they are available, with the CLI/API as the alternative.
