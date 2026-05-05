---
name: docutray
description: >-
  Use docutray-cli (or the Python/Node SDKs / REST API) to convert documents to
  structured data, identify document types, manage extraction schemas (types),
  run processing steps, and create custom document types. Covers install,
  authentication (DOCUTRAY_API_KEY, docutray login, OAuth, --base-url for
  staging), and troubleshooting. Use this skill whenever a task involves
  docutray, document conversion, document-type identification, or extraction
  schemas.
---

# DocuTray

DocuTray is an AI-powered document processing platform. The CLI (`@docutray/cli`) and SDKs convert documents (PDF, JPEG, PNG, GIF, BMP, WebP) into structured JSON using extraction schemas called **document types**.

## When to use this skill

Use it for any task that touches DocuTray: setting up auth, converting documents, identifying document types, listing or inspecting types, running processing steps, or designing custom document types and schemas.

The CLI is the canonical interface in this skill. Python, Node, and REST equivalents live in `references/`.

## 1. Setup

### 1.1 Detect the integration path

| Project marker | Integration path | Reference |
|---|---|---|
| Agent / shell / no project | **CLI** (default) | `references/setup/cli.md` |
| `pyproject.toml` or `requirements.txt` | Python SDK | `references/setup/python.md` |
| `package.json` or `tsconfig.json` | Node SDK | `references/setup/node.md` |
| Other languages | REST API | `references/setup/rest.md` |

For agents working without a project context, default to the **CLI** path.

### 1.2 Get an API key

1. Open **app.docutray.com** → **Account** → **API Keys**.
2. Click **Create API Key**.
3. Copy the key (starts with `dt_live_`). It is shown only once.

Never hardcode keys. Use `DOCUTRAY_API_KEY`.

### 1.3 Authenticate (CLI)

The recommended path is the env var — it works in any shell, including agent shells, and overrides any stored config:

```bash
export DOCUTRAY_API_KEY="dt_live_your_key_here"
```

`docutray login` is the alternative. **Important:** `docutray login` requires a TTY. Inside an agent shell or CI it errors with `Non-interactive mode requires --api-key flag or api-key argument`. Use one of the non-interactive forms:

```bash
# Non-interactive: flag form
docutray login --api-key dt_live_your_key_here

# Non-interactive: positional form
docutray login dt_live_your_key_here

# Or: have the user run interactive login in their own terminal
# (with `! docutray login` in Claude Code)
docutray login
```

For staging:

```bash
docutray login --base-url https://staging.docutray.com
# or
docutray --base-url https://staging.docutray.com status
```

Credentials live at `~/.config/docutray/config.json`. The env var takes precedence when both are set.

### 1.4 Verify

```bash
docutray status
```

Successful output shows `authenticated: true`, the masked API key, the credential source (env var or config file), and the active base URL. If a user authenticated in another terminal, run `docutray status` to confirm.

> **SDK and REST setup details:** see `references/setup/{python,node,rest}.md`. **Troubleshooting:** see `references/setup/troubleshooting.md`.

## 2. Convert

Convert a document to structured JSON using a document type code.

```bash
# Synchronous (default) — output goes to stdout as JSON
docutray convert invoice.pdf --type electronic-invoice

# Save to a file via shell redirection
docutray convert invoice.pdf -t electronic-invoice > result.json

# A public URL is also accepted as the source
docutray convert https://example.com/doc.pdf -t electronic-invoice

# Async with status updates on stderr (useful for large docs)
docutray convert large-doc.pdf -t electronic-invoice --async --timeout 600

# Webhook notification on completion
docutray convert receipt.jpg -t receipt --webhook-url https://example.com/hook

# Attach metadata
docutray convert invoice.pdf -t electronic-invoice \
  --metadata '{"ref":"order-123"}'
```

**Flags** (full list — there is no `--output` and no `--format`; save to file with shell redirection):

