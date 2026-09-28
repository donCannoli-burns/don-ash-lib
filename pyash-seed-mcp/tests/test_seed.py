from __future__ import annotations

import contextlib
import importlib.util
import io
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import subprocess
import sys
import threading
import time
import urllib.parse

ROOT = Path(__file__).resolve().parents[1]
BRIDGE_PATH = ROOT / "bridge" / "pyash_seed_mcp.py"
REGISTRY = ROOT / "data" / "pyash-mcp" / "tools.tsv"


def load_bridge():
    spec = importlib.util.spec_from_file_location("pyash_seed_mcp_tested", BRIDGE_PATH)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


bridge = load_bridge()


class FakeRelayHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        size = int(self.headers.get("Content-Length", "0"))
        fields = urllib.parse.parse_qs(self.rfile.read(size).decode("utf-8"), keep_blank_values=True)
        tool = fields.get("tool", [""])[0]
        if fields.get("pwd", [""])[0] != "test-pwd":
            payload = {"ok": False, "error": "pwd missing"}
        elif tool == "echo":
            payload = {"ok": True, "kind": "string", "value": fields["arg_message"][0]}
        elif tool == "add":
            value = float(fields["arg_a"][0]) + float(fields["arg_b"][0])
            payload = {"ok": True, "kind": "number", "value": value}
        elif tool == "logic":
            value = fields["arg_enabled"][0].lower() == "true"
            payload = {"ok": True, "kind": "string", "value": "enabled" if value else "disabled"}
        elif tool == "health":
            payload = {"ok": True, "kind": "string", "value": "pyash-seed-mcp ready"}
        else:
            payload = {"ok": False, "error": "unknown tool"}
        body = json.dumps(payload).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass


@contextlib.contextmanager
def fake_relay():
    server = ThreadingHTTPServer(("127.0.0.1", 0), FakeRelayHandler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        host, port = server.server_address
        yield f"http://{host}:{port}/relay_pyash_mcp.ash"
    finally:
        server.shutdown()
        server.server_close()
        thread.join(timeout=2)


def modern_meta():
    return {
        "_meta": {
            "io.modelcontextprotocol/protocolVersion": "2026-07-28",
            "io.modelcontextprotocol/clientInfo": {"name": "tests", "version": "1"},
            "io.modelcontextprotocol/clientCapabilities": {},
        }
    }


def assert_true(cond, message):
    if not cond:
        raise AssertionError(message)


def unit_checks():
    tools = bridge.load_registry(REGISTRY)
    assert_true(list(tools) == ["add", "echo", "health", "logic"], "registry sort/tool names")
    assert_true(tools["add"].mcp_definition()["inputSchema"]["required"] == ["a", "b"], "add schema")
    assert_true(bridge.validate_arguments(tools["echo"], {"message": "hi"}) == {"message": "hi"}, "echo args")
    try:
        bridge.validate_arguments(tools["add"], {"a": 1, "b": True})
    except bridge.SeedError:
        pass
    else:
        raise AssertionError("bool must not validate as a number")

    try:
        bridge.RelayClient("http://example.com/x", None)
    except bridge.SeedError:
        pass
    else:
        raise AssertionError("remote relay guard did not fire")


def server_checks():
    tools = bridge.load_registry(REGISTRY)
    with fake_relay() as url:
        server = bridge.MCPServer(tools, bridge.RelayClient(url, "test-pwd"))

        discover = server.handle({"jsonrpc": "2.0", "id": 1, "method": "server/discover", "params": modern_meta()})
        assert_true(discover["result"]["resultType"] == "complete", "discover modern resultType")
        assert_true(discover["result"]["supportedVersions"] == ["2026-07-28"], "discover version")

        listing = server.handle({"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": modern_meta()})
        assert_true(listing["result"]["resultType"] == "complete", "list modern resultType")
        assert_true(len(listing["result"]["tools"]) == 4, "list tools count")
        assert_true(listing["result"]["cacheScope"] == "public", "list cache scope")

        call_params = {"name": "add", "arguments": {"a": 7, "b": 35}, **modern_meta()}
        called = server.handle({"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": call_params})
        assert_true(called["result"]["content"][0]["text"] == "42", "add tool text")
        assert_true(called["result"]["structuredContent"] == 42.0, "add structured content")

        legacy = server.handle(
            {
                "jsonrpc": "2.0",
                "id": 4,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2025-11-25",
                    "capabilities": {},
                    "clientInfo": {"name": "legacy-test", "version": "1"},
                },
            }
        )
        assert_true(legacy["result"]["protocolVersion"] == "2025-11-25", "legacy version")
        assert_true("resultType" not in legacy["result"], "legacy result must not get modern discriminator")


def subprocess_checks():
    with fake_relay() as url:
        env = dict(**__import__("os").environ)
        env.update({"PYASH_MCP_RELAY_URL": url, "KOLMAFIA_PWD": "test-pwd"})
        proc = subprocess.Popen(
            [sys.executable, str(BRIDGE_PATH)],
            cwd=ROOT,
            env=env,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        assert proc.stdin and proc.stdout and proc.stderr
        requests = [
            {"jsonrpc": "2.0", "id": "d", "method": "server/discover", "params": modern_meta()},
            {"jsonrpc": "2.0", "id": "l", "method": "tools/list", "params": modern_meta()},
            {
                "jsonrpc": "2.0",
                "id": "c",
                "method": "tools/call",
                "params": {"name": "echo", "arguments": {"message": "hello MCP"}, **modern_meta()},
            },
            {
                "jsonrpc": "2.0",
                "id": "i",
                "method": "initialize",
                "params": {
                    "protocolVersion": "2025-11-25",
                    "capabilities": {},
                    "clientInfo": {"name": "legacy", "version": "1"},
                },
            },
        ]
        for req in requests:
            proc.stdin.write(json.dumps(req, separators=(",", ":")) + "\n")
        proc.stdin.close()
        out = proc.stdout.read()
        err = proc.stderr.read()
        rc = proc.wait(timeout=5)
        assert_true(rc == 0, f"stdio process failed rc={rc} stderr={err}")
        lines = [json.loads(line) for line in out.splitlines() if line]
        assert_true(len(lines) == 4, f"expected 4 stdout MCP messages, got {len(lines)}: {out!r}")
        assert_true(lines[2]["result"]["content"][0]["text"] == "hello MCP", "stdio echo")
        assert_true(err == "", f"unexpected stderr: {err!r}")


def main():
    unit_checks()
    server_checks()
    subprocess_checks()
    print("PYASH_SEED_TESTS=PASS")
    print("checks=unit,modern-discover,modern-tools,legacy-initialize,stdio,fake-relay")


if __name__ == "__main__":
    main()
