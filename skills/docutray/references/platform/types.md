# Types — detailed reference

Manage document types (extraction schemas) — the templates DocuTray uses when converting documents. This file covers read-only operations (`list`, `get`, `export`); for `create` / `update`, see `references/advanced/custom-types-workflow.md`.

Verified against `@docutray/cli/0.3.2` and a real org listing; `conversionSpec` coverage documented from `@docutray/cli/0.4.0`. Run `docutray types <subcommand> --help` to confirm.
SDK snippets are verified against the `docutray` Node SDK **0.1.5** and Python SDK **0.2.1** sources.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `list` | List available types (paginated, with search) |
| `get` | Get metadata for a single type |
| `export` | Export a type definition (currently same shape as `get`) |
| `create` | Create a new type — see `custom-types-workflow.md` |
| `update` | Update an existing type — see `custom-types-workflow.md` |

There is **no** `view` subcommand (use `get`) and **no** `delete` subcommand. Lifecycle is managed via `--draft` / `--publish` on `update`, or via the dashboard.

## Response shape

Common type fields (returned by all three commands):

| Field | Type | Notes |
|---|---|---|
| `id` | string (cuid) | Internal database id (e.g. `cmditbp6h000zrq01jl0whzcr`) |
| `codeType` | string | Stable identifier used by `--types` on `identify` and `-t/--type` on `convert` (e.g. `factura`, `electronic-invoice`). **Note: the field name is `codeType`, not `code`.** |
| `name` | string | Human-readable name |
| `description` | string | One-sentence description |
| `isPublic` | boolean | `true` when the type is part of DocuTray's shared catalog; `false` when scoped to your org |
| `isDraft` | boolean | `true` while the type is in draft (not usable for conversion) |
| `status` | string | `"PUBLISHED"` or `"DRAFT"` |
| `createdAt` | string (ISO 8601) | UTC timestamp |
| `updatedAt` | string (ISO 8601) | UTC timestamp |

`get` and `export` additionally return the full type definition:

| Field | Type | Notes |
|---|---|---|
| `jsonSchema` | object | The JSON Schema used for extraction (object with `type`, `required`, `properties`) |
| `promptHints` | string | Free-form hints applied during conversion |
| `identifyPromptHints` | string | Free-form hints applied during identification |
| `conversionMode` | string | `"json"` \| `"toon"` \| `"multi_prompt"` |
| `keepPropertyOrdering` | boolean | When `true`, preserves the field order from the schema |
| `conversionSpec` | object \| null | Export mapping (JSON → CSV/Excel columns), verbatim as stored; `null` when no spec is set. **Absent from `list` items** — only the single-type endpoints return it. See `../advanced/conversion-spec.md` |

### Envelope

- `list` is wrapped — `{"data":[...], "pagination":{...}}`.
- `get` and `export` are **flat** — fields are at the top level (no `data` envelope). Use `jq .jsonSchema` (not `jq .data.jsonSchema`).

## List

```bash
$ docutray types list --help
USAGE
  $ docutray types:list [--json] [--limit <value>] [--page <value>] [--search <value>]
```

| Flag | Default | Description |
|---|---|---|
| `--json` | when piped | Force JSON output |
| `--limit=<n>` | 20 | Results per page |
| `--page=<n>` | 1 | Page number |
| `--search=<term>` | — | Case-insensitive substring filter on type name |

Examples:

```bash
docutray types list
docutray types list --search invoice
docutray types list --limit 50 --page 2

# Extract codes for use with `identify --types` or `convert -t`
docutray types list --json | jq -r '.data[].codeType'

# Filter to published, public types only
docutray types list --json \
  | jq -r '.data[] | select(.isPublic and .status == "PUBLISHED") | .codeType'
```

### List response

```json
{
  "data": [
    {
      "id": "cmditbp6h000zrq01jl0whzcr",
      "codeType": "balance_ocho_columnas",
      "name": "Balance 8 Columnas",
      "description": "Balance de 8 columnas, con identificación de empresa, periodo y cuentas con sus valores",
      "isPublic": true,
      "isDraft": false,
      "status": "PUBLISHED",
      "createdAt": "2025-07-25T12:43:46.360Z",
      "updatedAt": "2025-07-31T18:05:07.931Z"
    },
    {
      "id": "cmcfbrakq000fv501j6w3wihs",
      "codeType": "bl",
      "name": "Bill of Lading",
      "description": "Documento utilizado en el proceso aduanero. Contiene información del consignatario, la carga, puerto origen/destino, entre otros.",
      "isPublic": true,
      "isDraft": false,
      "status": "PUBLISHED",
      "createdAt": "2025-06-27T21:28:59.978Z",
      "updatedAt": "2025-07-29T02:29:53.140Z"
    }
  ],
  "pagination": {
    "total": 27,
    "page": 1,
    "limit": 20
  }
}
```

