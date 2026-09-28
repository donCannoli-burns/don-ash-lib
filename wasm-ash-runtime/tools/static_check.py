#!/usr/bin/env python3
"""Cheap source/package checks for wasm-ash.

This is not an ASH parser. Its job is to catch packaging mistakes and a few
known ASH portability hazards before the authoritative `verify` run in
KoLmafia.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASH_FILES = sorted((ROOT / "scripts").rglob("*.ash"))


def strip_comments_and_strings(text: str) -> str:
    out = []
    i = 0
    state = "code"
    while i < len(text):
        c = text[i]
        n = text[i + 1] if i + 1 < len(text) else ""
        if state == "code":
            if c == "/" and n == "/":
                state = "line"
                out.extend("  ")
                i += 2
                continue
            if c == "/" and n == "*":
                state = "block"
                out.extend("  ")
                i += 2
                continue
            if c == '"':
                state = "string"
                out.append(" ")
                i += 1
                continue
            out.append(c)
            i += 1
        elif state == "line":
            if c == "\n":
                state = "code"
                out.append("\n")
            else:
                out.append(" ")
            i += 1
        elif state == "block":
            if c == "*" and n == "/":
                state = "code"
                out.extend("  ")
                i += 2
            else:
                out.append("\n" if c == "\n" else " ")
                i += 1
        else:  # string
            if c == "\\" and i + 1 < len(text):
                out.extend("  ")
                i += 2
            elif c == '"':
                state = "code"
                out.append(" ")
                i += 1
            else:
                out.append("\n" if c == "\n" else " ")
                i += 1
    return "".join(out)


def balanced(code: str, path: Path) -> None:
    pairs = {')': '(', ']': '[', '}': '{'}
    opening = set(pairs.values())
    stack: list[tuple[str, int]] = []
    for pos, c in enumerate(code):
        if c in opening:
            stack.append((c, pos))
        elif c in pairs:
            if not stack or stack[-1][0] != pairs[c]:
                raise AssertionError(f"{path}: unbalanced {c} at byte {pos}")
            stack.pop()
    if stack:
        raise AssertionError(f"{path}: unclosed delimiter {stack[-1][0]} at byte {stack[-1][1]}")


def check_function_order(path: Path, code: str) -> None:
    # ASH normally requires user-defined functions to be visible before use.
    # Direct recursion is allowed. This catches accidental forward calls among
    # our wasm_* functions without attempting to parse the whole language.
    decl = re.compile(r"\b(?:void|boolean|int|string|WasmImmediate)\s+(wasm_[A-Za-z0-9_]+)\s*\(")
    call = re.compile(r"\b(wasm_[A-Za-z0-9_]+)\s*\(")
    declarations = [(m.start(), m.group(1)) for m in decl.finditer(code)]
    decl_pos = {name: pos for pos, name in declarations}
    for m in call.finditer(code):
        name = m.group(1)
        if name not in decl_pos:
            continue  # likely imported from runtime.ash in the CLI/example.
        # Determine whether this token is itself the declaration token.
        if any(pos <= m.start() <= pos + 120 and n == name for pos, n in declarations):
            # More precise check: a declaration match ending at this function name.
            prefix = code[max(0, m.start()-80):m.start()]
            if re.search(r"(?:void|boolean|int|string|WasmImmediate)\s+$", prefix):
                continue
        if m.start() < decl_pos[name]:
            raise AssertionError(f"{path}: forward call to {name} before its definition")


def check_ash(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    code = strip_comments_and_strings(text)
    balanced(code, path)
    # ASH reserves Java-style ternary syntax but does not implement it.
    if "?" in code:
        raise AssertionError(f"{path}: '?' found in executable ASH source")
    if path.name == "runtime.ash":
        forbidden = [
            "visit_url", "cli_execute", "adventure", "adv1", "buy",
            "autosell", "put_shop", "put_stash", "take_stash",
            "chat_private", "chat_clan", "kmail", "send_gift",
        ]
        for name in forbidden:
            if re.search(rf"\b{re.escape(name)}\s*\(", code):
                raise AssertionError(f"{path}: forbidden host mutation surface {name}()")
    check_function_order(path, code)


def decode_hex(path: Path) -> bytes:
    chunks = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].split("//", 1)[0]
        chunks.append(line)
    raw = "".join(chunks)
    digits = "".join(c for c in raw if c not in " \t\r\n,:")
    if len(digits) % 2:
        raise AssertionError(f"{path}: odd hex digit count")
    return bytes.fromhex(digits)


def check_fixture(path: Path) -> None:
    data = decode_hex(path)
    if data[:8] != b"\x00asm\x01\x00\x00\x00":
        raise AssertionError(f"{path}: invalid Wasm v1 header")
    if len(data) < 9:
        raise AssertionError(f"{path}: implausibly short module")


def main() -> None:
    for p in ASH_FILES:
        check_ash(p)
        print(f"PASS ash-static {p.relative_to(ROOT)}")
    for p in sorted((ROOT / "data" / "wasm-ash" / "examples").glob("*.hex")):
        check_fixture(p)
        print(f"PASS wasm-fixture {p.relative_to(ROOT)}")
    print("static_check PASS")


if __name__ == "__main__":
    main()
