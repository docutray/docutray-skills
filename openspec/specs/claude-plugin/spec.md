# claude-plugin Specification

## Purpose
The repository is a Claude Code / OpenAI plugin bundle that ships the `docutray` skill together with the DocuTray remote MCP server.

## Requirements

### Requirement: Repository is a valid plugin bundle
The repository root SHALL contain `.claude-plugin/plugin.json` with `name` `docutray`, a semantic `version` equal to the latest release in `CHANGELOG.md` and to the skill's `metadata.version`, a `description`, an `author`, `homepage`, `repository` and `license`. `claude plugin validate .` SHALL pass without errors.

#### Scenario: Validation
- **WHEN** a maintainer runs `claude plugin validate .` at the repository root
- **THEN** the command SHALL exit with status 0

### Requirement: Plugin wires the remote MCP server
The plugin SHALL declare, inline under `mcpServers` in `.claude-plugin/plugin.json`, one server named `docutray` of type `http` with URL `https://app.docutray.com/api/mcp`, and SHALL NOT embed API keys or other credentials; authentication happens through the server's OAuth flow. The repository SHALL NOT have a root `.mcp.json`, which Claude Code would also load as project configuration for contributors of this repository.

#### Scenario: Install registers the server
- **GIVEN** a user installs the plugin in Claude Code
- **WHEN** they run `claude mcp list`
- **THEN** the server SHALL appear as `plugin:docutray:docutray` with URL `https://app.docutray.com/api/mcp`

### Requirement: Plugin ships the docutray skill
The plugin SHALL expose the existing `skills/docutray` skill without duplicating it, so `npx skills add docutray/docutray-skills` and the plugin install deliver the same skill. The skill SHALL route agents to the DocuTray MCP tools when they are available, and to the CLI, SDKs or REST API otherwise.

#### Scenario: Single source for the skill
- **WHEN** the plugin is installed
- **THEN** the `docutray` skill SHALL be loaded from `skills/docutray/SKILL.md`
