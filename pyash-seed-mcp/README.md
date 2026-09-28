# PyASH Seed MCP

A **generic / seed Model Context Protocol server whose tool bodies execute in PyASH inside KoLmafia**.

This project intentionally does **not** pretend PyASH v0.1 can directly own an MCP process transport. The supplied PyASH interpreter has no JSON objects, dictionaries, imports, sockets, or stdin/stdout process API. Instead, the seed keeps those responsibilities separated:

```text
MCP host
   │
   │ newline-delimited JSON-RPC over stdio
   ▼
bridge/pyash_seed_mcp.py
   │
   │ narrow form POST to loopback KoLmafia relay
   ▼
relay/relay_pyash_mcp.ash
   │
   │ import <pyash.ash>
   ▼
data/pyash-mcp/tools/*.py
   │
   ▼
PyASH v0.1 interpreter
```

The **MCP adapter is transport glue**. The actual seed tools are written in the supplied Python-like PyASH language and run in ASH/KoLmafia.

## What it supports

### MCP

- stdio transport
- current **MCP 2026-07-28** `server/discover`
- `tools/list`
- `tools/call`
- modern `resultType: "complete"`
- modern per-response server identity metadata
- modern cache hints for discovery/tool listing
- modern scalar `structuredContent`
- compatibility with legacy `initialize` for:
  - `2025-11-25`
  - `2025-06-18`
- legacy `ping`
- newline-delimited JSON-RPC framing
- no third-party Python package dependency

Current MCP specification references:

- https://modelcontextprotocol.io/specification/2026-07-28
- https://modelcontextprotocol.io/specification/2026-07-28/server/discover
- https://modelcontextprotocol.io/specification/2026-07-28/server/tools
- https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/stdio

### PyASH seed tool ABI

A tool:

1. receives registry-declared scalar arguments as PyASH globals;
2. runs a registry-approved `.py` source file;
3. assigns its result to the global variable `result`.

Supported argument/result primitives follow PyASH v0.1:

```text
string
number
integer   (seed-side validation; represented numerically in PyASH)
boolean
None      (result only)
```

No list/dict input is claimed because the supplied PyASH v0.1 does not implement those types yet.

## Included seed tools

| MCP tool | PyASH source | Purpose |
| --- | --- | --- |
| `echo` | `data/pyash-mcp/tools/echo.py` | echo a string |
| `add` | `data/pyash-mcp/tools/add.py` | add two numbers |
| `logic` | `data/pyash-mcp/tools/logic.py` | demonstrate PyASH `if/else` |
| `health` | `data/pyash-mcp/tools/health.py` | zero-argument runtime smoke tool |

For example, `add.py` is simply:

```python
# Seeded globals: a, b
result = a + b
```

## Install the KoLmafia side

Run:

```bash
./tools/install.sh /path/to/your/KoLmafia-root
```

That installs:

```text
scripts/pyash.ash
relay/relay_pyash_mcp.ash
data/pyash-mcp/tools.tsv
data/pyash-mcp/tools/*.py
```

Then in KoLmafia gCLI:

```text
verify pyash.ash
verify relay/relay_pyash_mcp.ash
```

The first command is the original PyASH verification gate. The second is the seed dispatcher gate.

## Start the MCP server

The adapter is stdlib-only Python 3:

```bash
export KOLMAFIA_PWD='<current KoLmafia pwd hash>'
python3 /absolute/path/to/pyash-seed-mcp/bridge/pyash_seed_mcp.py
```

Normally your MCP host launches that command for you.

The default relay endpoint is:

```text
http://127.0.0.1:60080/relay_pyash_mcp.ash
```

Override it with:

```bash
export PYASH_MCP_RELAY_URL='http://127.0.0.1:60080/relay_pyash_mcp.ash'
```

The adapter refuses non-loopback hosts by default. Do not put a KoLmafia password hash onto an untrusted plaintext network. An intentional remote deployment requires `PYASH_MCP_ALLOW_REMOTE=1` **and** your own secured transport boundary.

## Generic MCP host configuration

A host that accepts command/args style MCP configuration can point to:

```json
{
  "command": "python3",
  "args": [
    "/absolute/path/to/pyash-seed-mcp/bridge/pyash_seed_mcp.py"
  ]
}
```

Pass `KOLMAFIA_PWD` through the process environment rather than committing it to the project.

## Add a new PyASH tool

The registry is the single seed manifest:

```text
data/pyash-mcp/tools.tsv
```

Format:

