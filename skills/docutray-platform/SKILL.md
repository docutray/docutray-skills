---
name: docutray-platform
description: >-
  Core DocuTray platform usage: convert documents to structured data, identify
  document types automatically, list and manage extraction schemas with types
  commands, and run processing pipelines with steps. Use this skill when working
  with docutray convert, docutray identify, docutray types, or docutray steps.
---

# DocuTray Platform

Core commands for document processing. Assumes DocuTray is already set up (see `docutray-setup` skill for installation and authentication).

## 1. Convert

Convert a document (PDF, image) into structured JSON data using an extraction schema.

### CLI

```bash
# Basic conversion
docutray convert invoice.pdf --type invoice

# Save output to a file
docutray convert invoice.pdf --type invoice --output result.json

# Output as CSV
docutray convert invoice.pdf --type invoice --format csv
```

**Options:**

| Flag | Description |
|------|-------------|
| `--type`, `-t` | Document type to extract (required) |
| `--output`, `-o` | Output file path (default: stdout) |
| `--format` | Output format: `json` (default), `csv` |

### Python SDK

```python
# Synchronous
result = client.convert(file_path="invoice.pdf", document_type="invoice")
print(result.data)

# Async
result = await async_client.convert(file_path="invoice.pdf", document_type="invoice")
```

### Node SDK

```typescript
const result = await client.convert({
  filePath: "invoice.pdf",
  documentType: "invoice",
});
console.log(result.data);
```

### REST API

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@invoice.pdf" \
  -F "document_type=invoice" \
  https://app.docutray.com/api/convert
```

**Response:**

```json
{
  "success": true,
  "data": {
    "document_type": "invoice",
    "fields": {
      "invoice_number": "INV-2024-001",
      "date": "2024-03-15",
      "total": 1500.00,
      "vendor": "Acme Corp"
    }
  }
}
```

> **Details:** @references/convert-reference.md — async conversion, file bytes/buffer input, batch processing, output formats

## 2. Identify

Detect the document type of a file automatically. Returns the best match with a confidence score.

### CLI

```bash
docutray identify unknown-document.pdf
```

**Output:**

```json
{
  "success": true,
  "data": {
    "document_type": "invoice",
    "confidence": 0.95
  }
}
```

### Python SDK

```python
result = client.identify(file_path="unknown-document.pdf")
print(f"Type: {result.data.document_type}, Confidence: {result.data.confidence}")
```

### Node SDK

```typescript
const result = await client.identify({ filePath: "unknown-document.pdf" });
console.log(`Type: ${result.data.documentType}, Confidence: ${result.data.confidence}`);
```

### REST API

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@unknown-document.pdf" \
  https://app.docutray.com/api/identify
```

**Confidence scores:**
- `0.9–1.0` — High confidence, safe to use directly with `convert`
- `0.7–0.9` — Moderate confidence, review recommended
- `< 0.7` — Low confidence, manual verification needed

## 3. Types

Manage document extraction schemas — the templates that define what fields to extract from each document type.

### List All Types

**CLI:**

```bash
docutray types list
```

**Python SDK:**

```python
types = client.types.list()
for t in types:
    print(f"{t.name}: {t.description}")
```

**Node SDK:**

```typescript
const types = await client.types.list();
for (const t of types) {
  console.log(`${t.name}: ${t.description}`);
}
```

**REST API:**

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types
```

### Get Type Details

Retrieve a single document type with its extraction schema.

**CLI:**

```bash
docutray types get invoice
```

**Python SDK:**

```python
doc_type = client.types.get("invoice")
print(doc_type.schema)
```

**Node SDK:**

```typescript
const docType = await client.types.get("invoice");
console.log(docType.schema);
```

**REST API:**

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types/invoice
```

**Response:**

```json
{
  "success": true,
  "data": {
    "name": "invoice",
    "description": "Standard invoice document",
    "schema": {
      "fields": [
        { "name": "invoice_number", "type": "string", "required": true },
        { "name": "date", "type": "date", "required": true },
        { "name": "total", "type": "number", "required": true },
        { "name": "vendor", "type": "string", "required": false }
      ]
    }
  }
}
```

### Export Type Schema

Export a document type's schema as a standalone JSON file.

**CLI:**

```bash
# Export to stdout
docutray types export invoice

# Save to file
docutray types export invoice --output invoice-schema.json
```

**Python SDK:**

```python
schema = client.types.export("invoice")
```

**Node SDK:**

```typescript
const schema = await client.types.export("invoice");
```

