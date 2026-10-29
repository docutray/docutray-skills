# Validation rules: author, test, save

Checked against CLI **0.6.0** (`83f8f1d`, released as 0.6.0), Node SDK **0.2.0**, Python SDK **0.3.0**, MCP tools and the monorepo validation guide. The API deployment must also support DSL rules. See the maintained [validation guide](https://docs.docutray.com/docs/guides/validation) and [operator reference](https://docs.docutray.com/docs/guides/validation-operators) for additional operators.

## Choose the checks

Read the type's actual JSON Schema and saved `dslRules` first; paths must match the extracted `data`, not the conversion envelope. JSON Schema handles structure, required fields, formats and enums. DSL adds business constraints such as totals, comparisons across fields, conditions and per-item checks. Store rule text in `dslRules`, not a `validationRules` property.

Rules are plain text, one per line. `#` starts a comment outside quotes. A rule has a subject, an operator and any parameters:

```text
field.invoice_number required
field.total greaterThan 0
field.currency in("CLP", "USD")
field.due_date dateAfterOrEqual field.issue_date
field.items[*].amount greaterOrEqual 0

define itemsTotal sum field.items[*].amount
calculated.itemsTotal equalsWithPrecision(field.subtotal, 2)
define expectedTotal sum field.subtotal field.tax
field.total equalsWithPrecision(calculated.expectedTotal, 2)

when field.discount greaterThan 0 then {
  field.discount_reason required
}

forEach field.items[*] as line then {
  line.description required
  line.quantity greaterThan 0
}
```

- `field.x` addresses root data, `field.supplier.tax_id` nested data, `[0]` an indexed item, and `[*]` every item. Inside `forEach`, `line.x` refers to that item; `field.x` still addresses the root.
- Most operators skip missing/null subjects. Add `required` (also rejects empty text) or `exists` when absence must fail. A missing reference used as a parameter fails with `FIELD_REFERENCE_NOT_FOUND`.
- Single-parameter operators accept `greaterThan 0` or `greaterThan(0)`; multiple parameters use parentheses. Quote text literals. Quoted `"field.x"` is literal text.
- Define calculated values before use. Supported calculations include `sum`/`add`, `subtract`, `average`, `min`, `max`, `count`, `concat`, and field/literal assignment. Do not invent multiplication, division or JavaScript expressions. Undefined calculated references are rejected with line/column diagnostics by API/MCP compile checks.
- Wildcards on the same array pair by index; comparing two different wildcard arrays has no single comparison value and reports execution errors. Use totals, a fixed index, or `forEach` with an appropriate fixed reference.
- `forEach` requires an existing array; `when` on a missing/null field is false. Rules run in order. A failed calculation leaves its variable undefined; later references also fail.
- API rules are limited to 64 KiB UTF-8. Do not assume arbitrary expressions or operators are supported; consult the operator reference for less common checks.

## CLI workflow (0.6.0+)

Use the stored `codeType` (including the organization's prefix). The CLI resolves it to the internal ID. First inspect and back up the current rules:

```bash
docutray types get acme_invoice --json
docutray types rules get acme_invoice --raw > previous-rules.dsl
```

Write proposed rules to a separate `rules.dsl`. Extract sample data with `jq '.data' result.json > extracted.json`; do not pass `{data, validation}` as the document to validate.

```bash
# Dry-run replacement rules: nothing is saved
docutray types rules test acme_invoice --data extracted.json --rules rules.dsl
# Also test deliberately invalid data to verify the expected issues
docutray types rules test acme_invoice --data invalid.json --rules rules.dsl

# After reviewing results and fixing unintended failures, replace saved rules
docutray types rules set acme_invoice rules.dsl
docutray types rules get acme_invoice --raw
# Omitting --rules tests the saved rules
docutray types rules test acme_invoice --data extracted.json
```

A deliberately invalid fixture should exit **1** with the intended issues. Compilation/API/input errors exit **2** and do not establish whether the data is valid. Review schema issues as well as rule issues before saving. Saving replaces all rules, so preserve existing constraints unless the requested change removes them.

| Command | Inputs and behavior |
|---|---|
| `types rules get CODE [--raw \| --json]` | JSON is `{codeType, dslRules}`; `dslRules` is text or `null`. `--raw` emits only text, empty when there are no rules. `--raw` and `--json` are exclusive. |
| `types rules set CODE RULES [--json]` | Positional `RULES`: file, inline DSL or `-` for stdin. No `--file` / `--rules` flag. |
| `types rules set CODE --clear [--json]` | Remove all rules; incompatible with a positional rules value. |
| `types rules test CODE --data DATA [--rules RULES] [--json]` | `DATA`: JSON file, inline JSON or `-`. `RULES`: file, inline DSL or `-`; omit to use saved rules. |

Only one of `--data` and `--rules` can consume stdin. Empty rules text is rejected by `set` and `test --rules`: use `set --clear` to remove saved rules; omit `--rules` to test stored rules. Path-like DSL input that does not exist fails locally. Use real files for multiline rules to avoid shell quoting problems.

```bash
cat rules.dsl | docutray types rules set acme_invoice -
docutray types rules test acme_invoice --data '{"total":10}' --rules 'field.total greaterThan 0'
# Only when the user requests removal
docutray types rules set acme_invoice --clear
```

Test exits are **0 valid / 1 invalid / 2 error**. Unlike conversion commands, this command can gate scripts or CI. Invalid DSL is rejected with diagnostics before persistence; fix reported line/column errors. Public platform types cannot be changed: use an organization-owned type for writes.

## MCP equivalents (prefer when available)

1. `get_document_type` accepts `document_type` (ID or code) and returns `json_schema` and saved `dslRules`.
2. Dry-run using `validate_document_data`:

   ```json
   {"document_type":"acme_invoice","data":{"total":10},"dslRules":"field.total greaterThan 0"}
   ```

   Omit `dslRules` to use saved rules. `null` or empty text disables DSL for this dry-run only; the schema still runs. No rules or versions are saved.
3. Save using `update_document_type_validation_rules`:

   ```json
   {"codeType":"acme_invoice","dslRules":"field.total greaterThan 0"}
   ```

   Send exactly one of `codeType` or `documentTypeId`. Requires `docutray:document_types:write` and an organization-owned type. `null` or empty text clears saved rules; unchanged text is a no-op. Read back with `get_document_type`.

MCP compilation failures include line/column diagnostics. `convert_document` and `get_conversion_status` expose informational `validation`; very long issue lists may be shortened, so use on-demand validation or REST when complete detail is needed.

## SDK and REST equivalents

SDK methods take the **internal ID**, not `codeType`; resolve it from the paginated type listing first (see [Types](../platform/types.md)). These examples assume `typeId` / `type_id` already identifies the desired type.

```typescript
// docutray Node SDK >= 0.2.0; client is a DocuTray instance
const current = await client.documentTypes.get(typeId);
const rules = 'field.total greaterThan 0';
const checked = await client.documentTypes.validate(typeId, { total: 10 }, { dslRules: rules });
// After reviewing checked.valid and checked.issues:
await client.documentTypes.update(typeId, { dslRules: rules });
const saved = await client.documentTypes.get(typeId);
// Clear only when requested:
await client.documentTypes.update(typeId, { dslRules: null });
```

```python
# docutray Python SDK >= 0.3.0; client is a Client instance
current = client.document_types.get(type_id)
rules = "field.total greaterThan 0"
checked = client.document_types.validate(type_id, {"total": 10}, dsl_rules=rules)
# After reviewing checked.valid and checked.issues:
client.document_types.update(type_id, dsl_rules=rules)
saved = client.document_types.get(type_id)
# Clear only when requested:
client.document_types.update(type_id, dsl_rules=None)
```

Both SDKs support rules at create/update: Node uses `dslRules`, Python arguments use `dsl_rules`; returned `DocumentType` keeps the API spelling `dslRules`. Omit the validate override to use saved rules; pass `null` / `None` to test without DSL. Compilation failures raise `DSLValidationError` with diagnostics. CLI create/update have no equivalent DSL flag; use `types rules set` after creation. Even `types create --schema <full-export.json>` does not carry over exported `dslRules`: extract them separately, dry-run them against the new type, save with `types rules set`, and read back.

REST (`Authorization: Bearer $DOCUTRAY_API_KEY`):

| Operation | Request |
|---|---|
| Read | `GET /api/document-types/{id-or-code}` → stored `dslRules` |
| Test stored rules | `POST /api/document-types/{id}/validate` with the extracted object as the entire JSON body |
| Dry-run override | Same endpoint, body `{"data":{"total":10},"dslRules":"field.total greaterThan 0"}` |
| Replace | `PUT /api/document-types/{id}` with `{"dslRules":"field.total greaterThan 0"}` |
| Clear | Same PUT with `{"dslRules":null}` |

The `{data, dslRules}` envelope is reserved for dry-runs; if the document itself has both root keys, send it inside an explicit override envelope. API/MCP accept empty text or null to disable DSL; the CLI instead requires `--clear` for persistence and rejects empty `--rules`. Read back after saving.

## Read results correctly

On-demand `/validate`, CLI `types rules test`, and MCP `validate_document_data` return `valid`, structured `issues`, plus legacy `errors`/`warnings` summaries (`count`, `messages`). Older responses may omit `valid`/`issues`; prefer SDK compatibility helpers such as Node `isValidationValid`, or inspect error counts. Do not confuse those summaries with conversion arrays.

Issues include `field`, `message`, `severity`, `code`, `source` (`schema` or `rule`), and optionally `value`, `rule`, `details`. Concrete array paths such as `items[1].amount` identify failing rows. Use stable codes for branching; messages are human-facing Spanish text.

Conversion `validation` has a different shape:

- Outcome: `{valid, errors: Issue[], warnings: Issue[]}`.
- `null`: skipped because the type has neither schema nor rules.
- `{"status":"error"}`: validation could not complete, or there is no validation record. This means unknown validity, not invalid data.

Conversion validation is informational: even invalid data can accompany status `SUCCESS`. Inspect `validation` explicitly, and use a dry-run validity gate when your workflow needs one. See [Convert](../platform/convert.md) for status recovery and webhook behavior.
