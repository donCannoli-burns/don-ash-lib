#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 ]]; then
  echo "usage: $0 /path/to/KoLmafia-root" >&2
  exit 2
fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KOL="$1"
mkdir -p "$KOL/scripts" "$KOL/relay" "$KOL/data/pyash-mcp/tools"
cp "$ROOT/scripts/pyash.ash" "$KOL/scripts/pyash.ash"
cp "$ROOT/relay/relay_pyash_mcp.ash" "$KOL/relay/relay_pyash_mcp.ash"
cp "$ROOT/data/pyash-mcp/tools.tsv" "$KOL/data/pyash-mcp/tools.tsv"
cp "$ROOT"/data/pyash-mcp/tools/*.py "$KOL/data/pyash-mcp/tools/"
printf 'Installed PyASH Seed MCP KoLmafia side into %s\n' "$KOL"
printf 'Next: verify pyash.ash, then start bridge/pyash_seed_mcp.py from your MCP host.\n'
