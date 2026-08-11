## 1. Close the unverified REST items

- [x] 1.1 `references/setup/rest.md`: replace the flagged `identify` example with the live-verified shape — no `data` envelope, `document_type` as an object with `code`/`name`/`confidence`, `alternatives` entries carrying the same three fields — and delete the "unverified / contradicts the CLI" warning now that it is resolved.
- [x] 1.2 `references/setup/rest.md`: correct the multipart file part from `file` to `image` in the `identify` example, noting that a part named `file` is rejected with `Validation error` / `Image file is required`.
- [x] 1.3 `references/setup/rest.md`: correct the same `file` → `image` part in the `convert` example, and record that `convert` itself was not re-run — the field name is confirmed from the live `identify` rejection plus the SDK's shared upload constant (design Decision 7).
- [x] 1.4 `references/setup/rest.md`: document that `identify` requires a candidate list (`document_type_code_options`, JSON-encoded in multipart), matching the CLI's `--types` requirement.
- [x] 1.5 `references/setup/rest.md`: update the opening provenance line to state which endpoints are live-verified (document-type list/get, identify) and which are not (convert, steps, status).

## 2. Record the live-verified write behavior

- [x] 2.1 `references/advanced/conversion-spec.md`: state the `--conversion-spec` over embedded-`--schema` precedence as live-verified, adding that `jsonSchema` still comes from `--schema` in the same call.
- [x] 2.2 `references/advanced/conversion-spec.md`: note the `1 column` singular form alongside the existing plural examples, so a reader parsing the line does not assume a fixed suffix.
- [x] 2.3 `references/advanced/custom-types-workflow.md`: document that `types create` with an already-used code fails with a generic `500 Error processing request` that does not name the code, and that `types create` output is not reliably a single JSON object — read `.codeType` defensively when scripting.
- [x] 2.4 `references/setup/troubleshooting.md`: add rows for the duplicate-code `500` and for the `image` multipart part.

## 3. Per-file verification provenance

- [x] 3.1 `references/setup/node.md` and `references/setup/python.md`: state that snippets were verified by installing the package and probing the documented call paths, naming Node `0.1.5` / Python `0.2.1`.
- [x] 3.2 `references/platform/{convert,identify,steps,types}.md`: confirm each SDK provenance line names the same two versions, and that no file claims a verification it did not receive.
- [x] 3.3 `references/setup/rest.md`: name the live API and the date-free verification scope (which endpoints, which fields) rather than a bare "verified".

## 4. Release and verification

- [x] 4.1 `CHANGELOG.md`: move the REST `identify` item from *flagged as contradicting the CLI* to *corrected and live-verified*; add the `image` multipart correction, the duplicate-code `500`, and the live-verified precedence.
- [x] 4.2 Drift sweep: grep for `/api/types`, `client.types`, `file=@`, `docutray.exceptions`, `ConvertResult`, `DocumentTypeSchema` and confirm zero hits outside the intentional "do not do this" callouts.
- [x] 4.3 Re-run the SDK probe against both installed packages and confirm every documented call path still resolves; record the pass/fail counts in the change.
- [x] 4.4 Confirm `SKILL.md` is still ≤ 500 lines and `openspec validate --strict verify-sdk-rest-accuracy` passes.
- [x] 4.5 **Handoff (not a repo change):** the verification org holds two draft types, `roberto_zz_tmp_convspec_verify` and `roberto_zz_tmp_precedence`. The CLI has no delete subcommand — they must be removed from the dashboard by the account owner.
