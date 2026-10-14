# Design

## Context

Text-only change. The behavior it documents is in `@docutray/cli@0.5.0` (`src/commands/login.ts`, `src/oauth.ts`, `CHANGELOG.md` 0.5.0) and in the server change archived as `docutray/openspec/changes/archive/2026-10-14-cli-login-organization-consent`.

## Goals / Non-Goals

**Goals:** stop sending agents through the dashboard detour; keep the documented stderr stable markers accurate.

**Non-Goals:** documenting the server-side scope (`docutray:cli`) beyond what an agent needs to diagnose an `invalid_scope` error; a separate reference page.

## Decisions

- **Keep the dashboard API key as a fallback, not as the fix.** Headless agents with no browser still need it, and it works with any CLI version.
- **Patch version (`1.3.1`).** No new capability for agents; the guidance is corrected to match the current CLI.
- **Version-gate the advice ("CLI ≥ 0.5.0").** Agents may run against an older global install; the troubleshooting row tells them to upgrade first.

## Risks / Trade-offs

- [Users on CLI ≤ 0.4.1 still get an arbitrary organization] → The row says to upgrade; the dashboard key remains documented as the fallback.
