#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /path/to/KoLmafia-root" >&2
  exit 2
fi

root=$(cd "$1" && pwd)
project=$(cd "$(dirname "$0")/.." && pwd)

mkdir -p "$root/scripts/wasm-ash" "$root/data/wasm-ash/examples"
cp "$project/scripts/wasm-ash/runtime.ash" "$root/scripts/wasm-ash/runtime.ash"
cp "$project/scripts/wasm-ash/wasm-ash.ash" "$root/scripts/wasm-ash/wasm-ash.ash"
cp "$project/scripts/wasm-ash/example.ash" "$root/scripts/wasm-ash/example.ash"
cp "$project/data/wasm-ash/examples/"*.hex "$root/data/wasm-ash/examples/"

echo "Installed wasm-ash into $root"
echo "Run in gCLI: call wasm-ash/wasm-ash.ash selftest"
