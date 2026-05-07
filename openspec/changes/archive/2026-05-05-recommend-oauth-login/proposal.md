## Why

`@docutray/cli/0.3.0` adds a non-interactive OAuth login flow (`docutray login --oauth`) that lets an AI coding agent drive the full authentication ceremony without ever seeing the API key. Today's skill predates the feature: it instructs agents to either ask the user to paste a key in chat (insecure — key ends up in conversation history) or to run interactive login in their own terminal as a manual step. The skill should now recommend `--oauth` as the canonical agent path, with `DOCUTRAY_API_KEY` and the `--api-key` / positional forms as fallbacks for environments where opening a browser isn't possible.

## What Changes

- Restructure `skills/docutray/SKILL.md` §1.3 (Authenticate) so `docutray login --oauth` is presented first, framed as "the recommended path for agents — your API key never enters the conversation."
- Document `--oauth`, `--no-browser`, and `--timeout=<seconds>` flags. Quote the verified `--help` output and observed stdout/stderr behavior (JSON success payload on stdout, progress + auth URL on stderr, exit 0 on success, default 180s timeout).
- Update `skills/docutray/references/setup/cli.md` Authentication section with the same restructuring and an "observed behavior" block (port `9876` callback, multi-org auto-selection, `apiKey` masked as `<first-4>****<last-4>`).
- Update `skills/docutray/references/setup/troubleshooting.md` to extend the existing "Non-interactive mode requires --api-key…" row to mention `--oauth`, and add OAuth-specific rows (timeout, port-bind, callback error).
- Update SKILL.md §8 Troubleshooting row for the same error.
- Add a `[Unreleased]` entry to `CHANGELOG.md` documenting the new recommendation and the `@docutray/cli >= 0.3.0` requirement.
- Modify the existing `Documented commands match the live CLI` requirement on the `docutray-skill` capability so the "login non-interactive" scenario recognizes `--oauth` and *requires* it be documented as the agent-recommended path.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `docutray-skill`: tighten the login-documentation requirement to recognize and require `docutray login --oauth` for agents, in addition to the existing `--api-key` / positional / env-var alternatives.

## Impact

- `skills/docutray/SKILL.md` — section §1.3 restructured; §1 frontmatter description tweaked; §8 troubleshooting row extended.
- `skills/docutray/references/setup/cli.md` — Authentication section rewritten.
- `skills/docutray/references/setup/troubleshooting.md` — login row extended; new OAuth rows added.
- `CHANGELOG.md` — `[Unreleased]` entry added.
- `openspec/specs/docutray-skill/spec.md` — one requirement modified (after archive).
- No code changes; no breaking changes for downstream consumers (the old non-interactive forms still work). Effective only once `@docutray/cli/0.3.0` is published.
