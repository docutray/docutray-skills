## 1. New skill skeleton

- [x] 1.1 Create `skills/docutray/SKILL.md` with frontmatter `name: docutray` and the description from the proposal
- [x] 1.2 Create empty directory tree `skills/docutray/references/{setup,platform,advanced}/`
- [x] 1.3 Write root SKILL.md sections (When to use, Setup, Convert, Identify, Types, Steps, Custom Types, Troubleshooting, Technical Reference) with CLI as canonical example
- [x] 1.4 Verify root SKILL.md is ≤ 500 lines (`wc -l`)

## 2. References — setup/

- [x] 2.1 Move `skills/docutray-setup/references/cli-setup.md` → `skills/docutray/references/setup/cli.md` and add the non-interactive `docutray login` caveat (real flag forms: `--api-key`, positional, `DOCUTRAY_API_KEY`, `--base-url`)
- [x] 2.2 Move `skills/docutray-setup/references/python-sdk-setup.md` → `skills/docutray/references/setup/python.md`
- [x] 2.3 Move `skills/docutray-setup/references/node-sdk-setup.md` → `skills/docutray/references/setup/node.md`
- [x] 2.4 Move `skills/docutray-setup/references/rest-api-setup.md` → `skills/docutray/references/setup/rest.md`
- [x] 2.5 Extract Troubleshooting content from `skills/docutray-setup/SKILL.md §8` into `skills/docutray/references/setup/troubleshooting.md`

## 3. References — platform/

- [x] 3.1 Move `skills/docutray-platform/references/convert-reference.md` → `skills/docutray/references/platform/convert.md`. Apply corrections: remove `--output`/`--format`; document real flags (`-t/--type` required, `--async`, `--json`, `--metadata`, `--timeout` default 300, `--webhook-url`); replace fabricated response shape with schema-driven `{data:{...}}`; show shell redirection for save-to-file
- [x] 3.2 Extract Identify content from `skills/docutray-platform/SKILL.md §2` into `skills/docutray/references/platform/identify.md`. Document real flags: `--types <csv>`, `--async`, `--json`
- [x] 3.3 Move `skills/docutray-platform/references/types-reference.md` → `skills/docutray/references/platform/types.md`. Purge any references to non-existent `types view` and `types delete`. Verify documented flags for `types create/update/list/get/export` against `--help`. Note: `types export` does support `-o/--output` and `--force`
- [x] 3.4 Move `skills/docutray-platform/references/steps-reference.md` → `skills/docutray/references/platform/steps.md`. Verify against `steps run` and `steps status` `--help`: `steps run` flags = `--no-wait`, `--json`, `--metadata`, `--webhook-url`; `steps status` flag = `--json`

## 4. References — advanced/

- [x] 4.1 Move `skills/docutray-advanced/references/document-type-workflow-reference.md` → `skills/docutray/references/advanced/custom-types-workflow.md`. Verify documented `types create/update` flags against `--help` (real flags: `--name`, `--code`, `--description`, `--schema`, `--prompt-hints`, `--identify-hints`, `--conversion-mode`, `--keep-ordering`, `--publish`/`--draft`)
- [x] 4.2 Move `skills/docutray-advanced/references/schema-design-reference.md` → `skills/docutray/references/advanced/schema-design.md`

## 5. Drift sweep

- [x] 5.1 `grep -RE 'convert.*--output|convert.*--format|types view|types delete|"success".*true|"document_type"\s*:|"fields"\s*:\s*{' skills/docutray/` returns nothing
- [x] 5.2 `grep -E 'docutray login' skills/docutray/SKILL.md skills/docutray/references/setup/cli.md` shows the non-interactive caveat
- [x] 5.3 Smoke-test every CLI invocation in `skills/docutray/SKILL.md` by running its `--help` form; every flag must appear

## 6. Old skills + repo metadata

- [x] 6.1 Delete `skills/docutray-setup/`
- [x] 6.2 Delete `skills/docutray-platform/`
- [x] 6.3 Delete `skills/docutray-advanced/`
- [x] 6.4 Update `README.md` skill table to a single `docutray` row
- [x] 6.5 Update `CLAUDE.md` "Repository Structure" section to describe the unified `skills/docutray/` layout

## 7. OpenSpec deltas

- [x] 7.1 Write `specs/docutray-skill/spec.md` (ADDED Requirements covering root SKILL.md frontmatter, sections, line cap, references layout, CLI-canonical examples, verified-CLI correctness)
- [x] 7.2 Write `specs/repo-structure/spec.md` (MODIFIED Requirements: single skill directory + README single-skill table)
- [x] 7.3 Write REMOVED Requirements deltas for: `docutray-setup-skill`, `docutray-setup-content`, `docutray-platform-skill`, `docutray-platform-content`, `docutray-advanced-skill`, `document-type-workflow`, `schema-design`, `prompt-hints`
- [x] 7.4 `openspec validate consolidate-into-single-skill --strict` passes

## 8. Land

- [x] 8.1 `find skills -name SKILL.md` returns exactly `skills/docutray/SKILL.md`
- [ ] 8.2 Open PR; on merge, archive change with `openspec archive consolidate-into-single-skill`
