#!/usr/bin/env bash
# Verifica que la versión del plugin, la del skill y la última release del
# CHANGELOG coincidan. Uso: scripts/check-versions.sh
set -euo pipefail
cd "$(dirname "$0")/.."

plugin=$(sed -n 's/^  "version": "\(.*\)",$/\1/p' .claude-plugin/plugin.json)
skill=$(sed -n 's/^  version: "\(.*\)"$/\1/p' skills/docutray/SKILL.md)
changelog=$(sed -n 's/^## \[\([0-9][^]]*\)\].*/\1/p' CHANGELOG.md | head -n 1)

echo "plugin.json: ${plugin:-?}  SKILL.md: ${skill:-?}  CHANGELOG: ${changelog:-?}"
if [ -z "$plugin" ] || [ "$plugin" != "$skill" ] || [ "$plugin" != "$changelog" ]; then
  echo "Las versiones no coinciden: subirlas juntas en la release." >&2
  exit 1
fi
