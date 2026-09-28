#!/usr/bin/env bash
set -euo pipefail
adb reverse tcp:60080 tcp:60080
adb reverse --list
