#!/usr/bin/env python3
"""Generic seed MCP stdio adapter for PyASH tools.

The MCP wire protocol lives here because PyASH v0.1 intentionally has no JSON,
stdio, sockets, dictionaries, or imports. Tool *implementation* stays in PyASH;
this process only validates JSON-RPC, translates scalar arguments to the narrow
KoLmafia relay form contract, and translates the scalar result back to MCP.
"""
from __future__ import annotations

import argparse
import dataclasses
import json
import math
import os
from pathlib import Path
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Iterable

SERVER_NAME = "pyash-seed-mcp"
SERVER_VERSION = "0.1.0"
MODERN_VERSION = "2026-07-28"
LEGACY_VERSION = "2025-11-25"
SUPPORTED_LEGACY = {"2025-11-25", "2025-06-18"}
SERVER_INFO = {
    "name": SERVER_NAME,
    "version": SERVER_VERSION,
    "description": "Generic MCP seed whose tools execute in KoLmafia PyASH.",
}
TOOL_NAME_RE = re.compile(r"^[A-Za-z0-9_.-]{1,128}$")
ARG_NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
LOOPBACK_HOSTS = {"127.0.0.1", "localhost", "::1"}


class SeedError(Exception):
    pass


@dataclasses.dataclass(frozen=True)
class ArgSpec:
    name: str
    kind: str
    required: bool
    default: Any = None
    has_default: bool = False

    def schema(self) -> dict[str, Any]:
        type_name = {
            "string": "string",
            "number": "number",
            "integer": "integer",
            "boolean": "boolean",
        }[self.kind]
        out: dict[str, Any] = {"type": type_name}
        if self.has_default:
            out["default"] = self.default
        return out


@dataclasses.dataclass(frozen=True)
class ToolSpec:
    name: str
    title: str
    description: str
    script: str
    args: tuple[ArgSpec, ...]

    def mcp_definition(self) -> dict[str, Any]:
        properties = {arg.name: arg.schema() for arg in self.args}
        required = [arg.name for arg in self.args if arg.required]
        schema: dict[str, Any] = {
            "type": "object",
            "properties": properties,
            "additionalProperties": False,
        }
        if required:
            schema["required"] = required
        return {
            "name": self.name,
            "title": self.title,
            "description": self.description,
            "inputSchema": schema,
            "annotations": {
                "readOnlyHint": True,
                "destructiveHint": False,
                "idempotentHint": True,
                "openWorldHint": False,
            },
        }


def _parse_default(kind: str, raw: str) -> Any:
    if kind == "string":
        return raw
    if kind == "number":
        try:
            value = float(raw)
        except ValueError as exc:
            raise SeedError(f"invalid number default {raw!r}") from exc
        if not math.isfinite(value):
            raise SeedError("numeric defaults must be finite")
        return value
    if kind == "integer":
        try:
            return int(raw, 10)
        except ValueError as exc:
            raise SeedError(f"invalid integer default {raw!r}") from exc
    if kind == "boolean":
        lowered = raw.lower()
        if lowered == "true":
            return True
        if lowered == "false":
            return False
        raise SeedError(f"invalid boolean default {raw!r}")
    raise SeedError(f"unsupported argument kind: {kind}")


def parse_arg_spec(text: str) -> tuple[ArgSpec, ...]:
    if not text or text == "-":
        return ()
    args: list[ArgSpec] = []
    seen: set[str] = set()
    for entry in text.split(","):
        parts = entry.split(":", 3)
        if len(parts) < 3:
            raise SeedError(f"invalid argument spec: {entry!r}")
        name, kind, mode = (part.strip() for part in parts[:3])
        if not ARG_NAME_RE.fullmatch(name):
            raise SeedError(f"invalid argument name: {name!r}")
        if name in seen:
            raise SeedError(f"duplicate argument name: {name}")
        seen.add(name)
        if kind not in {"string", "number", "integer", "boolean"}:
            raise SeedError(f"unsupported argument kind for {name}: {kind}")
        if mode not in {"required", "optional"}:
            raise SeedError(f"argument mode must be required/optional for {name}")
        has_default = len(parts) == 4
        if mode == "required" and has_default:
            raise SeedError(f"required argument {name} must not have a default")
        default = _parse_default(kind, parts[3]) if has_default else None
        args.append(
            ArgSpec(
                name=name,
                kind=kind,
                required=(mode == "required"),
                default=default,
                has_default=has_default,
            )
        )
    return tuple(args)


