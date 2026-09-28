#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
BRIDGE = ROOT / "bridge" / "pyash_seed_mcp.py"
RELAY = ROOT / "relay" / "relay_pyash_mcp.ash"
PYASH = ROOT / "scripts" / "pyash.ash"
REGISTRY = ROOT / "data" / "pyash-mcp" / "tools.tsv"


def load_bridge():
    spec = importlib.util.spec_from_file_location("pyash_seed_mcp", BRIDGE)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot import bridge")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def main() -> int:
    errors: list[str] = []
    relay = RELAY.read_text(encoding="utf-8")
    pyash = PYASH.read_text(encoding="utf-8")

    # Dispatcher must remain a narrow PyASH host. These direct execution/network
    # surfaces are not needed by the seed and should not silently appear later.
    stripped = "\n".join(line.split("//", 1)[0] for line in relay.splitlines())
    forbidden = [
        "cli_execute(",
        "visit_url(",
        "adventure(",
        "adv1(",
        "buy(",
        "create_matcher(",
        "chat_private(",
        "send_kmail(",
    ]
    for token in forbidden:
        if token in stripped:
            errors.append(f"relay contains forbidden direct capability: {token}")

    required = [
        "import <pyash.ash>;",
        'file_to_map("pyash-mcp/tools.tsv"',
        'starts_with(path, "pyash-mcp/tools/")',
        'PY_GLOBALS["result"]',
        "py_exec_range(",
        "form_fields()",
    ]
    for token in required:
        if token not in relay:
            errors.append(f"relay missing required seed mechanism: {token}")

    if "arbitrary ASH" not in pyash:
        errors.append("vendored PyASH does not look like the supplied v0.1 source")

    try:
        bridge = load_bridge()
        tools = bridge.load_registry(REGISTRY)
    except Exception as exc:  # validation script should print a compact diagnosis
        errors.append(f"registry/bridge validation failed: {exc}")
        tools = {}

    if set(tools) != {"add", "echo", "health", "logic"}:
        errors.append(f"unexpected seed tool set: {sorted(tools)}")

    for tool in tools.values():
        source = ROOT / "data" / tool.script
        if not source.is_file():
            errors.append(f"tool source missing: {source}")
            continue
        text = source.read_text(encoding="utf-8")
        if not re.search(r"(?m)^result\s*=", text) and "result =" not in text:
            errors.append(f"tool does not assign result: {tool.name}")

    if errors:
        print("PYASH_SEED_VALIDATE=FAIL")
        for error in errors:
            print(error)
        return 1

    print("PYASH_SEED_VALIDATE=PASS")
    print(f"tools={len(tools)}")
    print("transport=stdio-jsonrpc")
    print("modern_protocol=2026-07-28")
    print("legacy_initialize_compat=2025-11-25,2025-06-18")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
