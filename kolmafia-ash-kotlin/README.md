# kolmafia-ash-kotlin

A small Kotlin/JVM binding for KoLmafia's built-in ASH runtime.

It calls KoLmafia's local Browser JSON API (`/KoLmafia/jsonApi`) and represents ASH enumerated values (`item`, `skill`, `monster`, etc.) with Kotlin types.

## Design

```text
Kotlin/JVM
    |
    | AshClient
    |  - blocking
    |  - CompletableFuture
    |  - suspend
    v
POST /KoLmafia/jsonApi
    |
    v
KoLmafia ASH runtime
```

The core library intentionally has no third-party runtime dependencies. It uses Java's `HttpClient` and a small internal JSON codec.

Current project defaults:

- Kotlin Gradle plugin: 2.4.20
- Java toolchain: 21
- Library source remains compatible with older Kotlin syntax (locally smoke-compiled with Kotlin 1.9.0)

## What this binds

This is a binding to KoLmafia's **built-in ASH runtime functions** exposed by the Browser JSON API. Function names sent to that API use JavaScript-style camelCase, e.g. ASH `available_amount()` becomes `availableAmount`.

KoLmafia's `ashref` command is the best local authority for the exact built-in ASH functions implemented by the KoLmafia revision you are running.

This v0.1.0 does **not** pretend that arbitrary user-defined functions inside any `.ash` file automatically become JSON API functions. A generated adapter layer can be added separately for custom ASH libraries.

## Build

With Gradle installed:

```bash
gradle test
gradle build
```

The source itself has no third-party runtime dependencies.

## Basic use

```kotlin
import dev.doncannoli.kolmafia.ash.*

fun main() {
    val mafia = AshClient(
        AshClientOptions(
            baseUrl = "http://127.0.0.1:60080",
            pwdProvider = {
                System.getenv("KOLMAFIA_PWD")
                    ?: error("Provide the current KoLmafia pwd hash at runtime")
            },
        )
    )

    println(mafia.myNameBlocking())
    println(mafia.myMeatBlocking())
    println(mafia.availableAmountBlocking(Item("seal-clubbing club")))
}
```

Do not hard-code or commit the `pwd` value. The binding accepts a callback specifically so current session material can be supplied at runtime.

## Suspend API

The library exposes real `suspend` calls without requiring `kotlinx-coroutines` in the core:

```kotlin
suspend fun inspect(mafia: AshClient) {
    val name = mafia.myName()
    val meat = mafia.myMeat()
    val clubs = mafia.availableAmount(Item("seal-clubbing club"))

    println("$name: $meat meat, $clubs clubs")
}
```

Your application can invoke these from whatever coroutine runtime it already uses.

## Generic ASH calls

Typed convenience methods are intentionally just sugar over the generic runtime binding:

```kotlin
val result: JsonValue = mafia.callBlocking(
    "numericModifier",
    "Item Drop",
)

val modifier = result.doubleOrNull()
```

For a function not yet wrapped, use its JSON-API/JavaScript-style name.

## Batching

```kotlin
val batch = mafia.callManyBlocking(
    calls = listOf(
        AshFunctionCall("myName"),
        AshFunctionCall("myMeat"),
        AshFunctionCall("availableAmount", listOf(Item("filthy lucre"))),
    ),
    properties = listOf("kingLiberated"),
)

println(batch.properties)
println(batch.functions)
```

The result order is preserved exactly as KoLmafia's Browser JSON API specifies.

## ASH enumerated values

```kotlin
Item("filthy lucre")
Item(1)
Familiar("Mosquito")
Skill("Lunging Thrust-Smack")
Effect("Ode to Booze")
Monster("Knob Goblin Embezzler")
Location("Noob Cave")
Slot("hat")
Stat("Muscle")
Path("Actually Ed the Undying")
AscensionClass("Seal Clubber")
Element("hot")
Phylum("goblin")
Thrall("Spice Ghost")
Servant("Cat")
```

These encode to KoLmafia Browser JSON API placeholders such as:

```json
{
  "objectType": "Item",
  "identifierString": "filthy lucre"
}
```

Numeric identifiers are supported where the wrapper exposes an integer constructor:

```json
{
  "objectType": "Item",
  "identifierNumber": 1
}
```

