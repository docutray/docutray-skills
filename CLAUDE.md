# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent skills repository for [DocuTray CLI](https://docs.docutray.com/cli) — AI-powered document processing. Skills teach AI coding agents (Claude Code, Cursor, Codex, etc.) how to use `docutray-cli` commands. Published via `npx skills add docutray/docutray-skills` following the [Agent Skills specification](https://agentskills.io).

## Repository Structure

- `skills/` — Contains the three distributable skills, each with a `SKILL.md` (YAML frontmatter + Markdown) and optional `references/` directory for detailed docs
  - `docutray-setup/` — Installation, authentication, troubleshooting
  - `docutray-platform/` — Core CLI commands: convert, identify, types, steps
  - `docutray-advanced/` — Custom document types, schemas, processing pipelines
- `openspec/` — Change management via [OpenSpec](https://github.com/openspec-dev/openspec): `config.yaml`, `specs/`, `changes/`

## Key Conventions

- Skills are `SKILL.md` files with YAML frontmatter (`name`, `description`) followed by Markdown instructions
- Keep each `SKILL.md` under 500 lines; use `references/` subdirectory for detailed documentation
- Use progressive disclosure pattern (essentials first, details in references)
- All content is Markdown + YAML — no build system, no tests, no compiled code
- Changes are managed through OpenSpec workflow (use `/opsx:new`, `/opsx:continue`, etc.)
