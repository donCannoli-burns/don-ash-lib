# ash.mod v1 for KoLmafia ASH

`ash.mod` is a small, declarative module descriptor for ASH libraries. It is designed around KoLmafia's existing `import`, `verify`, `call`, `file_to_array`, and gCLI surfaces rather than pretending KoLmafia already has a native package resolver.

## Design

A module has a stable ID, semantic version string, entry ASH file, optional smoke script, documentation pointers, locked file metadata, and zero or more dependency declarations.

The v1 descriptor is intentionally non-executable. `ashmod.ash` does not read arbitrary commands from the file. Its only execution modes construct:

```text
verify <validated .ash path>
call <validated .ash path>
```

from the `entry` and `smoke` directives.

## Grammar

Blank lines and lines beginning with `#` are ignored.

```text
ashmod 1
module <module-id>
version <version>
entry <relative-script.ash>
smoke <relative-smoke.ash>              # optional
manifest <relative-file>                # optional
readme <relative-file>                  # optional
namespace <prefix>                      # optional
importsafe true|false                    # optional

file <relative-file> <bytes> <sha256>
require <module-id> <constraint> <entry-script.ash> [source-url]
```

Tokens may not contain spaces in v1. Version constraints are opaque lock metadata in v1; the runtime reader reports them but does not solve them or perform network installs.

## DON Master module

The supplied `don_master_lib.ash` declares `DON_MASTER_VERSION = "0.1.0"` and has no ASH imports, so this descriptor declares no dependencies. The three checksums are taken directly from `don_master_manifest.json`; the recovered `don_master_smoke.ash` exactly matches the manifest's 204-byte SHA-256 entry.

## Install

Put these files somewhere KoLmafia can read from `scripts/` (top-level or a subdirectory):

```text
ash.mod
ashmod.ash
don_master_lib.ash
don_master_smoke.ash
don_master_manifest.json
DON_MASTER_ASHLIB_README.md
```

Then:

```text
call ashmod.ash show
call ashmod.ash check
call ashmod.ash verify
call ashmod.ash smoke
```

`check` is non-mutating. `verify` asks KoLmafia to parse/validate the module entry. `smoke` explicitly runs the declared smoke script.

## Why no automatic `get` / network install in v1?

A module descriptor should not silently become a second execution authority. Dependency installation needs a separate resolver with source pinning, version selection, update policy, and an explicit mutation boundary. v1 makes the dependency graph machine-readable first and fails visibly when a required entry is absent.