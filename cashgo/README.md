# CashGo

**CashGo** is a Cargo-inspired project/dependency manager written in KoLmafia **ASH**.

It does not try to replace KoLmafia's Git installer. CashGo provides the missing project layer around it:

```text
cashgo.toml
    ↓
ASH parser + validation
    ↓
deterministic dependency graph
    ↓
cashgo.lock
    ↓
KoLmafia native git checkout / update / sync
    ↓
scripts / relay / data installed by KoLmafia
```

## Why this architecture

KoLmafia already has a Git package transport that installs supported repository folders into the correct runtime locations. CashGo therefore uses that existing mechanism rather than attempting to write package files into `scripts/` through ASH data-file APIs.

CashGo only emits a narrow set of generated gCLI commands:

- `git checkout <validated-source> [validated-ref]`
- `git update <validated-source>`
- `git sync`
- `call <validated-entry> [one argument token]`

Manifest values are validated before those commands are constructed. CashGo never evaluates a manifest value as an arbitrary gCLI command.

## Install

Copy:

```text
scripts/cashgo.ash
```

into KoLmafia's `scripts/` directory.

Then:

```text
verify cashgo.ash
call cashgo.ash help
```

## Project manifest

CashGo manifests are deliberately stored in KoLmafia's `data/` tree because ASH's `file_to_buffer()` / `buffer_to_file()` API is data-directory-oriented.

Default path:

```text
~/.kolmafia/data/cashgo/cashgo.toml
```

Create one:

```text
call cashgo.ash init my-project
```

Example:

```toml
[package]
name = "my-project"
version = "0.1.0"
entry = "my-project.ash"

[dependencies]
vprops = "github:Veracity0/vprops@main"
helper = "git:https://github.com/example/helper.git@release"
optional-tool = "optional:github:example/tool@main"
```

### Dependency syntax

```text
github:OWNER/REPO
github:OWNER/REPO@BRANCH
git:https://github.com/OWNER/REPO.git@BRANCH
optional:github:OWNER/REPO@BRANCH
```

`@BRANCH` is optional.

This v0.1 syntax intentionally does **not** accept shell fragments, whitespace-bearing sources, SSH URLs, command substitutions, or arbitrary gCLI.

## Commands

```text
call cashgo.ash init <name>
call cashgo.ash check
call cashgo.ash add <alias> <dependency-spec>
call cashgo.ash remove <alias>
call cashgo.ash lock
call cashgo.ash tree
call cashgo.ash metadata
call cashgo.ash fetch
call cashgo.ash build
call cashgo.ash install <alias>
call cashgo.ash update
call cashgo.ash run [single-argument]
```

### Dry run

Anything that would invoke KoLmafia Git can be previewed:

```text
call cashgo.ash fetch --dry-run
call cashgo.ash update --dry-run
call cashgo.ash install vprops --dry-run
call cashgo.ash run --dry-run
```

### Alternate manifest

```text
call cashgo.ash check --manifest=cashgo/projects/foo/cashgo.toml
```

Paths are relative to KoLmafia's `data/` directory.

## Cargo-ish semantics

| Cargo idea | CashGo v0.1 |
| --- | --- |
| `Cargo.toml` | `cashgo.toml` |
| `Cargo.lock` | `cashgo.lock` |
| `cargo init/new` | `cashgo init/new` |
| `cargo add` | `cashgo add` |
| `cargo remove` | `cashgo remove` |
| `cargo fetch` | `cashgo fetch` |
| `cargo build` | alias of `fetch` + `git sync` |
| `cargo update` | `cashgo update` |
| `cargo tree` | `cashgo tree` |
| `cargo metadata` | `cashgo metadata` |
| `cargo run` | `cashgo run` |

ASH is interpreted, so there is no native compile/link stage. CashGo's `build` therefore means: **resolve manifest → validate → install dependencies → sync runtime files → write lock metadata**.

## Lockfile semantics

`cashgo.lock` records the exact dependency spec that CashGo resolved from the manifest. In v0.1 it does **not** claim to pin a remote Git commit SHA; KoLmafia's Git subsystem remains the source of truth for the actual checked-out revision.

This distinction is intentional. A future v0.2 can add revision discovery/pinning if KoLmafia exposes a stable read-only project-info surface suitable for it.

## Safety properties

CashGo v0.1:

- does not call `visit_url()` itself;
- does not POST to KoL or spend turns;
- does not run arbitrary gCLI strings from a manifest;
- rejects whitespace and command punctuation in aliases/refs;
- only accepts GitHub shorthand or HTTPS Git sources;
- supports `--dry-run` for every transport action;
- leaves repository installation/copy semantics to KoLmafia's native Git implementation.

The one intentional privileged boundary is `cli_execute()`, used only after source/ref/entry validation to invoke fixed `git` and `call` command forms.

## Current limitations

v0.1 is intentionally small:

- exact Git source + optional branch/ref only;
- no semver range solving yet;
- no registry service;
- no checksum/commit pinning claim;
- no SSH/private-repository auth abstraction;
- `run` accepts one argument token in this version;
- it does not parse a dependency repository's own CashGo manifest recursively. KoLmafia's native `dependencies.txt` mechanism still handles dependencies declared by installed repositories.

Those are natural v0.2+ targets rather than things to fake in the first release.

## KoLmafia grounding

CashGo is designed around existing KoLmafia behavior rather than inventing a second installer:

- ASH `import` searches the `scripts/` directory and subdirectories.
- ASH `file_to_buffer()` / `buffer_to_file()` are data-file oriented.
- `cli_execute()` is the ASH escape hatch for gCLI commands that do not have direct ASH equivalents.
- KoLmafia's Git installer supports `checkout`, `update`, and `sync`, and Git-installed repositories can provide `manifest.json` and `dependencies.txt`.

Reference material:

- https://wiki.kolmafia.us/index.php/Import
- https://wiki.kolmafia.us/index.php/Cli_execute
- https://wiki.kolmafia.us/index.php/Map_to_file
- https://kolmafia.us/threads/you-can-now-install-scripts-using-git-instead-of-svn.27794/

## Why It Exists

KoLmafia has Git transport but not a small declarative project/dependency manifest layer with lock metadata and dry-run semantics.

## Files

- `LICENSE` — packaged source/support material.
- `MANIFEST.md` — packaged source/support material.
- `VALIDATION.md` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `examples/` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `tests/` — packaged source/support material.

## Status

Prototype.

## Compatibility

KoLmafia ASH; Python 3 is used only by the portable static validator.

## Provenance

Extracted and packaged as a standalone repository from `cashgo-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- portable static validator

KoLmafia verify and Git mutation paths not run.
