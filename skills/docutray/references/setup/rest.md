# REST API setup — detailed reference

DocuTray's REST API is what the CLI and SDKs talk to under the hood. The convert response shape below is verified against the live API; other endpoint responses (types list/get, identify, status) include a top-level `data` envelope but their internal shape may evolve — when in doubt, hit the endpoint and inspect.

## Base URL

| Environment | URL |
|-------------|-----|
| Production | `https://app.docutray.com` |
| Staging | `https://staging.docutray.com` |

## Authentication

Include the API key as a Bearer token in every request:

```
Authorization: Bearer dt_live_your_key_here
```

## Verification

```bash
curl -s -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types
```

A `200` response with JSON data confirms authentication.

## Endpoints

### List Document Types

```
GET /api/document-types?limit=20&page=1
```

**Response:**

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
    }
  ],
  "pagination": {
    "total": 27,
    "page": 1,
    "limit": 20
  }
}
```

The identifier field is `codeType` (not `code`). Use it as `--types <codeType>` on `identify` and `-t <codeType>` on `convert`.

### Get document type

```
GET /api/document-types/{codeType}
```

**Response:**

```json
{
  "data": {
    "id": "cmc3lrbzk0007wu01dzjw2zzz",
    "codeType": "factura",
    "name": "Factura Electrónica",
    "description": "Factura Electrónica del SII (Chile)…",
    "isPublic": true,
    "isDraft": false,
    "status": "PUBLISHED",
    "createdAt": "2025-06-19T16:35:43.856Z",
    "updatedAt": "2025-08-19T13:50:37.744Z"
  }
}
```

In `@docutray/cli/0.3.2+`, `docutray types get` and `docutray types export` return the full type definition — including `jsonSchema`, `promptHints`, `identifyPromptHints`, `conversionMode`, and `keepPropertyOrdering` — as a flat object (no `data` envelope). Use the CLI for parity. The exact REST per-type endpoint shape is not re-verified here; treat the CLI as authoritative.

### Convert Document

```
POST /api/convert
Content-Type: multipart/form-data
```

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | binary | Yes | Document file (JPEG, PNG, GIF, BMP, WebP, PDF) |
| `document_type` | string | Yes | Name of the document type to extract |

**Example:**

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@invoice.pdf" \
  -F "document_type=invoice" \
  https://app.docutray.com/api/convert
```

**Response** — top-level `data` whose keys come from the document type's schema. Example values are illustrative; key names depend on the active schema (DocuTray's default org schemas often use Spanish keys like `moneda`, `detalle`, `fecha_emision`):

```json
{
  "data": {
    "invoice_id": "INV-2024-001",
    "moneda": "USD",
    "fecha_emision": "2024-03-15",
    "monto_total": 1500.00,
    "detalle": [
      { "nombre": "Servicio", "cantidad": "1", "precio_total": 1500.00 }
    ]
  }
}
```

### Identify document

```
POST /api/identify
Content-Type: multipart/form-data
```

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | binary | Yes | Document file to identify |

**Example:**

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "file=@document.pdf" \
  https://app.docutray.com/api/identify
```

**Response:**

```json
{
  "data": {
    "document_type": "electronic-invoice",
    "confidence": 0.95,
    "alternatives": [
      { "document_type": "receipt", "confidence": 0.04 }
    ]
  }
}
```

### Check status

```
GET /api/status
```

**Response:**

```json
{
  "data": {
    "authenticated": true,
    "plan": "pro",
    "usage": { "documents": 150, "limit": 10000 }
  }
}
```

## Response format

All successful responses include a top-level `data` field. For `convert`, `data` holds the schema-driven extraction directly (no `fields` envelope). Branch on HTTP status, not on a `success` boolean.

**Errors** use the same envelope with HTTP 4xx/5xx and an `error` object:

```json
{
  "error": {
    "code": "INVALID_API_KEY",
    "message": "The provided API key is invalid"
  }
}
```

## Error Codes

| HTTP Status | Error Code | Description |
|-------------|-----------|-------------|
| 400 | `INVALID_REQUEST` | Malformed request or missing required fields |
| 401 | `INVALID_API_KEY` | Missing or invalid API key |
| 403 | `FORBIDDEN` | Key lacks permissions for this operation |
| 404 | `NOT_FOUND` | Document type or resource not found |
| 413 | `FILE_TOO_LARGE` | File exceeds 100MB limit |
| 415 | `UNSUPPORTED_FORMAT` | File format not supported |
| 429 | `RATE_LIMITED` | Too many requests — check `Retry-After` header |
| 500 | `INTERNAL_ERROR` | Server error — retry with exponential backoff |

## Rate Limiting

When rate limited (429), the response includes a `Retry-After` header with the number of seconds to wait.

## Supported File Formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.

## Examples in Other Languages

### Go

```go
req, _ := http.NewRequest("GET", "https://app.docutray.com/api/types", nil)
req.Header.Set("Authorization", "Bearer "+os.Getenv("DOCUTRAY_API_KEY"))
resp, err := http.DefaultClient.Do(req)
```

### Ruby

```ruby
require "net/http"
require "json"

uri = URI("https://app.docutray.com/api/types")
req = Net::HTTP::Get.new(uri)
req["Authorization"] = "Bearer #{ENV['DOCUTRAY_API_KEY']}"
res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
data = JSON.parse(res.body)
```

### PHP

```php
$ch = curl_init("https://app.docutray.com/api/types");
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer " . getenv("DOCUTRAY_API_KEY"),
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = json_decode(curl_exec($ch));
```
