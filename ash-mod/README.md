# ash-mod

A small, non-executable `ash.mod` descriptor format and ASH reader/checker for KoLmafia script modules.

## What It Does

`ash.mod` records module identity, version, entry script, optional smoke test, documentation pointers, locked-file metadata, and dependency declarations. `ashmod.ash` reads and validates that metadata and only constructs validated `verify`/`call` operations for declared ASH paths.

## Why It Exists

KoLmafia already supplies script loading, `verify`, `call`, and Git transport. This experiment adds machine-readable module metadata without pretending ASH already has a full package solver or silently creating a second execution authority.

## Installation

Copy `ashmod.ash` into KoLmafia's `scripts/` tree and place an `ash.mod` descriptor beside the module you want to inspect.

## Usage

```text
call ashmod.ash show
call ashmod.ash check
call ashmod.ash verify
call ashmod.ash smoke
```

See `ASH_MOD_SPEC.md` for the v1 grammar and `examples/don-master/ash.mod` for a concrete descriptor.

## Files

- `ashmod.ash` — descriptor reader/checker.
- `ASH_MOD_SPEC.md` — v1 format and design constraints.
- `examples/don-master/ash.mod` — non-self-contained format example extracted from the original bundle.

## Status

Prototype. Descriptor/static checks are available; installed KoLmafia remains the authoritative ASH parser/runtime.

## Compatibility

KoLmafia ASH.

## Provenance

Extracted as its own semantic artifact from `ashmod_don_master_bundle.zip`; the original bundle also contained the separate `don-master-ash-lib` artifact. See `PROVENANCE.md`.

## License

MIT License. See `LICENSE`.

## Packaging Verification

**PASS**

- ASH structural check
- example descriptor/lock syntax check
- selected source hash match

Installed KoLmafia verify has not been run; runtime verification remains separate from publication readiness.
