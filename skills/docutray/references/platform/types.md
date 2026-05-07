# Types — detailed reference

Manage document types (extraction schemas) — the templates DocuTray uses when converting documents. This file covers read-only operations (`list`, `get`, `export`); for `create` / `update`, see `references/advanced/custom-types-workflow.md`.

Verified against `@docutray/cli/0.3.2` and a real org listing. Run `docutray types <subcommand> --help` to confirm.

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
  "createdAt": "2025-06-19T16:35:43.856Z",
  "updatedAt": "2025-08-19T13:50:37.744Z"
}
```

> **Earlier versions (`@docutray/cli/0.3.1` and below)**: only metadata was returned — `jsonSchema`, `promptHints`, `identifyPromptHints`, `conversionMode`, and `keepPropertyOrdering` were absent. Upgrade to 0.3.2+ to inspect the schema via the CLI.

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

Identical to `types get` — flat object including `jsonSchema`, `promptHints`, `identifyPromptHints`, `conversionMode`, and `keepPropertyOrdering`. The on-disk file written with `-o` contains the same JSON.

## SDK equivalents

### Python

```python
from docutray import Client

client = Client()

# List
result = client.types.list()
for t in result.data:
    print(f"{t.code_type}: {t.name}")    # property name in SDK may be code_type or codeType

# Get
result = client.types.get("factura")
print(result.data.name, result.data.status)

# Export (same shape as get today)
result = client.types.export("factura")
```

(SDK property casing may differ — verify against the SDK source. The CLI returns the JSON shape shown above; SDKs typically convert `codeType` → `code_type` in Python and keep `codeType` in JS.)

### Node

```typescript
import { DocuTray } from "docutray";

const client = new DocuTray();

// List
const list = await client.types.list();
for (const t of list.data) console.log(`${t.codeType}: ${t.name}`);

// Get
const got = await client.types.get("factura");
console.log(got.data.name, got.data.status);

// Export (same shape as get today)
const exported = await client.types.export("factura");
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

Each file contains the full type definition (metadata + `jsonSchema` + hints + conversion mode), so the snapshot is sufficient to recreate the type via `docutray types create`.
