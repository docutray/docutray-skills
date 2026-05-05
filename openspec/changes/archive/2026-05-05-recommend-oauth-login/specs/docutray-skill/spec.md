## MODIFIED Requirements

### Requirement: Documented commands match the live CLI
Every `docutray` command, subcommand, flag, and argument shown in `skills/docutray/SKILL.md` and any file under `skills/docutray/references/` SHALL match the help output of `docutray <command> --help` for `@docutray/cli/0.3.0` or later.

#### Scenario: Convert flags are real
- **WHEN** the convert section in `SKILL.md` or `references/platform/convert.md` is read
- **THEN** the documented flags SHALL be a subset of `{-t, --type, --async, --json, --metadata, --timeout, --webhook-url}` plus the positional `SOURCE` argument; `--output` and `--format` SHALL NOT appear on `convert`

#### Scenario: Save-to-file uses shell redirection
- **WHEN** an example shows saving convert output to a file
- **THEN** it SHALL use shell redirection (e.g. `> result.json`) rather than a non-existent `--output` flag

#### Scenario: Identify flags are real
- **WHEN** the identify section is read
- **THEN** the documented flags SHALL be a subset of `{--async, --json, --types}`

#### Scenario: Types subcommands are real
- **WHEN** the types section is read
- **THEN** the documented subcommands SHALL be a subset of `{list, get, export, create, update}`; `view` and `delete` SHALL NOT appear

#### Scenario: Login non-interactive forms documented
- **WHEN** the setup section or `references/setup/cli.md` documents `docutray login`
- **THEN** it SHALL warn that the bare `docutray login` form requires a TTY and SHALL document at least one non-interactive alternative drawn from: `docutray login --oauth`, `docutray login --api-key <key>`, the positional `docutray login <key>`, or the `DOCUTRAY_API_KEY` env var

#### Scenario: OAuth is the recommended agent path
- **WHEN** the setup section in `SKILL.md` and the Authentication section in `references/setup/cli.md` document agent or non-interactive login
- **THEN** they SHALL present `docutray login --oauth` first as the recommended path for AI coding agents, with a brief rationale that the API key never enters the agent's conversation context (the CLI prints the auth URL to stderr, opens the browser, waits for the callback, writes the key to `~/.config/docutray/config.json`, and returns a JSON success payload on stdout whose `apiKey` field is masked)

#### Scenario: OAuth flags documented
- **WHEN** `docutray login --oauth` is documented
- **THEN** the documentation SHALL also document the related flags `--no-browser` (skip auto-opening the browser) and `--timeout=<seconds>` (default 180), and SHALL note the stdout/stderr split (success JSON on stdout, auth URL and progress on stderr)
