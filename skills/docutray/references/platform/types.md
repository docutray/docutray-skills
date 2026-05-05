# Types — detailed reference

Manage document types (extraction schemas) — the templates DocuTray uses when converting documents. This file covers read-only operations (`list`, `get`, `export`); for `create` / `update`, see `references/advanced/custom-types-workflow.md`.

Verified against `@docutray/cli/0.2.1`. Run `docutray types <subcommand> --help` to confirm.

## Subcommands

| Subcommand | Purpose |
|---|---|
| `list` | List available types (paginated, with search) |
| `get` | Get full details of a single type |
| `export` | Export a type definition as JSON (stdout or file) |
| `create` | Create a new type — see custom-types-workflow.md |
| `update` | Update an existing type — see custom-types-workflow.md |

There is **no** `view` subcommand (use `get`) and **no** `delete` subcommand. Lifecycle is managed via `--draft` / `--publish` on `update`, or via the dashboard.

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
docutray types list | jq '.data[].codeType'   # extract just the codes
```

Response (JSON form):

```json
{
  "data": [
    {
      "code": "electronic-invoice",
      "name": "Electronic invoice",
      "description": "Standard electronic invoice"
    },
    {
      "code": "receipt",
      "name": "Receipt",
      "description": "Purchase receipt"
    }
  ]
}
```

The list includes user-created, organization, and public document types.

## Get

```bash
$ docutray types get --help
USAGE
  $ docutray types:get CODE [--json]

ARGUMENTS
  CODE  Document type code
```

```bash
docutray types get electronic-invoice
docutray types get electronic-invoice --json | jq .data.fields
```

Returns the full type definition including the JSON schema and configuration (prompt hints, identify hints, conversion mode, draft/publish status).

## Export

```bash
$ docutray types export --help
USAGE
  $ docutray types:export CODE [--force] [--json] [-o <value>]

ARGUMENTS
  CODE  Document type code

FLAGS
  -o, --output=<value>  Output file path. If omitted, writes to stdout.
      --force           Overwrite existing file
      --json            Output as JSON (default when piped)
```

```bash
# To stdout
docutray types export electronic-invoice

# To a file
docutray types export electronic-invoice -o invoice-type.json

# Overwrite an existing file
docutray types export electronic-invoice -o invoice-type.json --force

# Pipe to jq
docutray types export electronic-invoice | jq .
```

`types export` is the only types subcommand with an `--output` flag. (`convert` does not have one — use shell redirection instead.)

## SDK equivalents

### Python

```python
from docutray import Client

client = Client()

# List
types = client.types.list()
for t in types:
    print(f"{t.code}: {t.name}")

# Get
doc_type = client.types.get("electronic-invoice")
print(doc_type.schema)

# Export
import json
schema = client.types.export("electronic-invoice")
with open("invoice-type.json", "w") as f:
    json.dump(schema, f, indent=2)
```

### Node

```typescript
import { DocuTray } from "docutray";
import { writeFileSync } from "node:fs";

const client = new DocuTray();

// List
const types = await client.types.list();
for (const t of types) console.log(`${t.code}: ${t.name}`);

// Get
const docType = await client.types.get("electronic-invoice");
console.log(docType.schema);

// Export
const schema = await client.types.export("electronic-invoice");
writeFileSync("invoice-type.json", JSON.stringify(schema, null, 2));
```

## REST API equivalents

```bash
# List
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types

# Get
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types/electronic-invoice

# Export
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types/electronic-invoice/export \
  -o invoice-type.json
```

## Schema structure (overview)

A document type's `schema` is a JSON Schema (`type: object`) describing the fields to extract. Quick example:

```json
{
  "type": "object",
  "required": ["invoice_number", "date", "total"],
  "properties": {
    "invoice_number": {
      "type": ["string", "null"],
      "description": "Unique invoice identifier, top-right of page"
    },
    "date": {
      "type": ["string", "null"],
      "format": "date",
      "description": "Invoice issue date"
    },
    "total": {
      "type": ["number", "null"],
      "description": "Grand total"
    },
    "line_items": {
      "type": ["array", "null"],
      "description": "Line items table",
      "items": {
        "type": "object",
        "properties": {
          "description": { "type": ["string", "null"] },
          "quantity":    { "type": ["number", "null"] },
          "unit_price":  { "type": ["number", "null"] }
        }
      }
    }
  }
}
```

For the full schema-design playbook (required + nullable, descriptive descriptions, dates/enums, tabular data, nesting), see `references/advanced/schema-design.md`.

## Common patterns

### Check whether a type exists before converting

```python
codes = {t.code for t in client.types.list()}
if "electronic-invoice" in codes:
    result = client.convert(file_path="doc.pdf", document_type="electronic-invoice")
else:
    print("Type 'electronic-invoice' not available")
```

### Export every schema for version control

```bash
for CODE in $(docutray types list --json | jq -r '.data[].code'); do
  docutray types export "$CODE" -o "schemas/${CODE}.json" --force
done
```

### Inspect a type before converting

```bash
docutray types list --search invoice
docutray types get electronic-invoice
docutray convert sample.pdf -t electronic-invoice
```
