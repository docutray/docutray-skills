## Context

See `proposal.md` — Why. The constraints that shape the approach:

- **`SKILL.md` has a hard 500-line cap** (spec requirement *"SKILL.md line cap"*) and currently sits at 351 lines. Conversion-spec material — two shapes, four column fields, three flags, the create/update asymmetry, the silent-drop caveat — is more than the root file can absorb at full depth.
- **The existing references tree is domain-organized** (spec requirement *"References tree organized by domain"*): `setup/`, `platform/`, `advanced/`. Conversion-spec depth has to land somewhere in that shape, not beside it.
- **Conversion-spec knowledge straddles two existing files.** Inspecting a spec belongs to `platform/types.md` (read-only operations); setting one belongs to `advanced/custom-types-workflow.md` (create/update). The *format* of a spec belongs to neither.
- **The CLI is the canonical interface** in this skill; SDK/REST are parity notes. The upstream source of truth is `@docutray/cli@0.4.0` ([docutray-cli#36](https://github.com/docutray/docutray-cli/pull/36)) and SDK `docutray@0.1.5` ([docutray-node#24](https://github.com/docutray/docutray-node/pull/24)).
- **No live verification is available in this repo.** Unlike the `0.3.2` sweep, the documented behavior here is taken from the merged upstream PR (its help output, README, and OpenSpec requirements) rather than from a CLI run against a real org.

## Goals / Non-Goals

**Goals:**

- One place an agent can read to learn what a conversion spec *is* and how to write one, reachable from both the read path and the write path.
- Each existing file gains only what belongs to its own domain — no duplicated format tables that can drift apart.
- The three flags, the create/update asymmetry, and the silent-drop caveat are discoverable from `SKILL.md` without opening a reference.

**Non-Goals:**

- Teaching tray export end-to-end (how the exported CSV/Excel is produced or consumed downstream). The skill documents the *mapping*, not the export product.
- Documenting the API-side validation rules for a spec. The CLI validates only that the value is an object with `columns` or `sheets` and lets the API reject the rest; the skill mirrors that boundary rather than duplicating rules that would drift.
- Full JSONPath tutorial content. Enough syntax to write ordinary column paths against a known schema, no more.
- Re-verifying every unrelated `0.2.1` / `0.3.2` version marker in the tree. Only markers on files this change touches are refreshed.

## Decisions

### 1. Conversion-spec depth lives in a new `references/advanced/conversion-spec.md`

The format (both shapes, column fields, `jsonPath` authoring, worked examples), the full flag semantics, and the SDK/REST parity notes go in one new file under `advanced/`, alongside `custom-types-workflow.md` and `schema-design.md`.

*Alternatives considered:* (a) **Split across `platform/types.md` and `advanced/custom-types-workflow.md`** — rejected: the format table would have to be duplicated or arbitrarily assigned to one of them, and an agent reading only the create path would miss the inspect path. (b) **Fold into `custom-types-workflow.md`** — rejected: that file is a conversational playbook for designing a type from a sample document; a reference table on export-column mapping does not fit its shape, and it is already 342 lines. (c) **`SKILL.md` only** — rejected on the line cap and on progressive disclosure.

Each existing file then gets its domain slice plus a pointer: `platform/types.md` documents `conversionSpec` in the response shape and the `Export spec` line; `custom-types-workflow.md` adds the flags to its `create`/`update` tables and the round-trip step; `schema-design.md` gets a closing pointer that the schema being designed is what `jsonPath` selects from.

### 2. `SKILL.md` gets a compact subsection under §6, not a new top-level section

Conversion spec is part of the document-type lifecycle, not a peer of Convert/Identify/Types/Steps. It lands as a short block in §6 (Custom Types) covering the three flags, one example of each shape, the asymmetry in one sentence, and the silent-drop warning — with the `>` **Depth** pointer the file already uses. §4 (Types) gains only the response-shape sentence and the `Export spec` line, since §4 is explicitly read-only.

The out-of-scope line at the end of §6 drops `conversionSpec` and keeps `dslRules` / `validationRules` / pipeline design.

*Alternative considered:* a new §7 "Export spec". Rejected — it would renumber sections 7 and 8 and imply the spec is a standalone workflow rather than a field on a type.

### 3. Document the create/update asymmetry explicitly, as a rule with a reason

The single most surprising behavior is that `create --schema export.json` carries the spec and `update --schema export.json` does not. Both mentions state the reason inline ("an update only touches the fields you name") rather than cross-referencing, because an agent reading the update path may never read the create path.

*Alternative considered:* documenting it once in the new reference file. Rejected — the asymmetry is a footgun at the point of use, not a detail to look up.

### 4. Mirror the CLI's minimal validation instead of teaching spec validity

The skill documents the shape check the CLI performs (object with `columns` or `sheets`) and states that everything beyond it is the API's call, so a bad spec surfaces as an API error. This keeps the skill from asserting validation rules it cannot verify and that would drift as the API evolves — the same rationale the upstream CLI change used for not duplicating `validateConversionSpec`.

### 5. Raise the CLI floor to `0.4.0` only on the files this change touches

`SKILL.md`'s Technical Reference moves to `0.4.0`, as do the "verified against" lines on `platform/types.md` and `advanced/custom-types-workflow.md` (the latter is stale at `0.2.1` and this change edits its flag tables anyway). `convert.md`, `steps.md`, `cli.md`, and `identify.md` keep their current markers — this change does not re-verify them, and bumping a marker without re-verifying makes the claim less true, not more.

The `login --oauth` floor stays phrased as `>= 0.3.2` where it appears: that is a statement about when the feature landed, not about what was verified.

*Alternative considered:* a repo-wide bump to `0.4.0`. Rejected on the above; a separate verification sweep can do it honestly.

### 6. State provenance rather than implying live verification

The new reference file opens by naming its source as `@docutray/cli@0.4.0` help output and the upstream PR, and directs the reader to `docutray types create --help` to confirm — matching how other reference files invite confirmation, but without claiming an org-verified run that did not happen here.

### 7. Skill version `1.2.0`

New documented capability, no retraction of existing guidance — a minor bump under the repo's SemVer convention (`CHANGELOG.md` header). `metadata.version` in `SKILL.md` frontmatter and the `CHANGELOG.md` entry move together, as in `1.1.0`.

## Risks / Trade-offs

- **The documented behavior is not verified against a live org.** → Provenance is stated explicitly (Decision 6), every flag table is reproduced from `0.4.0` help output rather than paraphrased, and readers are pointed at `--help`. A follow-up verification pass against a real org can promote the wording.
- **A fourth reference file adds a navigation hop.** → Mitigated by pointers from all three places an agent would plausibly start (`SKILL.md` §6, `platform/types.md`, `advanced/custom-types-workflow.md`), and by keeping the flags themselves in `SKILL.md` so the common case needs no hop.
- **The silent-drop caveat depends on the API deployment, which the skill cannot detect.** → Documented as a verification step (`types get` after write) rather than a precondition the agent can check, plus a troubleshooting row so it is findable from the symptom.
- **`SKILL.md` grows toward the 500-line cap.** → The §6 block is budgeted at ~30 lines (351 → ~385), leaving headroom; depth is displaced to the reference file by design.
- **Column-field details (`type: formula`, `formula`) come from the SDK's TypeScript definitions, not from CLI docs.** → Documented as optional fields with the SDK as the named source; the skill does not claim formula columns are exercised by any CLI example.
