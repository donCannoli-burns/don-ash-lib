#!/usr/bin/env python3
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs

HOST = "127.0.0.1"
PORT = 61880


def call_result(call):
    name = call.get("name")
    args = call.get("args", [])
    if name == "myName":
        return "Fake Cannoli"
    if name == "myLevel":
        return 13
    if name == "myMeat":
        return 123456
    if name == "availableAmount":
        assert args[0]["objectType"] == "Item"
        assert args[0]["identifierString"] == "seal-clubbing club"
        return 2
    if name == "getProperty":
        return "fake-value"
    if name == "cliExecute":
        return True
    if name == "setProperty":
        return None
    if name == "visitUrl":
        return "fake page"
    return {"echoFunction": name, "echoArgs": args}


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/KoLmafia/jsonApi":
            self.send_error(404)
            return

        length = int(self.headers.get("Content-Length", "0"))
        form = parse_qs(self.rfile.read(length).decode("utf-8"))
        if form.get("pwd", [None])[0] != "test-pwd":
            self._json({"error": "bad pwd"})
            return

        request = json.loads(form["body"][0])
        response = {}
        if "properties" in request:
            response["properties"] = [p == "kingLiberated" for p in request["properties"]]
        if "functions" in request:
            response["functions"] = [call_result(c) for c in request["functions"]]
        self._json(response)

    def _json(self, obj):
        payload = json.dumps(obj).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    HTTPServer((HOST, PORT), Handler).serve_forever()