The list includes user-created, organization, and public document types. `pagination.total` is the count across all pages; iterate `--page` until you've covered it.

> **Earlier versions (`@docutray/cli/0.3.0`)**: the response also included a `pageOptions` block with `client.apiKey` in plain text. **Fixed in 0.3.1.** If you're still on 0.3.0, do not pipe `types list --json` to logs or shared destinations.

## Get

```bash
$ docutray types get --help
USAGE
  $ docutray types:get CODE [--json]

ARGUMENTS
  CODE  Document type code (the `codeType` field from `types list`)
```

```bash
docutray types get factura
docutray types get factura --json | jq '{codeType, name, status}'
docutray types get factura --json | jq .jsonSchema   # extract just the schema
```

### Get response (`@docutray/cli/0.3.2+`)

Flat object — no `data` envelope. Includes the full type definition:

```json
{
  "id": "cmc3lrbzk0007wu01dzjw2zzz",
  "codeType": "factura",
  "name": "Factura Electrónica",
  "description": "Factura Electrónica del SII (Chile), con datos de emisor, receptor y detalle de productos/servicios.",
  "isPublic": true,
  "isDraft": false,
  "status": "PUBLISHED",
  "jsonSchema": {
    "type": "object",
    "required": ["fecha_emision", "folio", "rut_emisor", "..."],
    "properties": {
      "folio": { "type": "number" },
      "fecha_emision": { "type": "string", "format": "date-time" },
      "detalle": {
        "type": "array",
        "items": {
          "type": "object",
          "required": ["descripcion", "cantidad", "precio_total"],
          "properties": { "descripcion": { "type": "string" }, "cantidad": { "type": "number" }, "precio_total": { "type": "number" } }
        }
      }
    }
  },
  "promptHints": "En estos documentos se ocupa el punto (\".\") como separador de miles…",
  "identifyPromptHints": "",
  "conversionMode": "json",
  "keepPropertyOrdering": false,
  "conversionSpec": {
    "sheets": [
      { "name": "Encabezado", "columns": [{ "header": "Folio", "jsonPath": "$.folio" }] },
      { "name": "Detalle", "columns": [{ "header": "Descripción", "jsonPath": "$.detalle[*].descripcion" }] }
    ]
  },
  "createdAt": "2025-06-19T16:35:43.856Z",
  "updatedAt": "2025-08-19T13:50:37.744Z"
}
```

> **Earlier versions (`@docutray/cli/0.3.1` and below)**: only metadata was returned — `jsonSchema`, `promptHints`, `identifyPromptHints`, `conversionMode`, and `keepPropertyOrdering` were absent. Upgrade to 0.3.2+ to inspect the schema via the CLI.

> **`conversionSpec` does not need 0.4.0 to be *read*.** `get` / `export` dump the API object verbatim, so the field has been travelling in JSON output since the API started returning it. What 0.4.0 adds is the `Export spec` summary line below and the write flags (`--conversion-spec`, `--no-conversion-spec`).

### Human output and the `Export spec` line

Non-`--json` output summarizes the conversion spec instead of dumping it — a 14-column spec would flood the key-value listing. Four forms:

```
Export spec: 2 sheets, 14 columns     # multi-sheet ({"sheets": […]})
Export spec: 5 columns                # single table ({"columns": […]})
Export spec: (none)                   # conversionSpec is null or absent
Export spec: (present)                # a spec the CLI can't summarize (columns/sheets isn't an array)
```

`(present)` is a deliberate fallback — a cosmetic summary line never costs you the whole output. Treat "anything other than `(none)`" as "a spec is stored"; use `--json` when you need the real contents.

`--json` (and piped) output is **never** summarized: `conversionSpec` travels verbatim as the API returned it, with no derived or computed fields.