**REST API:**

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types/invoice/export
```

> **Details:** @references/types-reference.md — schema structure, field types, validation, managing custom types

## 4. Steps

Run multi-step processing pipelines that chain operations (e.g., identify → convert → validate → store).

### Run a Pipeline

**CLI:**

```bash
docutray steps run invoice-pipeline --input invoice.pdf
```

**Python SDK:**

```python
execution = client.steps.run(
    pipeline="invoice-pipeline",
    input_file="invoice.pdf",
)
print(f"Execution ID: {execution.id}")
```

**Node SDK:**

```typescript
const execution = await client.steps.run({
  pipeline: "invoice-pipeline",
  inputFile: "invoice.pdf",
});
console.log(`Execution ID: ${execution.id}`);
```

**REST API:**

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "pipeline=invoice-pipeline" \
  -F "file=@invoice.pdf" \
  https://app.docutray.com/api/steps
```

**Response:**

```json
{
  "success": true,
  "data": {
    "execution_id": "exec_abc123",
    "status": "ENQUEUED"
  }
}
```

### Check Pipeline Status

**CLI:**

```bash
docutray steps status exec_abc123
```

**Python SDK:**

```python
status = client.steps.status("exec_abc123")
print(f"Status: {status.status}, Progress: {status.progress}")
```

**Node SDK:**

```typescript
const status = await client.steps.status("exec_abc123");
console.log(`Status: ${status.status}, Progress: ${status.progress}`);
```

**REST API:**

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/steps/status/exec_abc123
```

**Status values:** `ENQUEUED` → `PROCESSING` → `SUCCESS` | `ERROR`

> **Details:** @references/steps-reference.md — pipeline configuration, step types, polling patterns, error recovery

## 5. Common Patterns

### Identify Then Convert

When the document type is unknown, chain `identify` and `convert`:

**CLI:**

```bash
TYPE=$(docutray identify document.pdf | jq -r '.data.document_type')
docutray convert document.pdf --type "$TYPE"
```

**Python SDK:**

```python
identified = client.identify(file_path="document.pdf")
result = client.convert(
    file_path="document.pdf",
    document_type=identified.data.document_type,
)
```

**Node SDK:**

```typescript
const identified = await client.identify({ filePath: "document.pdf" });
const result = await client.convert({
  filePath: "document.pdf",
  documentType: identified.data.documentType,
});
```

### Batch Processing

Process multiple files in a directory:

**CLI (Bash):**

```bash
for f in documents/*.pdf; do
  docutray convert "$f" --type invoice --output "${f%.pdf}.json"
done
```

**Python SDK:**

```python
import json
from pathlib import Path

for pdf in Path("documents").glob("*.pdf"):
    result = client.convert(file_path=str(pdf), document_type="invoice")
    pdf.with_suffix(".json").write_text(json.dumps(result.data))
```

### Inspect Available Types Before Converting

```bash
# List all types, then get schema details for one
docutray types list
docutray types get invoice
# Now convert with confidence
docutray convert invoice.pdf --type invoice
```

## 6. Error Handling

### Common Errors

| Symptom | Cause | Fix |
|---------|-------|-----|
| `401 Unauthorized` | Invalid or missing API key | Verify key starts with `dt_live_` and is set correctly |
| `404 Not Found` on convert | Document type doesn't exist | Run `docutray types list` to see available types |
| `415 Unsupported Format` | File format not supported | Use JPEG, PNG, GIF, BMP, WebP, or PDF |
| `413 File Too Large` | File exceeds 100MB limit | Reduce file size or split multi-page PDFs |
| `429 Rate Limited` | Too many requests | Wait for `Retry-After` seconds, then retry |
| `PROCESSING` stuck | Pipeline step failed | Check `docutray steps status <id>` for error details |
| Low confidence on identify | Document doesn't match known types | Check available types or create a custom type |

### Error Response Format

All errors follow a consistent format:

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Document type 'invoce' not found. Did you mean 'invoice'?"
  }
}
```

> For the full error code reference, see `@references/rest-api-setup.md` in the `docutray-setup` skill.

## Technical Reference

| Detail | Value |
|--------|-------|
| Supported formats | JPEG, PNG, GIF, BMP, WebP, PDF |
| Max file size | 100MB |
| Response format | `{ "success": true, "data": {...} }` |
| Base URL | `https://app.docutray.com` |
| API prefix | `/api/` (endpoints include this prefix) |
| Auth header | `Authorization: Bearer <key>` |
| Pipeline statuses | `ENQUEUED` → `PROCESSING` → `SUCCESS` \| `ERROR` |
