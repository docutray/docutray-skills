# Proposal

## Why

The skill tells agents that `docutray login --oauth` auto-selects the user's first organization and that the only way to pick another one is to create an API key in the dashboard and run `docutray login --api-key`. Since `@docutray/cli@0.5.0` ([docutray-cli#42](https://github.com/docutray/docutray-cli/pull/42), server side [docutray#1095](https://github.com/docutray/docutray/pull/1095)) that is no longer true: the user chooses the organization on the DocuTray consent screen, and the server binds the token and the API key to it. An agent following the current text sends users with several organizations through an unnecessary manual detour, and the documented stderr line no longer exists.

## What Changes

- `SKILL.md` §8 and `references/setup/troubleshooting.md`: the "OAuth picked the wrong organization" row now says to choose the organization on the consent screen (re-run `docutray login --oauth`), and to upgrade the CLI if it is older than 0.5.0. The dashboard API key stays as the fallback for headless setups.
- `references/setup/cli.md`: the observed `login --oauth` output is updated for 0.5.0 (no `Multiple organizations found` line; the consent screen lists the user's organizations with the active one preselected). The agent note explains the consent-screen choice, the `Organization was not chosen in the browser; using: …` line (server that did not bind the token), and the `OAuth error (invalid_scope)` failure against a deployment without the `docutray:cli` scope.
- Version bump to `1.3.1` in `CHANGELOG.md`, `SKILL.md` `metadata.version` and `.claude-plugin/plugin.json`.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `docutray-skill`: adds a requirement that the OAuth organization choice is documented as happening on the consent screen.

## Impact

- `skills/docutray/SKILL.md`, `skills/docutray/references/setup/cli.md`, `skills/docutray/references/setup/troubleshooting.md`, `CHANGELOG.md`, `.claude-plugin/plugin.json`.
- Consumers: agents using the skill (Claude Code, Cursor, Codex, …) and the docs site, which mirrors these files through `docutray/scripts/generate-skills-docs.sh`.
