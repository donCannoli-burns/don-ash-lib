# KoLmafia Android ↔ Rust ↔ ASH Binding

A small Android/JNI binding for **KoLmafia's built-in ASH runtime library**.

```text
Android Kotlin/Java
       │ JNI
       ▼
Rust cdylib
       │ HTTP POST
       ▼
/KoLmafia/jsonApi
       │
       ▼
KoLmafia ASH runtime functions
```

The Rust side is the transport and type boundary. The Android side is intentionally thin.

## What this binds

KoLmafia exposes its runtime functions through `/KoLmafia/jsonApi`. Requests are form-encoded with `pwd` and a JSON `body`; runtime function names are JavaScript-style camelCase. This library lets callers use familiar ASH spellings such as `available_amount` and translates them to `availableAmount`.

This is a binding to **built-in ASH runtime functions**, not a general interpreter for arbitrary user-defined functions declared inside `.ash` files. Script execution can still be reached explicitly through effectful surfaces such as `cli_execute`, but it is intentionally not disguised as a normal read-only function call.

## Android networking: use ADB reverse

On a physical Android device, `127.0.0.1` means the phone, not the computer running KoLmafia. For development, keep the binding's secure-by-default loopback policy and bridge the port with ADB:

```bash
adb reverse tcp:60080 tcp:60080
```

Then Android can use:

```text
http://127.0.0.1:60080
```

without exposing KoLmafia's relay port to your LAN.

The repository includes:

```bash
./scripts/adb-reverse.sh
```

Direct non-loopback endpoints are rejected by default. They can be enabled explicitly, but remember that ordinary HTTP would transmit the KoLmafia `pwd` value over the network. Prefer a tunnel/proxy with an appropriate security model rather than casually enabling LAN HTTP.

## Build requirements

- Rust toolchain
- Android SDK + NDK
- `cargo-ndk`
- Android Studio/Gradle for the Kotlin library module

Install cargo-ndk:

```bash
cargo install cargo-ndk
```

Build the Rust `.so` files into the Android library's `jniLibs` tree:

```bash
./scripts/build-android.sh
```

This builds:

```text
arm64-v8a/
armeabi-v7a/
x86_64/
```

`cargo-ndk` handles the Android target/toolchain environment and writes the output in the directory layout expected by Android Gradle projects.

## Rust usage

The core crate can also be used directly from Rust:

```rust
use kolmafia_ash_android::{item, AshClient};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let pwd = std::env::var("KOLMAFIA_PWD")?;
    let mafia = AshClient::loopback(pwd)?;

    println!("name: {}", mafia.my_name()?);
    println!("level: {}", mafia.my_level()?);

    let count = mafia.available_amount(item("seal-clubbing club"))?;
    println!("clubs: {count}");

    Ok(())
}
```

Generic calls accept normal ASH names:

```rust
use serde_json::json;

let value = mafia.call_value(
    "get_property",
    vec![json!("lastAdventure")],
)?;
```

The binding translates common spellings automatically:

```text
my_name           -> myName
available_amount  -> availableAmount
get_property      -> getProperty
visit_url         -> visitUrl
```

## KoL enumerated values

The Browser JSON API accepts enumerated values as placeholders. Helpers are included for common types:

```rust
use kolmafia_ash_android::{
    item, item_id,
    skill, effect,
    familiar, location,
    monster, path,
};

let it = item("seal-clubbing club");
let same_shape_by_id = item_id(1234);
let sk = skill("Saucegeyser");
let loc = location("Noob Cave");
```

Generic constructors are also available:

```rust
use kolmafia_ash_android::{enum_id, enum_string};

let coinmaster = enum_string("Coinmaster", "The Hermit");
let some_item = enum_id("Item", 1234);
```

## Batch requests

```rust
use kolmafia_ash_android::{item, AshBatch};

let batch = AshBatch::new()
    .property("kingLiberated")
    .call("my_name", [])
    .call("my_level", [])
    .call("available_amount", [item("seal-clubbing club")]);

let response = mafia.execute_batch(&batch)?;
println!("{response:#}");
```

The request is sent as one `/KoLmafia/jsonApi` HTTP POST.

## Kotlin usage

The sample Android library lives under:

```text
android/kolmafia-ash/
```

Connect through the ADB-reversed loopback endpoint:

```kotlin
import dev.kolmafia.ash.KoLValue
import dev.kolmafia.ash.KoLmafiaAshClient

val mafia = KoLmafiaAshClient.loopback(pwdHash)

val name = mafia.myName()
val level = mafia.myLevel()
val adventures = mafia.myAdventures()

val clubs = mafia.availableAmount(
    KoLValue.item("seal-clubbing club"),
)

mafia.close()
```

