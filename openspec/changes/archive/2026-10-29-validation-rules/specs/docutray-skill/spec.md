## MODIFIED Requirements

### Requirement: Documented commands match the live CLI
Every `docutray` command, subcommand, flag, and argument shown in `skills/docutray/SKILL.md` and any file under `skills/docutray/references/` SHALL match the help output of `docutray <command> --help` for `@docutray/cli/0.6.0` or later.

#### Scenario: Convert flags are real
- **WHEN** the convert section in `SKILL.md` or `references/platform/convert.md` is read
- **THEN** the documented flags SHALL be a subset of `{-t, --type, --async, --json, --metadata, --timeout, --webhook-url}` plus the positional `SOURCE` argument; `--output` and `--format` SHALL NOT appear on `convert`

#### Scenario: Save-to-file uses shell redirection
- **WHEN** an example shows saving convert output to a file
- **THEN** it SHALL use shell redirection (e.g. `> result.json`) rather than a non-existent `--output` flag

#### Scenario: Identify flags are real
- **WHEN** the identify section is read
- **THEN** the documented flags SHALL be a subset of `{--async, --json, --types}`

#### Scenario: Identify response shape is consistent across surfaces
- **WHEN** an `identify` response is shown anywhere in the skill, whether CLI or REST
- **THEN** it SHALL have no `data` wrapper, `document_type` SHALL be an object with `code`, `name`, and `confidence`, and each entry of `alternatives` SHALL carry the same three fields

#### Scenario: Types subcommands are real
- **WHEN** the types section is read
- **THEN** the documented subcommands SHALL be a subset of `{list, get, export, create, update, rules get, rules set, rules test}`; `view` and `delete` SHALL NOT appear

#### Scenario: Types create and update flags are real
- **WHEN** the `types create` and `types update` flag tables are read
- **THEN** the documented flags SHALL be a subset of the `0.4.0` help output — for `create`: `{--code, --conversion-mode, --conversion-spec, --description, --draft, --identify-hints, --json, --keep-ordering, --name, --prompt-hints, --publish, --schema}`; for `update`: the same set plus `--no-conversion-spec` and minus `--code` (which is positional and cannot be changed)

#### Scenario: Login non-interactive forms documented
- **WHEN** the setup section or `references/setup/cli.md` documents `docutray login`
- **THEN** it SHALL warn that the bare `docutray login` form requires a TTY and SHALL document at least one non-interactive alternative drawn from: `docutray login --oauth`, `docutray login --api-key <key>`, the positional `docutray login <key>`, or the `DOCUTRAY_API_KEY` env var

#### Scenario: OAuth is the recommended agent path
- **WHEN** the setup section in `SKILL.md` and the Authentication section in `references/setup/cli.md` document agent or non-interactive login
- **THEN** they SHALL present `docutray login --oauth` first as the recommended path for AI coding agents, with a brief rationale that the API key never enters the agent's conversation context (the CLI prints the auth URL to stderr, opens the browser, waits for the callback, writes the key to `~/.config/docutray/config.json`, and returns a JSON success payload on stdout whose `apiKey` field is masked)

#### Scenario: OAuth flags documented
- **WHEN** `docutray login --oauth` is documented
- **THEN** the documentation SHALL also document the related flags `--no-browser` (skip auto-opening the browser) and `--timeout=<seconds>` (default 180), and SHALL note the stdout/stderr split (success JSON on stdout, auth URL and progress on stderr)

#### Scenario: Documented CLI floor is consistent
- **WHEN** the Technical Reference table in `SKILL.md` and the "verified against" lines in `references/` files that document `types` behavior are read
- **THEN** they SHALL name `@docutray/cli/0.6.0` and SHALL NOT claim verification against a version older than the behavior they describe


## ADDED Requirements

### Requirement: DSL validation workflow
The skill SHALL teach DSL authoring against the actual schema, dry-run testing before saving through CLI or MCP, read-back verification, ownership restrictions, and CLI test exit codes. Detailed SDK and REST equivalents SHALL live in a linked reference.

#### Scenario: Proposed rules
- **WHEN** an agent changes rules
- **THEN** it reads existing rules, tests proposed text on valid and invalid samples without saving, reviews issues, saves the intended text and reads back

#### Scenario: CLI syntax
- **WHEN** rules commands are documented
- **THEN** set uses positional input or --clear, test uses --data and optional --rules, and exits are 0 valid, 1 invalid, 2 error

### Requirement: Informational conversion validation
The skill SHALL distinguish conversion success from data validity and describe convert status plus validation outcomes, skipped validation and system failure.

#### Scenario: Unknown validity
- **WHEN** validation is null, absent or status:error
- **THEN** the agent does not infer data validity, and recognizes null as skipped and status:error as incomplete checks or missing records

#### Scenario: Invalid data
- **WHEN** conversion succeeds with validation.valid false
- **THEN** the skill explains that conversion remains successful and recommends an explicit validity gate when needed
