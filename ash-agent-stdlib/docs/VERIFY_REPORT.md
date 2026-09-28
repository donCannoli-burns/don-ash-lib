# Verification Report — ASH Agent Standard Library v0.1.0

## Status

- Target source entries: **41**
- Required functions per source: **10**
- Rendered source modules: **41**
- Rendered function definitions: **410**
- Unique function names: **410**
- Every module has exactly ten exports: **TRUE**
- Read-only smoke coverage: **41/41 source modules**
- Live KoLmafia `verify`: **NOT RUN**

The build environment has Java 21, but it does not contain a KoLmafia JAR and outbound binary retrieval is unavailable. No claim of live parser/runtime verification is made.

## Current KoLmafia compatibility target

The current release context inspected during this build was **KoLmafia r29307**, published 2026-09-27.

Compatibility work used:
- current KoLmafia GitHub source/release metadata;
- the current ASH function reference at `https://wiki.kolmafia.us/index.php/Ash_Functions`;
- source/API spot checks for less-obvious functions/proxy fields before using them.

The local installed KoLmafia runtime remains authoritative. Run `ashref <name>` and `verify` locally if the installed revision differs.

## Static corpus checks

| Check | Result |
|---|---|
| 41 source modules rendered | PASS |
| monolithic master renders all 410 exports once | PASS |
| exactly 10 `aal_*` definitions per module | PASS |
| total definitions = 410 | PASS |
| global function names unique | PASS |
| brackets / braces / parentheses balanced after stripping comments/literals | PASS |
| internal `aal_*` calls resolve to generated exports | PASS |
| no direct mutating API calls in generated source modules | PASS |
| no top-level executable calls in source modules | PASS |
| high-similarity purpose audit (>= 0.86) | PASS — 0 pairs |
| smoke script touches every source module | PASS — 41/41 |

## API spot checks

The generated code was reviewed against current ASH documentation/source for the less-trivial API surfaces it uses, including:

`my_effects`, `effect_modifier`, `monster_element`, `elemental_resistance`,
`weight_adjustment`, `stills_available`, `creatable_amount`, `mp_cost`,
`pulls_remaining`, `my_storage_meat`, `historical_age`, `to_path`,
`in_mysticality_sign`, skill proxy fields such as `.class` / `.buff`, and
location turn-count metadata such as `.turns_spent`.

This is an API audit, **not** a substitute for a live `verify`.

## Import-safety boundary

Generated modules intentionally contain no direct calls to the mutating primitives scanned by this build:

`visit_url`, `cli_execute`, `set_property`, `buy`, `retrieve_item`, `use`,
`eat`, `drink`, `adventure`, `run_choice`, `run_combat`, stash/storage movement,
equipment/familiar mutation, `create`, `autosell`, `mallsell`, recovery mutation,
or MCD changes.

Several generated functions perform read-only state or pricing queries. `mall_price`
can trigger a read-only mall lookup depending on KoLmafia cache state.

## Local verification commands

Place the master file and `lib/` modules under KoLmafia's `scripts/` tree, then run:

```text
verify ash_agent_stdlib_master.ash
verify ash_agent_stdlib.ash
verify ash_agent_smoke.ash
call ash_agent_smoke.ash
```

The smoke script is intentionally read-only.

## Known limitations

1. Static source analyzers intentionally parse common quoted/regex patterns rather than implementing a full ASH parser.
2. Runtime state helpers reflect KoLmafia's current local/cache state.
3. Price/value helpers are heuristic and may invoke read-only mall pricing.
4. Combat-context functions are meaningful only when the corresponding combat state is available.
5. v0.1.0 deliberately provides no mutating executor layer; planning/execution separation is intentional.
6. Exact installed-runtime acceptance remains pending the user's local `verify`.