For an enumerated type not represented by a convenience class:

```kotlin
AshEnumRef("SomeType", "some value")
```

## Enumerated object details

KoLmafia's JSON API has a special `identity` function for asking for the full proxy object behind a placeholder:

```kotlin
val itemDetails = mafia.identityBlocking(Item("filthy lucre"))
```

It is intentionally returned as `JsonValue`, because KoLmafia proxy-record fields differ by ASH datatype and can evolve.

## Properties

```kotlin
val liberated = mafia.getPropertyBlocking("kingLiberated")

val values = mafia.getPropertiesBlocking(
    "kingLiberated",
    "currentHardcore",
)
```

## Policy hook

Transport and policy are separate. By default the binding allows calls supported by the endpoint.

A caller can structurally deny selected runtime functions:

```kotlin
val mafia = AshClient(
    AshClientOptions(
        pwdProvider = ::currentPwd,
        policy = AshCallPolicy.deny(
            "cliExecute",
            "visitUrl",
        ),
    )
)
```

Or provide a custom policy:

```kotlin
val onlyReadOnly = AshCallPolicy { name, args ->
    require(name in approvedReadOnlyFunctions) {
        "Function $name is outside this application's ASH allowlist"
    }
}
```

This is useful when the library is embedded beneath a stronger control plane. It does not claim to classify every ASH function by itself.

## Generate wrappers from your local `ashref`

Capture the exact function catalog from the KoLmafia build you use, then run the included conservative generator:

```text
ashref
```

Save the output as `ashref.txt`, then:

```bash
python3 tools/generate_from_ashref.py ashref.txt GeneratedAsh.kt
```

The generator intentionally emits `JsonValue` return types and generic `Any?` parameters. That makes generation fail-soft across unusual ASH signatures instead of guessing incorrect Kotlin types. Tighten selected wrappers once verified.

## Project layout

```text
src/main/kotlin/dev/doncannoli/kolmafia/ash/
    Builtins.kt
    Client.kt
    Json.kt
    Policy.kt
    Types.kt

src/test/kotlin/dev/doncannoli/kolmafia/ash/
    SmokeTest.kt

examples/
    ReadOnly.kt

tools/
    generate_from_ashref.py
```

## Validation performed for v0.1.0

The packaged source was checked in two ways:

1. Core source and the read-only example compile with the locally available Kotlin 1.9.0 compiler on JDK 21.
2. A fake local `/KoLmafia/jsonApi` server verified request encoding and response parsing without touching a live KoL character. The smoke asserted:
   - `pwd` form encoding
   - JSON body form encoding
   - `availableAmount` camelCase function name
   - `Item` placeholder serialization
   - property batching
   - function-result ordering
   - response decoding

The fake transport smoke returned `KOTLIN_ASH_BINDING_SMOKE=PASS`.

A live KoLmafia session was not used during this package test.

## References

- KoLmafia Browser JSON API: https://wiki.kolmafia.us/index.php?title=Browser_JSON_API
- KoLmafia `ashref`: https://wiki.kolmafia.us/index.php/Ashref
- ASH functions: https://wiki.kolmafia.us/index.php/Ash_Functions
- ASH data types: https://wiki.kolmafia.us/index.php/Data_Types
- Kotlin releases: https://kotlinlang.org/docs/releases.html

## License

MIT. KoLmafia itself is a separate project with its own license and authorship. This library is not an ownership claim over KoLmafia or community ASH scripts.

## Why It Exists

It brings a small typed Kotlin API, batching, properties, and policy hooks to the same local ASH runtime surface.

## Files

- `.gitignore` — packaged source/support material.
- `LICENSE` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `build.gradle.kts` — packaged source/support material.
- `examples/` — packaged source/support material.
- `settings.gradle.kts` — packaged source/support material.
- `src/` — packaged source/support material.
- `tools/` — packaged source/support material.

## Status

Prototype.

## Compatibility

Kotlin/JVM targeting Java 21; Gradle 2.4.20 plugin when using the supplied build; live calls require KoLmafia.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-ash-kotlin-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## Packaging Verification

**PARTIAL**

- main Kotlin source compilation with kotlinc

Gradle/JUnit suite not run because Gradle is unavailable.
