# REST API setup — detailed reference

DocuTray's REST API is what the CLI and SDKs talk to under the hood.

**Verification scope.** Checked against the live API: `GET /api/document-types` (path, `data` envelope, item fields), `GET /api/document-types/{id}` (id-not-code, envelope, full payload including `conversionSpec`), and `POST /api/identify` (`image` part, required candidate list, envelope-free response shape). **Not re-verified:** `POST /api/convert`, the `steps` endpoints, and `GET /api/status` — their shapes below are inherited from earlier documentation; hit the endpoint and inspect before relying on them.

**Envelopes are not uniform.** Document-type reads wrap the object in `data`; `identify` returns its fields at the top level. Don't generalize one endpoint's envelope to another.

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
  https://app.docutray.com/api/document-types
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
GET /api/document-types/{id}
```

> **This endpoint takes the internal `id`, not the `codeType`.** Passing a code returns `404` — verified against the live API. The CLI accepts a code because it resolves code→id for you; over REST, get the `id` from the list endpoint first.

**Response** — the full type definition, wrapped in a `data` envelope:

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
    "jsonSchema": { "type": "object", "properties": { "…": {} } },
    "promptHints": "…",
    "identifyPromptHints": "",
    "conversionMode": "json",
    "keepPropertyOrdering": false,
    "conversionSpec": { "sheets": [ { "name": "…", "columns": [] } ] },
    "createdAt": "2025-06-19T16:35:43.856Z",
    "updatedAt": "2025-08-19T13:50:37.744Z"
  }
}
```

**Envelope differs from the CLI.** REST wraps the type in `data`; `docutray types get` / `types export` unwrap it and print the same object **flat**. So it's `jq .data.jsonSchema` over REST but `jq .jsonSchema` via the CLI.

`conversionSpec` (the JSON → CSV/Excel export mapping) is carried on `GET`, `POST`, and `PUT` of `/api/document-types` — sent in the request body on create and update, returned inside `data` on the single-type endpoint, and **absent from the list endpoint**. It requires an API deployment that supports the field; an older deployment accepts and silently discards it. See `../advanced/conversion-spec.md`.

### Convert Document

```
POST /api/convert
Content-Type: multipart/form-data
```

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | binary | Yes | Document file (JPEG, PNG, GIF, BMP, WebP, PDF) |
| `document_type` | string | Yes | Code of the document type to extract with |

> **The file part is named `image`, not `file`.** Confirmed from the live `identify` endpoint's rejection of a `file` part and from the SDKs, which upload every document under the same `image` field. The `convert` endpoint itself was **not** separately re-run — if a request fails validation here, check the part name first.

**Example:**

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "image=@invoice.pdf" \
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
| `image` | binary | Yes | Document file to identify (JPEG, PNG, GIF, BMP, WebP, PDF) |
| `document_type_code_options` | string | Yes in practice | JSON-encoded array of candidate `codeType` values, e.g. `["factura","oc"]` |

> **The file part is named `image`, not `file`** — even for PDFs. A part named `file` is rejected with `{"message":"Validation error","errors":["Image file is required"]}`.
>
> **A candidate list is required in practice**, mirroring the CLI's `--types`: without `document_type_code_options` the API returns a validation error.

**Example:**

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "image=@document.pdf" \
  -F 'document_type_code_options=["factura","boleta_honorarios","oc"]' \
  https://app.docutray.com/api/identify
```

**Response** — verified against the live API. **No `data` envelope**, and `document_type` is an *object*, not a string:

```json
{
  "document_type": {
    "code": "factura",
    "name": "Factura Electrónica",
    "confidence": 1
  },
  "alternatives": [
    { "code": "oc", "name": "Orden de Compra", "confidence": 0.05 },
    { "code": "boleta_honorarios", "name": "Boleta de Honorarios", "confidence": 0.01 },
    { "code": "otro", "name": "Otro/No identificado", "confidence": 0.01 }
  ]
}
```

This is byte-for-byte the shape `docutray identify --json` prints — unlike the document-type endpoints, `identify` has no envelope for the CLI to unwrap. See `../platform/identify.md`.

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
req, _ := http.NewRequest("GET", "https://app.docutray.com/api/document-types", nil)
req.Header.Set("Authorization", "Bearer "+os.Getenv("DOCUTRAY_API_KEY"))
resp, err := http.DefaultClient.Do(req)
```

### Ruby

```ruby
require "net/http"
require "json"

uri = URI("https://app.docutray.com/api/document-types")
req = Net::HTTP::Get.new(uri)
req["Authorization"] = "Bearer #{ENV['DOCUTRAY_API_KEY']}"
res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
data = JSON.parse(res.body)
```

### PHP

```php
$ch = curl_init("https://app.docutray.com/api/document-types");
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer " . getenv("DOCUTRAY_API_KEY"),
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = json_decode(curl_exec($ch));
```
