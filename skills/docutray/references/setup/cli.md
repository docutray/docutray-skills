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

### Option 1: `DOCUTRAY_API_KEY` env var (recommended)

```bash
export DOCUTRAY_API_KEY="dt_live_your_key_here"
```

Works in any environment: local dev, agent shells, CI/CD, Docker. Always wins over the config file when both are set.

### Option 2: `docutray login`

```bash
$ docutray login --help
USAGE
  $ docutray login [API-KEY] [--api-key <value>] [--base-url <value>] [--json]
```

**Important:** the bare `docutray login` form requires a TTY. Inside an agent/CI it errors with:

```
Non-interactive mode requires --api-key flag or api-key argument
```

Use one of these forms instead:

```bash
# Non-interactive: flag form
docutray login --api-key dt_live_your_key_here

# Non-interactive: positional form (equivalent)
docutray login dt_live_your_key_here

# Or, ask the user to run interactive login in their own terminal
# (in Claude Code: prefix with `! ` so the user runs it)
docutray login
```

The interactive form prompts to choose between pasting an existing API key or doing OAuth2 in the browser; OAuth opens a tab, lets the user select an organization, and writes the resulting key to `~/.config/docutray/config.json` with restricted permissions.

For staging:

```bash
docutray login --base-url https://staging.docutray.com
```

### Priority order

1. `DOCUTRAY_API_KEY` env var.
2. `~/.config/docutray/config.json` (from `docutray login`).

### Logout

```bash
docutray logout
```

Removes the stored credentials from `~/.config/docutray/config.json`. Has no effect on env-var-based auth (the API key itself is not invalidated either — that has to happen in the dashboard).

## Verification

```bash
$ docutray status
authenticated:    true
api_key:          dt_live_********abc1
credential_source: env
base_url:         https://app.docutray.com
config_path:      /Users/<user>/.config/docutray/config.json
```

```bash
# JSON form (default when piped)
docutray status --json
```

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
