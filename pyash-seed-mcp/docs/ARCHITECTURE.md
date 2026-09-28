# Architecture

## Boundary map

```text
┌────────────────────────────────────────────┐
│ MCP host                                   │
└──────────────────────┬─────────────────────┘
                       │ stdio JSON-RPC
                       ▼
┌────────────────────────────────────────────┐
│ pyash_seed_mcp.py                          │
│                                            │
│ - MCP framing/protocol                     │
│ - registry -> JSON Schema                  │
│ - primitive argument validation            │
│ - loopback endpoint enforcement            │
│ - no tool business logic                   │
└──────────────────────┬─────────────────────┘
                       │ HTTP form POST
                       ▼
┌────────────────────────────────────────────┐
│ relay_pyash_mcp.ash                        │
│                                            │
│ - reads same registry                      │
│ - script allowlist                         │
│ - seeds PyASH globals                      │
│ - executes PyASH source                    │
│ - returns scalar envelope                  │
└──────────────────────┬─────────────────────┘
                       │ py_exec_range()
                       ▼
┌────────────────────────────────────────────┐
│ supplied PyASH v0.1 interpreter            │
└──────────────────────┬─────────────────────┘
                       │
                       ▼
┌────────────────────────────────────────────┐
│ data/pyash-mcp/tools/*.py                  │
│                                            │
│ result = ...                               │
└────────────────────────────────────────────┘
```

## Why not implement the stdio server in PyASH itself?

The supplied PyASH v0.1 intentionally does not implement:

- imports
- lists/dictionaries
- JSON parsing
- file/socket/process APIs
- stdin/stdout server loops
- arbitrary ASH calls

Adding all of those just to say the wire adapter was “pure PyASH” would turn a small MCP seed into a new runtime project and would erase PyASH's current capability boundary.

The stdio process is therefore an adapter, not the tool runtime.

## Why a relay script?

KoLmafia relay UI scripts provide a narrow local HTTP entry surface and `form_fields()`. That lets the adapter supply already-validated scalar inputs without exposing the gCLI or dynamically evaluating ASH source.

## Shared registry

`data/pyash-mcp/tools.tsv` is read independently by:

- the MCP adapter, to advertise and validate tools;
- the ASH dispatcher, to decide which PyASH file may execute.

This prevents advertisement/execution drift.

## Protocol eras

The seed supports two MCP behavior families:

### Modern (`2026-07-28`)

- `server/discover`
- no required initialize handshake
- per-request `_meta`
- `resultType: complete`
- scalar structured content

### Legacy compatibility

- `initialize`
- `notifications/initialized`
- tools list/call
- ping

The adapter does not claim the full legacy or modern feature surface; it advertises only tools.
