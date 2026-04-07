## Purpose

Defines requirements for the docutray-setup skill content — context detection, integration paths, authentication, verification, and reference documentation.

## Requirements

### Requirement: Context detection recommends correct integration path
The skill SHALL instruct agents to detect the project type by checking for marker files and recommend the appropriate integration path.

#### Scenario: Python project detected
- **WHEN** the project contains `pyproject.toml` or `requirements.txt`
- **THEN** the skill SHALL recommend the Python SDK path (`pip install docutray`, requires Python 3.10+)

#### Scenario: Node.js/TypeScript project detected
- **WHEN** the project contains `package.json` or `tsconfig.json`
- **THEN** the skill SHALL recommend the Node SDK path (`npm install docutray`, requires Node.js 20+)

#### Scenario: Other language project detected
- **WHEN** the project contains neither Python nor Node.js marker files
- **THEN** the skill SHALL recommend the REST API path with `Authorization: Bearer` header

#### Scenario: Agent direct interaction
- **WHEN** the agent is working outside a specific project context or needs CLI tooling
- **THEN** the skill SHALL recommend the CLI path (`npm install -g @docutray/cli` or `npx @docutray/cli`)

### Requirement: API key creation instructions included for all paths
The skill SHALL include instructions for creating an API key via the dashboard for all integration paths.

#### Scenario: API key creation steps
- **WHEN** an agent follows any integration path
- **THEN** the instructions SHALL direct users to app.docutray.com > Account > API Keys to create a key

### Requirement: Authentication configuration for each path
The skill SHALL document authentication configuration for each integration path.

#### Scenario: CLI authentication
- **WHEN** following the CLI path
- **THEN** the skill SHALL document env var `DOCUTRAY_API_KEY` (priority 1) and `docutray login` writing to `~/.config/docutray/config.json` (priority 2)

#### Scenario: Python SDK authentication
- **WHEN** following the Python SDK path
- **THEN** the skill SHALL document `Client(api_key=...)` constructor parameter and env var `DOCUTRAY_API_KEY`

#### Scenario: Node SDK authentication
- **WHEN** following the Node SDK path
- **THEN** the skill SHALL document `new DocuTray({ apiKey: ... })` constructor parameter and env var `DOCUTRAY_API_KEY`

#### Scenario: REST API authentication
- **WHEN** following the REST API path
- **THEN** the skill SHALL document `Authorization: Bearer <key>` header

### Requirement: Verification step for each path
The skill SHALL include a verification step to confirm the API key works for each integration path.

#### Scenario: CLI verification
- **WHEN** CLI setup is complete
- **THEN** the skill SHALL instruct running `docutray status` and checking the `authenticated` field

#### Scenario: Python SDK verification
- **WHEN** Python SDK setup is complete
- **THEN** the skill SHALL instruct running `client.types.list()` and confirming a successful response

#### Scenario: Node SDK verification
- **WHEN** Node SDK setup is complete
- **THEN** the skill SHALL instruct running `await client.types.list()` and confirming a successful response

#### Scenario: REST API verification
- **WHEN** REST API setup is complete
- **THEN** the skill SHALL instruct running `curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" https://app.docutray.com/api/types`

### Requirement: Environment variable is primary auth method
The skill SHALL recommend `DOCUTRAY_API_KEY` environment variable as the primary authentication method across all paths.

#### Scenario: Auth method priority
- **WHEN** the skill presents authentication options
- **THEN** `DOCUTRAY_API_KEY` env var SHALL be listed first as the recommended approach, with path-specific alternatives as secondary

### Requirement: Staging environment support documented
The skill SHALL document how to use the staging environment for each integration path.

#### Scenario: Staging configuration
- **WHEN** a user needs to use the staging environment
- **THEN** the skill SHALL document `--base-url https://staging.docutray.com` for CLI and equivalent base URL config for SDKs and REST API

### Requirement: SKILL.md line count under 500
The SKILL.md file SHALL stay under 500 lines, with detailed documentation in the `references/` subdirectory.

#### Scenario: Line count check
- **WHEN** the `skills/docutray-setup/SKILL.md` file line count is measured
- **THEN** it SHALL be under 500 lines

### Requirement: Reference documents for each integration path
The skill SHALL include dedicated reference files for detailed per-path documentation.

#### Scenario: Reference files exist
- **WHEN** the `skills/docutray-setup/references/` directory is listed
- **THEN** it SHALL contain `python-sdk-setup.md`, `node-sdk-setup.md`, `rest-api-setup.md`, and `cli-setup.md`

### Requirement: Progressive disclosure pattern
The SKILL.md SHALL present essential information first and reference detailed docs for depth.

#### Scenario: Skill structure
- **WHEN** an agent reads the SKILL.md
- **THEN** it SHALL find concise setup instructions for each path in the main file, with `@references/<file>.md` pointers to detailed documentation
