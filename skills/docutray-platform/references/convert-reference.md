# Convert — Detailed Reference

## CLI Options

```bash
docutray convert <file> --type <document-type> [options]
```

| Flag | Description |
|------|-------------|
| `--type`, `-t` | Document type to extract (required) |
| `--output`, `-o` | Output file path (default: stdout) |
| `--format` | Output format: `json` (default), `csv` |

## Async Conversion

For large files or batch processing, use async conversion to avoid timeouts.

### REST API

**Start async conversion:**

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@large-document.pdf" \
  -F "document_type=invoice" \
  https://app.docutray.com/api/convert-async
```

**Response:**

```json
{
  "success": true,
  "data": {
    "conversion_id": "conv_abc123",
    "status": "ENQUEUED"
  }
}
```

**Poll for results:**

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/convert-async/status/conv_abc123
```

**Status values:** `ENQUEUED` → `PROCESSING` → `SUCCESS` | `ERROR`

When status is `SUCCESS`, the response includes the full extraction result in `data.result`.

### Python SDK

```python
# Start async conversion
conversion = client.convert_async(
    file_path="large-document.pdf",
    document_type="invoice",
)

# Poll for completion
result = conversion.wait()  # Blocks until done
print(result.data)

# Or check status manually
status = client.convert_async_status(conversion.id)
print(status.status)  # ENQUEUED, PROCESSING, SUCCESS, ERROR
```

### Node SDK

```typescript
// Start async conversion
const conversion = await client.convertAsync({
  filePath: "large-document.pdf",
  documentType: "invoice",
});

// Poll for completion
const result = await conversion.wait(); // Blocks until done
console.log(result.data);

// Or check status manually
const status = await client.convertAsyncStatus(conversion.id);
console.log(status.status);
```

## File Input Methods

### File Path (Default)

```python
result = client.convert(file_path="invoice.pdf", document_type="invoice")
```

```typescript
const result = await client.convert({ filePath: "invoice.pdf", documentType: "invoice" });
```

### File Bytes / Buffer

**Python:**

```python
with open("invoice.pdf", "rb") as f:
    result = client.convert(
        file=f.read(),
        file_name="invoice.pdf",
        document_type="invoice",
    )
```

**Node:**

```typescript
import { readFileSync } from "fs";

const buffer = readFileSync("invoice.pdf");
const result = await client.convert({
  file: buffer,
  fileName: "invoice.pdf",
  documentType: "invoice",
});
```

### URL Reference (REST API)

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/invoice.pdf", "document_type": "invoice"}' \
  https://app.docutray.com/api/convert
```

## Batch Processing

### CLI — Process a Directory

```bash
for f in documents/*.pdf; do
  docutray convert "$f" --type invoice --output "${f%.pdf}.json"
done
```

### CLI — Mixed Document Types

Use `identify` first to determine the type:

```bash
for f in documents/*.pdf; do
  TYPE=$(docutray identify "$f" | jq -r '.data.document_type')
  if [ "$TYPE" != "null" ]; then
    docutray convert "$f" --type "$TYPE" --output "${f%.pdf}.json"
  fi
done
```

### Python SDK — Async Batch

```python
from docutray import AsyncClient
import asyncio
from pathlib import Path

async def batch_convert(directory: str, document_type: str):
    client = AsyncClient()
    tasks = []
    for pdf in Path(directory).glob("*.pdf"):
        tasks.append(client.convert(file_path=str(pdf), document_type=document_type))
    results = await asyncio.gather(*tasks)
    for pdf, result in zip(Path(directory).glob("*.pdf"), results):
        pdf.with_suffix(".json").write_text(result.json())

asyncio.run(batch_convert("documents", "invoice"))
```

### Node SDK — Concurrent Batch

```typescript
import { DocuTray } from "docutray";
import { readdir } from "fs/promises";
import { join } from "path";

const client = new DocuTray();
const files = (await readdir("documents")).filter((f) => f.endsWith(".pdf"));

const results = await Promise.all(
  files.map((f) =>
    client.convert({ filePath: join("documents", f), documentType: "invoice" })
  )
);
```

## Output Formats

### JSON (Default)

```bash
docutray convert invoice.pdf --type invoice
```

Returns structured JSON with extracted fields matching the document type schema.

### CSV

```bash
docutray convert invoice.pdf --type invoice --format csv
```

Flattens the extracted fields into CSV format. Useful for spreadsheet workflows.

## Piping and Composition

```bash
# Extract a specific field
docutray convert invoice.pdf --type invoice | jq '.data.fields.total'

# Chain with other tools
docutray convert invoice.pdf --type invoice | jq '.data.fields' > extracted.json

# Identify then convert in one line
docutray convert doc.pdf --type "$(docutray identify doc.pdf | jq -r '.data.document_type')"
```

## Supported File Formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
