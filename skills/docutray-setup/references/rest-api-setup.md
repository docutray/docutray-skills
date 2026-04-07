# REST API Setup — Detailed Reference

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
GET /api/types
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "name": "invoice",
      "description": "Standard invoice document"
    }
  ]
}
```

### Get Document Type

```
GET /api/types/{name}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "name": "invoice",
    "description": "Standard invoice document",
    "schema": { ... }
  }
}
```

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

**Response:**

```json
{
  "success": true,
  "data": {
    "document_type": "invoice",
    "fields": {
      "invoice_number": "INV-2024-001",
      "total": 1500.00
    }
  }
}
```

### Identify Document

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
  "success": true,
  "data": {
    "document_type": "invoice",
    "confidence": 0.95
  }
}
```

### Check Status

```
GET /api/status
```

**Response:**

```json
{
  "success": true,
  "data": {
    "authenticated": true,
    "plan": "pro",
    "usage": { "documents": 150, "limit": 10000 }
  }
}
```

## Response Format

All responses follow this structure:

**Success:**

```json
{
  "success": true,
  "data": { ... }
}
```

**Error:**

```json
{
  "success": false,
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
