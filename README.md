# don-ash-lib

A small-project source shelf for KoLmafia ASH libraries, runtime experiments, language bindings, and developer utilities.

Each project keeps its own source, README, provenance, and license inside a named directory. This repository is intentionally a collection of small projects rather than one unified framework.

## KoLmafia Git installation: DON Master ASH Lib

This repository is a multi-project source shelf. **KoLmafia's `git checkout` installs only DON Master ASH Lib**, using the repository-root `manifest.json` pointing at `don-master-ash-lib/`. Other shelf projects are not synced.

In KoLmafia's graphical CLI:

```text
git checkout https://github.com/donCannoli-burns/don-ash-lib.git main
verify don_master_lib.ash
call don_master_smoke.ash
```

The checked-in installable files live under `don-master-ash-lib/scripts/`; KoLmafia syncs them to its `scripts/` directory. The GitHub browser URL ending in `/tree/main/don-master-ash-lib` is not itself a valid KoLmafia Git checkout URL.

Use `git list` to inspect installed repositories and `git update` to update them. If you already copied `don_master_lib.ash` manually, inspect that copy before installing to avoid overwriting local edits.

## Project shelf

| Project | Purpose | Packaging verification |
|---|---|---|
| [ash-agent-stdlib](ash-agent-stdlib/) | Agent-oriented ASH helper corpus and compatibility library. | PASS |
| [ash-mod](ash-mod/) | Declarative `ash.mod` descriptor format and KoLmafia-native reader/checker. | PASS |
| [ash-pyash-webscraper](ash-pyash-webscraper/) | Bounded GET-only ASH/PyASH web scraper with HTML/Markdown/PDF output. | PASS |
| [cashgo](cashgo/) | Cargo-inspired ASH project/dependency manifest and lock experiment. | PASS |
| [don-master-ash-lib](don-master-ash-lib/) | Namespaced general-purpose KoLmafia ASH utility library. | PASS |
| [dtrack-suite](dtrack-suite/) | GPL-3.0-preserving source-only staging of hardened pTrack suite. **Not installed by the root manifest.** | STAGED — RUNTIME UNVERIFIED |
| [kingdomsitter](kingdomsitter/) | Go-first ASH parser/IR/analysis and TypeScript sidecar. | PARTIAL |
| [kolmafia-ash-android-rust](kolmafia-ash-android-rust/) | Android Kotlin/Java → Rust JNI → KoLmafia JSON API binding. | UNVERIFIED |
| [kolmafia-ash-c](kolmafia-ash-c/) | C11 binding for KoLmafia ASH/runtime access. | PARTIAL |
| [kolmafia-ash-cpp20](kolmafia-ash-cpp20/) | C++20 Browser JSON API binding. | PASS |
| [kolmafia-ash-csharp](kolmafia-ash-csharp/) | C# binding for KoLmafia ASH/runtime access. | UNVERIFIED |
| [kolmafia-ash-go](kolmafia-ash-go/) | Go binding for KoLmafia ASH/runtime access. | PASS |
| [kolmafia-ash-html-binding](kolmafia-ash-html-binding/) | Bounded ASH ↔ HTML/HTML5 relay binding. | PASS |
| [kolmafia-ash-java](kolmafia-ash-java/) | Java 21 binding for KoLmafia ASH/runtime access. | PASS |
| [kolmafia-ash-kotlin](kolmafia-ash-kotlin/) | Kotlin/JVM binding for KoLmafia ASH/runtime access. | PARTIAL |
| [kolmafia-ash-objective-c](kolmafia-ash-objective-c/) | Objective-C/Foundation binding for KoLmafia's Browser JSON API. | PARTIAL |
| [kolmafia-ash-swift](kolmafia-ash-swift/) | Swift package binding for KoLmafia ASH/runtime access. | PARTIAL |
| [kolmafia-ash-wasm](kolmafia-ash-wasm/) | C→Wasm core plus JavaScript Browser JSON API host binding. | PASS |
| [pyash](pyash/) | Small Python-like interpreter implemented in ASH. | PASS |
| [pyash-seed-mcp](pyash-seed-mcp/) | MCP stdio bridge whose tool bodies execute in PyASH inside KoLmafia. | PASS |
| [wasm-ash-runtime](wasm-ash-runtime/) | Bounded WebAssembly v1 parser/stack VM implemented in ASH. | PASS |

Open a project's own README for installation, usage, compatibility, verification details, and project-specific provenance.

The verification labels above describe the packaging-session checks, not a blanket claim of production readiness.

## Root compatibility files

This repository originally held the DON Master ASH Lib and `ash.mod` experiment directly at repository root. Those files are intentionally retained so existing links/checkouts do not break:

