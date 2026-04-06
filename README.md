# docutray-skills

Agent skills for [DocuTray CLI](https://docs.docutray.com/cli) — AI-powered document processing from your coding agent.

## Install

```bash
npx skills add docutray/docutray-skills
```

This installs skills for AI coding agents like Claude Code, Cursor, Windsurf, Codex, and [40+ others](https://agentskills.io).

## What's included

| Skill | Description |
|-------|-------------|
| `docutray-setup` | Install, configure, and authenticate docutray-cli and SDKs |
| `docutray-platform` | Core platform usage: convert, identify, types, and steps commands |
| `docutray-advanced` | Advanced features: document type creation, schema design, and processing pipelines |

## What is DocuTray?

DocuTray converts documents (PDFs, images, scanned files) into structured JSON data using AI-powered extraction schemas called **document types**. The CLI is designed for automation pipelines and AI agents — all output is JSON with clear exit codes.

Key commands:

- `docutray convert` — Extract structured data from a document
- `docutray identify` — Detect document type automatically
- `docutray types list/get/export` — Manage extraction schemas
- `docutray steps run/status` — Execute processing pipelines

Learn more at [docutray.com](https://docutray.com) · [CLI docs](https://docs.docutray.com/cli)

## Development

This repository uses [OpenSpec](https://github.com/openspec-dev/openspec) for change management and follows the [Agent Skills specification](https://agentskills.io).

## License

MIT
