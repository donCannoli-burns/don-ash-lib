# Validation — v0.1.0

Validation was performed locally without contacting a live KoLmafia character.

## Toolchain

- OpenJDK / javac 21.0.11
- Java release target: 21
- Third-party runtime dependencies: none

## Checks

- Main library compilation: PASS
- warning-free `-Xlint:all` compilation: PASS
- Fake `/KoLmafia/jsonApi` HTTP transport: PASS
- `application/x-www-form-urlencoded` request body: PASS
- special-character `pwd` round trip: PASS
- typed `Item` placeholder serialization: PASS
- numeric enum placeholder serialization: PASS
- property/function mixed batch: PASS
- response ordering: PASS
- JSON decode: PASS
- deny-policy evaluation before transport: PASS
- `ashref` fixture parsing: PASS
- generated Java wrapper compilation: PASS
- read-only example compilation: PASS
- packaged JAR consumer compilation/execution: PASS
- live KoL actions: 0

The HTTP smoke test uses the JDK's local `HttpServer` and never connects to port 60080.
