# don-ash-lib

A small-project source shelf for KoLmafia ASH libraries, runtime experiments, language bindings, and developer utilities.

Each project keeps its own source, README, provenance, and license inside a named directory. The repository is intentionally a collection of small projects rather than one unified framework.

## Project shelf

| Project | Purpose | Status |
|---|---|---|
| [ash-agent-stdlib](ash-agent-stdlib/) | Large agent-oriented ASH utility/compatibility library with indexed source modules and tests. | Experimental |
| [ash-mod](ash-mod/) | Declarative `ash.mod` descriptor format and KoLmafia-native reader/checker. | Prototype |
| [don-master-ash-lib](don-master-ash-lib/) | Namespaced general-purpose KoLmafia ASH utility library. | Prototype |
| [kolmafia-ash-html-binding](kolmafia-ash-html-binding/) | Bounded ASH ↔ HTML/HTML5 relay binding. | Prototype |
| [kolmafia-ash-objective-c](kolmafia-ash-objective-c/) | Objective-C client binding for KoLmafia's Browser JSON API / ASH runtime surface. | Experimental |

Open a project's own README for installation, usage, compatibility, verification status, and project-specific provenance.

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

Projects may share a repository because this repository's purpose is archival/source collection, but they remain semantically independent and should not be treated as one combined runtime.

## Provenance

The shelf was assembled from the KoLmafia ASH language-lab development session. See [PROVENANCE.md](PROVENANCE.md) and each project's own `PROVENANCE.md`.

## License

Original project code controlled by **donCannoli-burns** in the five project directories above is released under the MIT License. Each project carries its own `LICENSE`.

Existing third-party notices, source-pattern credits, copyrights, and upstream license terms remain in force for material they cover. References to community projects are attribution and provenance, not claims of authorship or ownership.

Software is provided without warranty; use it at your own risk.
