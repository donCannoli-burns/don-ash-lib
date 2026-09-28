# wasm-ash v0.1 execution subset

`wasm-ash` parses the real WebAssembly binary module format, but deliberately implements a small execution profile that is realistic for KoLmafia ASH.

## Module format

Supported/parsed sections:

- `0` custom — skipped
- `1` type — parsed
- `2` import — **rejected**
- `3` function — parsed
- `7` export — parsed; function exports only
- `10` code — parsed
- all other standard sections — **rejected in v0.1**

The loader requires Wasm magic `00 61 73 6d` and binary version `01 00 00 00`.

Input is a hexadecimal text representation of the `.wasm` bytes. Whitespace, commas, colons, `#` comments, and `//` comments in files are accepted. This avoids depending on text decoding preserving arbitrary binary bytes through ASH's text-oriented file functions.

## Types

Only `i32` (`0x7f`) is executable in v0.1.

- zero or more `i32` parameters
- zero or one `i32` result
- `i32` locals

ASH uses signed 64-bit integers, so the engine explicitly wraps values to WebAssembly's 32-bit two's-complement semantics.

## Instructions

Implemented:

| Opcode | Instruction |
|---:|---|
| `0x00` | `unreachable` (trap) |
| `0x01` | `nop` |
| `0x0b` | `end` |
| `0x0f` | `return` |
| `0x10` | `call` (defined functions only) |
| `0x1a` | `drop` |
| `0x1b` | `select` |
| `0x20` | `local.get` |
| `0x21` | `local.set` |
| `0x22` | `local.tee` |
| `0x41` | `i32.const` |
| `0x45` | `i32.eqz` |
| `0x46..0x4f` | `i32.eq/ne/lt/gt/le/ge` signed + unsigned |
| `0x6a` | `i32.add` |
| `0x6b` | `i32.sub` |
| `0x6c` | `i32.mul` |
| `0x6d` | `i32.div_s` |
| `0x6f` | `i32.rem_s` |
| `0x71` | `i32.and` |
| `0x72` | `i32.or` |
| `0x73` | `i32.xor` |
| `0x74` | `i32.shl` |
| `0x75` | `i32.shr_s` |
| `0x76` | `i32.shr_u` |

Not yet implemented:

- structured control: `block`, `loop`, `if`, `else`, `br`, `br_if`, `br_table`
- memory/load/store
- globals
- tables / `call_indirect`
- `i64`, `f32`, `f64`, SIMD, references
- imports / WASI / host calls
- start function
- bulk-memory and post-MVP proposals

## Safety boundary

v0.1 has no import mechanism and no host-call instruction. A guest can consume CPU inside the interpreter but cannot directly call ASH functions, KoLmafia APIs, URLs, gCLI, or game actions.

Three guards bound input/execution:

- module input size, default `1048576` bytes (1 MiB)
- instruction fuel, default `100000`
- call depth, default `64` frames

Configure them with:

```ash
wasm_set_max_module_bytes(262144);
wasm_set_fuel(25000);
wasm_set_max_call_depth(32);
```

This is an execution guard, not a security proof. The runtime should still be treated as experimental code parsing untrusted bytecode.
