# Conversion spec (export mapping) — detailed reference

A document type can carry a **conversion spec**: the mapping from the JSON that DocuTray extracts to the columns of the CSV/Excel file produced by tray export. The extraction schema (`jsonSchema`) decides *what gets pulled out of the document*; the conversion spec decides *how that lands in a spreadsheet*.

The two are independent — a type can have a schema and no spec (it just doesn't export to a fixed sheet layout), and changing one does not change the other.

Documented from the `@docutray/cli/0.4.0` help output and [docutray-cli#36](https://github.com/docutray/docutray-cli/pull/36) (SDK `docutray@0.1.5`). Run `docutray types create --help` and `docutray types update --help` to confirm flag spellings against your installed version. The behavior here has not been re-verified against a live organization — treat `--help` and a post-write `docutray types get` as the ground truth.

## The two shapes

A spec is a JSON object in one of two shapes. Which one you use depends on whether the export is a single table or a workbook with several sheets.

**Single-table** — top-level `columns`:

```json
{
  "columns": [
    { "header": "Folio",   "jsonPath": "$.folio" },
    { "header": "Fecha",   "jsonPath": "$.fecha_emision" },
    { "header": "Total",   "jsonPath": "$.total" }
  ]
}
```

**Multi-sheet** — top-level `sheets`, each with a `name` and its own `columns`:

```json
{
  "sheets": [
    {
      "name": "Encabezado",
      "columns": [
        { "header": "Folio", "jsonPath": "$.folio" },
        { "header": "Fecha", "jsonPath": "$.fecha_emision" }
      ]
    },
    {
      "name": "Detalle",
      "columns": [
        { "header": "Descripción", "jsonPath": "$.detalle[*].descripcion" },
        { "header": "Cantidad",    "jsonPath": "$.detalle[*].cantidad" },
        { "header": "Importe",     "jsonPath": "$.detalle[*].precio_total" }
      ]
    }
  ]
}
```

The two are mutually exclusive: a spec has `columns` **or** `sheets` at the top level, not both. The single-table shape is the older of the two (the SDK calls its type `LegacyConversionSpec`) and remains fully supported.

## Column fields

Source: the `ConversionSpecColumn` interface exported by `docutray@0.1.5`.

| Field | Required | Description |
|---|---|---|
| `header` | yes | The column header text in the exported CSV/Excel file |
| `jsonPath` | no | JSONPath expression selecting the value for this column |
| `type` | no | `"data"` or `"formula"`. Defaults to `"data"` when omitted |
| `formula` | no | Excel formula, used only when `type` is `"formula"` |

`jsonPath` is optional on purpose: a formula column carries a `formula` instead.

> **A data column with no `jsonPath` is accepted on write but is not safe in a `sheets` spec.** The API's write path tolerates it (it stores as a placeholder that exports as an empty cell), but multi-sheet **CSV** export validates more strictly and rejects a data column without a path — so the spec saves cleanly and then fails at export time. Give every data column a `jsonPath`, or mark it `"type": "formula"`.

## Writing `jsonPath`

The paths select from **the document type's own extraction schema** — the same `jsonSchema` you designed for that type (see `schema-design.md`). Export the type and read its schema before writing a spec, so the paths point at fields that actually get extracted:

```bash
docutray types get factura --json | jq .jsonSchema
```

A field that isn't in the schema will never have a value to select, no matter how the path is written.

### Worked example

Given this extraction schema:

```json
{
  "type": "object",
  "required": ["folio", "fecha_emision", "total", "detalle"],
  "properties": {
    "folio":         { "type": ["number", "null"] },
    "fecha_emision": { "type": ["string", "null"], "format": "date" },
    "total":         { "type": ["number", "null"] },
    "detalle": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["descripcion", "cantidad", "precio_total"],
        "properties": {
          "descripcion":  { "type": ["string", "null"] },
          "cantidad":     { "type": ["number", "null"] },
          "precio_total": { "type": ["number", "null"] }
        }
      }
    }
  }
}
```

The scalar fields sit at the root (`$.folio`, `$.total`), and the repeating line items are reached through the array (`$.detalle[*].descripcion`). A natural mapping puts the scalars on a header sheet and the line items on their own sheet — the multi-sheet example above is exactly this schema's spec.

Common path forms:

| Path | Selects |
|---|---|
| `$.total` | A scalar at the root of the extracted object |
| `$.emisor.rut` | A field inside a nested object |
| `$.detalle[*].descripcion` | One value per element of a repeating array |
| `$.detalle[0].descripcion` | Only the first element of an array |

## Setting a spec — `types create`

```bash
docutray types create --name "Invoice" --code invoice \
  --description "Standard invoice" \
  --schema schema.json \
  --conversion-spec spec.json
```

`--conversion-spec <file|json>` accepts three forms:

1. **Inline JSON** — `--conversion-spec '{"columns":[{"header":"Total","jsonPath":"$.total"}]}'`
2. **A path to a file holding a bare spec** — a file whose content is `{"columns": […]}` or `{"sheets": […]}`
3. **A path to a full `types export` payload** — the CLI pulls the `conversionSpec` key out of it

Form 3 is what makes copying a mapping between types a one-liner:

```bash
docutray types export factura -o factura.json
docutray types create --name "Factura v2" --code factura_v2 \
  --description "…" --schema nuevo-schema.json \
  --conversion-spec factura.json      # reuses factura's export mapping
```

This only works when the source type actually has a spec. Against an export whose `conversionSpec` is `null`, the flag fails with `Invalid conversion spec: expected an object with "columns" or "sheets"` — the CLI finds the key and then rejects its value. Check before copying:

```bash
docutray types get factura            # → "Export spec: (none)" means there's nothing to copy
```

Without the flag (and without a spec embedded in `--schema`, see below) the `conversionSpec` key is simply not sent — the type is created with no export mapping.

## Replacing and clearing — `types update`

```bash
# Replace the stored spec
docutray types update invoice --conversion-spec spec.json

# Remove the stored spec entirely
docutray types update invoice --no-conversion-spec
```

`--conversion-spec` on `update` parses exactly as it does on `create` (inline, bare file, or full export payload). `--no-conversion-spec` sends `conversionSpec: null`, clearing whatever was stored.

The two flags are **mutually exclusive** — passing both fails with an exclusive-flags error before any API call. Either one on its own satisfies `types update`'s "at least one field to update must be provided" check, so you can change only the spec and nothing else.

## The `--schema` carry-over asymmetry

This is the one behavior worth memorizing, because the two commands deliberately differ:

- **`types create --schema <full export payload>` carries the embedded `conversionSpec` over.** Creating a type builds it from scratch, so reproducing the whole exported definition is what you want. This completes the round-trip below.
- **`types update --schema <full export payload>` ignores the embedded `conversionSpec`.** An update is partial by contract — it must not modify a field the user never named. Use `--conversion-spec` to change the mapping.

An explicit `--conversion-spec` always **takes precedence** over a spec embedded in `--schema`.

### Round-trip: export → create

```bash
docutray types export factura -o factura.json
docutray types create --name "Copia" --code factura_copy \
  --description "Copy of factura" --schema factura.json
# → sends both jsonSchema and conversionSpec from factura.json
```

No extra flags needed: `types export` output includes the spec, and `create --schema` carries it. Before `0.4.0` this round-trip silently lost the mapping — the recreated type extracted the same fields but no longer exported to the same spreadsheet.

## Inspecting a spec — `types get`

Human-readable output carries an **`Export spec`** summary line rather than dumping the whole spec (a 14-column spec would flood a key-value listing):

```
Export spec: 2 sheets, 14 columns     # multi-sheet
Export spec: 5 columns                # single-table
Export spec: (none)                   # no spec stored
Export spec: (present)                # stored, but not summarizable (columns/sheets isn't an array)
```

`(present)` is a deliberate fallback: a cosmetic summary line must never cost the user the whole output, so an unrecognized shape degrades instead of throwing. When checking whether a spec stored, test for **not `(none)`** rather than matching one of the count forms.

JSON output is unsummarized — `conversionSpec` travels verbatim, exactly as the API returned it, with no derived fields:

```bash
docutray types get invoice --json | jq .conversionSpec
docutray types export invoice | jq .conversionSpec

# Count columns in a multi-sheet spec
docutray types export invoice | jq '[.conversionSpec.sheets[].columns[]] | length'
```

`conversionSpec` is `null` when no spec is stored, and is **absent from `types list` responses** — only the single-type endpoints return it.

## Validation

The CLI checks only that the value parses to a JSON object with a `columns` or `sheets` key. Anything beyond that — path validity, header uniqueness, sheet-name rules, formula syntax — is the API's call, and an invalid spec surfaces as an API error rather than a CLI one.

| Failure | Result |
|---|---|
| Value is neither an existing path nor valid JSON | CLI error naming `--conversion-spec`, exit code 1, no API call |
| Parses to an array, a scalar, or an object without `columns`/`sheets` | CLI error explaining the expected shape, exit code 1, no API call |
| Well-shaped but semantically invalid | Passed to the API, which rejects it |

Don't try to pre-validate a spec against these rules in the skill's guidance — the API is the source of truth and duplicating its rules here would drift.

## Requires a current API deployment

> **The field can be silently dropped.** Against a DocuTray API deployment that predates `conversionSpec` support on document types, the field is accepted and discarded — no error, no warning, and the CLI has no way to detect it. A create or update appears to succeed with the spec lost.
>
> **Always confirm after writing:**
> ```bash
> docutray types get <code>        # → "Export spec: 5 columns", not "(none)"
> ```

## SDK equivalents

### Node (`docutray@0.1.5+`)

`conversionSpec` is available on `DocumentType`, `DocumentTypeCreateParams`, and `DocumentTypeUpdateParams`. Omit it to leave a type's spec untouched; pass `null` to clear it.

```typescript
import { DocuTray, isMultiSheetConversionSpec } from "docutray";

const client = new DocuTray();

// Note: documentTypes.get() takes the internal `id`, not the `codeType`.
// The CLI resolves code → id for you; in the SDK, look it up via list().
const docType = await client.documentTypes.get(docTypeId);

if (isMultiSheetConversionSpec(docType.conversionSpec)) {
  console.log(docType.conversionSpec.sheets.map((sheet) => sheet.name));
} else if (docType.conversionSpec) {
  console.log(docType.conversionSpec.columns.length);
}
```

Exported types: `ConversionSpec` (the union), `ConversionSpecColumn`, `ConversionSpecSheet`, `LegacyConversionSpec` (top-level `columns`), and `MultiSheetConversionSpec` (top-level `sheets`). The `isMultiSheetConversionSpec()` guard narrows the union and accepts `null` / `undefined` — returning `false` rather than throwing — so it can be called directly on `DocumentType.conversionSpec`, which is absent from list responses.

### Python

The Python SDK follows the same field name on its document-type create/update params. Verify the exact casing (`conversion_spec` vs `conversionSpec`) against the installed SDK version before relying on it.

### REST

`conversionSpec` is carried on `GET` / `POST` / `PUT` of `/api/document-types` — sent in the request body on create and update, returned in the response body on the single-type endpoints. It is not present on the list endpoint.

## Related

- `schema-design.md` — designing the `jsonSchema` that a spec's `jsonPath` expressions select from
- `custom-types-workflow.md` — the full create / update playbook these flags plug into
- `../platform/types.md` — `types get` / `export` response shapes
