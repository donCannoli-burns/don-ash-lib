#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/manual"
DIST="$ROOT/dist"
rm -rf "$OUT/main" "$DIST"
mkdir -p "$OUT/main" "$DIST"
find "$ROOT/src/main/java" -name '*.java' -print0 | xargs -0 javac --release 21 -Xlint:all -d "$OUT/main"
jar --create --file "$DIST/kolmafia-ash-java-0.1.0.jar" -C "$OUT/main" dev/doncannoli/kolmafia/ash -C "$OUT/main" dev/doncannoli/kolmafia/ashrefgen
printf 'built %s\n' "$DIST/kolmafia-ash-java-0.1.0.jar"
