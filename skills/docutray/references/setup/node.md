# Node SDK Setup — Detailed Reference

Verified against the `docutray` Node SDK **0.1.5**, installed from npm. Snippets are verified by **installing the package and probing the documented call paths**, not by reading the SDK source or its README (the README is known to disagree with the source on `steps.runAsync`).

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
  const page = await client.documentTypes.list();
  console.log(`Authenticated. ${page.data.length} document types on this page.`);
} catch (error) {
  console.error("Authentication failed:", error);
}
```

> **Resources are namespaced.** Calls go through `client.convert.run()`, `client.identify.run()`, `client.documentTypes.list()`, `client.steps.runAsync()` — not `client.convert(...)` or `client.types(...)`. `list()` returns a `Page` with a `.data` array (plus `hasNextPage()`, `iterPages()`, `autoPagingIter()`), not a bare array.

## TypeScript Types

The SDK provides full TypeScript type definitions:

```typescript
import { readFileSync } from "node:fs";
import {
  DocuTray,
  Page,
  ConversionStatus,
  DocumentType,
  // Export-mapping types (docutray@0.1.5+)
  ConversionSpec,
  ConversionSpecColumn,
  ConversionSpecSheet,
  LegacyConversionSpec,
  MultiSheetConversionSpec,
  isMultiSheetConversionSpec,
} from "docutray";

const client = new DocuTray();

// Fully typed responses
const page: Page<DocumentType> = await client.documentTypes.list();
const result: ConversionStatus = await client.convert.run({
  file: readFileSync("invoice.pdf"),
  documentTypeCode: "invoice",
});
console.log(result.data);   // extracted fields, or null on failure
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
  const result = await client.convert.run({
    file: readFileSync("doc.pdf"),
    documentTypeCode: "invoice",
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
import { readFileSync } from "node:fs";

const result = await client.convert.run({
  file: readFileSync("invoice.pdf"),
  documentTypeCode: "invoice",
});
console.log(result.data);
```

Provide exactly one source: `file`, `url`, or `base64`. Optional: `contentType`, `filename`, `documentMetadata`, `webhookUrl`.

### Convert Asynchronously

`runAsync()` returns immediately with a status object carrying a `wait()` method that polls to completion:

```typescript
const status = await client.convert.runAsync({
  url: "https://example.com/invoice.pdf",
  documentTypeCode: "invoice",
});
const result = await status.wait({ onStatus: (s) => console.log(s.status) });
console.log(result.data);

// Or poll manually
const current = await client.convert.getStatus(status.conversion_id);
```

### List Available Document Types

```typescript
const page = await client.documentTypes.list();          // { data, hasNextPage(), … }
for (const t of page.data) {
  console.log(`${t.codeType}: ${t.name}`);
}

// Search, or walk every page
const filtered = await client.documentTypes.list({ search: "invoice" });
for await (const t of client.documentTypes.list().autoPagingIter()) {
  console.log(t.codeType);
}
```

### Get a Specific Document Type

```typescript
// get() takes the internal `id`, not the `codeType` — look it up via list()
const docType = await client.documentTypes.get(docTypeId);
console.log(docType.jsonSchema);
```

`documentTypes` also exposes `create(params)`, `update(id, params)`, and `validate(id, data)`. There is **no** `export()` method — use the CLI's `docutray types export` for that.

### Read a Document Type's Export Spec

`docutray@0.1.5+` exposes `conversionSpec` — the JSON → CSV/Excel column mapping used by tray export — on `DocumentType`, `DocumentTypeCreateParams`, and `DocumentTypeUpdateParams`. It is a union of two shapes, so narrow it with the exported `isMultiSheetConversionSpec()` guard (which accepts `null` / `undefined` and returns `false`, since list responses omit the field):

```typescript
import { isMultiSheetConversionSpec } from "docutray";

// documentTypes.get() takes the internal `id`, not the `codeType`
const docType = await client.documentTypes.get(docTypeId);

if (isMultiSheetConversionSpec(docType.conversionSpec)) {
  console.log(docType.conversionSpec.sheets.map((sheet) => sheet.name));
} else if (docType.conversionSpec) {
  console.log(`${docType.conversionSpec.columns.length} columns`);
}
```

On create/update params: omit `conversionSpec` to leave it unchanged, or pass `null` to clear it. See `../advanced/conversion-spec.md`.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DOCUTRAY_API_KEY` | API key (starts with `dt_live_`) |
| `DOCUTRAY_BASE_URL` | Override base URL (default: `https://app.docutray.com`) |

## Supported File Formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
