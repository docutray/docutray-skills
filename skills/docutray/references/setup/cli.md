# CLI setup — detailed reference

Verified against `@docutray/cli/0.2.1`. When in doubt, run `docutray <command> --help`.

## Installation

```bash
# Global install
npm install -g @docutray/cli

# Or run without installing
npx @docutray/cli <command>
```

**Requirements:** Node.js 20+.

## Authentication

### Option 1 (recommended for agents): `docutray login --oauth`

Available in `@docutray/cli >= 0.3.2` (introduced in 0.3.1). Drives an OAuth browser flow without a TTY: the CLI prints the auth URL on stderr, opens the user's browser, blocks on the local callback, and writes the resulting API key to `~/.config/docutray/config.json`. The agent never sees the unmasked key.

```bash
$ docutray login --help
USAGE
  $ docutray login [API-KEY] [--api-key <value>] [--base-url
    <value>] [--json] [--no-browser] [--oauth] [--timeout <value>]

FLAGS
  --api-key=<value>   API key for non-interactive login
  --base-url=<value>  Custom base URL for the DocuTray API (default:
                      https://app.docutray.com)
  --json              Output as JSON (default when piped)
  --no-browser        Skip opening the browser; print the URL only (--oauth only)
  --oauth             Login via OAuth in the browser (works without a TTY)
  --timeout=<value>   [default: 180] OAuth callback timeout in seconds
                      (--oauth only)
```

#### Observed behavior (verified end-to-end against `@docutray/cli/0.3.2`)

```bash
$ docutray login --oauth
```

- **stderr** (progress, in order):
  ```
  Open this URL to authorize: https://app.docutray.com/api/auth/oauth2/authorize?client_id=docutray-cli&response_type=code&redirect_uri=http://localhost:9876/callback&...
  Opening browser for authentication...
  Waiting for authentication (timeout: 180s)...
  Exchanging authorization code...
  Fetching organizations...
  Multiple organizations found, using: <org-name>
  Creating API key...
  ```
- **stdout** (success JSON, after the user authorizes):
  ```json
  {
    "message": "Login successful",
    "apiKey": "dtXJ****dWhx",
    "organizationId": "JjfaVBa3fDuAvqTpBzFqlFuQcCgBDjyn",
    "organizationName": "docutray.com",
    "configPath": "/Users/<user>/.config/docutray/config.json"
  }
  ```
- **exit 0** on success.

Notes for agents:

- The auth URL prefix `Open this URL to authorize:` is a stable marker — grep stderr for it if the agent needs to surface the URL to the user (e.g. when the browser auto-open fails).
- `apiKey` in the success JSON is **masked** as `<first-4>****<last-4>`. The unmasked key is only on disk in `~/.config/docutray/config.json`.
- The CLI binds the OAuth callback on `http://localhost:9876/callback` — keep that port free and not blocked by the local firewall.
- When the authenticated user belongs to multiple DocuTray orgs, the CLI auto-selects the first one (visible in the `Multiple organizations found, using: …` stderr line). To pick a specific org, log into the dashboard with that org, create an API key there, and use `docutray login --api-key <key>` instead.

#### Useful flags

```bash
docutray login --oauth --no-browser           # print URL only; don't auto-open
docutray login --oauth --timeout 60           # custom callback timeout (default 180s)
docutray login --oauth --base-url https://staging.docutray.com   # staging
```

### Option 2: `DOCUTRAY_API_KEY` env var

For environments where `--oauth` won't work (CI runners, headless servers, no browser):

```bash
export DOCUTRAY_API_KEY="dt_live_your_key_here"
```

Works in any shell. Always wins over the config file when both are set.

### Option 3: pass an existing key to `docutray login`

When the user already has a key (e.g. from the dashboard) and wants it written to the config file:

```bash
# Non-interactive: flag form
docutray login --api-key dt_live_your_key_here

# Non-interactive: positional form (equivalent)
docutray login dt_live_your_key_here
```

### Bare `docutray login` (interactive only)

```bash
docutray login
```

Requires a TTY. From an agent shell or CI it errors with `Non-interactive mode requires --api-key flag or api-key argument`. The interactive form prompts the user to choose between pasting a key and OAuth; the same OAuth ceremony as `--oauth` runs underneath. Useful when the user runs it themselves in their own terminal (`! docutray login` in Claude Code).

For staging in interactive mode:

```bash
docutray login --base-url https://staging.docutray.com
```

### Priority order

