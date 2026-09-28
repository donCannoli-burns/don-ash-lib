# Test Status

## Source checks completed in this build environment

- Project tree/materialization: PASS
- Rust public API/JNI symbol consistency inspection: PASS
- Kotlin ↔ JNI method-name consistency inspection: PASS
- jni-rs 0.22 `EnvUnowned`/`with_env` FFI model cross-check: PASS (against current docs)
- JSON API endpoint path/form-field inspection: PASS
- Loopback-default / explicit-remote-policy inspection: PASS
- No plaintext `pwd` logging in supplied source: PASS
- Android INTERNET permission present: PASS
- `cargo-ndk` build script emits Gradle-compatible `jniLibs` layout: PASS (static inspection)

## Not executable in this container

This environment does not currently contain `rustc` or `cargo`, so the following were **not** claimed as executed here:

- `cargo fmt --check`
- `cargo test`
- `cargo clippy`
- Android NDK cross-compilation
- Gradle/Kotlin compilation
- live `/KoLmafia/jsonApi` smoke test

The repository contains the commands/scripts needed to run those checks on a Rust + Android NDK host.

## Suggested verification sequence

```bash
cargo fmt --check
cargo test
cargo clippy --all-targets -- -D warnings
./scripts/build-android.sh
./scripts/adb-reverse.sh
```

Then run a minimal Android call against a live KoLmafia session:

```kotlin
KoLmafiaAshClient.loopback(pwdHash).use { mafia ->
    check(mafia.myName().isNotBlank())
    check(mafia.myLevel() >= 1)
}
```
