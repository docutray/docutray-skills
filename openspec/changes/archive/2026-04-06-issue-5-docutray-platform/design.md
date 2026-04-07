## Context

The `docutray-platform` skill skeleton has valid frontmatter and section headers but no instructional content. The `docutray-setup` skill (merged in PR #4) establishes the pattern: progressive disclosure via SKILL.md (essentials) + `references/` (details), with CLI/Python/Node/REST examples for each feature.

## Goals / Non-Goals

**Goals:**
- Provide complete instructions for all four core CLI commands (convert, identify, types, steps)
- Follow the same multi-SDK pattern established in `docutray-setup`
- Keep SKILL.md under 500 lines using progressive disclosure
- Create reference files for advanced details per command area

**Non-Goals:**
- Custom document type creation (belongs in `docutray-advanced` skill)
- Authentication setup (covered by `docutray-setup` skill)
- SDK installation instructions (covered by `docutray-setup` skill)

## Decisions

### 1. SKILL.md structure follows command-first organization
Each command gets its own section with essential usage. Common patterns (identify → convert chaining) get a dedicated section. Error handling is consolidated at the end.

**Rationale:** Mirrors the CLI's own command structure, making it intuitive. Agents can jump to the relevant section based on the user's intent.

### 2. Three reference files instead of four
`convert-reference.md`, `types-reference.md`, `steps-reference.md`. No separate `identify-reference.md` because identify is a simple single-purpose command — its full documentation fits within SKILL.md.

**Rationale:** Avoids creating a reference file with only a few lines of additional content.

### 3. Consistent example format: CLI → Python → Node → REST
Every command shows all four integration paths in the same order, matching `docutray-setup`'s precedent. REST examples use `curl` with the established base URL pattern (`https://app.docutray.com/api`).

**Rationale:** Agents can reliably find the integration path matching their project context.

### 4. Error handling consolidated at end of SKILL.md
Rather than duplicating error tables per command, a single error handling section covers common errors across all commands with a reference to the REST API setup reference for the full error code table.

**Rationale:** Saves ~60 lines in SKILL.md. Most errors (auth, rate limiting, file format) are shared across commands.

## Risks / Trade-offs

- [SKILL.md approaching 500-line limit] → Aggressive use of progressive disclosure; only essential examples in SKILL.md, advanced options in references
- [Consistency drift with docutray-setup] → Cross-check base URLs, response formats, and auth patterns during implementation
