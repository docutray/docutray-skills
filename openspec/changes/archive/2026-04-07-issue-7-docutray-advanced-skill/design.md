## Context

The `docutray-advanced` skill is a placeholder with TODO comments. The `docutray-platform` skill (issue #5) established the pattern: SKILL.md with YAML frontmatter, progressive disclosure, `@references/` for detailed docs, under 500 lines. The advanced skill needs to follow this pattern but with a different focus — interactive agent workflow rather than API reference.

The target audience is coding agents (Claude Code, Cursor, Codex) that need to guide human users through creating custom document types. This is fundamentally an interaction design problem: the skill instructs the agent on how to ask questions, in what order, and what CLI commands to run.

## Goals / Non-Goals

**Goals:**
- Teach agents the complete document type creation/update workflow via CLI
- Provide JSON schema design guidelines optimized for LLM-based extraction
- Document promptHints and identifyPromptHints usage
- Keep SKILL.md under 500 lines using references for detail
- Support progressive disclosure: don't dump all questions at once

**Non-Goals:**
- Validation rules (`dslRules`, `validationRules`) — out of scope for v1
- Conversion spec (`conversionSpec`) and `conversionMode` details
- SDK/REST API examples (this skill is CLI-workflow-focused, not API-reference)
- Pipeline/steps creation (separate concern)

## Decisions

### Decision 1: Workflow-centric SKILL.md, not API-reference

The platform skill is organized by command (convert, identify, types, steps) with multi-language examples. The advanced skill will be organized by workflow steps (check existing → create → design schema → configure hints) since the value is in the interaction pattern, not the CLI syntax.

**Alternative considered:** Mirror platform's command-centric structure. Rejected because the advanced skill's core value is guiding agents through a multi-step interactive process, not documenting CLI flags.

### Decision 2: Two reference files

- `schema-design-reference.md` — JSON schema patterns, field types, nullable/required combos, array/object examples, enum usage. This is dense reference material that would bloat SKILL.md.
- `document-type-workflow-reference.md` — Detailed decision tree, step-by-step flow, multi-document handling, example dialogues. Provides depth for agents that need more context.

**Alternative considered:** Single reference file. Rejected because schema design and workflow flow are distinct concerns with different access patterns.

### Decision 3: CLI-only examples in SKILL.md

Unlike the platform skill which includes Python SDK, Node SDK, and REST API examples, this skill focuses exclusively on CLI commands. The workflow is agent-driven and CLI is the natural interface for agents executing commands on behalf of users.

### Decision 4: Progressive disclosure interaction pattern

The skill instructs agents to ask questions in stages:
1. Document analysis and existing type check
2. Name and code
3. Main fields
4. Additional fields and tabular data
5. Prompt hints
6. Schema validation with user
7. CLI execution

This prevents overwhelming users with all configuration options at once.

## Risks / Trade-offs

- [SKILL.md line budget] The 500-line limit requires careful editing. → Mitigation: Offload JSON schema examples and detailed workflows to references.
- [CLI command accuracy] The `types create` and `types update` flags must match the actual CLI. → Mitigation: Reference the issue's documented CLI commands which are already implemented.
- [Multi-agent compatibility] Different agents have different interaction capabilities. → Mitigation: Use simple ask/respond patterns that work in any agent context; avoid agent-specific features.
