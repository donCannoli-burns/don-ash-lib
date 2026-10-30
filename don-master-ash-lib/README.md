# DON Master ASH Lib

`don_master_lib.ash` is a standalone, import-safe KoLmafia ASH utility layer built to replace the common pattern of importing several overlapping legacy helper libraries into every personal script.

## Install with KoLmafia Git (recommended)

Paste this into KoLmafia's graphical CLI:

```text
git checkout https://github.com/donCannoli-burns/don-ash-lib.git main
verify don_master_lib.ash
call don_master_smoke.ash
```

The repository-root `manifest.json` selects `don-master-ash-lib/`. KoLmafia installs the files under `don-master-ash-lib/scripts/` into its local `scripts/` directory; unrelated source-shelf projects are not installed.

**Do not use** the GitHub browser URL `.../tree/main/don-master-ash-lib` with `git checkout`: KoLmafia Git requires the repository URL and optional branch. For updates use `git update`.

Manual install remains possible: copy `don_master_lib.ash` into KoLmafia's `scripts/` directory (and `don_master_smoke.ash` if you want the smoke test).

Import the library from any ASH script:

```ash
import <don_master_lib.ash>;
```

## Optional C2T-inspired, import-safe utility modules

These additional scripts install alongside `don_master_lib.ash` but are **not imported by the core automatically**:

| Module | Public API | Effect |
| --- | --- | --- |
| `don_iotm_catalog.ash` | `don_iotm_catalog()`, `don_iotm_find(key)`, `don_iotm_status(key)` | Read-only IotM metadata and state hints, no execution |
| `don_relay_select2.ash` | `don_relay_tag_searchable_selects(page)` | Pure HTML string transformation; caller supplies optional UI assets |
| `don_train_plan.ash` | `don_train_layout_valid(config)`, `don_train_layout_error(config)` | Validate eight train stations, no workshed mutation |

The APIs use `don_` names and default to **no** network, choices, CLI commands, purchases, equipment changes or preferences writes. This is capability discovery and validation, not a generic dynamic executor.

