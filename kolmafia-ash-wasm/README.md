# kolmafia-ash-wasm

A small WebAssembly binding for KoLmafia's ASH runtime.

The WebAssembly module owns the wire-format construction for ASH function calls,
enumerated KoL values, batches, and an optional allow/deny policy. The host owns
HTTP transport. This is intentional: WebAssembly itself has no universal HTTP
API, so keeping transport as a host capability lets the same `.wasm` run in a
KoLmafia relay page, Node, or another WebAssembly host.

## Architecture

```text
browser / Node / Wasm host
        |
        | host fetch / transport
        v
js/kolmafia-ash.js
        |
        | typed values + calls
        v
dist/kolmafia_ash.wasm
  - enum placeholder encoding
  - function request framing
  - batch request framing
  - allow/deny policy
        |
        v
POST /KoLmafia/jsonApi
        |
        v
KoLmafia RuntimeLibrary / ASH
```

The `pwd` value is supplied at runtime by a callback. It is never compiled into
the `.wasm` file and this package does not persist it.

## Build

Requirements:

- Clang with the `wasm32` target
- `wasm-ld`
- Node 18+ for tests/examples

```bash
make
make test
```

The produced module is:

```text
dist/kolmafia_ash.wasm
```

It is a freestanding Wasm module: no WASI imports and no third-party runtime
libraries are required.

## Browser / relay usage

```js
import {
  AshClient,
  Item,
  Skill,
} from "./js/kolmafia-ash.js";

const mafia = await AshClient.create({
  // Same-origin is preferable when loaded by a KoLmafia relay page.
  baseUrl: "",
  pwdProvider: async () => currentPwd,
});

mafia.setAllowList([
  "myName",
  "myMeat",
  "availableAmount",
  "haveSkill",
]);

console.log(await mafia.myName());
console.log(await mafia.myMeat());
console.log(await mafia.availableAmount(Item("filthy lucre")));
console.log(await mafia.haveSkill(Skill("Torso Awaregness")));
```

## Generic ASH calls

```js
const value = await mafia.call("numericModifier", "Item Drop");
```

Arguments may contain nested ASH enumerated values:

```js
await mafia.call(
  "someFunction",
  {
    item: Item("seal tooth"),
    target: Monster("Knob Goblin Embezzler"),
  }
);
```

The WebAssembly core turns `Item("filthy lucre")` into the Browser JSON API
placeholder:

```json
{
  "objectType": "Item",
  "identifierString": "filthy lucre"
}
```

Numeric identifiers are supported too:

```js
Item(1)
```

becomes:

```json
{
  "objectType": "Item",
  "identifierNumber": 1
}
```

## Typed enumerated helpers

Included helpers are:

```text
Item Familiar Skill Effect Monster Location Slot Stat Path
AscensionClass Element Phylum Thrall Servant Coinmaster
```

For another ASH enumerated type:

```js
Enumerated("SomeType", "some value")
```

## Batching

```js
const result = await mafia.batch({
  properties: ["kingLiberated"],
  functions: [
    { name: "myName", args: [] },
    { name: "myMeat", args: [] },
    { name: "availableAmount", args: [Item("filthy lucre")] },
  ],
});
```

## Policy gate

Allowlist:

```js
mafia.setAllowList([
  "myName",
  "myMeat",
  "availableAmount",
]);
```

Denylist:

```js
mafia.setDenyList([
  "cliExecute",
  "visitUrl",
]);
```

The policy lives in WebAssembly linear memory and `ash_build_function` refuses a
rejected function before the JavaScript transport is called. It is a useful
local structural guard, but it should not be mistaken for a complete security
boundary: a hostile host can bypass or replace the module. Keep authority in
the application/control plane as appropriate.

## `ashref` generator

Capture your installed KoLmafia function surface:

```text
ashref
```

Save the output, then run:

```bash
node tools/ashrefgen.mjs ashref.txt generated-ash.js
```

The generator emits small prototype methods for conservative, non-overloaded
signatures and skips ambiguous/unsupported signatures instead of guessing.

Example input:

```text
string my_name( )
int my_meat( )
int available_amount( item )
boolean have_skill( skill )
```

Then install the generated methods:

```js
import { AshClient } from "./js/kolmafia-ash.js";
import { installGeneratedASH } from "./generated-ash.js";

installGeneratedASH(AshClient);
```

## What this binds

v0.1 binds KoLmafia's built-in ASH RuntimeLibrary through the Browser JSON API.
It does **not** embed the ASH interpreter in WebAssembly, and it does not yet
turn arbitrary user `.ash` library functions into callable Browser JSON API
functions. A future adapter can generate a narrow exported shim for a custom
ASH library.

## Cross-origin note

A relay page served by KoLmafia can use the relative `/KoLmafia/jsonApi` path.
A random web page on another origin may be restricted by browser cross-origin
rules. The Node/other-host model has no such browser-origin requirement and can
supply its own transport.

## Validation

`npm test` performs only local tests. It does not contact KoL or a live
KoLmafia process. It verifies:

- actual `.wasm` instantiation
- string and numeric enumerated placeholders
- function request generation
- mixed property/function batches
- allowlist and denylist enforcement
- policy rejection before transport
- URL-form request fields
- `pwd` special-character preservation
- response decoding
- `ashref` wrapper generation and JavaScript syntax

## Why It Exists

It makes the ASH runtime call-building/type layer usable from browser-like or Wasm hosts while keeping transport in JavaScript.

## Files

- `LICENSE` — packaged source/support material.
- `Makefile` — packaged source/support material.
- `VALIDATION.md` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `examples/` — packaged source/support material.
- `fixtures/` — packaged source/support material.
- `js/` — packaged source/support material.
- `package.json` — packaged source/support material.
- `src/` — packaged source/support material.
- `tests/` — packaged source/support material.
- `tools/` — packaged source/support material.

## Status

Prototype.

## Compatibility

Clang with wasm32 target plus Node.js for tests; browser/relay usage requires a running KoLmafia session.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-ash-wasm-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- wasm32 compile
- Node Wasm core/client smoke
- ashref generated-wrapper syntax check

Generated dist output was removed after verification.
