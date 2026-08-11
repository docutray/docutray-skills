## Context

See `proposal.md` — Why. What shapes the approach:

- **The corrective edits are already merged into the branch.** This change is not "go fix the docs" — it is "encode the constraint that keeps them fixed, and close the two items left unverified." Its tasks are therefore weighted toward the spec and the residual gaps, not a rewrite.
- **The failure was silent and long-lived.** The CLI content of this skill has been verified repeatedly (`0.2.1`, `0.3.2`, now `0.4.0`) and held up. The SDK and REST content never was, and drifted through at least three releases without a single reader noticing — because a wrong snippet in a reference file produces no error until an agent runs it in someone else's project.
- **The hedge was the tell.** The broken sections carried phrases like *"verify SDK attribute names against the SDK source"* and *"the exact REST per-type endpoint shape is not re-verified here."* Those read as diligence but function as permanent deferral: they mark a known gap without a mechanism to close it.
- **READMEs are not authoritative.** The Node README's `steps.runAsync('step_id', {...})` contradicts its own source (`runAsync(params)` with `stepId` inside). Verification has to hit the installed artifact.
- **What was actually verified in this session:** both SDKs installed from npm/PyPI and probed (19 old patterns fail, 20 new pass); the CLI read paths and all write paths for `conversionSpec` against a live org on `0.4.0`; the REST document-type and `identify` endpoints against the live API. Not exercised: REST `convert` (the `image` field name is confirmed for `identify` and shared in SDK source, but not separately re-run), and the `steps` endpoints.

## Goals / Non-Goals

**Goals:**

- A requirement whose verification is a **procedure someone can run**, not a judgment call — install the package, probe the documented paths, compare.
- Constraints stated per surface (SDK, REST, CLI) because their failure modes and verification methods genuinely differ.
- The residual unverified items either closed or explicitly labeled, with no silent hedges left behind.

**Non-Goals:**

- Re-verifying the CLI content. It was checked this session and held; the CLI requirement is extended only with the `identify` shape scenario.
- Adding automated CI checks. This repo has no build or test system by design (`CLAUDE.md`); a requirement that presumes CI would be unenforceable here. The verification is a documented manual procedure.
- Covering the `knowledgeBases` resource, which the skill does not document and this change does not add.
- Documenting every API rough edge encountered. Only the two that change what an agent should write (`500` on duplicate code, non-single-object create output) are in scope.

## Decisions

### 1. Three requirements split by surface, not one "documentation is accurate"

SDK, REST, and CLI fail differently and are checked differently: the SDK by installing and probing, REST by curling the live API, the CLI by `--help` plus a live run. A single merged requirement would have to state the union of verification methods and would let a reader satisfy it by checking whichever surface is convenient.

*Alternative considered:* one requirement with per-surface scenarios. Rejected — the surfaces have different version anchors (`docutray` Node/Python versions vs `@docutray/cli`), and merging them makes the version claim ambiguous.

### 2. The verification method is written into the requirement text

The requirement says *install the package and probe the documented call paths*, and explicitly rules out reading the source or the README. This is unusual for a spec — it constrains method, not just outcome — but it is the load-bearing part: the previous state of the world was a documented intention to verify against the source, and it produced 19 broken snippets. Naming the README as non-authoritative is included because it actively misled during this session.

### 3. Version floors are named per package, and per-file provenance is required

Each reference file with SDK snippets states which SDK versions it was checked against, mirroring the existing CLI "verified against" convention. Without it, a future reader cannot tell whether a snippet is stale or the package moved.

*Alternative considered:* a single global version table in `SKILL.md`. Rejected — it drifts from the files it describes, which is the same failure this change addresses.

### 4. Envelope correctness is specified per endpoint, explicitly non-uniform

The live API is inconsistent: document-type reads wrap in `data`, `identify` does not. `rest.md` previously opened by asserting a uniform envelope and then showed a wrong `identify` example consistent with that assertion — the generalization caused the error. The requirement therefore forbids presenting one envelope as universal.

### 5. Org-prefix guidance attaches to the create-then-use flow, not to a glossary

The prefix only bites when a code is created and later reused. Stating it once in a concept section would not reach the agent writing `convert -t "$CODE"`. The requirement is phrased as an obligation on every create-then-use site, plus a findable troubleshooting row keyed to the 404 symptom.

### 6. The duplicate-code `500` is documented despite being an API defect

`types create` with an existing code returns `500 Error processing request` — no conflict status, no mention of the code. An agent scripting creation will hit it and cannot diagnose it from the response. Documenting the symptom is cheap and correct even though the right long-term fix belongs in the API, not the skill.

### 7. Leave REST `convert` marked rather than claim it

The `image` field name is confirmed by the live `identify` rejection of `file` and by the SDK's shared `UPLOAD_FIELD_NAME` constant, so the `convert` example is corrected to `image` — but the change records that `convert` itself was not re-run, rather than folding it into the verified set. Same discipline that made the earlier `0.4.0` marker decisions honest.

## Risks / Trade-offs

- **A method-prescribing requirement can age.** If the SDKs later ship a typed test harness, "install and probe" becomes the clumsy way. → The requirement names the *outcome* (snippets valid against the installed package) first and the method as the means; a future change can swap the method without touching the outcome.
- **Per-file version markers multiply the places to update.** → They are already the convention for CLI content, and the alternative (a central table) drifts worse.
- **Verification is manual and needs credentials plus quota.** Nobody will re-run it casually. → The change records exactly what was checked and how, so the next sweep is a re-run rather than a rediscovery; and the SDK half needs no credentials at all — installing and probing is free and catches the largest error class.
- **Two temporary document types remain in the verification org** (`roberto_zz_tmp_convspec_verify`, `roberto_zz_tmp_precedence`), both drafts. The CLI has no delete subcommand, so cleanup is a dashboard action outside this repo. → Noted in tasks as a handoff item, not a repo change.
