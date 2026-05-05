## Context

The repo currently ships three sibling skills (`docutray-setup`, `docutray-platform`, `docutray-advanced`), each with its own SKILL.md and `references/`. They were split along product-team boundaries (install vs core API vs custom types), but real agent sessions cross those boundaries within seconds. A captured session (`8db64bf3-6428-4662-acb9-be3fad251c29.jsonl`) shows the agent loading setup → platform back-to-back to do a basic invoice conversion, and surfaces three concrete documentation defects across two of the three skills:

1. `docutray convert` is documented with `--output` and `--format` flags that do not exist in `@docutray/cli/0.2.1`.
2. `docutray login` is documented as "interactive" with no warning that the CLI errors out (`Non-interactive mode requires --api-key flag`) when invoked from inside an agent shell.
3. The convert response shape is documented as `{success, data:{document_type, fields:{...}}}`; the real shape is `{data:{...schema-driven keys...}}`.

The CLI's `--help` output (captured at planning time) is the source of truth for this change. SKILL.md ≤ 500 lines is enforced by `CLAUDE.md`.

## Goals / Non-Goals

**Goals:**
- One skill (`docutray`) that any agent loads to do any docutray task end-to-end.
- Tight root SKILL.md (≤500 lines) with CLI as the canonical example. SDKs/REST in references.
- `references/` organized by domain (`setup/`, `platform/`, `advanced/`) so an agent can pull only the depth it needs.
- All commands and flags in the new tree match `docutray <cmd> --help` for `@docutray/cli/0.2.1`.
- Single OPSX change so the consolidation lands atomically.

**Non-Goals:**
- New skill content beyond what already exists in the three skills (the only writes are the relocation, the structural root SKILL.md, and the verified-CLI fixes).
- Validation rules (`dslRules`, `validationRules`) — still out of scope.
- Pipeline/steps creation — still out of scope (only `steps run`/`steps status` are documented).
- Rebuilding SDK examples from `--help` (Python/Node SDKs are not part of the captured CLI verification; SDK reference files are relocated as-is).
- Republishing to the skills registry. That is a follow-up.

## Decisions

### Decision 1: Single skill named `docutray`

The skill matches the CLI binary and npm package name. Frontmatter `name: docutray`, directory `skills/docutray/`.

**Alternatives considered:** `docutray-cli` (CLI-first naming), `docutray-skills` (whole-product naming). Rejected — `docutray` matches user mental model from `docutray --help` and is shortest.

### Decision 2: Nested references by domain (`setup/`, `platform/`, `advanced/`)

11 reference files split across three folders. Lets agents load only the slice they need (e.g. `setup/python.md` without pulling `platform/types.md`).

**Alternatives considered:** Flat with prefixes (`setup-cli.md`, `platform-convert.md`); flat without prefixes. Rejected — at 11 files, nesting is more navigable and folder names self-document the domain.

### Decision 3: CLI is the canonical example in root SKILL.md

The root SKILL.md shows one example per operation, in CLI form. SDK and REST equivalents live in references. Keeps the root small and aligns with the captured-session use case (CLI is what agents shell out to).

**Alternatives considered:** Quad-show every operation (CLI/Python/Node/REST) like the old platform SKILL.md did. Rejected — this is what blew the previous platform SKILL past 450 lines and made cross-language drift inevitable.

### Decision 4: Apply CLI corrections during the move, not after

The plan was to do consolidation first and corrections later. Combined here because every corrected line lives in a file we're already rewriting; doing it twice wastes work and risks inconsistency. The corrections set is fixed (table in implementation tasks) and based on `--help` output captured before this change began.

**Alternatives considered:** Two changes (structure first, correctness second). Rejected — would force re-editing the same files immediately. Reviewing the diff is still tractable: the corrections are localized and listed.

### Decision 5: Spec consolidation — drop 8, add 1, modify 1

The 8 existing capability specs (`docutray-setup-skill`, `docutray-setup-content`, `docutray-platform-skill`, `docutray-platform-content`, `docutray-advanced-skill`, `document-type-workflow`, `schema-design`, `prompt-hints`) are subsumed into a single new `docutray-skill` capability. `repo-structure` is modified to describe one skill. Specs are removed by emitting `## REMOVED Requirements` deltas listing each existing requirement; OpenSpec then prunes the capability on archive.

**Alternatives considered:** Keep capability specs and re-target them to the new skill. Rejected — the original split mirrored the skill split and no longer makes sense; collapsing to one capability matches the new physical layout.

## Risks / Trade-offs

- [SKILL.md exceeds 500-line cap] The combined source is ~1,036 lines of SKILL.md. → Mitigation: relocate all non-essential prose to references; root keeps one canonical example per operation and links out for depth. Verification step `wc -l` enforces.
- [Reference drift after relocation] Moving files preserves drift. → Mitigation: corrections table in the implementation tasks is the explicit punch list applied during the move; verification step greps for the broken patterns and fails if any survive.
- [Schema-driven response keys vary by org] Real convert response uses keys from the active schema (often Spanish on default DocuTray org schemas). → Mitigation: document the response as schema-driven (top-level `data` with arbitrary keys) and call out that example values are illustrative, not literal.
- [SDK reference files not re-verified against the SDKs] Only the CLI was captured. → Mitigation: scope is CLI-correctness; SDK files move as-is. A follow-up change can re-verify SDK references with the same methodology.
- [BREAKING change for downstream consumers] Anyone with installed skills will see three directories disappear. → Mitigation: the README, CLAUDE.md, and the next release note should call this out. Skills are not API-coupled to user code, so the blast radius is small.

## Migration Plan

1. Land this change on `main` via the OPSX flow.
2. Open a PR (auto-driven, single change). Reviewer compares old → new mapping table from this design doc.
3. After merge, archive the OPSX change so specs collapse to the new shape.
4. Tag and re-publish via `npx skills add docutray/docutray-skills` consumers' next pull.
5. Rollback: revert the merge commit; old skills directories return intact.

## Open Questions

- Should `references/setup/troubleshooting.md` be `setup/troubleshooting.md` (current plan) or `troubleshooting.md` at the top of `references/`? Defaulting to under `setup/` since most current troubleshooting content is auth-related; revisit if non-setup troubleshooting grows.
- Should the README link directly to `references/` files for navigability? Out of scope for this change; defer.
