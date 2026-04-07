# Steps — Detailed Reference

## Overview

Steps are multi-step processing pipelines that chain DocuTray operations. Pipelines run asynchronously — you submit a job and poll for results.

## Pipeline Execution

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
print(f"Status: {execution.status}")
```

**Node SDK:**

```typescript
const execution = await client.steps.run({
  pipeline: "invoice-pipeline",
  inputFile: "invoice.pdf",
});
console.log(`Execution ID: ${execution.id}`);
console.log(`Status: ${execution.status}`);
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
    "status": "ENQUEUED",
    "pipeline": "invoice-pipeline"
  }
}
```

## Status Monitoring

### Check Pipeline Status

**CLI:**

```bash
docutray steps status exec_abc123
```

**Python SDK:**

```python
status = client.steps.status("exec_abc123")
print(f"Status: {status.status}")
print(f"Progress: {status.progress}")
print(f"Current step: {status.current_step}")
```

**Node SDK:**

```typescript
const status = await client.steps.status("exec_abc123");
console.log(`Status: ${status.status}`);
console.log(`Progress: ${status.progress}`);
console.log(`Current step: ${status.currentStep}`);
```

**REST API:**

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/steps/status/exec_abc123
```

### Status Values

| Status | Description |
|--------|-------------|
| `ENQUEUED` | Pipeline submitted, waiting to start |
| `PROCESSING` | Pipeline is running, check `progress` for details |
| `SUCCESS` | Pipeline completed successfully |
| `ERROR` | Pipeline failed, check `error` field for details |

### Status Response (Processing)

```json
{
  "success": true,
  "data": {
    "execution_id": "exec_abc123",
    "status": "PROCESSING",
    "pipeline": "invoice-pipeline",
    "progress": {
      "current_step": 2,
      "total_steps": 4,
      "step_name": "extract_fields",
      "percentage": 50
    }
  }
}
```

### Status Response (Success)

```json
{
  "success": true,
  "data": {
    "execution_id": "exec_abc123",
    "status": "SUCCESS",
    "pipeline": "invoice-pipeline",
    "result": {
      "document_type": "invoice",
      "fields": {
        "invoice_number": "INV-2024-001",
        "total": 1500.00
      },
      "validations": {
        "passed": true,
        "checks": 5
      }
    }
  }
}
```

### Status Response (Error)

```json
{
  "success": true,
  "data": {
    "execution_id": "exec_abc123",
    "status": "ERROR",
    "pipeline": "invoice-pipeline",
    "error": {
      "step": "extract_fields",
      "code": "EXTRACTION_FAILED",
      "message": "Could not extract required field 'invoice_number'"
    }
  }
}
```

## Polling Patterns

### Python SDK — Wait for Completion

```python
import time

execution = client.steps.run(pipeline="invoice-pipeline", input_file="doc.pdf")

while True:
    status = client.steps.status(execution.id)
    if status.status in ("SUCCESS", "ERROR"):
        break
    print(f"Progress: {status.progress.percentage}%")
    time.sleep(2)

if status.status == "SUCCESS":
    print(status.result)
else:
    print(f"Failed at step '{status.error.step}': {status.error.message}")
```

### Node SDK — Wait with Timeout

```typescript
const execution = await client.steps.run({
  pipeline: "invoice-pipeline",
  inputFile: "doc.pdf",
});

const timeout = 60_000; // 60 seconds
const start = Date.now();

while (Date.now() - start < timeout) {
  const status = await client.steps.status(execution.id);
  if (status.status === "SUCCESS") {
    console.log(status.result);
    break;
  }
  if (status.status === "ERROR") {
    console.error(`Failed: ${status.error.message}`);
    break;
  }
  await new Promise((r) => setTimeout(r, 2000));
}
```

### CLI — Poll in a Script

```bash
EXEC_ID=$(docutray steps run invoice-pipeline --input doc.pdf | jq -r '.data.execution_id')

while true; do
  STATUS=$(docutray steps status "$EXEC_ID" | jq -r '.data.status')
  case "$STATUS" in
    SUCCESS) docutray steps status "$EXEC_ID" | jq '.data.result'; break ;;
    ERROR)   docutray steps status "$EXEC_ID" | jq '.data.error'; break ;;
    *)       echo "Status: $STATUS"; sleep 2 ;;
  esac
done
```

## Error Recovery

### Retry on Failure

If a pipeline fails on a transient error (e.g., timeout, rate limit), retry the execution:

```python
from docutray.exceptions import APIError

MAX_RETRIES = 3

for attempt in range(MAX_RETRIES):
    try:
        execution = client.steps.run(pipeline="invoice-pipeline", input_file="doc.pdf")
        # ... poll for completion ...
        break
    except APIError as e:
        if attempt == MAX_RETRIES - 1:
            raise
        print(f"Attempt {attempt + 1} failed: {e.message}. Retrying...")
```

### Common Pipeline Errors

| Error Code | Cause | Fix |
|------------|-------|-----|
| `PIPELINE_NOT_FOUND` | Pipeline name doesn't exist | Verify pipeline name in your account |
| `EXTRACTION_FAILED` | Could not extract required fields | Check document quality and type match |
| `VALIDATION_FAILED` | Extracted data failed validation | Review schema constraints |
| `TIMEOUT` | Step took too long | Retry or check file size |
| `RATE_LIMITED` | Too many concurrent executions | Wait and retry with backoff |
