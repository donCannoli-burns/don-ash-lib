# Collection Provenance

Repository: `donCannoli-burns/don-ash-lib`  
Collection role: small-project KoLmafia ASH source shelf  
Packaging update: 2026-09-28  
Session source: https://github.com/donCannoli-burns/kol-ash-lab

## Added project directories

- `ash-agent-stdlib/` — extracted from `ash_agent_stdlib_v0.1.0.zip`.
- `ash-mod/` — descriptor-system portion extracted from `ashmod_don_master_bundle.zip`.
- `don-master-ash-lib/` — utility-library portion extracted from `ashmod_don_master_bundle.zip`.
- `kolmafia-ash-html-binding/` — extracted from `kolmafia-ash-html-binding-v0.1.0.zip`.
- `kolmafia-ash-objective-c/` — extracted from `kolmafia-objective-c-ash-binding.zip`.

Each directory contains its own more specific provenance record.

## Existing root material

Before the shelf expansion, this repository already contained the combined DON Master ASH Lib + `ash.mod` source at repository root. That material was preserved rather than deleted or silently relocated. Shelf copies now also exist under `don-master-ash-lib/` and `ash-mod/`.

## Packaging changes

- Added project directories without removing the source-session artifacts.
- Excluded generated build/cache directories and Git metadata from project copies.
- Added explicit MIT licenses to projects authorized by donCannoli-burns.
- Preserved project-level provenance and attribution.
- Verified pushed project files against local Git blob hashes after transfer.

## License and attribution

Original project code controlled by donCannoli-burns in the five added project directories is released under the MIT License.

Existing third-party notices, source-pattern credits, copyrights, and upstream licenses remain in force for material they cover. Packaging does not claim ownership of referenced third-party projects and does not silently relicense third-party material.
