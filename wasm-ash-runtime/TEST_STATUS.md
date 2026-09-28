# wasm-ash v0.1 — test status

## Passed in this build environment

### ASH-oriented static checks

```text
PASS ash-static scripts/wasm-ash/example.ash
PASS ash-static scripts/wasm-ash/runtime.ash
PASS ash-static scripts/wasm-ash/wasm-ash.ash
PASS wasm-fixture data/wasm-ash/examples/add.hex
PASS wasm-fixture data/wasm-ash/examples/answer.hex
static_check PASS
```

`tools/static_check.py` checks the packaged ASH sources for balanced delimiters, the unsupported `?:` syntax, accidental forward calls among local `wasm_*` functions, valid Wasm-v1 fixture headers, and a denylist of accidental effectful KoLmafia host-call surfaces inside the runtime.

### Independent WebAssembly-engine validation

Node.js v22's built-in WebAssembly engine validates and executes both bundled modules:

```text
PASS WebAssembly.validate add.hex (65 bytes), raw fixture byte-match
PASS WebAssembly.validate answer.hex (39 bytes), raw fixture byte-match
PASS add(7,35) = 42
PASS add(-5,2) = -3
PASS double(21) = 42
PASS answer() = 42
check_fixtures PASS
```

This matters because it verifies that the example payloads are genuine valid WebAssembly binaries rather than merely byte strings accepted by our own parser.

The check caught a real build-time fixture error: the first draft of `add.hex` declared a 14-byte type-section payload whose actual payload was 12 bytes. The fixture and embedded self-test copy were corrected to `0x0c`, after which the independent engine accepted the module.

### Hex transport round-trip

The included converter was checked by converting the validated `add.wasm` bytes back to wasm-ash hex and comparing the normalized bytes with `add.hex`.

```text
PASS wasm_to_hex roundtrip add.wasm
```

Run all portable checks with:

```bash
make check
```

## Still required on a real KoLmafia installation

This build environment does not contain a running KoLmafia instance/ASH interpreter, so KoLmafia's parser is the remaining authoritative syntax/runtime gate.

After copying/installing the project, run in gCLI:

```text
verify wasm-ash/runtime.ash
verify wasm-ash/wasm-ash.ash
call wasm-ash/wasm-ash.ash selftest
```

Expected self-test results:

```text
PASS add(7,35) = 42
PASS add(-5,2) = -3
PASS double(21) = 42
wasm-ash selftest PASS
```

Then test file transport:

```text
call wasm-ash/wasm-ash.ash run wasm-ash/examples/answer.hex answer
```

Expected:

```text
Returned: 42
```

If your installed KoLmafia reports an ASH syntax incompatibility, its `ashref`/parser is authoritative. The Wasm fixtures themselves have already been validated independently; such a failure should therefore be treated as an ASH compatibility issue rather than silently weakening the Wasm parser.