- `don_master_lib.ash`
- `don_master_smoke.ash`
- `don_master_manifest.json`
- `ash.mod`
- `ashmod.ash`
- `ASH_MOD_SPEC.md`
- `DON_MASTER_ASHLIB_README.md`

The corresponding shelf copies live in `don-master-ash-lib/` and `ash-mod/`.

## Source-shelf rule

```text
one small idea
    ↓
one named project directory
    ↓
source + README + provenance + license
```

Projects share this repository because its purpose is a small-project source collection, but they remain semantically independent and should not be treated as one combined runtime.

## Integrity

The 2026-09-28 shelf import was checked against the local packaged Git trees:

- 20 project directories expected
- 20 project directories present
- 388 tracked project files checked
- 388 Git blob hashes matched
- 0 missing or mismatched tracked files

## Provenance

The shelf was assembled from the KoLmafia ASH language-lab development session. See [PROVENANCE.md](PROVENANCE.md) and each project's own `PROVENANCE.md`.

## License

Each project is distributed under the license recorded in its own `LICENSE` and provenance files.

The five projects whose licensing was explicitly cleared during the 2026-09-28 packaging session are released under MIT by **donCannoli-burns**:

- `ash-agent-stdlib`
- `ash-mod`
- `don-master-ash-lib`
- `kolmafia-ash-html-binding`
- `kolmafia-ash-objective-c`

Other projects retain their source-supplied licensing, including any dual-license terms. Existing third-party notices, source-pattern credits, copyrights, and upstream license terms remain in force for material they cover.

Software is provided without warranty; use it at your own risk.

## pTrack legacy accounting compatibility

The KoLmafia-installable `don-master-ash-lib/scripts/don_track_compat.ash` is a trimmed compatibility extraction from The Dictator's DicsLibrary (via Prusias-kol/pTrack / [dTrack](https://github.com/donCannoli-burns/dTrack)). It exports the legacy functions needed by `ProfitTracking.ash`: `get_property_int`, `get_property_bool`, `total_amount`, `itemValue`, and their valuation helpers. The legacy pricing rules were preserved rather than silently substituting the more general `don_item_value` model. The large action-oriented remainder of DicsLibrary is deliberately excluded.

This module imports `don_master_lib.ash` and is intended for pTrack accounting compatibility, not a replacement for every function in the full historical DicsLibrary. **Experimental — use at your own risk.** Run `verify ptrack.ash` or `verify ptrack` after updating both repositories. No live KoLmafia compile or accounting comparison has yet been executed by this change.

## Absorbed update-library module and GPL separation

The installable `don-master-ash-lib/scripts/don_updates_lib.ash` is the hardened, namespaced implementation of Prusias-kol's MIT-licensed pUpdates, with stable `data/dUpdates/` files, old `data/pUpdates/` read fallback, and `prusias_pUpdates_` preference keys. The `pUpdates` command entrypoint itself lives in [don_custom_functions](https://github.com/donCannoli-burns/don_custom_functions), which already declares don-ash-lib as a dependency. The upstream MIT notice ships at `don-master-ash-lib/third_party/pUpdates-MIT.txt`.

The independently staged `dtrack-suite/` source tree is **GPL-3.0**, not MIT. The original GPL notice is retained under that project as `LICENSE`, and a copy is installed beside the separate `don_track_compat.ash` under `don-master-ash-lib/third_party/dTrack-GPL-3.0.txt`. The root `manifest.json` still installs only `don-master-ash-lib/`, and does not install the staged dTrack suite. This isolation avoids accidental activation of untested tracking scripts or implying that their GPL-3.0 contents have been relicensed. Review licensing compatibility before distributing a combined runtime work.

## BoneFarm / BoneTrack shared helpers

The installable `don-master-ash-lib/scripts/don_bone_lib.ash` and read-only `don_bone_smoke.ash` support the absorbed [BoneFarm and BoneTrack commands](https://github.com/donCannoli-burns/don_custom_functions). This is a small shared helper, **not** a second installation of `boneFarm.ash`, `boneTrack.ash`, or the relay dashboard. See [the module's usage and provenance](don-master-ash-lib/README.md#absorbed-skeleton-of-crimbo-past-bone-helpers-2026-10-29). The root manifest still installs only `don-master-ash-lib/`.

## Absorbed CodMaster primitives

`don-master-ash-lib/scripts/don_codmaster_lib.ash` adds import-safe Codpiece gem configuration read/write, current gem capture, preset equip and historical save compatibility. The runnable `codMaster.ash` lives in `don_custom_functions`, and `UnderTheSea` consumes its shared APIs. Saved presets remain under `data/cod_master/saves/*.txt`; `spell.txt` is not copied to GitHub. See [the library usage guide](don-master-ash-lib/README.md#codmaster-absorbed-library-2026-10-29).
