---
name: docutray-setup
description: >-
  Install, configure, and authenticate docutray-cli, docutray-python, or
  docutray-node SDK. Use this skill when setting up DocuTray for the first time,
  configuring authentication, running docutray login, or troubleshooting
  connection issues.
---

# DocuTray Setup

This skill guides you through setting up DocuTray — an AI-powered document processing platform that converts documents (PDFs, images) into structured data.

## 1. Detect Project Context

Check the project to recommend the right integration path:

```
IF pyproject.toml OR requirements.txt exists → Python SDK (Section 4)
IF package.json OR tsconfig.json exists    → Node SDK (Section 5)
IF neither exists                          → REST API (Section 6) or CLI (Section 7)
```

For agents working outside a project context, use the **CLI** path.

## 2. Create an API Key

All integration paths require an API key.

1. Go to **app.docutray.com** > **Account** > **API Keys**
2. Click **Create API Key**
3. Copy the key (starts with `dt_live_`) — it is shown only once

> **Important:** Never hardcode API keys in source files. Use environment variables.

## 3. Set the Environment Variable (Recommended)

The `DOCUTRAY_API_KEY` environment variable works across all integration paths and is recommended as the primary authentication method.

```bash
export DOCUTRAY_API_KEY="dt_live_your_key_here"
```

For persistence, add it to your shell profile (`.bashrc`, `.zshrc`) or `.env` file.

For CI/CD, set it as a secret in your pipeline configuration.

## 4. Python SDK

**Requirements:** Python 3.10+

### Install

```bash
pip install docutray
```

### Authenticate

The SDK reads `DOCUTRAY_API_KEY` automatically, or pass it explicitly:

```python
from docutray import Client

# Option 1: Env var (recommended) — just instantiate
client = Client()

# Option 2: Explicit key
client = Client(api_key="dt_live_your_key_here")
```

### Verify

```python
# List available document types to confirm auth works
types = client.types.list()
print(types)
```

A successful response confirms authentication is working.

### Staging Environment

```python
client = Client(base_url="https://staging.docutray.com")
```

> **Details:** @references/python-sdk-setup.md — async client, error handling, advanced configuration

## 5. Node SDK

**Requirements:** Node.js 20+

### Install

```bash
npm install docutray
```

### Authenticate

```typescript
import { DocuTray } from "docutray";

// Option 1: Env var (recommended) — reads DOCUTRAY_API_KEY automatically
const client = new DocuTray();

// Option 2: Explicit key
const client = new DocuTray({ apiKey: "dt_live_your_key_here" });
```

### Verify

```typescript
// List available document types to confirm auth works
const types = await client.types.list();
console.log(types);
```

A successful response confirms authentication is working.

### Staging Environment

```typescript
const client = new DocuTray({ baseUrl: "https://staging.docutray.com" });
```

> **Details:** @references/node-sdk-setup.md — TypeScript types, error handling, async patterns

## 6. REST API

For languages without an SDK, use the REST API directly.

### Base URL

```
https://app.docutray.com/api
```

### Authenticate

Include the API key as a Bearer token in every request:

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types
```

### Verify

```bash
curl -s -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types
```

A `200` response with a JSON array confirms authentication is working.

### Staging Environment

Replace the base URL:

```
https://staging.docutray.com/api
```

> **Details:** @references/rest-api-setup.md — full endpoint list, request/response formats, error codes

## 7. CLI

For direct terminal usage and agent interactions.

### Install

```bash
# Global install
npm install -g @docutray/cli

# Or run without installing
npx @docutray/cli
```

### Authenticate

**Option 1: Environment variable (recommended)**

```bash
export DOCUTRAY_API_KEY="dt_live_your_key_here"
```

**Option 2: Interactive login**

```bash
docutray login
```

This stores credentials at `~/.config/docutray/config.json`. The env var takes priority if both are set.

### Verify

```bash
docutray status
```

Check the `authenticated` field in the output — it should be `true`.

### Staging Environment

```bash
docutray --base-url https://staging.docutray.com status
```

> **Details:** @references/cli-setup.md — full command reference, CI/CD patterns, piping/composition

## 8. Troubleshooting

### Authentication Errors

| Symptom | Cause | Fix |
|---------|-------|-----|
| `401 Unauthorized` | Invalid or missing API key | Verify key starts with `dt_live_` and is set correctly |
| `403 Forbidden` | Key lacks permissions | Create a new key with appropriate permissions in the dashboard |
| `DOCUTRAY_API_KEY not set` | Env var not exported | Run `export DOCUTRAY_API_KEY="dt_live_..."` in your current shell |

### Connection Errors

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ECONNREFUSED` / timeout | Network issue or wrong URL | Verify connectivity to `app.docutray.com` |
| SSL/TLS errors | Proxy or firewall interference | Check proxy settings, try `curl https://app.docutray.com` |

### Common Issues

- **Key shown only once:** If you lost your API key, create a new one in the dashboard
- **Wrong environment:** Verify you're not mixing production keys with staging URLs
- **Config file conflicts:** If `docutray login` was used, check `~/.config/docutray/config.json` for stale entries
- **Python version:** DocuTray requires Python 3.10+. Check with `python --version`
- **Node version:** DocuTray requires Node.js 20+. Check with `node --version`

## Technical Reference

| Detail | Value |
|--------|-------|
| API key prefix | `dt_live_` |
| Production URL | `https://app.docutray.com` |
| Staging URL | `https://staging.docutray.com` |
| Config file path | `~/.config/docutray/config.json` |
| Python min version | 3.10+ |
| Node min version | 20+ |
| Supported formats | JPEG, PNG, GIF, BMP, WebP, PDF |
| Max file size | 100MB |
| Auth header | `Authorization: Bearer <key>` |
| Response format | `{ "success": true, "data": {...} }` |
