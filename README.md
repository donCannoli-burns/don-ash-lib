# don-ash-lib

A small-project source shelf for KoLmafia ASH libraries, runtime experiments, language bindings, and developer utilities.

Each project keeps its own source, README, provenance, and license inside a named directory. This repository is intentionally a collection of small projects rather than one unified framework.

## Project shelf

| Project | Purpose | Packaging verification |
|---|---|---|
| [ash-agent-stdlib](ash-agent-stdlib/) | Agent-oriented ASH helper corpus and compatibility library. | PASS |
| [ash-mod](ash-mod/) | Declarative `ash.mod` descriptor format and KoLmafia-native reader/checker. | PASS |
| [ash-pyash-webscraper](ash-pyash-webscraper/) | Bounded GET-only ASH/PyASH web scraper with HTML/Markdown/PDF output. | PASS |
| [cashgo](cashgo/) | Cargo-inspired ASH project/dependency manifest and lock experiment. | PASS |
| [don-master-ash-lib](don-master-ash-lib/) | Namespaced general-purpose KoLmafia ASH utility library. | PASS |
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