def load_registry(path: Path) -> dict[str, ToolSpec]:
    tools: dict[str, ToolSpec] = {}
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise SeedError(f"cannot read registry {path}: {exc}") from exc
    for lineno, raw in enumerate(lines, 1):
        if not raw or raw.startswith("#"):
            continue
        cols = raw.split("\t")
        if len(cols) != 5:
            raise SeedError(f"{path}:{lineno}: expected 5 tab-separated columns")
        name, title, description, script, arg_text = cols
        if not TOOL_NAME_RE.fullmatch(name):
            raise SeedError(f"{path}:{lineno}: invalid MCP tool name {name!r}")
        if name in tools:
            raise SeedError(f"{path}:{lineno}: duplicate tool {name}")
        if not script.startswith("pyash-mcp/tools/") or ".." in script or not script.endswith(".py"):
            raise SeedError(f"{path}:{lineno}: unsafe script path {script!r}")
        tools[name] = ToolSpec(
            name=name,
            title=title,
            description=description,
            script=script,
            args=parse_arg_spec(arg_text),
        )
    return dict(sorted(tools.items()))


def _is_json_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(float(value))


def validate_arguments(spec: ToolSpec, arguments: Any) -> dict[str, Any]:
    if arguments is None:
        arguments = {}
    if not isinstance(arguments, dict):
        raise SeedError("tool arguments must be a JSON object")
    allowed = {arg.name for arg in spec.args}
    extras = sorted(set(arguments) - allowed)
    if extras:
        raise SeedError("unexpected argument(s): " + ", ".join(extras))

    normalized: dict[str, Any] = {}
    for arg in spec.args:
        if arg.name not in arguments:
            if arg.required:
                raise SeedError(f"missing required argument: {arg.name}")
            if arg.has_default:
                normalized[arg.name] = arg.default
            continue
        value = arguments[arg.name]
        ok = False
        if arg.kind == "string":
            ok = isinstance(value, str)
        elif arg.kind == "boolean":
            ok = type(value) is bool
        elif arg.kind == "integer":
            ok = isinstance(value, int) and not isinstance(value, bool)
        elif arg.kind == "number":
            ok = _is_json_number(value)
        if not ok:
            raise SeedError(f"argument {arg.name!r} must be {arg.kind}")
        normalized[arg.name] = value
    return normalized


def _form_value(value: Any) -> str:
    if type(value) is bool:
        return "true" if value else "false"
    if isinstance(value, str):
        return value
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        if not math.isfinite(value):
            raise SeedError("non-finite numbers are not supported")
        return repr(value)
    raise SeedError(f"cannot encode tool argument type: {type(value).__name__}")


