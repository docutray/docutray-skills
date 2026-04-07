# Python SDK Setup — Detailed Reference

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
    types = await client.types.list()
    result = await client.convert(
        file_path="invoice.pdf",
        document_type="invoice",
    )
    print(result)
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
    types = client.types.list()
    print(f"Authenticated. {len(types)} document types available.")
except Exception as e:
    print(f"Authentication failed: {e}")
```

## Error Handling

```python
from docutray import Client
from docutray.exceptions import (
    AuthenticationError,
    NotFoundError,
    RateLimitError,
    APIError,
)

client = Client()

try:
    result = client.convert(file_path="doc.pdf", document_type="invoice")
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
result = client.convert(
    file_path="invoice.pdf",
    document_type="invoice",
)
print(result.data)
```

### Convert with File Bytes

```python
with open("invoice.pdf", "rb") as f:
    result = client.convert(
        file=f.read(),
        file_name="invoice.pdf",
        document_type="invoice",
    )
```

### List Available Document Types

```python
types = client.types.list()
for t in types:
    print(f"{t.name}: {t.description}")
```

### Get a Specific Document Type

```python
doc_type = client.types.get("invoice")
print(doc_type.schema)
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DOCUTRAY_API_KEY` | API key (starts with `dt_live_`) |
| `DOCUTRAY_BASE_URL` | Override base URL (default: `https://app.docutray.com`) |

## Supported File Formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
