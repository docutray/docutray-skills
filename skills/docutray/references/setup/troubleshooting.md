# Troubleshooting — detailed reference

Authentication, connectivity, and environment issues across all integration paths (CLI, Python SDK, Node SDK, REST API).

## Authentication errors

| Symptom | Cause | Fix |
|---|---|---|
| `401 Unauthorized` | Invalid or missing API key | Verify `DOCUTRAY_API_KEY` starts with `dt_live_`. Re-export it. Check with `docutray status` (CLI). |
| `403 Forbidden` | Key lacks permissions for this operation | Issue a new key in **app.docutray.com → Account → API Keys**. |
| `DOCUTRAY_API_KEY not set` (SDKs) | Env var not exported in the current shell | `export DOCUTRAY_API_KEY="dt_live_..."` and re-run. |
| `Non-interactive mode requires --api-key flag or api-key argument` | Bare `docutray login` invoked without a TTY (agent shell or CI) | Preferred: `docutray login --oauth` (CLI ≥ 0.3.2, drives the browser flow without exposing the key). Fallbacks: `docutray login --api-key dt_live_...`, the positional form `docutray login dt_live_...`, or set `DOCUTRAY_API_KEY` in the environment. |
| OAuth callback never returns / hangs | User hasn't authorized in the browser; or `localhost:9876` is unreachable from the user's browser | Wait up to the timeout (default 180s); pass `--timeout <seconds>` to shorten. Verify port 9876 is free with `lsof -nP -iTCP:9876`. If port is blocked, free it or contact the CLI team for a workaround. |
| OAuth picks the wrong organization | Authenticated user has multiple DocuTray orgs; CLI auto-selects the first (`Multiple organizations found, using: …` on stderr) | Log into the dashboard with the desired org, create an API key there, and use `docutray login --api-key <key>` instead. |
| Browser doesn't open from `--oauth` | No default browser, headless system, or auto-open blocked by the desktop environment | Use `docutray login --oauth --no-browser`, then surface the URL printed on stderr to the user manually. |
| Stale credentials after rotating a key | `~/.config/docutray/config.json` still holds the old key | `docutray logout` then re-authenticate; or set `DOCUTRAY_API_KEY` (env wins). |

## Connection errors

| Symptom | Cause | Fix |
|---|---|---|
| `ECONNREFUSED` / connection timeout | Network issue or wrong base URL | Run `curl -I https://app.docutray.com` to test reachability. |
| SSL/TLS errors | Corporate proxy or firewall TLS interception | Check proxy env vars (`HTTP_PROXY`, `HTTPS_PROXY`); verify the system trust store includes the proxy CA. |
| Wrong environment | Mixing production keys with `--base-url https://staging.docutray.com` (or vice versa) | Keys are environment-scoped. Use the right key for the active base URL. |
| Hangs on convert with large file | File approaching size/timeout limits | Use `--async --timeout 600` for synchronous polling, or `--webhook-url`. |

## Common gotchas

- **Key shown only once.** If the key was lost, create a new one in the dashboard. There is no "view existing key" flow.
- **Config file conflicts.** If both `DOCUTRAY_API_KEY` and the config file have keys, the env var wins. To force the config file, `unset DOCUTRAY_API_KEY` and re-run.
- **Python version.** DocuTray Python SDK requires Python 3.10+. Check with `python --version`.
- **Node version.** DocuTray Node SDK and CLI require Node.js 20+. Check with `node --version`.
- **Unsupported file type.** Only JPEG, PNG, GIF, BMP, WebP, and PDF are supported. Other formats yield `415 Unsupported Format`.
- **File size cap.** 100 MB hard limit. Larger files yield `413 File Too Large`. Split or compress before uploading.
- **Rate limits (`429`).** Honor the `Retry-After` header. Don't tight-loop retries.

## CLI-specific

- **`Error: Nonexistent flag: --output`**. The `--output` and `--format` flags do not exist on the conversion command. Save output with shell redirection: `docutray convert file.pdf -t code > result.json`.
- **`Command types:view not found` / `Command types:delete not found`.** Those subcommands do not exist. Use `types get <code>` for inspection. There is no delete subcommand — manage type lifecycle via `--draft` / `--publish` on `types update`, or remove via the dashboard.
- **`docutray status` shows `source: env` but the key looks wrong.** The shell-exported `DOCUTRAY_API_KEY` is in effect; either correct the export or `unset` it to fall back to the config file.
- **`docutray login --oauth` exits with port-bind error.** The OAuth callback uses `http://localhost:9876/callback`. Free the port (`lsof -nP -iTCP:9876` to find the process) and retry, or fall back to `--api-key`.
- **`docutray login --oauth` exit code on user cancellation** (closing the browser tab without authorizing) is non-zero with the provider's error message on stderr. Re-run when the user is ready.

## SDK-specific

- **Python: `AuthenticationError`** raised on first call. The client looks for `api_key=` then `DOCUTRAY_API_KEY`. If both are absent, set one.
- **Node: `ApiError: 401`** with no further detail. Same root cause; pass `apiKey` to the constructor or set `DOCUTRAY_API_KEY`.
- **Async client used in sync code (Python).** `AsyncClient` requires an `await` and an event loop; use `Client` for sync code.

## REST-specific

- **`415 Unsupported Format`** with a PDF file. Confirm the multipart upload uses the correct mime type: `Content-Type: multipart/form-data` with the file part typed as `application/pdf` (or let curl set it via `-F "file=@invoice.pdf"`).
- **Empty `data`** on convert. The document type code is wrong or unpublished. Verify with `GET /api/types/{code}` first.

## Verification commands

```bash
# CLI
docutray status

# Python
python -c "from docutray import Client; print(Client().types.list())"

# Node
node -e "import('docutray').then(m => new m.DocuTray().types.list().then(console.log))"

# REST
curl -sS -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types | head -200
```

If any of these fail with the same symptom, the issue is the API key or network — not the integration path.