class RelayClient:
    def __init__(self, url: str, pwd: str | None, timeout: float = 15.0, allow_remote: bool = False):
        self.url = url
        self.pwd = pwd
        self.timeout = timeout
        parsed = urllib.parse.urlsplit(url)
        if parsed.scheme not in {"http", "https"}:
            raise SeedError("relay URL must use http or https")
        if not allow_remote and (parsed.hostname or "") not in LOOPBACK_HOSTS:
            raise SeedError(
                "refusing non-loopback relay URL; set PYASH_MCP_ALLOW_REMOTE=1 only if you intentionally secured that path"
            )

    def call(self, tool: ToolSpec, arguments: dict[str, Any]) -> tuple[str, Any]:
        fields: dict[str, str] = {"tool": tool.name}
        if self.pwd:
            fields["pwd"] = self.pwd
        for name, value in arguments.items():
            fields[f"arg_{name}"] = _form_value(value)
        body = urllib.parse.urlencode(fields).encode("utf-8")
        request = urllib.request.Request(
            self.url,
            data=body,
            method="POST",
            headers={
                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
                "Accept": "application/json, text/plain, */*",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=self.timeout) as response:
                raw = response.read().decode("utf-8", errors="replace").strip()
        except (urllib.error.URLError, TimeoutError, OSError) as exc:
            raise SeedError(f"KoLmafia relay request failed: {exc}") from exc
        try:
            payload = json.loads(raw)
        except json.JSONDecodeError as exc:
            preview = raw[:240].replace("\n", "\\n")
            raise SeedError(f"relay returned non-JSON response: {preview!r}") from exc
        if not isinstance(payload, dict):
            raise SeedError("relay response must be a JSON object")
        if payload.get("ok") is not True:
            raise SeedError(str(payload.get("error", "PyASH tool failed")))
        kind = payload.get("kind")
        if kind not in {"none", "bool", "number", "string"}:
            raise SeedError(f"relay returned unsupported PyASH result kind: {kind!r}")
        return kind, payload.get("value")


def _server_meta() -> dict[str, Any]:
    return {"io.modelcontextprotocol/serverInfo": dict(SERVER_INFO)}


def _text_for_value(kind: str, value: Any) -> str:
    if kind == "none":
        return "None"
    if kind == "bool":
        return "True" if value else "False"
    if kind == "number":
        if isinstance(value, float) and value.is_integer():
            return str(int(value))
        return str(value)
    return str(value)


class MCPServer:
    def __init__(self, tools: dict[str, ToolSpec], relay: RelayClient):
        self.tools = tools
        self.relay = relay
        self.legacy_version = LEGACY_VERSION

    @staticmethod
    def _request_version(message: dict[str, Any]) -> str | None:
        params = message.get("params")
        if not isinstance(params, dict):
            return None
        meta = params.get("_meta")
        if not isinstance(meta, dict):
            return None
        version = meta.get("io.modelcontextprotocol/protocolVersion")
        return version if isinstance(version, str) else None

    def _modern(self, message: dict[str, Any]) -> bool:
        return message.get("method") == "server/discover" or self._request_version(message) == MODERN_VERSION

    def _success(self, request_id: Any, result: dict[str, Any], modern: bool) -> dict[str, Any]:
        if modern:
            result = dict(result)
            result.setdefault("resultType", "complete")
            meta = result.setdefault("_meta", {})
            if isinstance(meta, dict):
                meta.setdefault("io.modelcontextprotocol/serverInfo", dict(SERVER_INFO))
        return {"jsonrpc": "2.0", "id": request_id, "result": result}

    @staticmethod
    def _error(request_id: Any, code: int, message: str, data: Any = None) -> dict[str, Any]:
        error: dict[str, Any] = {"code": code, "message": message}
        if data is not None:
            error["data"] = data
        return {"jsonrpc": "2.0", "id": request_id, "error": error}

    def handle(self, message: Any) -> dict[str, Any] | None:
        if not isinstance(message, dict) or message.get("jsonrpc") != "2.0":
            return self._error(None, -32600, "Invalid Request")
        method = message.get("method")
        request_id = message.get("id")

        # Notifications never receive a response.
        if "id" not in message:
            if method in {"notifications/initialized", "notifications/cancelled"}:
                return None
            return None

        if not isinstance(method, str):
            return self._error(request_id, -32600, "Invalid Request")

        modern = self._modern(message)

        if method == "server/discover":
            return self._success(
                request_id,
                {
                    "supportedVersions": [MODERN_VERSION],
                    "capabilities": {"tools": {}},
                    "instructions": (
                        "Tools execute in the supplied PyASH v0.1 interpreter. "
                        "Seed tools accept scalar JSON arguments only and cannot directly invoke arbitrary ASH."
                    ),
                    "ttlMs": 60000,
                    "cacheScope": "public",
                },
                True,
            )

        if method == "initialize":
            params = message.get("params")
            requested = params.get("protocolVersion") if isinstance(params, dict) else None
            if requested in SUPPORTED_LEGACY:
                self.legacy_version = requested
            else:
                self.legacy_version = LEGACY_VERSION
            return self._success(
                request_id,
                {
                    "protocolVersion": self.legacy_version,
                    "capabilities": {"tools": {}},
                    "serverInfo": dict(SERVER_INFO),
                    "instructions": "Generic PyASH tool seed MCP.",
                },
                False,
            )

        if method == "ping":
            return self._success(request_id, {}, modern)

        if method == "tools/list":
            result: dict[str, Any] = {
                "tools": [tool.mcp_definition() for tool in self.tools.values()],
            }
            if modern:
                result["ttlMs"] = 60000
                result["cacheScope"] = "public"
            return self._success(request_id, result, modern)

        if method == "tools/call":
            params = message.get("params")
            if not isinstance(params, dict):
                return self._error(request_id, -32602, "Invalid params", "params must be an object")
            name = params.get("name")
            if not isinstance(name, str) or name not in self.tools:
                return self._error(request_id, -32602, "Invalid params", f"unknown tool: {name!r}")
            tool = self.tools[name]
            try:
                arguments = validate_arguments(tool, params.get("arguments", {}))
            except SeedError as exc:
                return self._error(request_id, -32602, "Invalid params", str(exc))
            try:
                kind, value = self.relay.call(tool, arguments)
                text = _text_for_value(kind, value)
                result = {
                    "content": [{"type": "text", "text": text}],
                    "isError": False,
                }
                if modern:
                    # 2026-07-28 allows structuredContent to be any JSON value.
                    result["structuredContent"] = value
                return self._success(request_id, result, modern)
            except SeedError as exc:
                result = {
                    "content": [{"type": "text", "text": str(exc)}],
                    "isError": True,
                }
                return self._success(request_id, result, modern)

        return self._error(request_id, -32601, "Method not found", method)


def serve_stdio(server: MCPServer, lines: Iterable[str] | None = None) -> int:
    source = sys.stdin if lines is None else lines
    for raw in source:
        raw = raw.strip()
        if not raw:
            continue
        try:
            message = json.loads(raw)
        except json.JSONDecodeError as exc:
            response = MCPServer._error(None, -32700, "Parse error", str(exc))
        else:
            response = server.handle(message)
        if response is not None:
            sys.stdout.write(json.dumps(response, separators=(",", ":"), ensure_ascii=False) + "\n")
            sys.stdout.flush()
    return 0


def _default_registry() -> Path:
    return Path(__file__).resolve().parents[1] / "data" / "pyash-mcp" / "tools.tsv"


def build_server(args: argparse.Namespace) -> MCPServer:
    tools = load_registry(Path(args.registry))
    pwd = args.pwd if args.pwd is not None else os.environ.get("PYASH_MCP_PWD") or os.environ.get("KOLMAFIA_PWD")
    allow_remote = args.allow_remote or os.environ.get("PYASH_MCP_ALLOW_REMOTE") == "1"
    relay = RelayClient(args.relay_url, pwd, timeout=args.timeout, allow_remote=allow_remote)
    return MCPServer(tools, relay)


def parse_cli(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generic stdio MCP adapter for PyASH seed tools")
    parser.add_argument("--registry", default=str(_default_registry()))
    parser.add_argument(
        "--relay-url",
        default=os.environ.get("PYASH_MCP_RELAY_URL", "http://127.0.0.1:60080/relay_pyash_mcp.ash"),
    )
    parser.add_argument("--pwd", default=None, help="KoLmafia pwd hash; prefer KOLMAFIA_PWD/PYASH_MCP_PWD env vars")
    parser.add_argument("--timeout", type=float, default=float(os.environ.get("PYASH_MCP_TIMEOUT", "15")))
    parser.add_argument("--allow-remote", action="store_true")
    parser.add_argument("--dump-tools", action="store_true", help="print tool definitions as JSON and exit")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    try:
        args = parse_cli(argv)
        server = build_server(args)
        if args.dump_tools:
            json.dump([tool.mcp_definition() for tool in server.tools.values()], sys.stdout, indent=2)
            sys.stdout.write("\n")
            return 0
        return serve_stdio(server)
    except SeedError as exc:
        print(f"pyash-seed-mcp: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
