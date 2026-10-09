## Context

Claude Code discovers `skills/` at the plugin root, and OpenAI converts `.claude-plugin/plugin.json` into its own manifest, so one bundle serves both directories.

## Decisions

- **Plugin root = repository root.** Reuses `skills/docutray` with no copy. `claude plugin validate` warns that the root `CLAUDE.md` is not loaded as plugin context; that file is guidance for contributors to this repository, not plugin content, so the warning is expected and `--strict` is not used.
- **Remote server only.** `plugin.json` declares the hosted server inline (`mcpServers`), not a root `.mcp.json`, which would also configure this repository for its contributors; there is no local MCP process to install and no API key to configure.
- **Marketplace in the same repo.** `.claude-plugin/marketplace.json` lists the plugin with `source: "./"`, so `claude plugin marketplace add docutray/docutray-skills` works without a separate repository.

## Non-Goals

Changing the skill content, adding commands or agents, or publishing to the directories (done from the DocuTray directory accounts).
