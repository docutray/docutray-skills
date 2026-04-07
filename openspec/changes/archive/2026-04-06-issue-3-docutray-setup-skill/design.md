## Context

The `docutray-setup` skill is a skeleton with TODO placeholders. It needs complete content so AI agents can guide users through DocuTray setup. The skill must work across multiple AI agents (Claude Code, Cursor, Codex, Windsurf) and support four integration paths: Python SDK, Node SDK, REST API, and CLI.

The 500-line limit on SKILL.md means detailed per-path documentation must live in `references/`.

## Goals / Non-Goals

**Goals:**
- Provide context detection logic so agents recommend the right integration path
- Cover all four integration paths with install, auth, and verification steps
- Keep SKILL.md scannable with progressive disclosure to references
- Ensure all code snippets are syntactically correct and copy-pasteable

**Non-Goals:**
- Teaching agents how to use DocuTray commands (that's the `docutray-platform` skill)
- Covering custom document types or schemas (that's `docutray-advanced`)
- Agent-specific syntax or workflows — content must be agent-agnostic

## Decisions

### 1. SKILL.md as routing layer, references for depth

SKILL.md contains context detection logic and concise per-path setup instructions (install → auth → verify). Each path gets a dedicated reference file with detailed examples, error handling, and advanced configuration.

**Why:** The 500-line limit forces this split. Agents that need quick setup get it from SKILL.md; agents that need deep help follow references.

**Alternative:** Single large SKILL.md with everything — rejected due to line limit and cognitive overload.

### 2. Context detection via file markers

Agents detect the project type by checking for marker files:
- `pyproject.toml` or `requirements.txt` → Python SDK path
- `package.json` or `tsconfig.json` → Node SDK path
- Neither → REST API or CLI path

**Why:** These are the most reliable, language-agnostic signals. Every Python/Node project has these files.

**Alternative:** Ask the user what language they use — rejected because agents should minimize questions when they can infer.

### 3. Environment variable as primary auth method

`DOCUTRAY_API_KEY` env var is recommended first across all paths, with path-specific alternatives as secondary options.

**Why:** Env vars work everywhere (CI/CD, local dev, all SDKs, CLI), avoid hardcoding secrets, and are the most portable approach.

### 4. Four reference files matching integration paths

One reference per path: `python-sdk-setup.md`, `node-sdk-setup.md`, `rest-api-setup.md`, `cli-setup.md`.

**Why:** Clean 1:1 mapping between SKILL.md sections and reference files. Agents can load only the relevant reference.

## Risks / Trade-offs

- [API details may drift] → Reference files document specific API key prefix (`dt_live_`), URLs, and SDK constructors. If these change, multiple files need updates. Mitigation: centralize key details in SKILL.md and reference from there.
- [500-line limit constrains SKILL.md] → May need to be very terse in the main file. Mitigation: progressive disclosure pattern is well-suited for this.
- [Staging environment is secondary concern] → Documented but not prominent. Mitigation: included in references, mentioned briefly in SKILL.md.
