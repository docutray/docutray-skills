# Node SDK Setup — Detailed Reference

## Installation

```bash
npm install docutray
```

Or with other package managers:

```bash
# Yarn
yarn add docutray

# pnpm
pnpm add docutray
```

**Requirements:** Node.js 20+

## Client Initialization

```typescript
import { DocuTray } from "docutray";

// Using env var DOCUTRAY_API_KEY (recommended)
const client = new DocuTray();

// Explicit API key
const client = new DocuTray({ apiKey: "dt_live_your_key_here" });

// Custom base URL (staging)
const client = new DocuTray({ baseUrl: "https://staging.docutray.com" });

// Combined options
const client = new DocuTray({
  apiKey: "dt_live_your_key_here",
  baseUrl: "https://staging.docutray.com",
});
```

## Authentication Priority

The SDK resolves the API key in this order:

1. `apiKey` option passed to `new DocuTray()`
2. `DOCUTRAY_API_KEY` environment variable

If neither is set, the client throws `AuthenticationError` on the first API call.

## Verification

```typescript
import { DocuTray } from "docutray";

const client = new DocuTray();

try {
  const types = await client.types.list();
  console.log(`Authenticated. ${types.length} document types available.`);
} catch (error) {
  console.error("Authentication failed:", error);
}
```

## TypeScript Types

The SDK provides full TypeScript type definitions:

```typescript
import {
  DocuTray,
  ConvertResult,
  DocumentType,
  DocumentTypeSchema,
} from "docutray";

const client = new DocuTray();

// Fully typed responses
const types: DocumentType[] = await client.types.list();
const result: ConvertResult = await client.convert({
  filePath: "invoice.pdf",
  documentType: "invoice",
});
```

## Error Handling

```typescript
import { DocuTray } from "docutray";
import {
  AuthenticationError,
  NotFoundError,
  RateLimitError,
  APIError,
} from "docutray";

const client = new DocuTray();

try {
  const result = await client.convert({
    filePath: "doc.pdf",
    documentType: "invoice",
  });
} catch (error) {
  if (error instanceof AuthenticationError) {
    // 401 — invalid or missing API key
    console.error("Check your DOCUTRAY_API_KEY");
  } else if (error instanceof NotFoundError) {
    // 404 — document type not found
    console.error("Document type does not exist");
  } else if (error instanceof RateLimitError) {
    // 429 — too many requests
    console.error(`Rate limited. Retry after ${error.retryAfter}s`);
  } else if (error instanceof APIError) {
    // Other API errors (500, etc.)
    console.error(`API error ${error.statusCode}: ${error.message}`);
  }
}
```

## Common Patterns

### Convert a Document

```typescript
const result = await client.convert({
  filePath: "invoice.pdf",
  documentType: "invoice",
});
console.log(result.data);
```

### Convert with Buffer

```typescript
import { readFileSync } from "fs";

const buffer = readFileSync("invoice.pdf");
const result = await client.convert({
  file: buffer,
  fileName: "invoice.pdf",
  documentType: "invoice",
});
```

### List Available Document Types

```typescript
const types = await client.types.list();
for (const t of types) {
  console.log(`${t.name}: ${t.description}`);
}
```

### Get a Specific Document Type

```typescript
const docType = await client.types.get("invoice");
console.log(docType.schema);
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DOCUTRAY_API_KEY` | API key (starts with `dt_live_`) |
| `DOCUTRAY_BASE_URL` | Override base URL (default: `https://app.docutray.com`) |

## Supported File Formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
