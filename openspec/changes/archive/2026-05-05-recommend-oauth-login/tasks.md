## 1. SKILL.md

- [x] 1.1 Restructure `skills/docutray/SKILL.md` §1.3 to put `docutray login --oauth` first; keep `DOCUTRAY_API_KEY`, `--api-key` / positional, and bare `docutray login` as fallbacks
- [x] 1.2 Update the frontmatter `description` if needed to mention OAuth as the agent path
- [x] 1.3 Update the §8 troubleshooting row for `Non-interactive mode requires --api-key flag…` to mention `--oauth`

## 2. References

- [x] 2.1 Rewrite the Authentication section in `skills/docutray/references/setup/cli.md` — paste verified `--help` block, document `--oauth`, `--no-browser`, `--timeout`; include the stdout/stderr behavior block (URL on stderr with `Open this URL to authorize:` prefix; success JSON on stdout; masked `apiKey`; exit 0)
- [x] 2.2 Note the multi-org auto-select behavior and the workaround
- [x] 2.3 Update `skills/docutray/references/setup/troubleshooting.md` — extend the "Non-interactive mode" row; add OAuth-specific rows (timeout, callback error, browser-open failure)

## 3. CHANGELOG

- [x] 3.1 Add `[Unreleased]` entry to `CHANGELOG.md` documenting the new `--oauth` recommendation and the `@docutray/cli >= 0.3.0` floor

## 4. Spec delta

- [x] 4.1 Write `specs/docutray-skill/spec.md` MODIFYING the existing `Documented commands match the live CLI` requirement so `--oauth` is recognized AND required as the agent-recommended login path
- [x] 4.2 `openspec validate recommend-oauth-login --strict` passes

## 5. Verification

- [x] 5.1 `grep -RE 'convert.*--output|convert.*--format|types view|types delete|"success"\s*:\s*true|"fields"\s*:\s*\{' skills/docutray/` returns no matches (no regression on the previous correctness sweep)
- [x] 5.2 `wc -l skills/docutray/SKILL.md` ≤ 500
- [x] 5.3 `grep -E 'docutray login --oauth' skills/docutray/SKILL.md skills/docutray/references/setup/cli.md` shows the recommendation in both files
- [x] 5.4 End-to-end smoke (already captured): `docutray logout && docutray login --oauth && docutray status` round-trip prints expected JSON

## 6. Land

- [ ] 6.1 Open PR; on merge, archive change with `openspec archive recommend-oauth-login -y`
