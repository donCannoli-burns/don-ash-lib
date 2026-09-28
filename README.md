# don-ash-lib

A modern, standalone KoLmafia ASH utility library and a small `ash.mod` module-descriptor experiment.

The current package is **DON Master ASH Lib v0.1.0**. It provides namespaced utility helpers for character state, preferences, inventory, valuation, familiars/outfits, recovery, quests/choices, bounded execution, combat primitives, and local update notes.

## Quick start

Copy the project files into a location KoLmafia can read from `scripts/`, then run:

```text
call ashmod.ash show
call ashmod.ash check
call ashmod.ash verify
call ashmod.ash smoke
```

Or import the library directly:

```ash
import <don_master_lib.ash>;
```

For the full API overview and migration notes, see [DON_MASTER_ASHLIB_README.md](DON_MASTER_ASHLIB_README.md). For the module format, see [ASH_MOD_SPEC.md](ASH_MOD_SPEC.md).

## Repository layout

- `don_master_lib.ash` — standalone master utility library
- `don_master_smoke.ash` — runtime smoke test
- `don_master_manifest.json` — recorded file sizes and SHA-256 provenance
- `ash.mod` — module descriptor for the library
- `ashmod.ash` — KoLmafia-native `ash.mod` reader/checker
- `ASH_MOD_SPEC.md` — `ash.mod` v1 format and design notes
- `DON_MASTER_ASHLIB_README.md` — detailed library documentation

## Design boundary

The library is intended to be safe to import: it performs no intentional KoL mutation at top level. Helpers that can mutate state are explicit functions and should be called deliberately by the consuming script.

`ash.mod` v1 is declarative. Its reader does not act as a network installer or general command executor; execution modes are limited to validated module entry/smoke-script operations.

## Provenance and third-party projects

This repository contains original glue, documentation, and clean reimplementations informed by patterns seen in existing KoLmafia community projects. References to BatBrain, ZLib, DicsLibrary, Choice Override, or other projects are acknowledgements of reviewed patterns, **not claims of authorship or ownership of those upstream projects**.

Unless third-party material is explicitly added later with its own license notice, this repository does not purport to relicense upstream code. Upstream authors retain their own copyrights and licenses.

## License

The original work in this repository is released under the [MIT License](LICENSE).

Software is provided without warranty; use it at your own risk.
