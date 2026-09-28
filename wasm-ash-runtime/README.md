# wasm-ash

A tiny **WebAssembly runtime / engine / VM written in KoLmafia ASH**.

This is intentionally not advertised as a complete WebAssembly implementation. It is a real parser + stack-machine interpreter for a bounded subset of the WebAssembly v1 binary format, designed around what is sensible inside ASH.

## What it does

```text
.wasm
  │
  │ convert bytes to hex text once
  ▼
module.hex
  │
  ▼
ASH loader
  ├── magic/version validation
  ├── section parser
  ├── unsigned/signed LEB128
  ├── type table
  ├── function table
  ├── export table
  └── code bodies
        │
        ▼
   stack-machine VM
        ├── i32
        ├── locals
        ├── calls
        ├── arithmetic
        ├── comparisons
        └── fuel/depth traps
```

The runtime interprets **actual Wasm opcodes**. Hex is only the transport encoding used to get arbitrary module bytes safely through ASH's text-oriented file APIs.

## Install

Copy the project contents into the matching KoLmafia directories:

```text
scripts/wasm-ash/runtime.ash
scripts/wasm-ash/wasm-ash.ash
scripts/wasm-ash/example.ash
data/wasm-ash/examples/add.hex
data/wasm-ash/examples/answer.hex
```

## Install helper

If the project is unpacked outside your KoLmafia root:

```bash
./tools/install.sh /path/to/KoLmafia-root
```

Or copy the `scripts/` and `data/` trees manually.

## Portable checks

With Python 3 and Node.js available:

```bash
make check
```

The fixture check runs the bundled modules through Node's independent WebAssembly engine before testing their expected exports. See `TEST_STATUS.md`.

## Smoke test

In gCLI:

```text
call wasm-ash/wasm-ash.ash selftest
```

Expected logical results:

```text
PASS add(7,35) = 42
PASS add(-5,2) = -3
PASS double(21) = 42
wasm-ash selftest PASS
```

You can also execute the example module:

```text
call wasm-ash/wasm-ash.ash run wasm-ash/examples/add.hex add 7 35
```

or:

```text
call wasm-ash/wasm-ash.ash run wasm-ash/examples/answer.hex answer
```

## Library API

```ash
import <wasm-ash/runtime.ash>;

if (!wasm_load_hex_file("wasm-ash/examples/add.hex")) {
    abort(wasm_error());
}

int result = wasm_invoke2("add", 20, 22);
if (wasm_error() != "") {
    abort(wasm_error());
}

print(result); // 42
```

General invocation uses an `int[int]` argument vector:

```ash
int[int] args = { 7, 35 };
int answer = wasm_invoke("add", args);
```

Convenience calls are supplied for 0–3 arguments:

```ash
wasm_invoke0("answer");
wasm_invoke1("double", 21);
wasm_invoke2("add", 7, 35);
wasm_invoke3("something", 1, 2, 3);
```

Module inspection:

```ash
wasm_print_module_info();
```

Input/execution limits:

```ash
wasm_set_max_module_bytes(262144);
wasm_set_fuel(50000);
wasm_set_max_call_depth(32);
```

## Converting `.wasm` to `.hex`

Linux/macOS:

```bash
xxd -p module.wasm | tr -d '\n' > module.hex
```

Or use the included helper:

```bash
python3 tools/wasm_to_hex.py module.wasm module.hex
```

No compiler is required to run the included examples; their binary modules are already encoded as hex. The corresponding validated raw `.wasm` bytes and human-readable `.wat` source are included under `fixtures/` for inspection/reference.

## Important boundary

There are **no Wasm imports or host functions in v0.1**.

That is deliberate. Guest code cannot call:

```text
visit_url
cli_execute
use
buy
adventure
chat
or arbitrary ASH functions
```

through this runtime. A future host ABI should be explicit and allowlisted rather than mapping arbitrary Wasm imports into ASH.

## Scope

See [`docs/SUBSET.md`](docs/SUBSET.md) for the exact supported module sections and opcodes.

The most valuable next implementation step is structured control flow (`block`, `loop`, `if`, `br`, `br_if`). Once that exists, substantially more compiler-generated Wasm becomes executable. Memory is the next major subsystem after control flow.

## Why hex instead of reading raw `.wasm` directly?

KoLmafia exposes `file_to_buffer()` / `file_to_array()` as text-oriented ASH file facilities. The WebAssembly binary format freely contains NULs and arbitrary byte values. Hex makes byte identity explicit and lets the ASH runtime remain deterministic instead of depending on character decoding behavior.

## License

MIT. This project is an independent experimental library and is not part of KoLmafia or WebAssembly itself.

## Why It Exists

It explores running genuine bounded Wasm bytecode inside ASH using a text-safe hex transport and explicit fuel/depth limits.

## Files

- `LICENSE` — packaged source/support material.
- `Makefile` — packaged source/support material.
- `TEST_STATUS.md` — packaged source/support material.
- `data/` — packaged source/support material.
- `docs/` — packaged source/support material.
- `fixtures/` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `tools/` — packaged source/support material.

## Status

Prototype.

## Compatibility

KoLmafia ASH for the runtime; Python 3 and Node.js for portable fixture checks.

## Provenance

Extracted and packaged as a standalone repository from `wasm-ash-runtime.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## Packaging Verification

**PASS**

- ASH-oriented static checks
- independent Node WebAssembly fixture validation/execution

KoLmafia verify/runtime selftest not run.