1. `DOCUTRAY_API_KEY` env var.
2. `~/.config/docutray/config.json` (from `docutray login` / `docutray login --oauth` / `docutray login --api-key`).

### Logout

```bash
docutray logout
```

Removes the stored credentials from `~/.config/docutray/config.json`. Has no effect on env-var-based auth (the API key itself is not invalidated either — that has to happen in the dashboard).

## Verification

```bash
$ docutray status
{
  "authenticated": true,
  "apiKey": "dtXJ****dWhx",
  "source": "config",
  "baseUrl": "https://app.docutray.com",
  "configPath": "/Users/<user>/.config/docutray/config.json",
  "organizationId": "JjfaVBa3fDuAvqTpBzFqlFuQcCgBDjyn",
  "organizationName": "docutray.com"
}
```

`--json` is the default when stdout is piped (it's also the default when run from an agent shell). The `apiKey` field is **masked**; the unmasked value lives on disk only. `source` is `env` when the key came from `DOCUTRAY_API_KEY`, `config` when it came from the config file. `organizationId` / `organizationName` are populated for OAuth-authenticated sessions.

A user who logged in from another terminal can be verified the same way.

## Authoritative command reference

| Command | Help URL |
|---|---|
| `docutray convert` | https://docs.docutray.com/cli/convert |
| `docutray identify` | https://docs.docutray.com/cli/identify |
| `docutray types list` | https://docs.docutray.com/cli/types/list |
| `docutray types get` | https://docs.docutray.com/cli/types/get |
| `docutray types export` | https://docs.docutray.com/cli/types/export |
| `docutray types create` | https://docs.docutray.com/cli/types/create |
| `docutray types update` | https://docs.docutray.com/cli/types/update |
| `docutray steps run` | https://docs.docutray.com/cli/steps/run |
| `docutray steps status` | https://docs.docutray.com/cli/steps/status |
| `docutray login` / `logout` / `status` | https://docs.docutray.com/cli/login |

Detailed flag tables for each operation live in:
- `references/platform/convert.md`
- `references/platform/identify.md`
- `references/platform/types.md`
- `references/platform/steps.md`
- `references/advanced/custom-types-workflow.md` (for `types create` / `types update`)

## Global flags

| Flag | Description |
|---|---|
| `--base-url <url>` | Override the API base URL (login, status). For per-command override, pass it on the command itself. |
| `--json` | Force JSON output. Default whenever stdout is piped. |
| `--help`, `-h` | Show help for a command. |
| `--version`, `-V` | Show CLI version (also `-v` from the binary banner). |

## Staging environment

```bash
docutray login --base-url https://staging.docutray.com
docutray status        # confirms credential_source + base_url
docutray convert doc.pdf -t electronic-invoice
```

Or set via env var (read by the CLI when present):

```bash
export DOCUTRAY_BASE_URL="https://staging.docutray.com"
```

## CI/CD patterns

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
      - run: docutray convert invoice.pdf -t electronic-invoice > result.json
        env:
          DOCUTRAY_API_KEY: ${{ secrets.DOCUTRAY_API_KEY }}
```

### GitLab CI

```yaml
process:
  image: node:20
  script:
    - npm install -g @docutray/cli
    - docutray convert invoice.pdf -t electronic-invoice > result.json
  variables:
    DOCUTRAY_API_KEY: $DOCUTRAY_API_KEY
```

### Docker

```dockerfile
FROM node:20-slim
RUN npm install -g @docutray/cli
# Pass DOCUTRAY_API_KEY at runtime:
# docker run -e DOCUTRAY_API_KEY=dt_live_... myimage \
#   docutray convert /data/doc.pdf -t electronic-invoice
```

## Piping and composition

The CLI outputs JSON by default when piped, making it composable:

```bash
# Pipe to jq
docutray convert invoice.pdf -t electronic-invoice | jq '.data.total'

# Save to file (no --output flag exists; use shell redirection)
docutray convert invoice.pdf -t electronic-invoice > result.json

# Identify then convert
TYPE=$(docutray identify document.pdf --json | jq -r '.data.document_type')
docutray convert document.pdf -t "$TYPE"

# Batch a directory
for f in documents/*.pdf; do
  docutray convert "$f" -t electronic-invoice > "${f%.pdf}.json"
done
```

## Supported file formats

JPEG, PNG, GIF, BMP, WebP, PDF — max 100MB per file. `convert`, `identify`, and `steps run` also accept a public URL in place of a local path.
