#!/usr/bin/env python3
"""Convert a binary .wasm file into wasm-ash's deterministic hex transport."""
from pathlib import Path
import argparse

p = argparse.ArgumentParser()
p.add_argument("input", type=Path)
p.add_argument("output", type=Path)
a = p.parse_args()

data = a.input.read_bytes()
with a.output.open("w", encoding="ascii") as f:
    f.write("# wasm-ash hex transport for: %s\n" % a.input.name)
    for offset in range(0, len(data), 16):
        chunk = data[offset:offset + 16]
        f.write(" ".join(f"{b:02x}" for b in chunk) + "\n")
