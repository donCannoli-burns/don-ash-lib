#!/usr/bin/env python3
"""Generate a conservative Kotlin wrapper skeleton from `ashref` output.

Usage:
    python3 tools/generate_from_ashref.py ashref.txt GeneratedAsh.kt

This deliberately emits JsonValue-returning wrappers for signatures it can parse.
You can tighten return types after generation, or extend TYPE_MAP below.
"""
import re, sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: generate_from_ashref.py ashref.txt GeneratedAsh.kt")

src = Path(sys.argv[1]).read_text(errors="replace").splitlines()
out = Path(sys.argv[2])

pat = re.compile(r"^\s*(.+?)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\((.*?)\)\s*;?\s*$")

def camel(s):
    parts = s.split('_')
    return parts[0] + ''.join(p[:1].upper()+p[1:] for p in parts[1:])

seen = set()
lines = [
    "package dev.doncannoli.kolmafia.ash.generated",
    "",
    "import dev.doncannoli.kolmafia.ash.*",
    "",
    "/** Generated from local KoLmafia `ashref`; overloads are suffixed when needed. */",
    "object GeneratedAsh {",
]
count = 0
for line in src:
    m = pat.match(line.strip())
    if not m:
        continue
    _ret, ash_name, params = m.groups()
    js_name = camel(ash_name)
    arity = 0 if not params.strip() else len([p for p in params.split(',') if p.strip()])
    key = (js_name, arity)
    suffix = "" if key not in seen else f"_{count}"
    seen.add(key)
    args = ", ".join(f"a{i}: Any?" for i in range(arity))
    call_args = ", ".join(f"a{i}" for i in range(arity))
    comma = ", " if call_args else ""
    lines += [
        f"    fun AshClient.{js_name}{suffix}Blocking({args}): JsonValue =",
        f"        callBlocking(\"{js_name}\"{comma}{call_args})",
        "",
    ]
    count += 1
lines += ["}", ""]
out.write_text("\n".join(lines))
print(f"generated {count} wrappers -> {out}")
