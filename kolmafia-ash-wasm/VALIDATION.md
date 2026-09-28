# Validation — kolmafia-ash-wasm v0.1.0

Validation was performed locally without contacting KoL or a running KoLmafia
session.

## Build

```text
clang --target=wasm32 ... src/ash_wasm.c
PASS
```

The resulting `dist/kolmafia_ash.wasm` is a freestanding WebAssembly module and
has zero imports. It does not require WASI.

## Core smoke test

```text
WASM_CORE_SMOKE=PASS
```

Covered:

- module instantiation
- module version
- ASH string enum placeholder encoding
- ASH numeric enum placeholder encoding
- JSON escaping
- function request construction
- nested typed values
- allowlist policy
- denylist policy
- rejected function before host transport
- mixed property/function batch construction

## Host-client smoke test

```text
WASM_CLIENT_SMOKE=PASS
```

Covered with a fake `fetch` implementation:

- `/KoLmafia/jsonApi` endpoint
- POST method
- `application/x-www-form-urlencoded`
- runtime-provided `pwd`
- special characters in `pwd`
- JSON body construction
- `Item` placeholder on the wire
- property/function response order
- response parsing
- policy rejection before network invocation

## `ashref` generator

```text
generated=7 skipped=2
```

The two skipped fixture signatures intentionally share the overloaded `buy`
name. Generated JavaScript passed `node --check`.

## Live actions

```text
KoL requests:         0
KoLmafia live calls:  0
mutations:            0
```
