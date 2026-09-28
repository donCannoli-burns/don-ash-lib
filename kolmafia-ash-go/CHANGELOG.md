# Changelog

## 0.1.0 - 2026-09-27

- Initial Go 1.20+ binding for KoLmafia's ASH runtime.
- Standard-library HTTP transport for `/KoLmafia/jsonApi`.
- `context.Context` cancellation and timeouts.
- Typed ASH enumerated placeholders.
- Generic calls, typed convenience calls, property reads, and batching.
- Host-defined allow/deny policy hook.
- Conservative `ashref` -> Go wrapper generator.
- Fake-server transport tests; no live KoL state used.