```text
name<TAB>title<TAB>description<TAB>script<TAB>args
```

Argument entries are comma-separated:

```text
name:type:required
name:type:optional
name:type:optional:default
```

Supported types:

```text
string
number
integer
boolean
```

Example registry row:

```text
multiply	Multiply	Multiply two numbers in PyASH.	pyash-mcp/tools/multiply.py	a:number:required,b:number:required
```

Then create:

```text
data/pyash-mcp/tools/multiply.py
```

with:

```python
result = a * b
```

Re-run:

```bash
make check
```

and reinstall the KoLmafia side.

See [`docs/ADDING_TOOLS.md`](docs/ADDING_TOOLS.md) for the complete seed ABI.

## Why the registry is shared

Both sides use the same `tools.tsv` authority:

```text
tools.tsv
   ├── stdio adapter -> MCP JSON Schema / validation
   └── relay ASH     -> script allowlist / argument seeding
```

That avoids having one list of tools advertised to the model and another list executable by KoLmafia.

## Safety boundary

This version deliberately exposes **pure PyASH seed execution**, not arbitrary KoLmafia execution.

The relay dispatcher does not contain direct calls to:

- gCLI execution
- URL fetching
- adventuring
- buying
- chat/kmail
- arbitrary ASH function-name dispatch

PyASH v0.1 itself also deliberately lacks arbitrary ASH dispatch.

That means adding an MCP tool does **not** automatically give it all of KoLmafia.

If you later add a `kol.*` host capability layer, keep it explicit and allowlisted rather than mapping arbitrary PyASH identifiers to ASH runtime functions.

See [`docs/SECURITY.md`](docs/SECURITY.md).

## Tests

Offline checks require only Python 3:

```bash
make check
```

They cover:

- the supplied PyASH static validator
- registry validation
- seed dispatcher static policy checks
- loopback transport guard
- MCP 2026 `server/discover`
- modern `tools/list`
- modern `tools/call`
- scalar structured content
- legacy `initialize`
- actual newline-delimited stdio subprocess framing
- fake KoLmafia relay integration

The final live gates must be run inside your KoLmafia installation:

```text
verify pyash.ash
verify relay/relay_pyash_mcp.ash
```

and then call the `health` MCP tool from a real MCP client.

See [`TEST_STATUS.md`](TEST_STATUS.md).

## Project structure

```text
pyash-seed-mcp/
├── bridge/
│   └── pyash_seed_mcp.py
├── data/
│   └── pyash-mcp/
│       ├── tools.tsv
│       └── tools/
│           ├── add.py
│           ├── echo.py
│           ├── health.py
│           └── logic.py
├── docs/
│   ├── ADDING_TOOLS.md
│   ├── ARCHITECTURE.md
│   └── SECURITY.md
├── relay/
│   └── relay_pyash_mcp.ash
├── scripts/
│   └── pyash.ash
├── tests/
│   └── test_seed.py
└── tools/
    ├── install.sh
    ├── validate_pyash_vendor.py
    └── validate_seed.py
```

## Supplied PyASH provenance

`scripts/pyash.ash` is copied unchanged from the user-supplied `pyash-v0.1.0(1).zip` used to build this seed.

Its SHA-256 at build time is recorded in `PROVENANCE.md`.

## Deliberate non-goals for v0.1

- pretending PyASH has native JSON/dict support when it does not
- arbitrary ASH runtime exposure
- Streamable HTTP directly from a KoLmafia relay script
- MCP resources/prompts
- MRTR/elicitation
- subscriptions
- asynchronous tool jobs
- nested JSON arguments
- hidden mutating tools

Those can be layered later without weakening the seed's basic execution boundary.

## Why It Exists

It keeps MCP transport logic outside the deliberately tiny PyASH language while still letting registered tool bodies execute inside KoLmafia.

## Files

- `LICENSE` — packaged source/support material.
- `MANIFEST.md` — packaged source/support material.
- `Makefile` — packaged source/support material.
- `TEST_STATUS.md` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `bridge/` — packaged source/support material.
- `data/` — packaged source/support material.
- `docs/` — packaged source/support material.
- `relay/` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `tests/` — packaged source/support material.
- `tools/` — packaged source/support material.

## Status

Prototype.

## Compatibility

Python 3 for the stdio MCP bridge plus KoLmafia/PyASH for host-side execution.

## Provenance

Extracted and packaged as a standalone repository from `pyash-seed-mcp.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- offline MCP unit/discover/tools/stdio/fake-relay suite

KoLmafia host-side verify remains required.
