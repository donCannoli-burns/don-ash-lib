# Manifest

## KoLmafia-side install

```text
scripts/pyash.ash                 -> <KoLmafia>/scripts/pyash.ash
relay/relay_pyash_mcp.ash         -> <KoLmafia>/relay/relay_pyash_mcp.ash
data/pyash-mcp/tools.tsv          -> <KoLmafia>/data/pyash-mcp/tools.tsv
data/pyash-mcp/tools/*.py         -> <KoLmafia>/data/pyash-mcp/tools/*.py
```

## MCP-host side

Run:

```text
bridge/pyash_seed_mcp.py
```

as a stdio MCP child process.
