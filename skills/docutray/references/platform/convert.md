# Convert — detailed reference

Verified against `@docutray/cli/0.2.1`. Run `docutray convert --help` to confirm.
SDK snippets are verified against the `docutray` Node SDK **0.1.5** and Python SDK **0.2.1** sources.

## CLI usage

```bash
docutray convert SOURCE -t <code> [flags]
```

`SOURCE` is a local file path **or** a public URL.

### Flags (complete set)

| Flag | Required | Description |
|---|---|---|
| `-t`, `--type=<code>` | yes | Document type code (run `docutray types list` to see available codes) |
| `--async` | no | Use async polling; status updates emitted to stderr. Useful for large docs. |
| `--json` | no | Force JSON output (default when stdout is piped) |
| `--metadata=<json>` | no | Attach JSON metadata, e.g. `'{"ref":"order-123"}'` |
| `--timeout=<seconds>` | no | Polling timeout for async (default 300) |
| `--webhook-url=<url>` | no | POST a notification when conversion completes |

There is **no** `--output` / `-o` flag and **no** `--format` flag. Save to a file with shell redirection. There is no built-in CSV output — use `jq` or a downstream tool.

### Examples

```bash
# Sync — output to stdout
docutray convert invoice.pdf --type electronic-invoice

# From a URL
docutray convert https://example.com/doc.pdf -t electronic-invoice

# Save to file via redirection
docutray convert invoice.pdf -t electronic-invoice > result.json

# Async with a 10-minute timeout
docutray convert large-doc.pdf -t electronic-invoice --async --timeout 600

# Webhook notification
docutray convert receipt.jpg -t receipt \
  --webhook-url https://example.com/hook

# Attach custom metadata
docutray convert invoice.pdf -t electronic-invoice \
  --metadata '{"ref":"order-123"}'
```

### Response shape

Top-level `data` whose keys come from the active document type's schema. There is no `success` envelope and no `fields` wrapper. Example values are illustrative:

```json
{
  "data": {
    "moneda": "USD",
    "fecha_emision": "2024-03-15",
    "monto_total": 1500.00,
    "detalle": [
      { "nombre": "Servicio", "cantidad": "1", "precio_total": 1500.00 }
    ]
  }
}
```

DocuTray's default org schemas often use Spanish key names (`moneda`, `detalle`, `fecha_pago`, …). The exact keys depend on the schema you defined or the public type you used.

## Python SDK

```python
from pathlib import Path

from docutray import Client

client = Client()

# Sync — exactly one source: file, url, or file_base64
result = client.convert.run(
    file=Path("invoice.pdf"),
    document_type_code="electronic-invoice",
)
print(result.data)

# From a URL, with metadata
result = client.convert.run(
    url="https://example.com/invoice.pdf",
    document_type_code="electronic-invoice",
    document_metadata={"ref": "order-123"},
)

# Async polling — run_async() returns a status with .wait()
status = client.convert.run_async(
    file=Path("large.pdf"),
    document_type_code="electronic-invoice",
)
result = status.wait(on_status=lambda s: print(s.status))
current = client.convert.get_status(status.conversion_id)   # or poll manually

# Asyncio client
from docutray import AsyncClient

async def run():
    aclient = AsyncClient()
    result = await aclient.convert.run(
        file=Path("invoice.pdf"),
        document_type_code="electronic-invoice",
    )
```

## Node SDK

```typescript
import { DocuTray } from "docutray";
import { readFileSync } from "node:fs";

const client = new DocuTray();

// Sync — exactly one source: file, url, or base64
const r1 = await client.convert.run({
  file: readFileSync("invoice.pdf"),
  documentTypeCode: "electronic-invoice",
});
console.log(r1.data);

// From a URL, with metadata
const r2 = await client.convert.run({
  url: "https://example.com/invoice.pdf",
  documentTypeCode: "electronic-invoice",
  documentMetadata: { ref: "order-123" },
});

// Async polling — runAsync() returns a status with .wait()
const status = await client.convert.runAsync({
  file: readFileSync("large.pdf"),
  documentTypeCode: "electronic-invoice",
});
const result = await status.wait({ onStatus: (s) => console.log(s.status) });
const current = await client.convert.getStatus(status.conversion_id);
```

## REST API

### Synchronous

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@invoice.pdf" \
  -F "document_type=electronic-invoice" \
  https://app.docutray.com/api/convert
```

Or with a URL reference:

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/invoice.pdf", "document_type": "electronic-invoice"}' \
  https://app.docutray.com/api/convert
```

Response:

```json
{
  "data": {
    "moneda": "USD",
    "monto_total": 1500.00,
    "detalle": [ { "nombre": "Servicio", "precio_total": 1500.00 } ]
  }
}
```

### Asynchronous (with polling)

Start the conversion and poll the status endpoint until `SUCCESS` or `ERROR`. The CLI's `--async` flag wraps this loop for you; in REST, do it manually:

```bash
# Start
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@large-document.pdf" \
  -F "document_type=electronic-invoice" \
  https://app.docutray.com/api/convert-async

# → { "data": { "conversion_id": "conv_abc123", "status": "ENQUEUED" } }

# Poll
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/convert-async/status/conv_abc123
```

Status values: `ENQUEUED` → `PROCESSING` → `SUCCESS` | `ERROR`. When `SUCCESS`, the response payload contains the extracted data.

## Batch processing

### CLI

```bash
# Same type for every file
for f in documents/*.pdf; do
  docutray convert "$f" -t electronic-invoice > "${f%.pdf}.json"
done

# Identify each file first, then convert
for f in documents/*.pdf; do
  TYPE=$(docutray identify "$f" --types invoice,receipt,electronic-invoice --json \
    | jq -r '.document_type.code')
  if [ -n "$TYPE" ] && [ "$TYPE" != "null" ]; then
    docutray convert "$f" -t "$TYPE" > "${f%.pdf}.json"
  fi
done
```

### Python (concurrent with the async client)

```python
import asyncio, json
from pathlib import Path
from docutray import AsyncClient

async def main():
    client = AsyncClient()
    pdfs = list(Path("documents").glob("*.pdf"))
    results = await asyncio.gather(
        *[
            client.convert.run(file=p, document_type_code="electronic-invoice")
            for p in pdfs
        ]
    )
    for p, r in zip(pdfs, results):
        p.with_suffix(".json").write_text(json.dumps(r.data))

asyncio.run(main())
```

### Node (concurrent)

```typescript
import { DocuTray } from "docutray";
import { readFileSync } from "node:fs";
import { readdir, writeFile } from "node:fs/promises";
import { join } from "node:path";

const client = new DocuTray();
const files = (await readdir("documents")).filter(f => f.endsWith(".pdf"));

const results = await Promise.all(
  files.map(f =>
    client.convert.run({
      file: readFileSync(join("documents", f)),
      documentTypeCode: "electronic-invoice",
    })
  )
);

for (const [i, r] of results.entries()) {
  await writeFile(`documents/${files[i].replace(/\.pdf$/, ".json")}`, JSON.stringify(r.data));
}
```

## Piping and composition

```bash
# Extract a specific field with jq
docutray convert invoice.pdf -t electronic-invoice | jq '.data.monto_total'

# Save the data subtree only
docutray convert invoice.pdf -t electronic-invoice | jq '.data' > extracted.json

# Chain identify → convert (identify requires --types; its response has no `data` wrapper)
docutray convert doc.pdf \
  -t "$(docutray identify doc.pdf --types invoice,receipt --json | jq -r '.document_type.code')"
```

## Supported file formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
