# Identify — detailed reference

Identify the type of a document by analyzing its content. Returns the best-matching document type plus alternatives ranked by confidence.

Verified against `@docutray/cli/0.2.1`. Run `docutray identify --help` to confirm.

## CLI usage

```bash
docutray identify SOURCE [flags]
```

`SOURCE` is a local file path **or** a public URL.

### Flags (complete set)

| Flag | Description |
|---|---|
| `--async` | Use async polling; status updates emitted to stderr |
| `--json` | Force JSON output (default when stdout is piped) |
| `--types=<csv>` | Comma-separated list of document type codes to restrict identification, e.g. `--types invoice,receipt,contract` |

There is **no** `--output` flag and **no** `-t/--type` flag — `--types` (plural) is for restricting the candidate set, not for selecting a single type.

### Examples

```bash
# Local file
docutray identify document.pdf

# From a URL
docutray identify https://example.com/doc.pdf

# Restrict to a candidate set (faster, less noise)
docutray identify document.pdf --types invoice,receipt,contract

# Force JSON
docutray identify document.pdf --json

# Async with status polling
docutray identify document.pdf --async
```

### Response shape

```json
{
  "data": {
    "document_type": "electronic-invoice",
    "confidence": 0.95,
    "alternatives": [
      { "document_type": "receipt", "confidence": 0.04 },
      { "document_type": "purchase_order", "confidence": 0.01 }
    ]
  }
}
```

`document_type` is the best match. `confidence` is in `[0, 1]`. `alternatives` lists the next-best candidates with their scores.

### Confidence interpretation

| Range | Recommendation |
|---|---|
| `>= 0.9` | High — feed straight into `convert` |
| `0.7 – 0.9` | Moderate — review or ask the user before converting |
| `< 0.7` | Low — verify manually or design a custom type |

## Python SDK

```python
from docutray import Client

client = Client()
result = client.identify(file_path="document.pdf")
print(result.data.document_type, result.data.confidence)

# Restrict candidates
result = client.identify(
    file_path="document.pdf",
    types=["invoice", "receipt", "contract"],
)
```

## Node SDK

```typescript
import { DocuTray } from "docutray";

const client = new DocuTray();
const r = await client.identify({ filePath: "document.pdf" });
console.log(r.data.documentType, r.data.confidence);

// Restrict candidates
const r2 = await client.identify({
  filePath: "document.pdf",
  types: ["invoice", "receipt", "contract"],
});
```

## REST API

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@document.pdf" \
  https://app.docutray.com/api/identify
```

Restrict candidates:

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
  -d '{"url": "https://example.com/doc.pdf"}' \
  https://app.docutray.com/api/identify
```

## Identify → convert chain

```bash
TYPE=$(docutray identify document.pdf --json | jq -r '.data.document_type')
docutray convert document.pdf -t "$TYPE" > result.json
```

In practice, gate the chain on confidence:

```bash
JSON=$(docutray identify document.pdf --json)
TYPE=$(echo "$JSON" | jq -r '.data.document_type')
SCORE=$(echo "$JSON" | jq -r '.data.confidence')

if (( $(echo "$SCORE >= 0.9" | bc -l) )); then
  docutray convert document.pdf -t "$TYPE" > result.json
else
  echo "Low confidence ($SCORE) for $TYPE — review needed" >&2
  exit 1
fi
```

## Supported file formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
