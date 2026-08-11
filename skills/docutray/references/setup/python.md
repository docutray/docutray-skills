# Python SDK Setup — Detailed Reference

Verified against the `docutray` Python SDK **0.2.1**, installed from PyPI. Snippets are verified by **installing the package and probing the documented call paths**, not by reading the SDK source or its README (the README is known to disagree with the source on `steps.runAsync`).

## Installation

```bash
pip install docutray
```

Or with a package manager:

```bash
# Poetry
poetry add docutray

# PDM
pdm add docutray
```

**Requirements:** Python 3.10+

## Client Initialization

### Synchronous Client

```python
from docutray import Client

# Using env var DOCUTRAY_API_KEY (recommended)
client = Client()

# Explicit API key
client = Client(api_key="dt_live_your_key_here")

# Custom base URL (staging)
client = Client(base_url="https://staging.docutray.com")

# Combined options
client = Client(
    api_key="dt_live_your_key_here",
    base_url="https://staging.docutray.com",
)
```

### Async Client

```python
from docutray import AsyncClient

async def main():
    client = AsyncClient()

    # All methods are async
    page = await client.document_types.list()
    result = await client.convert.run(
        file=Path("invoice.pdf"),
        document_type_code="invoice",
    )
    print(result.data)
```

## Authentication Priority

The SDK resolves the API key in this order:

1. `api_key` parameter passed to `Client()`
2. `DOCUTRAY_API_KEY` environment variable

If neither is set, the client raises `AuthenticationError` on the first API call.

## Verification

```python
from docutray import Client

client = Client()

# List document types to verify auth
try:
    page = client.document_types.list()
    print(f"Authenticated. {len(page.data)} document types on this page.")
except Exception as e:
    print(f"Authentication failed: {e}")
```

> **Resources are namespaced.** Calls go through `client.convert.run()`, `client.identify.run()`, `client.document_types.list()`, `client.steps.run_async()` — not `client.convert(...)` or `client.types(...)`. `list()` returns a `Page` (iterable, with `.data`, `.iter_pages()`, `.auto_paging_iter()`), not a bare list.

## Error Handling

```python
from pathlib import Path

from docutray import (
    Client,
    AuthenticationError,
    NotFoundError,
    RateLimitError,
    APIError,
)

client = Client()

try:
    result = client.convert.run(file=Path("doc.pdf"), document_type_code="invoice")
except AuthenticationError:
    # 401 — invalid or missing API key
    print("Check your DOCUTRAY_API_KEY")
except NotFoundError:
    # 404 — document type not found
    print("Document type does not exist")
except RateLimitError as e:
    # 429 — too many requests
    print(f"Rate limited. Retry after {e.retry_after}s")
except APIError as e:
    # Other API errors (500, etc.)
    print(f"API error {e.status_code}: {e.message}")
```

## Common Patterns

### Convert a Document

```python
from pathlib import Path

result = client.convert.run(
    file=Path("invoice.pdf"),
    document_type_code="invoice",
)
print(result.data)
```

Provide exactly one source: `file`, `url`, or `file_base64`. Optional: `content_type`, `document_metadata`.

### Convert Asynchronously

`run_async()` returns immediately with a status object carrying a `wait()` method that polls to completion:

```python
status = client.convert.run_async(
    url="https://example.com/invoice.pdf",
    document_type_code="invoice",
)
result = status.wait(on_status=lambda s: print(s.status))
print(result.data)

# Or poll manually
current = client.convert.get_status(status.conversion_id)
```

### List Available Document Types

```python
page = client.document_types.list()
for t in page.data:
    print(f"{t.codeType}: {t.name}")

# Search, or walk every item across pages
page = client.document_types.list(search="invoice")
for t in client.document_types.list().auto_paging_iter():
    print(t.codeType)
```

### Get a Specific Document Type

```python
# get() takes the internal id, not the code_type — look it up via list()
doc_type = client.document_types.get(doc_type_id)
print(doc_type.jsonSchema)
```

`document_types` also exposes `create(...)`, `update(...)`, and `validate(...)`. There is **no** `export()` method — use the CLI's `docutray types export` for that.

A document type also carries `conversionSpec` — the JSON → CSV/Excel column mapping used by tray export.

> **The Python SDK cannot write it (as of `docutray` 0.2.1).** `document_types.create()` and `.update()` take explicit keyword arguments only — no `conversion_spec` parameter and no `**kwargs` — so passing one raises `TypeError: unexpected keyword argument`. **Reading** works incidentally, because the `DocumentType` model allows extra fields:
>
> ```python
> doc_type = client.document_types.get(doc_type_id)
> spec = doc_type.model_extra.get("conversionSpec")   # API casing, not snake_case
> ```
>
> To set or clear a spec from a Python project, shell out to `docutray types create/update --conversion-spec` or call the REST endpoint directly. See `../advanced/conversion-spec.md`.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DOCUTRAY_API_KEY` | API key (starts with `dt_live_`) |
| `DOCUTRAY_BASE_URL` | Override base URL (default: `https://app.docutray.com`) |

## Supported File Formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
