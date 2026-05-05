# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent skills repository for [DocuTray CLI](https://docs.docutray.com/cli) — AI-powered document processing. Skills teach AI coding agents (Claude Code, Cursor, Codex, etc.) how to use `docutray-cli` commands. Published via `npx skills add docutray/docutray-skills` following the [Agent Skills specification](https://agentskills.io).

## Repository Structure

- `skills/docutray/` — The single distributable skill.
  - `SKILL.md` — root skill file (YAML frontmatter + Markdown), CLI as canonical example, ≤ 500 lines.
  - `references/setup/{cli,python,node,rest,troubleshooting}.md` — install/auth depth per integration path.
  - `references/platform/{convert,identify,types,steps}.md` — depth for the four core operations.
  - `references/advanced/{custom-types-workflow,schema-design}.md` — custom document types and JSON Schema design.
- `openspec/` — Change management via [OpenSpec](https://github.com/openspec-dev/openspec): `config.yaml`, `specs/`, `changes/`.

## Key Conventions

- Skills are `SKILL.md` files with YAML frontmatter (`name`, `description`) followed by Markdown instructions
- Keep each `SKILL.md` under 500 lines; use `references/` subdirectory for detailed documentation
- Use progressive disclosure pattern (essentials first, details in references)
- All content is Markdown + YAML — no build system, no tests, no compiled code
- Changes are managed through OpenSpec workflow (use `/opsx:new`, `/opsx:continue`, etc.)
