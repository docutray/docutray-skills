# Steps — detailed reference

Execute and monitor processing steps. Steps are reusable processing pipelines configured in the DocuTray dashboard; the CLI/SDK/REST surface lets you run a step on a document and poll its execution status.

Verified against `@docutray/cli/0.2.1`. Run `docutray steps run --help` and `docutray steps status --help` to confirm.

## CLI

### `steps run`

```bash
$ docutray steps run --help
USAGE
  $ docutray steps:run STEP-ID SOURCE [--json] [--metadata <value>]
    [--no-wait] [--webhook-url <value>]

ARGUMENTS
  STEP-ID  Step ID to execute
  SOURCE   File path or URL to process
```

| Flag | Description |
|---|---|
| `--no-wait` | Return immediately with execution status instead of waiting (default: wait) |
| `--json` | Force JSON output (default when piped) |
| `--metadata=<json>` | Attach JSON metadata to the execution |
| `--webhook-url=<url>` | POST a notification when the step completes |

There is **no** `--input` flag — `SOURCE` is a positional argument (file path **or** public URL). The default behavior is to wait for completion; use `--no-wait` for fire-and-forget plus polling.

```bash
# Run and wait for results
docutray steps run extract-fields invoice.pdf

# Run on a URL
docutray steps run extract-fields https://example.com/doc.pdf

# Async — return immediately with execution status
docutray steps run extract-fields invoice.pdf --no-wait

# Attach metadata + webhook
docutray steps run extract-fields invoice.pdf \
  --metadata '{"ref":"order-123"}' \
  --webhook-url https://example.com/hook
```

### `steps status`

```bash
$ docutray steps status --help
USAGE
  $ docutray steps:status EXECUTION-ID [--json]

ARGUMENTS
  EXECUTION-ID  Step execution ID to query
```

```bash
docutray steps status exec_abc123
docutray steps status exec_abc123 --json
```

Chain a `--no-wait` run with status polling:

```bash
docutray steps run extract-fields doc.pdf --no-wait \
  | jq -r .id \
  | xargs docutray steps status
```

## Status values

| Status | Description |
|---|---|
| `ENQUEUED` | Submitted, waiting to start |
| `PROCESSING` | Running — check `progress` for details |
| `SUCCESS` | Completed; result is in the response payload |
| `ERROR` | Failed; details are in the response `error` field |

### Response shapes

`PROCESSING`:

```json
{
  "data": {
    "execution_id": "exec_abc123",
    "status": "PROCESSING",
    "step_id": "extract-fields",
    "progress": {
      "current_step": 2,
      "total_steps": 4,
      "step_name": "extract_fields",
      "percentage": 50
    }
  }
}
```

`SUCCESS`:

```json
{
  "data": {
    "execution_id": "exec_abc123",
    "status": "SUCCESS",
    "step_id": "extract-fields",
    "result": {
      "data": {
        "moneda": "USD",
        "monto_total": 1500.00
      }
    }
  }
}
```

`ERROR`:

```json
{
  "data": {
    "execution_id": "exec_abc123",
    "status": "ERROR",
    "step_id": "extract-fields",
    "error": {
      "step": "extract_fields",
      "code": "EXTRACTION_FAILED",
      "message": "Could not extract required field 'invoice_number'"
    }
  }
}
```

## SDK equivalents

### Python

```python
from docutray import Client

client = Client()

# Default: waits for completion
execution = client.steps.run(step_id="extract-fields", source="invoice.pdf")
print(execution.id, execution.status)

# Async (no_wait)
execution = client.steps.run(step_id="extract-fields", source="invoice.pdf", no_wait=True)

# Poll
status = client.steps.status(execution.id)
print(status.status)
```

### Node

```typescript
import { DocuTray } from "docutray";

const client = new DocuTray();

// Default: waits
const execution = await client.steps.run({
  stepId: "extract-fields",
  source: "invoice.pdf",
});

// Async
const execution2 = await client.steps.run({
  stepId: "extract-fields",
  source: "invoice.pdf",
  noWait: true,
});

const status = await client.steps.status(execution2.id);
console.log(status.status);
```

## REST API

```bash
# Run
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -F "step_id=extract-fields" \
  -F "file=@invoice.pdf" \
  https://app.docutray.com/api/steps

# Status
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/steps/status/exec_abc123
```

URL reference:

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"step_id": "extract-fields", "url": "https://example.com/doc.pdf"}' \
  https://app.docutray.com/api/steps
```

## Polling patterns

### CLI

```bash
EXEC_ID=$(docutray steps run extract-fields doc.pdf --no-wait --json | jq -r '.data.execution_id')

while true; do
  STATUS=$(docutray steps status "$EXEC_ID" --json | jq -r '.data.status')
  case "$STATUS" in
    SUCCESS) docutray steps status "$EXEC_ID" --json | jq '.data.result'; break ;;
    ERROR)   docutray steps status "$EXEC_ID" --json | jq '.data.error';  exit 1 ;;
    *)       echo "Status: $STATUS"; sleep 2 ;;
  esac
done
```

### Python

```python
import time

execution = client.steps.run(step_id="extract-fields", source="doc.pdf", no_wait=True)
while True:
    status = client.steps.status(execution.id)
    if status.status in ("SUCCESS", "ERROR"):
        break
    time.sleep(2)

if status.status == "SUCCESS":
    print(status.result)
else:
    print(f"Failed at {status.error.step}: {status.error.message}")
```

### Node (with timeout)

```typescript
const execution = await client.steps.run({
  stepId: "extract-fields",
  source: "doc.pdf",
  noWait: true,
});

const timeout = 60_000;
const start = Date.now();

while (Date.now() - start < timeout) {
  const status = await client.steps.status(execution.id);
  if (status.status === "SUCCESS") { console.log(status.result); break; }
  if (status.status === "ERROR")   { console.error(status.error.message); break; }
  await new Promise(r => setTimeout(r, 2000));
}
```

## Error recovery

### Common pipeline errors

| Error code | Cause | Fix |
|---|---|---|
| `STEP_NOT_FOUND` | Step ID doesn't exist | Verify the step ID in the dashboard |
| `EXTRACTION_FAILED` | Could not extract required fields | Check document quality and type match |
| `VALIDATION_FAILED` | Extracted data failed validation | Review schema constraints / validation rules |
| `TIMEOUT` | Step took too long | Retry, or use `--webhook-url` instead of polling |
| `RATE_LIMITED` | Too many concurrent executions | Wait, then retry with backoff |

### Retry on transient failure

```python
from docutray.exceptions import APIError

MAX_RETRIES = 3
for attempt in range(MAX_RETRIES):
    try:
        execution = client.steps.run(step_id="extract-fields", source="doc.pdf")
        break
    except APIError as e:
        if attempt == MAX_RETRIES - 1:
            raise
        time.sleep(2 ** attempt)  # exponential backoff
```

## Webhook delivery

When `--webhook-url` is set, DocuTray POSTs to that URL on completion with the same `data` payload as `steps status`. Use this instead of polling for long-running steps.
