# Identify — detailed reference

Identify the type of a document by analyzing its content, against a candidate set you provide. Returns the best-matching document type plus alternatives ranked by confidence.

Verified against `@docutray/cli/0.3.0` and a real PDF. Run `docutray identify --help` to confirm flag spellings.

## Critical: `--types` is required in practice

The CLI's `--help` lists `--types` as optional, but the API rejects requests without a candidate list:

```bash
$ docutray identify document.pdf
{
  "error": "Validation error",
  "status": 400
}
```

Always pass a non-empty `--types <comma-separated codes>` list. Narrow it to the plausible candidates for your document; **don't blanket-pass every code from `types list`** because some types in the listing aren't usable by your org and will return:

```json
{
  "error": "You do not have permission to use the following document types: cenco_etiquetas_producto, …",
  "status": 403
}
```

## CLI usage

```bash
docutray identify SOURCE --types <code1>,<code2>[,…] [other flags]
```

`SOURCE` is a local file path **or** a public URL.

### Flags (complete set)

| Flag | Effective requirement | Description |
|---|---|---|
| `--types=<csv>` | required (API rejects without it) | Comma-separated list of document type codes to identify against, e.g. `--types invoice,receipt,contract` |
| `--async` | optional | Use async polling; status updates emitted to stderr |
| `--json` | optional | Force JSON output (default when stdout is piped) |

There is **no** `--output` flag and **no** `-t/--type` (singular). `--types` (plural) is for restricting the candidate set, not for selecting a single type.

### Picking candidate codes

Strategies, ranked by likelihood of working:

1. **Use file-name / context hints.** If the file is `aws-invoice-2024.pdf`, candidates are `invoice`, `electronic-invoice`, `factura`, `factura_internacional`. Pass those.
2. **Look up codes from the listing.** `docutray types list --json | jq -r '.data[].codeType'` returns every code in your org's view (note the field is `codeType`, not `code`). Pick the ones plausible for the document.
3. **Try, drop, retry.** If `403 You do not have permission to use the following document types: <code1>, <code2>` comes back, drop those codes and retry with the rest.

### Examples

```bash
# Local file with explicit candidates
docutray identify document.pdf --types invoice,receipt,contract

# From a URL (also requires --types)
docutray identify https://example.com/doc.pdf --types invoice,factura_internacional

# Force JSON
docutray identify document.pdf --types invoice,receipt --json

# Async with status polling
docutray identify document.pdf --types invoice,receipt --async
```

### Response shape

Verified against `docutray identify example-invoice-aws.pdf --types invoice,factura_internacional`:

```json
{
  "document_type": {
    "code": "invoice",
    "name": "Invoice",
    "confidence": 0.99
  },
  "alternatives": [
    { "code": "factura_internacional", "name": "Factura Internacional", "confidence": 0.2 },
    { "code": "otro", "name": "Otro/No identificado", "confidence": 0.01 }
  ]
}
```

Notes:

- **No `data` envelope.** Fields are at the top level. (This differs from `convert`, which returns `{"data": {...}}`.)
- **`document_type` is an object**, not a string. Read `.document_type.code` for the matched type code, `.document_type.name` for the human-readable name, and `.document_type.confidence` for the score.
- **`alternatives[]` items use `code` / `name` / `confidence`** — same shape as `document_type`.
- `confidence` is in `[0, 1]`. The `otro` / "Other / unidentified" entry is a built-in catch-all that always appears among the alternatives even if it has low score.

### Confidence interpretation

Read `.document_type.confidence`:

| Range | Recommendation |
|---|---|
| `>= 0.9` | High — feed straight into `convert` |
| `0.7 – 0.9` | Moderate — review or ask the user before converting |
| `< 0.7` | Low — verify manually, widen the candidate list, or design a custom type |

## Python SDK

```python
from docutray import Client

client = Client()
result = client.identify(
    file_path="document.pdf",
    types=["invoice", "receipt", "contract"],   # required
)
# result.data fields are at the top level (no `.data` wrapper on the dict either)
print(result.document_type.code, result.document_type.confidence)
for alt in result.alternatives:
    print(alt.code, alt.confidence)
```

(Verify SDK attribute names against the SDK source — the CLI returns the JSON shape shown above; SDK property names may differ slightly e.g. `documentType` in JS or `document_type` in Python.)

## Node SDK

```typescript
import { DocuTray } from "docutray";

const client = new DocuTray();
const r = await client.identify({
  filePath: "document.pdf",
  types: ["invoice", "receipt", "contract"],   // required
});
console.log(r.documentType.code, r.documentType.confidence);
for (const alt of r.alternatives) {
  console.log(alt.code, alt.confidence);
}
```

## REST API

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@document.pdf" \
  -F "types=invoice,receipt,contract" \
  https://app.docutray.com/api/identify
```

URL reference:

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com/doc.pdf","types":["invoice","receipt","contract"]}' \
  https://app.docutray.com/api/identify
```

The `types` field is required. Omitting it returns HTTP 400 with `{"error":"Validation error","status":400}`.

## Identify → convert chain

```bash
TYPE=$(docutray identify document.pdf --types invoice,receipt,factura_internacional --json \
  | jq -r '.document_type.code')
docutray convert document.pdf -t "$TYPE" > result.json
```

In practice, gate the chain on confidence:

```bash
JSON=$(docutray identify document.pdf --types invoice,receipt,factura_internacional --json)
TYPE=$(echo "$JSON" | jq -r '.document_type.code')
SCORE=$(echo "$JSON" | jq -r '.document_type.confidence')

if (( $(echo "$SCORE >= 0.9" | bc -l) )); then
  docutray convert document.pdf -t "$TYPE" > result.json
else
  echo "Low confidence ($SCORE) for $TYPE — review needed" >&2
  exit 1
fi
```

If the candidate list is dynamic (e.g. derived from the org's published types):

```bash
# Pull plausible codes (here, every public published type — you may want to narrow further)
CODES=$(docutray types list --limit 50 --json \
  | jq -r '.data[] | select(.isPublic == true and .status == "PUBLISHED") | .codeType' \
  | paste -sd, -)

docutray identify document.pdf --types "$CODES" --json
# May still 403 on a few specific codes — drop them and retry if needed.
```

## Supported file formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