Or use any current/future runtime function without waiting for a typed wrapper:

```kotlin
val result = mafia.call(
    "available_amount",
    KoLValue.item("seal-clubbing club"),
)
```

### Kotlin batching

```kotlin
val result = mafia.execute(
    AshBatch()
        .property("kingLiberated")
        .call("my_name")
        .call("my_level")
        .call(
            "available_amount",
            KoLValue.item("seal-clubbing club"),
        ),
)
```

## Explicit mutation boundary

These APIs are intentionally easy to identify as effectful:

### Rust

```rust
mafia.set_property("foo", "bar")?;
mafia.cli_execute("some command")?;
mafia.visit_url("inventory.php")?;
```

### Kotlin

```kotlin
mafia.setProperty("foo", "bar")
mafia.cliExecute("some command")
mafia.visitUrl("inventory.php")
```

If this is placed behind an agent, put confirmation/policy checks above these methods. The generic `call` API can still reach effectful ASH functions, so a high-assurance agent integration should also classify generic function names rather than treating `call()` as inherently read-only.

## JNI surface

`NativeBridge.kt` maps to four exported Rust JNI functions:

```text
nativeCreate
nativeDestroy
nativeCallJson
nativeExecuteJson
```

Rust uses a synchronized handle registry rather than passing raw heap pointers through Kotlin. Closing a client removes its handle; subsequent calls using that handle fail instead of dereferencing freed memory.

## Android manifest

The library manifest declares:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

No storage, contacts, location, accessibility, or other Android permissions are required by the binding.

## Tests

Rust unit tests cover:

- ASH snake_case → JavaScript camelCase conversion
- KoL enum placeholder shape
- batching
- loopback acceptance
- remote-host denial by default
- explicit remote opt-in

Run on a Rust-capable host:

```bash
cargo test
```

For a live Android smoke test:

```bash
./scripts/adb-reverse.sh
./scripts/build-android.sh
```

then load the Android library and call `KoLmafiaAshClient.loopback(activePwdHash)` while KoLmafia is running on the connected host.

## Security notes

1. Treat the KoLmafia `pwd` hash as a credential-like secret.
2. Do not log it from Rust or Kotlin.
3. Prefer ADB reverse for development instead of opening port 60080 to Wi-Fi/LAN.
4. Keep mutating ASH calls behind an explicit policy layer when used by agents.
5. `cli_execute` is a broad execution surface; it should receive stricter policy than ordinary query calls.
6. The binding does not make KoLmafia safe for untrusted remote access; it is only a client library.

## Project layout

```text
Cargo.toml
src/
  client.rs       Rust HTTP/ASH client
  error.rs        typed errors
  jni_bridge.rs   Android JNI exports + safe handle registry
  lib.rs
  types.rs        batch + KoL typed-value helpers

tests/
  public_api.rs

android/kolmafia-ash/
  build.gradle.kts
  src/main/AndroidManifest.xml
  src/main/java/dev/kolmafia/ash/
    AshBatch.kt
    KoLValue.kt
    KoLmafiaAshClient.kt
    NativeBridge.kt

scripts/
  adb-reverse.sh
  build-android.sh
```

## License

MIT OR Apache-2.0.

## JNI crate compatibility note

This source targets `jni = 0.22.4`. That release separates the FFI-safe `EnvUnowned` received by native methods from the full JNI `Env`; the exported JNI functions immediately enter `EnvUnowned::with_env(...)` before using JNI services. This follows the current jni-rs native-method model rather than the older pre-0.22 `JNIEnv` pattern.

## Why It Exists

It gives Android code a typed local bridge into KoLmafia runtime functions without embedding KoLmafia or exposing the relay port to a LAN by default.

## Files

- `Cargo.toml` — packaged source/support material.
- `LICENSE-APACHE` — packaged source/support material.
- `LICENSE-MIT` — packaged source/support material.
- `TEST_STATUS.md` — packaged source/support material.
- `android/` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `src/` — packaged source/support material.
- `tests/` — packaged source/support material.

## Status

Experimental.

## Compatibility

Rust toolchain, Android SDK/NDK, cargo-ndk, and Android Gradle tooling; a running KoLmafia relay is required for live calls.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-android-rust-ash-binding.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## Packaging Verification

**UNVERIFIED**

- source/Cargo/JNI/Android manifest consistency

Rust/cargo and Android SDK/NDK are unavailable here; compilation is not claimed.
