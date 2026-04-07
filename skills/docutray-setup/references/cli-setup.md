# CLI Setup — Detailed Reference

## Installation

```bash
# Global install
npm install -g @docutray/cli

# Or run without installing
npx @docutray/cli <command>
```

**Requirements:** Node.js 20+

## Authentication

### Option 1: Environment Variable (Recommended)

```bash
export DOCUTRAY_API_KEY="dt_live_your_key_here"
```

Works in all environments: local dev, CI/CD, Docker containers.

### Option 2: Interactive Login

```bash
docutray login
```

Stores credentials at `~/.config/docutray/config.json`.

### Priority Order

1. `DOCUTRAY_API_KEY` environment variable
2. `~/.config/docutray/config.json` (from `docutray login`)

The env var always takes priority if both are set.

### Logout

```bash
docutray logout
```

Removes the stored credentials from `~/.config/docutray/config.json`.

## Verification

```bash
docutray status
```

Output includes an `authenticated` field — should be `true`.

## Command Reference

### `docutray status`

Check authentication and account status.

```bash
docutray status
```

### `docutray convert`

Convert a document to structured data.

```bash
docutray convert <file> --type <document-type>
```

**Options:**

| Flag | Description |
|------|-------------|
| `--type`, `-t` | Document type to extract (required) |
| `--output`, `-o` | Output file path (default: stdout) |
| `--format` | Output format: `json` (default), `csv` |

**Examples:**

```bash
# Convert an invoice, output to stdout
docutray convert invoice.pdf --type invoice

# Save output to a file
docutray convert invoice.pdf --type invoice --output result.json

# Convert an image
docutray convert receipt.jpg --type receipt
```

### `docutray identify`

Identify the document type of a file.

```bash
docutray identify <file>
```

**Example:**

```bash
docutray identify unknown-document.pdf
```

### `docutray types list`

List all available document types.

```bash
docutray types list
```

### `docutray types get`

Get details of a specific document type.

```bash
docutray types get <name>
```

### `docutray types export`

Export a document type schema.

```bash
docutray types export <name>
```

### `docutray steps run`

Run a multi-step processing pipeline.

```bash
docutray steps run <pipeline> --input <file>
```

### `docutray steps status`

Check the status of a running pipeline.

```bash
docutray steps status <pipeline-id>
```

### `docutray login`

Authenticate interactively and store credentials.

```bash
docutray login
```

### `docutray logout`

Remove stored credentials.

```bash
docutray logout
```

## Global Options

| Flag | Description |
|------|-------------|
| `--base-url` | Override API base URL (e.g., `https://staging.docutray.com`) |
| `--json` | Force JSON output (default for most commands) |
| `--help`, `-h` | Show help for a command |
| `--version`, `-v` | Show CLI version |

## Staging Environment

```bash
# All commands accept --base-url
docutray --base-url https://staging.docutray.com status
docutray --base-url https://staging.docutray.com convert doc.pdf --type invoice
```

Or set via environment variable:

```bash
export DOCUTRAY_BASE_URL="https://staging.docutray.com"
```

## CI/CD Patterns

### GitHub Actions

```yaml
jobs:
  process:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm install -g @docutray/cli
      - run: docutray convert invoice.pdf --type invoice --output result.json
        env:
          DOCUTRAY_API_KEY: ${{ secrets.DOCUTRAY_API_KEY }}
```

### GitLab CI

```yaml
process:
  image: node:20
  script:
    - npm install -g @docutray/cli
    - docutray convert invoice.pdf --type invoice --output result.json
  variables:
    DOCUTRAY_API_KEY: $DOCUTRAY_API_KEY
```

### Docker

```dockerfile
FROM node:20-slim
RUN npm install -g @docutray/cli
# Pass DOCUTRAY_API_KEY at runtime:
# docker run -e DOCUTRAY_API_KEY=dt_live_... myimage docutray convert ...
```

## Piping and Composition

The CLI outputs JSON by default, making it composable with other tools:

```bash
# Pipe to jq for field extraction
docutray convert invoice.pdf --type invoice | jq '.data.fields.total'

# Process multiple files
for f in documents/*.pdf; do
  docutray convert "$f" --type invoice --output "${f%.pdf}.json"
done

# Identify then convert
TYPE=$(docutray identify document.pdf | jq -r '.data.document_type')
docutray convert document.pdf --type "$TYPE"
```

## Supported File Formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file.
