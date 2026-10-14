# Tasks

## 1. Skill text

- [x] 1.1 Rewrite the wrong-organization row in `SKILL.md` §8 and `references/setup/troubleshooting.md` (consent screen, upgrade to ≥ 0.5.0, dashboard key only as headless fallback); verify with `grep -rn "auto-selects the first" skills` returning nothing
- [x] 1.2 Update the observed `login --oauth` output and agent notes in `references/setup/cli.md` for 0.5.0 (no `Multiple organizations found` line, consent-screen choice, `Organization was not chosen in the browser`, `OAuth error (invalid_scope)`); verify the strings match `docutray-cli@0.5.0` `src/commands/login.ts` / `src/oauth.ts`
- [x] 1.3 Verify `SKILL.md` stays under 500 lines (`wc -l`)

## 2. Release

- [x] 2.1 Bump to `1.3.1` in `CHANGELOG.md`, `SKILL.md` `metadata.version` and `.claude-plugin/plugin.json`; verify with `scripts/check-versions.sh`

## Workflow follow-up

- Archive the change, open the PR, and after merge cut the `v1.3.1` release.
- In `docutray`: bump `vendor/docutray-skills` and `vendor/docutray-cli`, run `./scripts/generate-skills-docs.sh` and `./scripts/generate-cli-docs.sh`.
