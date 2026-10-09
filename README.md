# docutray-skills

Agent skills for [DocuTray CLI](https://docs.docutray.com/docs/cli) — AI-powered document processing from your coding agent.

## Install

Pick **one** of the two options. Both install the same `docutray` skill, so using both loads it twice.

### Claude Code: plugin (skill + MCP server)

The repository is a Claude Code plugin that bundles the `docutray` skill with the [DocuTray remote MCP server](https://docs.docutray.com/docs/mcp) (`https://app.docutray.com/api/mcp`):

```bash
claude plugin marketplace add docutray/docutray-skills
claude plugin install docutray@docutray
```

Then run `/mcp`, select `plugin:docutray:docutray` and sign in with your DocuTray account. No API key is needed: the server uses OAuth and you pick the organization on the consent screen.

If you previously ran `npx skills add docutray/docutray-skills` in Claude Code, remove that copy of the skill. Likewise, if you added the server by hand (`claude mcp add ... docutray`), remove it with `claude mcp remove docutray` before installing the plugin, or the same server will be registered twice.

### Other agents: skill only

```bash
npx skills add docutray/docutray-skills
```

This installs the skill for AI coding agents like Cursor, Windsurf, Codex, and [40+ others](https://agentskills.io). It does not include the MCP server.

## What's included

| Skill | Description |
|-------|-------------|
| `docutray` | One unified skill: install/auth, convert, identify, types (list/get/export), steps, and custom document type creation. CLI is the canonical example; Python/Node/REST equivalents and depth content live in `references/{setup,platform,advanced}/`. |

## What is DocuTray?

DocuTray converts documents (PDFs, images, scanned files) into structured JSON data using AI-powered extraction schemas called **document types**. The CLI is designed for automation pipelines and AI agents — all output is JSON with clear exit codes.

Key commands:

- `docutray convert` — Extract structured data from a document
- `docutray identify` — Detect document type automatically
- `docutray types list/get/export` — Manage extraction schemas
- `docutray steps run/status` — Execute processing pipelines

Learn more at [docutray.com](https://docutray.com) · [CLI docs](https://docs.docutray.com/docs/cli)

## Development

This repository uses [OpenSpec](https://github.com/openspec-dev/openspec) for change management and follows the [Agent Skills specification](https://agentskills.io).

## License

MIT
