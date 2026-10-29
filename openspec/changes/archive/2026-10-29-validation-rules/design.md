## Context

See proposal.md. CLI 0.6.0 source defines positional set input and flag-based test input, differing from the coordinating issue's illustrative syntax.

## Goals / Non-Goals

Keep entrypoint guidance under 500 lines and expose detailed authoring only on demand. No API, SDK, CLI implementation or monorepo submodule changes.

## Decisions

Use a dedicated advanced reference for DSL, MCP/SDK/REST parameters and result shapes; retain a compact mandatory dry-run-before-save flow in SKILL.md. Contrast conversion outcomes with on-demand summaries so agents do not gate data validity on conversion success. Check source/help without sending production documents or changing stored types.

## Risks / Trade-offs

API deployments may lag clients → state client floors and absent/unknown validation semantics. Saved rules replace the entire text → inspect and preserve existing rules, dry-run valid/invalid fixtures, and read back. Detailed SDK examples are source-checked, not a claim of live API verification.
