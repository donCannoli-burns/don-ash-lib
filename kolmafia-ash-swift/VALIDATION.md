# Validation

Validated in the build environment on 2026-09-27/28 with Swift 6.2.1 on x86_64 Linux.

Commands:

```text
swift build
swift test
swift run -q ashrefgen Fixtures/ashref.sample.txt /tmp/GeneratedASH.swift KoLmafiaASH
swiftc -typecheck -I <SwiftPM debug Modules dir> /tmp/GeneratedASH.swift
```

Results:

```text
SWIFT_BUILD=PASS
SWIFT_TEST=PASS (4/4)
ASHREF_GENERATOR=PASS (9 generated, 0 skipped for fixture)
ASHREF_GENERATED_TYPECHECK=PASS
LIVE_KOL_ACTIONS=0
```

The HTTP tests intercept URLSession locally; they do not contact a live KoLmafia process.
