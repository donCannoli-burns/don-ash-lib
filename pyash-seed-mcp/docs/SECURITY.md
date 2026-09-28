# Security Model

## Default trust boundary

The seed assumes:

```text
MCP host -> local stdio child -> local KoLmafia relay -> PyASH
```

The default KoLmafia endpoint is loopback-only:

```text
http://127.0.0.1:60080/relay_pyash_mcp.ash
```

The adapter rejects non-loopback relay URLs unless explicitly overridden.

## Why the pwd hash stays out of the registry

The KoLmafia `pwd` value is transport authentication material. It is read from:

```text
PYASH_MCP_PWD
```

or:

```text
KOLMAFIA_PWD
```

Do not commit it into the tool registry, source code, README examples, or MCP project repository.

## Tool authority

A registry entry authorizes only:

1. a specific tool name;
2. a specific PyASH file under `pyash-mcp/tools/`;
3. a declared set of scalar input globals.

The dispatcher rejects path traversal and does not map tool names to arbitrary ASH functions.

## No direct mutation surface in v0.1

The dispatcher intentionally does not need direct gCLI, network, adventure, purchase, or messaging operations.

The static validator fails if those surfaces are added to the dispatcher accidentally.

This does not prove every future PyASH extension is safe. It preserves the supplied v0.1 boundary.

## If you later expose KoLmafia capabilities

Prefer an explicit host-capability table such as:

```text
kol.my_name          read-only
kol.item_amount      read-only
kol.get_property     read-only
```

with separate policy for effectful calls.

Do **not** implement:

```text
unknown_pyash_identifier -> ASH runtime lookup -> execute
```

That would collapse the distinction between a small embedded language and unrestricted KoLmafia execution.

## MCP tool annotations

The seed marks its bundled pure-compute tools as read-only/idempotent/non-destructive. MCP clients must still treat server-provided annotations as untrusted metadata; authorization should be enforced by code, not by descriptive annotations.
