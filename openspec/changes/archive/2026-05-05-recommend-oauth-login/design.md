## Context

Two findings from a captured agent session and the `consolidate-into-single-skill` change set the stage:

1. The skill currently lists three non-interactive login alternatives — `--api-key <key>`, positional `<key>`, and `DOCUTRAY_API_KEY` — none of which keep the API key out of the agent's context. The least-bad workaround documented is "ask the user to run `! docutray login` in their own terminal," which is friction.
2. `@docutray/cli/0.3.0` (installed locally; will publish next) adds `docutray login --oauth`. Verified end-to-end during this session:

   ```
   $ docutray login --oauth
   # stderr (in order):
   #   Open this URL to authorize: https://app.docutray.com/api/auth/oauth2/authorize?...
   #   Opening browser for authentication...
   #   Waiting for authentication (timeout: 180s)...
   #   Exchanging authorization code...
   #   Fetching organizations...
   #   Multiple organizations found, using: <org-name>
   #   Creating API key...
   # stdout (after success):
   #   { "message": "Login successful",
   #     "apiKey": "<first-4>****<last-4>",
   #     "organizationId": "...",
   #     "organizationName": "...",
   #     "configPath": "/Users/<user>/.config/docutray/config.json" }
   # exit 0
   ```

   `docutray status` afterwards reports `authenticated: true, source: config` and includes `organizationId` / `organizationName`. The masked `apiKey` in both `login --oauth` and `status` JSON means the agent never sees the unmasked key.

The change is documentation-only: relocate `--oauth` to the top of the CLI auth section, document the observed behavior, and tighten the spec requirement.

## Goals / Non-Goals

**Goals:**
- Make `docutray login --oauth` the first path an agent reaches for in `SKILL.md` §1.3.
- Document `--no-browser` and `--timeout=<seconds>` in the right depth (CLI reference and troubleshooting).
- Note the precise stdout-vs-stderr split so agents can pipe stdout without losing the URL.
- Tighten the spec to require `--oauth` in the docs, not merely allow it.

**Non-Goals:**
- Removing the legacy `--api-key` / positional / env-var paths from the skill — they remain as fallbacks for browser-less environments.
- Documenting CLI-internal details (PKCE parameters, callback port behavior) beyond what an agent operator needs.
- Changing any other section of the skill.

## Decisions

### Decision 1: Recommend `--oauth` first; keep fallbacks

The new §1.3 ordering is:

1. `docutray login --oauth` — recommended for agents (key never seen).
2. `DOCUTRAY_API_KEY` env var — recommended when a browser isn't available (CI, headless server).
3. `docutray login --api-key <key>` / positional `<key>` — when the user already has a key and wants to install it via the config file.
4. Bare `docutray login` (interactive) — only documented as the user's manual fallback (`! docutray login` in Claude Code).

**Alternative considered:** make env var first, OAuth second. Rejected — env var requires the agent or user to handle a literal secret string (paste, export), which is the problem we're solving.

### Decision 2: Document the stdout/stderr split explicitly

The skill needs to call out: success JSON goes to **stdout**; the auth URL and progress go to **stderr**. Agents that pipe stdout through `jq` (a common pattern documented in `references/platform/convert.md`) get a clean payload without the URL contaminating it. This is also why `--oauth` is agent-friendly: the URL isn't lost and isn't mixed in.

### Decision 3: Document the masked `apiKey` field, not the raw key

The success JSON's `apiKey` field is always masked (`<first-4>****<last-4>`). The unmasked key only ever lives at `~/.config/docutray/config.json`, which the CLI reads on subsequent calls. Documenting this explicitly reassures readers that the agent cannot exfiltrate the key from the JSON it sees.

### Decision 4: Note the multi-org auto-selection

When the OAuth-authenticated user has multiple organizations, the current CLI auto-selects the first one and prints `Multiple organizations found, using: <name>` to stderr. There is no flag exposed to pick a different one. We document this as a known limitation, with the workaround "log in via the dashboard with the desired org and use the resulting key with `--api-key`." This is a candidate for a follow-up CLI feature (`--org <id>` on `login --oauth`) but is out of scope here.

### Decision 5: Spec change is MODIFIED, not ADDED

The existing requirement `Documented commands match the live CLI` already has a scenario `Login non-interactive forms documented` listing acceptable alternatives. We MODIFY that requirement so:
- The list of acceptable alternatives includes `docutray login --oauth`.
- A second scenario REQUIRES `--oauth` be documented as the recommended path for agents (not merely permitted).

This avoids creating a new sibling requirement just to add one bullet.

## Risks / Trade-offs

- [Premature rollout — CLI not yet published] The new docs reference flags that only exist in the locally-built CLI. → Mitigation: the `[Unreleased]` CHANGELOG entry includes the explicit `>= 0.3.0` floor; the SKILL.md text mentions the version gate near the OAuth recommendation. The skill is not republished to `npx skills add` until the CLI lands on npm.
- [Agent-friendly URL extraction] Agents that scrape stderr for the URL need a stable prefix. → Mitigation: document the `Open this URL to authorize:` prefix as a stable contract; flag any change to the CLI team if they later vary it.
- [Multi-org auto-select surprise] An agent's user belonging to multiple DocuTray orgs may end up authenticated against the wrong one. → Mitigation: document the behavior + workaround. Track upstream feature request for `--org`.
- [Browserless environments] `--oauth` is unusable in headless CI. → Mitigation: keep the env-var path documented as the explicit alternative; note this in the troubleshooting table.

## Migration Plan

1. Land this change on `main` via the OPSX flow.
2. Open a PR for review.
3. After merge, archive (`openspec archive recommend-oauth-login -y`) so the spec change syncs.
4. Once `@docutray/cli/0.3.0` is published to npm, this skill repo is ready to be re-published via `npx skills add` consumers' next pull.
5. Rollback: revert the merge commit; the previous SKILL.md guidance (paste key / env var) returns intact.

## Open Questions

- Is port `9876` a fixed callback port, or did this run happen to bind there? If fixed, document it explicitly so users know which port to keep free / which port to allow through firewalls. Defer until we re-verify after a few more runs.
- Should `--no-browser` be tested with a deliberate timeout to capture exit-code semantics? Defer; the help text already specifies timeout default and the success path is verified.
