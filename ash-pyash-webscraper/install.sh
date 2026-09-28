#!/usr/bin/env bash
set -euo pipefail
KOLMAFIA_HOME="${KOLMAFIA_HOME:-$HOME/.kolmafia}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$KOLMAFIA_HOME/scripts" "$KOLMAFIA_HOME/data/scraper" "$KOLMAFIA_HOME/data/pyash"
cp "$ROOT/scripts/ashscrape.ash" "$KOLMAFIA_HOME/scripts/ashscrape.ash"
cp "$ROOT/scripts/pyash-web.ash" "$KOLMAFIA_HOME/scripts/pyash-web.ash"
cp "$ROOT/data/pyash/web_demo.py" "$KOLMAFIA_HOME/data/pyash/web_demo.py"
printf 'Installed:\n  %s\n  %s\n  %s\n' \
  "$KOLMAFIA_HOME/scripts/ashscrape.ash" \
  "$KOLMAFIA_HOME/scripts/pyash-web.ash" \
  "$KOLMAFIA_HOME/data/scraper/"
