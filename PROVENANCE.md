# Collection Provenance

Repository: `donCannoli-burns/don-ash-lib`  
Collection role: small-project KoLmafia ASH source shelf  
Packaging update: 2026-09-28  
Session source: https://github.com/donCannoli-burns/kol-ash-lab

## Project directories

The completed shelf contains 20 semantic projects:

- `ash-agent-stdlib/`
- `ash-mod/`
- `ash-pyash-webscraper/`
- `cashgo/`
- `don-master-ash-lib/`
- `kingdomsitter/`
- `kolmafia-ash-android-rust/`
- `kolmafia-ash-c/`
- `kolmafia-ash-cpp20/`
- `kolmafia-ash-csharp/`
- `kolmafia-ash-go/`
- `kolmafia-ash-html-binding/`
- `kolmafia-ash-java/`
- `kolmafia-ash-kotlin/`
- `kolmafia-ash-objective-c/`
- `kolmafia-ash-swift/`
- `kolmafia-ash-wasm/`
- `pyash/`
- `pyash-seed-mcp/`
- `wasm-ash-runtime/`

Each directory contains its own more specific README, provenance record, and licensing information.

## Existing root material

Before the shelf expansion, this repository already contained the combined DON Master ASH Lib + `ash.mod` source at repository root. That material was preserved rather than deleted or silently relocated. Shelf copies also exist under `don-master-ash-lib/` and `ash-mod/`.

## Packaging changes

- Extracted/collated the session artifacts into semantic project directories.
- Excluded nested Git metadata and generated build/cache directories from the shelf copies.
- Preserved project-level provenance and attribution.
- Added explicit MIT licensing to the five projects authorized by donCannoli-burns on 2026-09-28.
- Retained source-supplied licensing for the remaining projects rather than homogenizing licenses.
- Verified the completed shelf against the packaged local Git trees.

## Integrity verification

Final source-shelf audit:

- project directories: 20 expected / 20 present
- tracked project files: 388 expected / 388 matched
- missing project directories: 0
- tracked-file Git blob mismatches: 0

The hash check compares the Git blob SHA of every tracked file in each packaged child project against the corresponding path in this repository.

## License and attribution

The following projects were explicitly authorized for MIT licensing by donCannoli-burns during this packaging pass:

- `ash-agent-stdlib`
- `ash-mod`
- `don-master-ash-lib`
- `kolmafia-ash-html-binding`
- `kolmafia-ash-objective-c`

Other projects keep the license supplied with their source artifact, including dual-license terms where present.

Existing third-party notices, source-pattern credits, copyrights, and upstream licenses remain in force for material they cover. Packaging does not claim ownership of referenced third-party projects and does not silently relicense third-party material.
