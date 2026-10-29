## Why

The skill excludes DSL rules even though the API, MCP, SDKs and CLI now support them. Agents need the actual command syntax and must distinguish invalid data from failed validation.

## What Changes

- Teach authoring, dry-run testing, saving and reading back DSL rules using CLI 0.6.0 and MCP.
- Explain conversion status and informational validation, with SDK and REST equivalents in references.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `docutray-skill`: document DSL operations, CLI floor and validation outcomes.

## Impact

Skill entrypoint, setup/platform/advanced references and coordinated plugin release metadata. Tracks docutray/docutray#1111; no monorepo vendor changes.
