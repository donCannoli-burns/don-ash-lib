# Test Status

Verified in the build environment on 2026-09-27.

Toolchain/dependencies used:

- GCC 14.2.0
- CMake 3.31.6
- libcurl 8.10.1
- json-c 0.18

Checks completed:

- C11 configure/build: PASS
- `-Wall -Wextra -Wpedantic`: PASS
- unit tests: PASS
- fake `/KoLmafia/jsonApi` integration test: PASS
- `-Werror`: PASS
- AddressSanitizer: PASS
- UndefinedBehaviorSanitizer: PASS

The integration test uses a loopback fake server and performs no live KoL or KoLmafia actions.