```bash
docutray types get factura --json | jq .conversionSpec
```

> Depth on the spec format, `jsonPath` authoring, and the `create`/`update` flags: `../advanced/conversion-spec.md`.

## Export

```bash
$ docutray types export --help
USAGE
  $ docutray types:export CODE [--force] [--json] [-o <value>]

ARGUMENTS
  CODE  Document type code (the `codeType` field from `types list`)

FLAGS
  -o, --output=<value>  Output file path. If omitted, writes to stdout.
      --force           Overwrite existing file
      --json            Output as JSON (default when piped)
```

```bash
# To stdout
docutray types export factura

# To a file
docutray types export factura -o factura-type.json

# Overwrite an existing file
docutray types export factura -o factura-type.json --force
```

`types export` is the only types subcommand with an `--output` flag. (`convert` does not have one — use shell redirection instead.)

### Export response

Identical to `types get` — flat object including `jsonSchema`, `promptHints`, `identifyPromptHints`, `conversionMode`, `keepPropertyOrdering`, and `conversionSpec`. The on-disk file written with `-o` contains the same JSON, which is what makes the export payload directly reusable as `--schema` / `--conversion-spec` input on `types create`.

## SDK equivalents

### Python

```python
from docutray import Client

client = Client()

# List — returns a Page; items are on .data
page = client.document_types.list()
for t in page.data:
    print(f"{t.codeType}: {t.name}")

page = client.document_types.list(search="factura")

# Get — takes the internal id, NOT the codeType, and returns the type directly
doc_type = client.document_types.get(doc_type_id)
print(doc_type.name, doc_type.status, doc_type.jsonSchema)
```

The Python model keeps the API's camelCase field names (`codeType`, `isDraft`, `jsonSchema`) rather than converting to snake_case; only method and argument names are snake_case. `DocumentType` allows extra fields, so keys the SDK doesn't declare (such as `conversionSpec`) are reachable via `doc_type.model_extra`.

### Node

```typescript
import { DocuTray } from "docutray";

const client = new DocuTray();

// List — returns a Page; items are on .data
const page = await client.documentTypes.list();
for (const t of page.data) console.log(`${t.codeType}: ${t.name}`);

// Get — takes the internal id, NOT the codeType, and returns the type directly
const docType = await client.documentTypes.get(docTypeId);
console.log(docType.name, docType.status, docType.jsonSchema);
```

**Neither SDK has an `export()` method** — `list`, `get`, `create`, `update`, and `validate` are the whole surface. To produce an export payload, use the CLI (`docutray types export <code>`); `get` returns the same object.

**Resolving a code to an id.** The CLI accepts a `codeType` everywhere and resolves it internally; the SDKs do not. Look the id up first:

```typescript
const page = await client.documentTypes.list({ search: "factura" });
const match = page.data.find((t) => t.codeType === "factura");
const docType = await client.documentTypes.get(match.id);
```

## REST API equivalents

```bash
# List
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  "https://app.docutray.com/api/document-types?limit=20&page=1"

# Get
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/document-types/factura

# Export (same shape as get today)
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/document-types/factura/export \
  -o factura-type.json
```

## Common patterns

### Build a candidate list for `identify`

```bash
# All published, public types
CODES=$(docutray types list --limit 50 --json \
  | jq -r '.data[] | select(.isPublic and .status == "PUBLISHED") | .codeType' \
  | paste -sd, -)

docutray identify document.pdf --types "$CODES" --json
```

Note: even after this filter, some `codeType` values may not be usable by your org and `identify` may return `403 You do not have permission to use the following document types: …`. Drop those from `$CODES` and retry.

### Check whether a type exists before converting

```bash
if docutray types get factura --json >/dev/null 2>&1; then
  docutray convert document.pdf -t factura > result.json
else
  echo "Type 'factura' not available" >&2
fi
```

### Pin org types in version control

```bash
mkdir -p schemas
for CODE in $(docutray types list --limit 50 --json | jq -r '.data[].codeType'); do
  docutray types export "$CODE" -o "schemas/${CODE}.json" --force
done
```

Each file contains the full type definition (metadata + `jsonSchema` + hints + conversion mode + `conversionSpec`), so the snapshot is sufficient to recreate the type via `docutray types create --schema <file>` — which carries the embedded export mapping over as well as the schema.
