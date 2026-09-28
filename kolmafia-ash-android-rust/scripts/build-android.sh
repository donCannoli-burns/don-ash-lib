#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/android/kolmafia-ash/src/main/jniLibs}"

command -v cargo >/dev/null || { echo "cargo is required" >&2; exit 1; }
command -v cargo-ndk >/dev/null || {
  echo "cargo-ndk is required: cargo install cargo-ndk" >&2
  exit 1
}

rustup target add \
  aarch64-linux-android \
  armv7-linux-androideabi \
  x86_64-linux-android

mkdir -p "$OUT"
cd "$ROOT"

cargo ndk \
  -t arm64-v8a \
  -t armeabi-v7a \
  -t x86_64 \
  -o "$OUT" \
  build --release

echo "JNI libraries written to: $OUT"
