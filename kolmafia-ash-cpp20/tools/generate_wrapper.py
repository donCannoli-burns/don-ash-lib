#!/usr/bin/env python3
"""Generate a small C++ wrapper header from a declarative ASH/JSON-API spec.

This intentionally consumes a tiny explicit YAML-free text format rather than
trying to parse wiki output. Generate the spec from `ashref` on the target
KoLmafia instance so the names/signatures stay build-local.

Format:
  <cpp_return> <cpp_name> <json_api_name> [<arg_type> <arg_name>]...

Supported return types: int64, string, bool, json
Supported arg types: int64, string, bool, enum

Example:
  int64 my_meat myMeat
  int64 available_amount availableAmount enum item
"""

from __future__ import annotations
import argparse
from pathlib import Path

RETURNS = {
    "int64": ("std::int64_t", "detail::as_int"),
    "string": ("std::string", "detail::as_string"),
    "bool": ("bool", "detail::as_bool"),
    "json": ("boost::json::value", ""),
}
ARGS = {
    "int64": "std::int64_t",
    "string": "std::string_view",
    "bool": "bool",
    "enum": "const ::kolmafia::ash::EnumRef&",
}


def parse_line(line: str):
    parts = line.split()
    if not parts or line.lstrip().startswith("#"):
        return None
    if len(parts) < 3 or (len(parts) - 3) % 2:
        raise ValueError(f"invalid spec line: {line.rstrip()}")
    ret, cpp_name, api_name = parts[:3]
    if ret not in RETURNS:
        raise ValueError(f"unsupported return type {ret!r}")
    args = []
    for i in range(3, len(parts), 2):
        typ, name = parts[i], parts[i + 1]
        if typ not in ARGS:
            raise ValueError(f"unsupported argument type {typ!r}")
        args.append((typ, name))
    return ret, cpp_name, api_name, args


def generate(spec: Path, namespace: str) -> str:
    rows = [x for line in spec.read_text().splitlines() if (x := parse_line(line))]
    out = [
        "#pragma once",
        '#include "kolmafia_ash/client.hpp"',
        "#include <cstdint>",
        "#include <string>",
        "#include <string_view>",
        "",
        f"namespace {namespace} {{",
        "class Api {",
        " public:",
        "  explicit Api(const ::kolmafia::ash::Client& client) : client_(client) {}",
    ]
    for ret, cpp_name, api_name, args in rows:
        cpp_ret, converter = RETURNS[ret]
        params = ", ".join(f"{ARGS[t]} {n}" for t, n in args)
        argnames = ", ".join(n for _, n in args)
        call_args = f"::kolmafia::ash::args({argnames})" if args else "{}"
        out.append(f"  [[nodiscard]] {cpp_ret} {cpp_name}({params}) const {{")
        out.append(f'    auto v = client_.call("{api_name}", {call_args});')
        if ret == "json":
            out.append("    return v;")
        elif ret == "int64":
            out += [
                '    if (v.is_int64()) return v.as_int64();',
                '    throw ::kolmafia::ash::ApiError("generated wrapper expected integer");',
            ]
        elif ret == "string":
            out += [
                '    if (v.is_string()) return std::string(v.as_string());',
                '    throw ::kolmafia::ash::ApiError("generated wrapper expected string");',
            ]
        elif ret == "bool":
            out += [
                '    if (v.is_bool()) return v.as_bool();',
                '    throw ::kolmafia::ash::ApiError("generated wrapper expected bool");',
            ]
        out.append("  }")
    out += [
        " private:",
        "  const ::kolmafia::ash::Client& client_;",
        "};",
        f"}} // namespace {namespace}",
        "",
    ]
    return "\n".join(out)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("spec", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("--namespace", default="kolmafia_generated")
    a = p.parse_args()
    a.output.write_text(generate(a.spec, a.namespace))


if __name__ == "__main__":
    main()
