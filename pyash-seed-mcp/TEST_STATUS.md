# Test Status

## Offline checks performed

Passed:

```text
PYASH_STATIC_VALIDATE=PASS
functions=42
lines=805

PYASH_SEED_VALIDATE=PASS
tools=4
transport=stdio-jsonrpc
modern_protocol=2026-07-28
legacy_initialize_compat=2025-11-25,2025-06-18

PYASH_SEED_TESTS=PASS
checks=unit,modern-discover,modern-tools,legacy-initialize,stdio,fake-relay
```

The test suite covers:

- supplied PyASH static validation
- shared registry parsing
- JSON Schema derivation
- primitive argument validation
- boolean-vs-number validation edge case
- loopback-only relay guard
- modern `server/discover`
- modern `tools/list`
- modern `tools/call`
- modern scalar `structuredContent`
- legacy `initialize`
- fake relay POST integration
- real subprocess stdin/stdout newline framing
- stdout cleanliness
- static rejection of direct high-authority dispatcher surfaces

## KoLmafia host-side gate

The offline suite was rerun successfully against this package. The current KoLmafia release line was also checked on 2026-09-27; GitHub lists **r29301** as latest (released 2026-09-26). This sandbox does not contain a KoLmafia installation/JAR and its execution container cannot fetch the release binary, so KoLmafia's own parser/runtime verification remains the host-side gate:

```text
verify pyash.ash
verify relay/relay_pyash_mcp.ash
```

Then launch the stdio bridge from an MCP client and call:

```text
health
add {"a": 7, "b": 35}
echo {"message": "hello"}
logic {"enabled": true}
```

Expected values:

```text
pyash-seed-mcp ready
42
hello
enabled
```

## Important scope statement

The offline fake relay verifies the MCP adapter contract, not KoLmafia relay execution semantics. KoLmafia's own `verify` plus a live `health` call are the authoritative integration test.
