# kolmafia-ash-swift

A dependency-light Swift 6 binding to KoLmafia's ASH runtime through KoLmafia's local Browser JSON API.

The library keeps KoLmafia as the runtime authority. Swift sends structured function/property requests to `/KoLmafia/jsonApi`; it does **not** embed the JVM, scrape gCLI output, or expose a native-code loading mechanism to ASH.

## Requirements

- Swift 6.x (package manifest uses `swift-tools-version: 6.0`)
- KoLmafia revision with `/KoLmafia/jsonApi`
- a running, logged-in KoLmafia instance for live calls
- the current KoLmafia `pwd` session hash supplied at runtime

No third-party package dependency is required by the core library.

## Basic use

```swift
import KoLmafiaASH

let mafia = AshClient(options: AshClientOptions(
    passwordProvider: {
        obtainCurrentKoLmafiaPwd()
    }
))

let name = try await mafia.myName()
let meat = try await mafia.myMeat()
let amount = try await mafia.availableAmount(Item("seal-clubbing club"))

print(name, meat, amount)
```

## Generic ASH calls

```swift
let result = try await mafia.call("numericModifier", "Item Drop")
let modifier = try result.requireDouble("numericModifier")
```

Function names passed to the JSON endpoint use KoLmafia's JavaScript/camelCase names.

## Typed KoL values

```swift
Item("filthy lucre")
Item(id: 1)
Skill("Lunging Thrust-Smack")
Monster("Knob Goblin Embezzler")
Effect("Ode to Booze")
Location("Noob Cave")
Familiar("Mosquito")
Slot("hat")
Stat("Muscle")
Path("Actually Ed the Undying")
AscensionClass("Seal Clubber")
Element("hot")
Phylum("goblin")
```

`Item("filthy lucre")`, for example, becomes:

```json
{
  "objectType": "Item",
  "identifierString": "filthy lucre"
}
```

Use `ASHEnumRef("SomeType", "value")` as a generic escape hatch for an enumerated type without a dedicated wrapper.

## Batching

```swift
let result = try await mafia.batch(ASHBatchRequest(
    properties: ["kingLiberated"],
    functions: [
        ASHFunctionCall(name: "myName"),
        ASHFunctionCall(name: "myMeat"),
        ASHFunctionCall("availableAmount", Item("filthy lucre"))
    ]
))
```

KoLmafia returns `properties` and `functions` in the same order as requested.

## Policy hook

The transport can be used directly, or an application can structurally restrict which ASH runtime functions it permits:

```swift
let mafia = AshClient(options: AshClientOptions(
    passwordProvider: currentPwd,
    policy: ASHPolicies.deny(
        "cliExecute",
        "visitUrl"
    )
))
```

Or fail closed with an allowlist:

```swift
policy: ASHPolicies.allowOnly(
    "myName",
    "myMeat",
    "myAdventures",
    "availableAmount"
)
```

The policy runs before any HTTP request is sent.

## Generate wrappers from `ashref`

KoLmafia's `ashref` CLI command reports the built-in ASH functions available in the installed KoLmafia version. Save that output and feed it to the included Swift generator:

```bash
swift run ashrefgen ashref.txt GeneratedASH.swift KoLmafiaASH
```

Example input:

```text
string my_name( )
int my_meat( )
int available_amount( item )
boolean have_skill( skill )
float numeric_modifier( string )
```

The generator produces `async throws` extension methods with Swift types and camelCase runtime names. It intentionally skips signatures it cannot safely map, including aggregate/optional forms and enumerated return values, rather than inventing an ABI.

## Build and test

```bash
swift build
swift test
```

The test suite uses an intercepted `URLSession`; it does not contact a live KoL character. It verifies:

- JSON encoding/decoding
- enum placeholders by name and ID
- `/KoLmafia/jsonApi` path
- `application/x-www-form-urlencoded` transport
- escaping of special characters in the session hash
- mixed property/function batching
- response ordering
- policy rejection before transport
- typed helper decoding

## Live read-only example

The example only makes read-style calls, but it still needs the current session hash:

```bash
KOLMAFIA_PWD='current-session-hash' swift run ash-readonly-example
```

Do not commit or persist that session value in source control.

## Architecture

```text
Swift application / agent
        |
        v
optional ASHCallPolicy
        |
        v
AshClient (async/await + URLSession)
        |
        v
POST /KoLmafia/jsonApi
        |
        v
KoLmafia RuntimeLibrary
        |
        v
ASH runtime
```

## Scope

This version binds KoLmafia's **built-in ASH runtime library**. It does not yet expose arbitrary top-level functions from a user `.ash` file as generated Swift methods. A future library-binding layer can generate a small ASH/JS adapter for explicitly exported functions and then generate Swift types from those signatures.

## License

MIT. See `LICENSE`.

## Why It Exists

It gives Swift clients typed ASH calls and generation support without embedding KoLmafia or hiding effectful surfaces.

## Files

- `.gitignore` — packaged source/support material.
- `CHANGELOG.md` — packaged source/support material.
- `Fixtures/` — packaged source/support material.
- `LICENSE` — packaged source/support material.
- `Package.swift` — packaged source/support material.
- `Sources/` — packaged source/support material.
- `Tests/` — packaged source/support material.
- `VALIDATION.md` — packaged source/support material.
- `VERSION` — packaged source/support material.

## Status

Prototype.

## Compatibility

Swift 6 toolchain; package declares macOS 13+ while the core sources also type-check on the available Linux Swift toolchain.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-ash-swift-v0.1.0.tar.gz` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## Packaging Verification

**PARTIAL**

- Swift core source typecheck

A full SwiftPM test attempt did not complete within the aggregate session gate; no full-test PASS is claimed.
