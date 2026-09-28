# KoLmafia ASH Java Binding

A dependency-free Java 21 client binding for KoLmafia's ASH runtime library via the local Browser JSON API.

## Design

```text
Java application / agent
        |
     AshPolicy
        |
     AshClient
        |
 JDK HttpClient
        |
POST /KoLmafia/jsonApi
        |
    KoLmafia
        |
   ASH runtime
```

The binding deliberately does **not** discover, persist, or hard-code KoLmafia's `pwd` session hash. Supply it at runtime through `PasswordProvider`.

## Requirements

- Java 21+
- A running local KoLmafia instance when making real calls
- No third-party runtime libraries

## Basic use

```java
import dev.doncannoli.kolmafia.ash.*;
import dev.doncannoli.kolmafia.ash.types.*;

AshClient mafia = new AshClient(
    AshClientOptions.defaults(() -> currentPwd())
);

String name = mafia.myName();
long meat = mafia.myMeat();
long lucre = mafia.availableAmount(new Item("filthy lucre"));
```

Generic calls return `AshValue`:

```java
double itemDrop = mafia
    .call("numericModifier", "Item Drop")
    .doubleValue();
```

Async calls use `CompletableFuture`:

```java
mafia.callAsync("myName")
    .thenApply(AshValue::stringValue)
    .thenAccept(System.out::println);
```

## Typed ASH values

The package contains wrappers for common enumerated types:

```java
new Item("filthy lucre")
new Item(1)
new Skill("Lunging Thrust-Smack")
new Monster("Knob Goblin Embezzler")
new Effect("Ode to Booze")
new Location("Noob Cave")
new Familiar("Mosquito")
new Slot("hat")
new Stat("Muscle")
new Path("Actually Ed the Undying")
```

`new Item("filthy lucre")` serializes to:

```json
{"objectType":"Item","identifierString":"filthy lucre"}
```

For an ASH enum not represented by a convenience wrapper, use `EnumRef` directly.

## Batching

```java
AshBatchResult result = mafia.batch(new AshBatchRequest(
    List.of("kingLiberated"),
    List.of(
        new AshFunctionCall("myName"),
        new AshFunctionCall("myMeat"),
        new AshFunctionCall("availableAmount", new Item("filthy lucre"))
    )
));
```

The Browser JSON API preserves request order for property and function result arrays.

## Policy hook

The transport does not decide what your application considers safe, but calls can be structurally filtered before network I/O:

```java
new AshClientOptions(
    URI.create("http://127.0.0.1:60080"),
    this::currentPwd,
    AshPolicy.deny("cliExecute", "visitUrl"),
    null,
    null
);
```

For fail-closed callers:

```java
AshPolicy.allowOnly(
    "myName",
    "myMeat",
    "myAdventures",
    "availableAmount"
)
```

This is an application guard, not a replacement for a real control-plane boundary.

## Generate wrappers from `ashref`

KoLmafia's `ashref` command reports the ASH functions implemented by the installed KoLmafia build. Save that output and run:

```bash
./gradlew classes
java -cp build/classes/java/main \
  dev.doncannoli.kolmafia.ashrefgen.Main \
  ashref.txt \
  GeneratedAsh.java \
  dev.example.generated
```

Or with this repository's fixture:

```bash
./scripts/test.sh
```

The generator maps conservative scalar signatures (`boolean`, `int`, `float`, `string`) and common KoL enum types. It skips unsupported aggregates and overloaded names rather than guessing.

## Validation

`./scripts/test.sh` uses JDK `HttpServer` as a fake `/KoLmafia/jsonApi` and verifies:

- URL-form encoding, including special characters in `pwd`
- exact API path and content type
- JSON request construction
- camelCase ASH function names
- string and numeric enum placeholders
- mixed property/function batching
- response-order preservation
- policy rejection before transport
- `ashref` generated Java compiles against the library

It performs **zero live KoL actions**.

## Scope

v0.1 binds KoLmafia's built-in ASH RuntimeLibrary. A future layer can generate a narrow Java facade for functions exported by a particular user `.ash` library.

## Why It Exists

It offers a dependency-light Java client and generator for structured ASH calls while keeping mutation policy explicit.

## Files

- `CHANGELOG.md` — packaged source/support material.
- `LICENSE` — packaged source/support material.
- `VALIDATION.md` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `build.gradle.kts` — packaged source/support material.
- `examples/` — packaged source/support material.
- `fixtures/` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `settings.gradle.kts` — packaged source/support material.
- `src/` — packaged source/support material.

## Status

Prototype.

## Compatibility

Java 21; Gradle is optional because the supplied test script can compile with javac; live calls require KoLmafia.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-ash-java-v0.1.0.tar.gz` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- supplied javac/fake JSON API smoke
- generated wrapper compile

No live KoLmafia call was used.
