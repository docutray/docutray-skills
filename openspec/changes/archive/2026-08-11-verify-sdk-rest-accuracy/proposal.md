## Why

A code review of the conversion-spec work surfaced one bad SDK call site. Checking the rest against the installed packages found that **every SDK snippet in the skill was broken** — 19/19 documented call patterns raise `TypeError` / `AttributeError` against `docutray` Node 0.1.5 and Python 0.2.1. Running the CLI against a live organization then found more: `/api/types` does not exist, the REST per-type endpoint rejects a `codeType`, the multipart field is `image` rather than `file`, and org-owned document types are silently namespaced so the documented custom-type flow (`types create --code X` → `convert -t X`) returns 404.

These were fixed ad hoc, outside this workflow. That leaves two gaps this change closes:

- **No spec covers SDK or REST accuracy.** The `docutray-skill` capability has *"Documented commands match the live CLI"* — the CLI and only the CLI. The SDK and REST sections were never constrained, which is exactly why they drifted unnoticed across at least three releases while the CLI content stayed correct. Nothing prevents the same drift tomorrow.
- **The fixes are unattested.** They were verified in a terminal session; nothing in the repo records what was checked, against which versions, or how to re-check it.

## What Changes

- **Add a requirement that SDK snippets match the installed SDK surface**, with a verification method that is actually runnable (install the package, probe the documented call paths) rather than "verify against the SDK source" — the unresolved hedge that let the drift persist.
- **Add a requirement that REST paths, multipart field names, and response envelopes match the live API**, covering the three concrete errors found: the non-existent `/api/types`, the id-vs-code argument on the per-type endpoint, and the `data` envelope being present on document-type reads but absent on `identify`.
- **Add a requirement that the org-prefix behavior is documented wherever a created code is later reused**, since it silently breaks the primary custom-type workflow.
- **Correct the REST `identify` example**, currently flagged as unverified and contradicting the CLI. Now verified against the live API: no `data` envelope, `document_type` is an object, and the file part is `image`.
- **Record that `--conversion-spec` beats a spec embedded in `--schema`**, now verified live rather than from source only, and that `jsonSchema` still comes from `--schema` in the same call.
- **Document two API rough edges observed while verifying**: creating a type whose code already exists returns a generic `500 Error processing request` rather than a conflict status, and `types create` output is not reliably single-object JSON — both matter to an agent scripting the create flow.
- **Record the verification provenance** — which surfaces were checked, against which versions, and how — so the next sweep can be a re-run rather than a rediscovery.

## Capabilities

### New Capabilities
<!-- none — this constrains existing skill content -->

### Modified Capabilities
- `docutray-skill`: gains requirements that (a) SDK snippets match the installed SDK surface with a runnable verification method, (b) REST paths, multipart field names, and response envelopes match the live API, and (c) the organization code prefix is documented wherever a created code is reused downstream. The existing *"Documented commands match the live CLI"* requirement gains a scenario pinning the verified `identify` response shape across both CLI and REST.

## Impact

- `skills/docutray/references/setup/rest.md` — corrected `identify` example (envelope, `document_type` shape, `image` field part), and the `file` → `image` correction on the convert example.
- `skills/docutray/references/advanced/conversion-spec.md` — precedence stated as live-verified; the duplicate-code `500` noted where the create flow is scripted.
- `skills/docutray/references/advanced/custom-types-workflow.md` — duplicate-code failure and the unreliable create-output shape noted alongside the existing org-prefix guidance.
- `skills/docutray/references/setup/troubleshooting.md` — rows for the duplicate-code `500` and the `image` field part.
- `openspec/specs/docutray-skill/spec.md` — updated on sync.
- `CHANGELOG.md` — the `identify` and multipart corrections move from *flagged* to *fixed*.
- Markdown and YAML only; no code, build, or runtime impact.
