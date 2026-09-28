#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/manual"
rm -rf "$OUT"
mkdir -p "$OUT/main" "$OUT/test" "$OUT/generated"
find "$ROOT/src/main/java" -name '*.java' -print0 | xargs -0 javac --release 21 -d "$OUT/main"
find "$ROOT/src/test/java" -name '*.java' -print0 | xargs -0 javac --release 21 --add-modules jdk.httpserver -cp "$OUT/main" -d "$OUT/test"
java --add-modules jdk.httpserver -cp "$OUT/main:$OUT/test" dev.doncannoli.kolmafia.ash.SmokeTest
java -cp "$OUT/main" dev.doncannoli.kolmafia.ashrefgen.Main "$ROOT/fixtures/ashref.sample.txt" "$OUT/generated/GeneratedAsh.java" dev.doncannoli.kolmafia.ash.generated
javac --release 21 -cp "$OUT/main" -d "$OUT/generated-classes" "$OUT/generated/GeneratedAsh.java"
echo "ASHREF_GENERATED_COMPILE=PASS"