| Flag | Required | Description |
|---|---|---|
| `-t`, `--type=<code>` | yes | Document type code (run `docutray types list` to see available codes) |
| `--async` | no | Use async polling; status updates are emitted to stderr |
| `--json` | no | Force JSON output (default when piped) |
| `--metadata=<json>` | no | Attach JSON metadata to the conversion |
| `--timeout=<seconds>` | no | Polling timeout for async (default 300) |
| `--webhook-url=<url>` | no | POST a notification when conversion completes |

**Response shape** — top-level `data` whose keys come from the active document-type schema. Example values are illustrative and depend on the schema (DocuTray's default org schemas often use Spanish keys):

```json
{
  "data": {
    "moneda": "EUR",
    "fecha_emision": "2026-04-12",
    "total": 1500.00,
    "detalle": [
      { "descripcion": "Servicios", "cantidad": 1, "importe": 1500.00 }
    ]
  }
}
```

> **Depth:** `references/platform/convert.md` — async patterns, SDK/REST equivalents, batch processing, error recovery.

## 3. Identify

Detect the best-matching document type for a file or URL. Returns the top match with a confidence score plus alternative candidates.

```bash
# Local file
docutray identify document.pdf

# URL
docutray identify https://example.com/doc.pdf

# Restrict to a candidate set
docutray identify document.pdf --types invoice,receipt,contract

# Async with status polling
docutray identify document.pdf --async
```

**Flags**: `--async`, `--json`, `--types <comma-separated codes>`. There is no `--output` flag.

**Confidence interpretation:**

- `>= 0.9` — high; safe to feed straight into `convert`.
- `0.7 – 0.9` — moderate; review or ask the user.
- `< 0.7` — low; verify manually or check whether a custom type is needed.

> **Depth:** `references/platform/identify.md`.

## 4. Types

Read-only operations. To create or update types, see Section 6 (Custom Types).

```bash
# List (paginated, search by name)
docutray types list
docutray types list --search invoice
docutray types list --limit 50 --page 2

# Get details for a single type
docutray types get electronic-invoice

# Export a type definition as JSON
docutray types export electronic-invoice                 # to stdout
docutray types export electronic-invoice -o invoice.json # to file
docutray types export electronic-invoice --force -o invoice.json
```

**Subcommands**: `list`, `get`, `export`, `create`, `update`. (No `view` or `delete` subcommand exists — use `get` for inspection; type lifecycle is managed via `--draft` / `--publish` on `update`, or via the dashboard.)

`types export` is the only command in this section that supports `-o, --output` (and `--force` for overwrite). `convert` does not.

> **Depth:** `references/platform/types.md` — schema structure, field types, SDK/REST equivalents.

## 5. Steps

Execute and monitor processing pipelines configured in the DocuTray dashboard.

```bash
# Run a step on a local file (waits for completion by default)
docutray steps run extract-fields invoice.pdf

# Run on a URL
docutray steps run extract-fields https://example.com/doc.pdf

# Async — return immediately with execution status
docutray steps run extract-fields invoice.pdf --no-wait

# Attach metadata or a webhook
docutray steps run extract-fields invoice.pdf \
  --metadata '{"ref":"order-123"}' \
  --webhook-url https://example.com/hook

# Check the status of an async execution
docutray steps status exec_abc123
```

**`steps run` flags:** `--no-wait`, `--json`, `--metadata`, `--webhook-url`. **`steps status` flag:** `--json`.

> **Depth:** `references/platform/steps.md` — pipeline configuration, polling patterns, error recovery.

## 6. Custom Types (advanced)

When no existing type fits, design a new document type. The high-level flow:

1. **Check first.** Run `docutray types list --search <term>` and `docutray identify <file>` before creating anything.
2. **Decide.** High-confidence existing match → use it. Partial match → ask the user (modify or create new). No match → create new.
3. **Gather progressively.** Don't dump every question at once: name/code → main fields → additional fields & tabular data → prompt hints → review → execute.
4. **Create or update.** Use `docutray types create` (full flag set) or `docutray types update <code>`. Both accept `--schema` (file path or inline JSON), `--name`, `--description`, `--prompt-hints`, `--identify-hints`, `--conversion-mode {json|toon|multi_prompt}`, `--keep-ordering`, `--publish`/`--draft`. `create` additionally requires `--code`.
5. **Test.** Run `docutray convert <sample> -t <code>` and iterate.

```bash
docutray types create \
  --name "Custom Invoice" \
  --code custom-invoice \
  --description "Acme Corp invoice format" \
  --schema schema.json \
  --prompt-hints "Dates DD/MM/YYYY; comma is decimal separator." \
  --identify-hints "Acme Corp logo top-left; PO numbers start with 'PO-'." \
  --publish
```

**Schema design — quick rules:**

- Make every field `required` and nullable: `"type": ["string", "null"]`. Guarantees the key always appears, with `null` when missing.
- Write descriptions that tell the LLM **where** to look on the page and **what format** to expect.
- Use `"format": "date"` for dates, `enum` for fixed value sets, `array` with `items` for tabular/repeating data.

> **Depth:** `references/advanced/custom-types-workflow.md` (decision tree, progressive disclosure stages, multi-document files, prompt-hint cookbook) and `references/advanced/schema-design.md` (field-type combinations, nesting, complex examples).

**Out of scope for this skill:** validation rules (`dslRules`, `validationRules`), pipeline creation (`steps` design), and advanced `conversionSpec` configuration.

## 7. Common Patterns

### Identify, then convert

```bash
TYPE=$(docutray identify document.pdf --json | jq -r '.data.document_type')
docutray convert document.pdf -t "$TYPE"
```

### Batch convert a directory

```bash
for f in documents/*.pdf; do
  docutray convert "$f" -t electronic-invoice > "${f%.pdf}.json"
done
```

### Inspect before converting

```bash
docutray types list --search invoice
docutray types get electronic-invoice
docutray convert invoice.pdf -t electronic-invoice
```

## 8. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Non-interactive mode requires --api-key flag or api-key argument` | `docutray login` invoked without a TTY (agent / CI) | Use `docutray login --api-key dt_live_...`, the positional form, or set `DOCUTRAY_API_KEY` |
| `Error: Nonexistent flag: --output` (or `--format`) on `convert` | Flag does not exist | Use shell redirection `> result.json` |
| `401 Unauthorized` | Missing or invalid key | Verify with `docutray status`; re-export `DOCUTRAY_API_KEY` |
| `403 Forbidden` | Key lacks permissions | Issue a new key in the dashboard |
| `404 Not Found` on convert/get | Document type code wrong | `docutray types list --search <term>` |
| `415 Unsupported Format` | File type not supported | Convert to JPEG/PNG/PDF/etc. |
| `413 File Too Large` | > 100MB | Split or compress |
| `429 Rate Limited` | Throttled | Honor `Retry-After` |
| `PROCESSING` stuck on a step | Pipeline failure | `docutray steps status <id>` for details |
| Low identify confidence | No matching type | Restrict with `--types`, or design a custom type (Section 6) |
| `command types:view not found` / `types:delete not found` | Subcommand doesn't exist | Use `types get` / there is no delete subcommand |

> **Depth:** `references/setup/troubleshooting.md` (env var/config conflicts, proxy/TLS, version checks) and `references/setup/rest.md` (full error code table).

## Technical Reference

| Detail | Value |
|---|---|
| CLI package | `@docutray/cli` (verified against 0.2.1) |
| API key prefix | `dt_live_` |
| Production base URL | `https://app.docutray.com` |
| Staging base URL | `https://staging.docutray.com` |
| Auth env var | `DOCUTRAY_API_KEY` |
| Auth config file | `~/.config/docutray/config.json` |
| HTTP auth header | `Authorization: Bearer <key>` |
| Source argument | Local file path **or** public URL (`convert`, `identify`, `steps run`) |
| Supported formats | JPEG, PNG, GIF, BMP, WebP, PDF |
| Max file size | 100 MB |
| Convert response | `{ "data": { ...schema-driven keys... } }` |
| Pipeline statuses | `ENQUEUED` → `PROCESSING` → `SUCCESS` \| `ERROR` |
| Python min version | 3.10+ |
| Node min version | 20+ |