The upstream project inspirations include C2Talon/liba, c2t_kol_scripts and insertSelect2. MIT notices for adapted material are in `third_party/C2Talon-MIT.txt` and `third_party/C2Talon-c2t_kol_scripts-MIT.txt`. See the [extraction audit](https://github.com/donCannoli-burns/don_custom_functions/blob/main/C2T_ASH_ADOPTION_AUDIT_2026-10-29.md).

## Design rules

1. **Importing the library does not intentionally mutate KoL state.** There are no top-level `visit_url`, `buy`, `adventure`, `set_property`, `cli_execute`, stash, or choice actions.
2. **Live state is read at call time.** Character state is not cached into global booleans that silently go stale.
3. **New public helpers use the `don_` namespace.** This makes the library much safer to use beside ZLib, DicsLibrary, BatBrain, old QuestLib/FunctionLib scripts, or newer libraries.
4. **Mutating operations look like mutations.** Examples: `don_acquire`, `don_choice`, `don_adventure_bounded`, `don_cli`, `don_set_pref`.
5. **Important mutations return structured results where practical.** Callers can inspect `ok`, messages, before/after values, turns, and Meat spent instead of trusting only a printed string.
6. **Compatibility shims are intentionally small.** Common old Don utility names remain available, but new code should prefer the namespaced API.

## Major sections

| Area | Primary API |
|---|---|
| Logging | `don_log`, `don_good`, `don_warning`, `don_header` |
| Pure helpers | `don_clamp`, `don_rnum`, `don_list_add`, `don_list_remove` |
| Preferences | `don_pref_string/int/float/bool/item/location/familiar`, `don_set_pref` |
| State | `don_snapshot`, `don_print_snapshot`, `don_is_overdrunk`, `don_have_adv` |
| Inventory | `don_owned_amount`, `don_true_owned_amount`, `don_retrieve`, `don_acquire`, `don_use_any` |
| Value | `don_price`, `don_item_value`, `don_profit`, `don_value_of_adventure` |
| Familiar/outfit | `don_use_familiar`, `don_train_familiar`, `don_save_outfit`, `don_wear_outfit` |
| Recovery/effects | `don_has_effect`, `don_song_count`, `don_song_limit`, `don_recover_hp/mp` |
| Quest/choice | `don_quest_step`, `don_quest_at_least`, `don_choice` |
| Execution | `don_adventure_bounded`, `don_cli`, `don_require` |
| Wand/time | `don_find_wand`, `don_wand_usable`, `don_minutes_to_rollover`, `don_day` |
| Combat primitives | `don_default_combat_action`, monster stat reads, elemental display helper |
| Update notes | `don_updates_init`, `don_updates_add`, `don_updates_check` |

## Compatibility shims

Current aliases retained for older Don scripts:

```text
needToAcquireItem
needToAcquirePullItem
WaitMinutes
MuscleClass
MoxieClass
MysticalityClass
getanduse
save_outfit
trainfam
FindWand
WandUseable
MinutesToRollover
Day
saucegeyserAll
```

The intent is to migrate callers gradually rather than break every personal script at once.

## Source-pattern map

This artifact is a new implementation. It does **not** vendor the listed projects into one copied file. Their architectures and public patterns were reviewed to decide what belongs in a modern master utility layer.

| Reviewed source | Pattern carried forward |
|---|---|
| BatBrain.ash | Records, explicit combat/state helpers, calculated values instead of magic globals |
| zlib.ash | Small broadly reusable helpers, formatting/list/math utilities |
| C2Talon/liba | Narrow modern modules and avoiding a single implicit global-state blob |
| C2Talon/c2t_lib | General personal-script utility coverage with current KoLmafia idioms |
| FunctionLib.ash | Inventory/familiar/general convenience layer |
| SmashLib.ash | Value/crafting-oriented utility concept; master lib exposes generic valuation instead of reproducing old smash tables |
| helper.ash | Common player-state conveniences |
| QuestLib.ash | Quest state normalization and small quest predicates |
| sims_lib.ash | Reusable personal automation helpers, but without hidden import-time actions |
| Prusias pUpdates | Tiny local change/update stream per script |
| DicsLibrary.ash | Typed property access, ownership/value thinking, live state reads |
| Choice-Override | Composable choice/relay support and explicit boundaries between presentation and action |
| relay_zlib_manager.ash | Human-manageable settings philosophy; a separate UI can be layered on this library later |

## Why BatBrain itself was not folded into the core

BatBrain is a combat reasoning engine, not merely a helper file. Pulling its complete historical combat model into a generic library would create a large second authority for modern combat mechanics and substantial symbol/dependency collision risk. The master library therefore takes the *architecture*—records, explicit calculations, combat primitives—but leaves deep combat modeling to a dedicated combat module.

That gives a cleaner future split:

```text
don_master_lib.ash        generic utility/state/value/execution primitives
       ↓
don_combat_lib.ash        optional modern BatBrain-like combat reasoning
       ↓
don_quest_lib.ash         optional high-level quest orchestration
       ↓
personal scripts          chowDown / yeti / farming / ascension workflows
```

## Migration example

Old:

```ash
if (needToAcquireItem($item[bucket of wine])) buy(1, $item[bucket of wine], 15000);
```

New:

```ash
don_item_result wine = don_acquire(1, $item[bucket of wine], 15000);
if (!wine.ok) abort(wine.message);
```

The second form gives the caller an explicit result and keeps the price ceiling next to the acquisition request.

## Runtime authority

The artifact was structurally checked here, but the authoritative compatibility check is your installed KoLmafia runtime. Run `verify don_master_lib.ash` locally. If your runtime reports a changed/deprecated built-in, adjust that wrapper in one place instead of patching every consuming script.


## Repository Packaging Status

This standalone repository was split from the same development bundle as `ash-mod` because the utility library can be installed and versioned independently of the descriptor reader. The original `DON_MASTER_ASHLIB_README.md` is retained unchanged for descriptor compatibility.

## Status

Prototype. Structural checks pass; run KoLmafia `verify don_master_lib.ash` and the supplied smoke script locally before relying on it.

## Compatibility

KoLmafia ASH; installed-runtime built-ins are authoritative.

## Provenance

See `PROVENANCE.md` and the source-pattern map above.

## License

MIT License. See `LICENSE`. Preserved source-pattern credits remain attribution, not relicensing claims over third-party work.

## Packaging Verification

**PASS**

- manifest JSON parse
- ash.mod file-lock hashes
- ASH structural check
- selected source hash match

Installed KoLmafia verify/smoke has not been run; runtime verification remains separate from publication readiness.

## Absorbed Skeleton of Crimbo Past bone helpers (2026-10-29)

`don-master-ash-lib/scripts/don_bone_lib.ash` is an **import-safe, read-only** helper used by the installable `boneFarm.ash` and `boneTrack.ash` commands in [don_custom_functions](https://github.com/donCannoli-burns/don_custom_functions). The standalone `don_bone_smoke.ash` checks counters and ownership without spending adventures.

Its APIs are `don_bone_daily_drops()`, `don_bone_rest_drops()`, `don_bone_adventure_drops()`, `don_bone_remaining(int)`, and `don_bone_owned_amount(item)`. The authoritative daily count `_knuckleboneDrops` **already includes** `_knuckleboneRests`; never sum those two counts. Both counters are read live, never cached on import.

The gameplay and relay entrypoints remain in `don_custom_functions`, not this source shelf: importing this library must never start farming, set a preference, retrieve inventory, open a wiki, or write tracking files. The historical BoneTrack `data/boneTrack/<player>/` tree stays in the calling scripts and is not managed by this library.

Sources and provenance: [boneFarm](https://github.com/donCannoli-burns/boneFarm) (main `fe0c953243b9637f564295e2ce3b18c3c03a9190`) and [boneTrack.ash](https://github.com/donCannoli-burns/boneTrack.ash) (main `4cd400c7d5fc94579124943236a512b86589e938`). The source repositories remain intact. This is an extract of small shared accounting primitives, not a vendored second copy of the runnable scripts.

In KoLmafia, `verify don_bone_lib.ash`, `verify don_bone_smoke.ash`, then `call don_bone_smoke.ash`. Actual KoLmafia runtime verification is separate from these GitHub edits.

## CodMaster absorbed library (2026-10-29)

The installable \`don-master-ash-lib/scripts/don_codmaster_lib.ash\` owns the shared, import-safe Codpiece configuration API; \`codMaster.ash\` remains a standalone command in [don_custom_functions](https://github.com/donCannoli-burns/don_custom_functions). Import does not change KoL state. All mutating functions require an explicit call.

Existing saves are **not migrated, renamed, or removed**. The original KoLmafia map format and relative path \`data/cod_master/saves/<name>.txt\` are retained exactly, including \`spell.txt\` and keys \`cod_master_Slot_1\` through \`cod_master_Slot_5\`. On the user's profile this is \`~/.kolmafia/data/cod_master/saves/spell.txt\`. The historic \`cod_master_validSaves\` comma-separated preference registry stays intact; files can still be read even if absent from that registry.

- \`don_cod_read(name, map)\` read-only and validates the five legacy keys; \`don_cod_print_saved(name)\` prints the preset.
- \`don_cod_write(name, map, overwrite)\` writes and reads back a verified save, refusing existing files when overwrite is false.
- \`don_cod_save_preferences(name, overwrite)\` and \`don_cod_load_preferences(name)\` preserve original slot preferences.
- \`don_cod_capture(map)\` reads mounted gems; \`don_cod_save_equipped(name, overwrite)\` stores them.
- \`don_cod_equip_saved(name)\` equips verified stored gems with inventory preflight and per-slot post-check; it may partially change equipment if a later slot fails.
- \`don_cod_valid_name(name)\` allows only ASCII letters, digits, dash and underscore, 1–64 characters; prevents directory traversal.

\`don_codmaster_smoke.ash\` performs read-only format tests. \`don_codmaster_ci_roundtrip.ash\` tests a real write/read cycle only in a disposable CI KoLmafia profile. Do not invoke the latter against a personal profile. No live Codpiece equip action is included in CI.

Provenance: [donCannoli-burns/codMaster](https://github.com/donCannoli-burns/codMaster), original \`scripts/codMaster.ash\` Git blob \`e0da5ef64ef203532dde37c53e3c7ca5f0b2573f\` at \`main\` \`7fb608b023a36fdd8a497c854253521aed2757d4\`. The original repository and private profile saves are untouched. The replacement fixes the original overwrite-before-confirmation ordering and slot-capture bug; its source need not remain separately checked out after the new version is verified.


### Canonical physical save path

KoLmafia resolves `map_to_file` paths within `~/.kolmafia/data/`. Thus the canonical *API* path `cod_master/saves/spell.txt` resolves to `~/.kolmafia/data/cod_master/saves/spell.txt`. The older redundant `data/cod_master/saves/spell.txt` *API* prefix is supported as a read-only fallback for legacy nested saves; it is never automatically removed. Missing files return empty maps despite a true `file_to_map` result, so the library validates nonempty keys.
