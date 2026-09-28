# Test status

## Completed in this environment

- Source-layout checks: PASS
- Browser JSON API path is present
- Required `application/x-www-form-urlencoded` transport is present
- `body` + `pwd` form fields are present
- snake_case -> camelCase translator is wired into generic calls and batches
- loopback-only default endpoint guard is present
- explicit `set_property`, `cli_execute`, and `visit_url` wrappers are present
- public KoL enum helper families are paired with implementations

## Not executable in this Linux container

The container has Clang 17 but does not have Apple's Foundation framework or GNUstep Foundation installed. Therefore a real Objective-C/Foundation compilation cannot be performed here.

The included Makefile targets the normal macOS toolchain:

```bash
clang -fobjc-arc -framework Foundation
```

Run on macOS:

```bash
make test
```

Then, with KoLmafia running:

```bash
KOLMAFIA_PWD='<active pwd hash>' ./build/kmash-smoke
```
