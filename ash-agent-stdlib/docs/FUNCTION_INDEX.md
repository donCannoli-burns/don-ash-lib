# Global Function Index

410 exported functions, grouped by domain/category.

## Adventure

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ezeco_location_advice` | `string aal_ezeco_location_advice(location loc)` | SOURCE 04: Ezandora repository ecosystem | READ_ONLY | Expose location accessibility and recent turn count as advisory context. |
| `aal_helper_pirate_access_context` | `string aal_helper_pirate_access_context()` | SOURCE 34: helper.ash | READ_ONLY | Summarize pirate access items/outfit rather than temporarily equipping them. |
| `aal_quest_location_state` | `string aal_quest_location_state(location loc)` | SOURCE 35: QuestLib.ash | READ_ONLY | Describe quest location accessibility/turn history. |
| `aal_quest_mcd_ceiling` | `int aal_quest_mcd_ceiling()` | SOURCE 35: QuestLib.ash | READ_ONLY | Return the legacy practical MCD ceiling implied by sign. |
| `aal_sims_delay_state` | `agent_resource_state aal_sims_delay_state()` | SOURCE 36: sims_lib.ash | READ_ONLY | Expose Mini-Hipster free-adventure usage relevant to delay-zone recommendations. |

## Adventure / Validation

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2scripts_map_monster_preflight` | `agent_check aal_c2scripts_map_monster_preflight(location where, monster target)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Check non-mutating prerequisites for using Map the Monsters at a requested location. |

## Analytics

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_astrogain_source_efficiency` | `float aal_astrogain_source_efficiency(float modifier_value, int turns, int meat_cost, int mp_cost_value, int meat_per_mp)` | SOURCE 20: Astro3207 Gain | PURE | Score a buff source with combined item/meat and MP opportunity costs. |
| `aal_checklist_completion_ratio` | `float aal_checklist_completion_ratio(item[int] items)` | SOURCE 16: pChecklist | READ_ONLY | Calculate fraction of valid checklist items owned at least once. |
| `aal_gain_effect_efficiency` | `float aal_gain_effect_efficiency(effect e, string modifier_name, int turns, int estimated_cost)` | SOURCE 19: Ezandora Gain | READ_ONLY | Compute simple cost per modifier-turn for an effect candidate. |
| `aal_ocd_cleanup_count` | `int aal_ocd_cleanup_count(item[int] items, int[item] keep_amounts)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | Count total copies above configured keep amounts across a caller item list. |
| `aal_profit_value_per_turn` | `float aal_profit_value_per_turn(agent_value_snapshot before, agent_value_snapshot after)` | SOURCE 13: ProfitTracking.ash | PURE | Compute total-value delta per turn. |
| `aal_ptrack_meat_per_adventure` | `float aal_ptrack_meat_per_adventure(agent_breakpoint before, agent_breakpoint after)` | SOURCE 09: pTrack repository | PURE | Compute liquid-meat delta per turn for a checkpoint interval. |
| `aal_stash_missing_count` | `int aal_stash_missing_count(int[item] expected)` | SOURCE 17: pStash | READ_ONLY | Count tracked stash entries below baseline. |
| `aal_time_seconds_per_turn` | `float aal_time_seconds_per_turn(int turns, int elapsed_ms)` | SOURCE 14: TimeTracking.ash | PURE | Calculate average seconds per turn. |
| `aal_time_turns_per_hour` | `float aal_time_turns_per_hour(int turns, int elapsed_ms)` | SOURCE 14: TimeTracking.ash | PURE | Calculate turn throughput for a timed interval. |

## Ascension

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ascend_config_fields` | `string aal_ascend_config_fields()` | SOURCE 07: c2t_ascend | PURE | Return stable names for a minimal Valhalla/ascension plan schema. |
| `aal_ascend_prerequisite_state` | `string aal_ascend_prerequisite_state()` | SOURCE 07: c2t_ascend | READ_ONLY | Expose current aftercore/interaction/king state relevant to entering Valhalla. |
| `aal_bootstrap_meatcar_state` | `string aal_bootstrap_meatcar_state()` | SOURCE 25: bootstrap.ash | READ_ONLY | Describe whether the meatcar is owned or creatable before attempting construction. |
| `aal_bootstrap_radio_state` | `string aal_bootstrap_radio_state()` | SOURCE 25: bootstrap.ash | READ_ONLY | Describe detuned-radio ownership and NPC price context. |
| `aal_bootstrap_starter_items` | `string aal_bootstrap_starter_items()` | SOURCE 25: bootstrap.ash | PURE | Return the legacy bootstrap's starter-item targets in deterministic order. |

## Capability Discovery

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_astrogain_effect_source_items` | `string aal_astrogain_effect_source_items(effect e, int max_entries)` | SOURCE 20: Astro3207 Gain | READ_ONLY | Find bounded item sources whose Effect modifier matches the requested effect. |
| `aal_astrogain_effect_source_skills` | `string aal_astrogain_effect_source_skills(effect e, int max_entries)` | SOURCE 20: Astro3207 Gain | READ_ONLY | Find bounded skill sources that map to the requested effect. |
| `aal_c2lib_priority_item_context` | `string aal_c2lib_priority_item_context(item[int] candidates)` | SOURCE 32: c2t_lib | READ_ONLY | Return first available item plus all candidate availability for explainable priority. |
| `aal_ezeco_iotm_presence` | `agent_check aal_ezeco_iotm_presence(item key_item, familiar key_familiar, skill key_skill)` | SOURCE 04: Ezandora repository ecosystem | READ_ONLY | Describe whether a feature is present through any of its item/familiar/skill surfaces. |
| `aal_liba_priority_item_reason` | `string aal_liba_priority_item_reason(item[int] candidates)` | SOURCE 30: liba | READ_ONLY | Select the first available item and explain the priority position. |

## Choices

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2scripts_choice_state` | `agent_choice_state aal_c2scripts_choice_state(int choice_id)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Describe whether KoLmafia is currently handling a requested choice and its configured choiceAdventure preference. |
| `aal_choiceoverride_choice_id` | `int aal_choiceoverride_choice_id(string page_text)` | SOURCE 39: Choice-Override | PURE | Parse a choice ID from common whichchoice HTML/query patterns without issuing a request. |
| `aal_choiceoverride_option_ids` | `string aal_choiceoverride_option_ids(string page_text)` | SOURCE 39: Choice-Override | PURE | Extract unique positive option values from choice-page HTML. |
| `aal_liba_choice_context` | `string aal_liba_choice_context()` | SOURCE 30: liba | READ_ONLY | Return compact current-choice context inspired by liba_inChoice. |
| `aal_pwrapper_choice_recovery_state` | `agent_choice_state aal_pwrapper_choice_recovery_state()` | SOURCE 12: pwrapper | READ_ONLY | Describe current choice and configured option without submitting it. |

## Classification

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2eco_repo_role` | `string aal_c2eco_repo_role(string repo_name)` | SOURCE 01: C2Talon repository ecosystem | PURE | Classify a C2Talon-style repository by its name into a useful runtime role. |

## Combat

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_batbrain_combat_state` | `agent_combat_state aal_batbrain_combat_state()` | SOURCE 29: BatBrain.ash | READ_ONLY | Capture current combat-relevant monster/player stats without taking an action. |
| `aal_batbrain_element_context` | `string aal_batbrain_element_context(monster m)` | SOURCE 29: BatBrain.ash | READ_ONLY | Serialize monster element and player elemental resistances for combat planning. |
| `aal_batbrain_hit_survival_margin` | `int aal_batbrain_hit_survival_margin(int expected_damage)` | SOURCE 29: BatBrain.ash | READ_ONLY | Compute player HP remaining after hypothetical damage. |
| `aal_batbrain_skill_mp_margin` | `int aal_batbrain_skill_mp_margin(skill s, int casts)` | SOURCE 29: BatBrain.ash | READ_ONLY | Compute MP remaining after hypothetical repeated skill use. |
| `aal_liba_combat_context` | `string aal_liba_combat_context()` | SOURCE 30: liba | READ_ONLY | Return compact combat indicators inspired by liba_inCombat without executing requests. |
| `aal_pwrapper_combat_recovery_state` | `string aal_pwrapper_combat_recovery_state()` | SOURCE 12: pwrapper | READ_ONLY | Describe whether wrapper recovery is currently in combat-like state using tracked combat signals. |

## Combat / Describe

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2lib_macro_description` | `string aal_c2lib_macro_description(string macro_text)` | SOURCE 32: c2t_lib | PURE | Describe BALLS-style combat macro structure without submitting it. |

## Combat / Finance

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_batbrain_monster_meat_value` | `float aal_batbrain_monster_meat_value(monster m)` | SOURCE 29: BatBrain.ash | READ_ONLY | Estimate base monster meat value after current meat-drop modifier. |

## Combat / Planning

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_batbrain_beaten_up_turn_cost` | `int aal_batbrain_beaten_up_turn_cost(int value_of_adventure)` | SOURCE 29: BatBrain.ash | PURE | Value the canonical three-adventure Beaten Up opportunity cost floor. |
| `aal_batbrain_runaway_value` | `float aal_batbrain_runaway_value(monster m, int value_of_adventure)` | SOURCE 29: BatBrain.ash | READ_ONLY | Estimate opportunity cost of running away as monster base meat plus one adventure value. |

## Community Service

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_hccs_test_order` | `string aal_hccs_test_order()` | SOURCE 06: c2t_hccs | PURE | Return Community Service test order used by c2t_hccs as a deterministic machine-readable list. |

## Consumption

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_consume_candidate` | `agent_consumption_candidate aal_consume_candidate(item it, int size, float expected_adventures, int price)` | SOURCE 21: Consume | PURE | Create a normalized consumable candidate with density/value fields. |
| `aal_consume_organ_remaining` | `int aal_consume_organ_remaining(string organ_name)` | SOURCE 21: Consume | READ_ONLY | Return remaining capacity for fullness, liver, or spleen by normalized organ name. |
| `aal_consume_organ_state` | `agent_organ_state aal_consume_organ_state()` | SOURCE 21: Consume | READ_ONLY | Capture current fullness, inebriety, and spleen usage/limits. |

## Crafting

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_smash_element_profile` | `string aal_smash_element_profile(item it)` | SOURCE 33: SmashLib.ash | READ_ONLY | Summarize elemental damage/resistance signals relevant to pulverization output. |
| `aal_smash_expected_material_tier` | `string aal_smash_expected_material_tier(item it)` | SOURCE 33: SmashLib.ash | READ_ONLY | Normalize power band to powder/nugget/wad family. |
| `aal_smash_inventory_candidates` | `string aal_smash_inventory_candidates(int min_power, int max_entries)` | SOURCE 33: SmashLib.ash | READ_ONLY | List owned ordinary equipment at/above a power threshold for later smash analysis. |
| `aal_smash_power_band` | `string aal_smash_power_band(item it)` | SOURCE 33: SmashLib.ash | READ_ONLY | Map equipment power to legacy pulverization power bands. |
| `aal_smash_slot_candidate` | `boolean aal_smash_slot_candidate(item it)` | SOURCE 33: SmashLib.ash | READ_ONLY | Check whether an item occupies an equipment slot commonly eligible for pulverization. |

## Crafting / Finance

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_smash_value_floor` | `int aal_smash_value_floor(item it)` | SOURCE 33: SmashLib.ash | READ_ONLY | Compute the immediate economic floor an item should beat before smashing. |

## Debugging

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ascend_config_fingerprint` | `int aal_ascend_config_fingerprint(string config_csv)` | SOURCE 07: c2t_ascend | PURE | Produce a stable lightweight fingerprint for detecting ascension-config drift. |
| `aal_choiceoverride_page_fingerprint` | `string aal_choiceoverride_page_fingerprint(string page_text)` | SOURCE 39: Choice-Override | PURE | Build a lightweight deterministic choice-page fingerprint from parsed ID/length/option list. |
| `aal_iron_scripts_html_parse_score` | `int aal_iron_scripts_html_parse_score(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Score reliance on substring/excise/matcher parsing around page requests. |
| `aal_ocd_missing_rule_context` | `string aal_ocd_missing_rule_context(item[int] inventory_items, boolean[item] ruled_items, int max_entries)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | List owned items lacking a caller-provided OCD policy map. |
| `aal_pupdateslog_checksum` | `int aal_pupdateslog_checksum(string[int] update_lines)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Produce a deterministic lightweight checksum from version numbers and line lengths. |
| `aal_pwrapper_error_context` | `string aal_pwrapper_error_context(string error_message)` | SOURCE 12: pwrapper | READ_ONLY | Combine a caught wrapper error with KoLmafia's latest combat/encounter diagnostics. |
| `aal_testout_assertion_count` | `int aal_testout_assertion_count(agent_diagnostic[int] results, boolean passed)` | SOURCE 24: testout.ash | PURE | Count passing or failing diagnostics. |
| `aal_testout_bool` | `agent_diagnostic aal_testout_bool(string name, boolean actual, boolean expected)` | SOURCE 24: testout.ash | PURE | Create a structured boolean smoke-test result. |
| `aal_testout_failures` | `string aal_testout_failures(agent_diagnostic[int] results, int max_entries)` | SOURCE 24: testout.ash | PURE | Emit bounded failing diagnostic rows. |
| `aal_testout_range` | `agent_diagnostic aal_testout_range(string name, float actual, float minimum, float maximum)` | SOURCE 24: testout.ash | PURE | Create a diagnostic for an inclusive numeric range. |
| `aal_testout_runtime_probe` | `string aal_testout_runtime_probe()` | SOURCE 24: testout.ash | READ_ONLY | Capture a harmless runtime probe replacing the original one-line vprint smoke idea with structured state. |
| `aal_testout_summary` | `string aal_testout_summary(agent_diagnostic[int] results)` | SOURCE 24: testout.ash | PURE | Summarize diagnostic pass/fail counts. |
| `aal_twisted_legacy_risk_score` | `int aal_twisted_legacy_risk_score(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Compute a coarse modernization risk score from legacy execution and page-scraping patterns. |

## Describe

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2eco_repo_capability_tags` | `string aal_c2eco_repo_capability_tags(string repo_name)` | SOURCE 01: C2Talon repository ecosystem | PURE | Produce compact capability tags inferred from ecosystem naming conventions. |
| `aal_sims_recommendation_reason` | `string aal_sims_recommendation_reason(familiar fam, string goal)` | SOURCE 36: sims_lib.ash | READ_ONLY | Generate concise human/agent-readable rationale for common familiar goals. |

## Diff / Change Detection

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2eco_manifest_delta` | `string aal_c2eco_manifest_delta(string[int] before_repos, string[int] after_repos)` | SOURCE 01: C2Talon repository ecosystem | PURE | Compare two repository manifests and report added/removed names. |
| `aal_c2scripts_resource_delta` | `agent_delta aal_c2scripts_resource_delta(string property_name, int before_value)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Compare a numeric tracked preference to an earlier captured value. |
| `aal_htmlform_changed` | `boolean aal_htmlform_changed(string old_value, string submitted_value)` | SOURCE 28: htmlform.ash | PURE | Check whether a submitted field actually changes persisted value. |
| `aal_profit_item_delta` | `agent_delta aal_profit_item_delta(item it, int before_total)` | SOURCE 13: ProfitTracking.ash | READ_ONLY | Compare current cross-location item total against an earlier captured total. |
| `aal_profit_snapshot_delta` | `string aal_profit_snapshot_delta(agent_value_snapshot before, agent_value_snapshot after)` | SOURCE 13: ProfitTracking.ash | PURE | Serialize value/turn/time changes between two profit snapshots. |
| `aal_ptrack_breakpoint_delta` | `string aal_ptrack_breakpoint_delta(agent_breakpoint before, agent_breakpoint after)` | SOURCE 09: pTrack repository | PURE | Serialize meat/turn/time deltas between two in-memory breakpoints. |
| `aal_time_adjacent_durations` | `string aal_time_adjacent_durations(string[int] names, int[int] stamps)` | SOURCE 14: TimeTracking.ash | PURE | Serialize elapsed time between adjacent named breakpoints. |
| `aal_zlib_setting_diff` | `string aal_zlib_setting_diff(string name, string old_value, string new_value)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Serialize one settings change instead of directly persisting it. |

## Effects

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2scripts_shavings_state` | `string aal_c2scripts_shavings_state()` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Expose the Daylight Shavings Helmet tracking preferences as compact machine context. |
| `aal_dics_song_state` | `string aal_dics_song_state()` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Summarize active Accordion Thief song effects and durations. |
| `aal_lowerstats_positive_effects` | `string aal_lowerstats_positive_effects(stat s, int max_entries)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | List active effects that positively modify the requested stat, bounded for agent context. |

## Equipment

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_functionlib_equipment_preflight` | `agent_check aal_functionlib_equipment_preflight(item it)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Check possession/equipability and current equip state without equipping. |
| `aal_helper_epic_weapon_state` | `string aal_helper_epic_weapon_state()` | SOURCE 34: helper.ash | READ_ONLY | Summarize class-relevant Epic/Legendary/Ultimate weapon ownership without changing equipment. |

## Familiar

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_functionlib_familiar_training_gap` | `agent_range_state aal_functionlib_familiar_training_gap(familiar fam, int target_weight)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Measure familiar base-weight gap before any training action. |
| `aal_helper_familiar_goal_score` | `float aal_helper_familiar_goal_score(familiar fam, string goal)` | SOURCE 34: helper.ash | READ_ONLY | Create an explainable familiar-goal score using weight and broad native modifiers. |
| `aal_sims_best_familiar` | `familiar aal_sims_best_familiar(familiar[int] candidates, string goal, int combat_bias)` | SOURCE 36: sims_lib.ash | READ_ONLY | Select highest-scoring candidate familiar without switching it. |
| `aal_sims_familiar_weight` | `int aal_sims_familiar_weight(familiar fam)` | SOURCE 36: sims_lib.ash | READ_ONLY | Return current effective familiar weight basis for recommendation logic. |
| `aal_sims_goal_score` | `float aal_sims_goal_score(familiar fam, string goal, int combat_bias)` | SOURCE 36: sims_lib.ash | READ_ONLY | Score owned familiars by weight plus broad goal/combat heuristics. |
| `aal_sims_runaway_capacity` | `int aal_sims_runaway_capacity(familiar fam)` | SOURCE 36: sims_lib.ash | READ_ONLY | Estimate weight-based free-runaway capacity using the legacy 5-weight-per-runaway heuristic. |

## Finance

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_dics_market_confidence` | `string aal_dics_market_confidence(item it, int fresh_days)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Classify price confidence from tradeability, historical age, historical price, and mall fallback. |
| `aal_dics_value_estimate` | `int aal_dics_value_estimate(item it, int fresh_days, float multiplier)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Estimate item value with a configurable sell-realization multiplier. |
| `aal_networth_inventory_value` | `int aal_networth_inventory_value(boolean include_storage, int max_historical_age, int historical_cap)` | SOURCE 22: networth.ash | READ_ONLY | Estimate total item value across the source-inspired account locations. |
| `aal_networth_item_value` | `int aal_networth_item_value(item it, boolean include_storage, int max_historical_age, int historical_cap)` | SOURCE 22: networth.ash | READ_ONLY | Value one item's included quantity with the normalized unit-price heuristic. |
| `aal_networth_location_value` | `int aal_networth_location_value(item it, string location_name, int max_historical_age, int historical_cap)` | SOURCE 22: networth.ash | READ_ONLY | Value one item in one named account location for explainable net-worth decomposition. |
| `aal_networth_total` | `int aal_networth_total(boolean include_storage, int max_historical_age, int historical_cap)` | SOURCE 22: networth.ash | READ_ONLY | Estimate liquid meat plus item value. |
| `aal_networth_unit_price` | `int aal_networth_unit_price(item it, int max_historical_age, int historical_cap)` | SOURCE 22: networth.ash | READ_ONLY | Modernize networth.ash pricing: autosell for untradeable, fresh historical price when sane, otherwise mall. |
| `aal_networth_value_floor` | `int aal_networth_value_floor(item it)` | SOURCE 22: networth.ash | READ_ONLY | Return a conservative non-negative value floor from autosell/NPC pricing. |
| `aal_ocd_liquidation_value` | `int aal_ocd_liquidation_value(item it, string action, int keep_amount)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | Estimate gross liquidation value of an OCD rule without executing it. |
| `aal_profit_inventory_value` | `int aal_profit_inventory_value(int max_historical_age)` | SOURCE 13: ProfitTracking.ash | READ_ONLY | Estimate total value of currently held inventory/closet/storage/display/shop/equipped items. |
| `aal_profit_liquid_meat` | `int aal_profit_liquid_meat()` | SOURCE 13: ProfitTracking.ash | READ_ONLY | Return liquid meat across inventory, closet, and storage. |

## Inventory

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_bootstrap_item_state` | `string aal_bootstrap_item_state(item it)` | SOURCE 25: bootstrap.ash | READ_ONLY | Describe inventory/storage availability of a bootstrap target. |
| `aal_checklist_custom_missing` | `string aal_checklist_custom_missing(item[int] items, int max_entries)` | SOURCE 16: pChecklist | READ_ONLY | List missing items from a caller-defined checklist. |
| `aal_checklist_item_state` | `agent_item_state aal_checklist_item_state(item it)` | SOURCE 16: pChecklist | READ_ONLY | Capture checklist ownership state across storage locations. |
| `aal_checklist_range_missing` | `string aal_checklist_range_missing(int first_id, int last_id, int max_entries)` | SOURCE 16: pChecklist | READ_ONLY | List missing valid items from an inclusive item-ID range. |
| `aal_checklist_total_owned` | `int aal_checklist_total_owned(item it)` | SOURCE 16: pChecklist | READ_ONLY | Count an item across inventory, closet, display, equipment, shop, and storage. |
| `aal_dics_total_amount` | `int aal_dics_total_amount(item it, boolean include_stash)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Count item ownership across inventory/equipment/closet/storage/display/shop and optionally stash. |
| `aal_functionlib_ownership_locations` | `string aal_functionlib_ownership_locations(item it)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Expose where an item is currently held instead of collapsing ownership to a boolean. |
| `aal_networth_quantity` | `int aal_networth_quantity(item it, boolean include_storage)` | SOURCE 22: networth.ash | READ_ONLY | Count relevant item copies for a net-worth calculation. |
| `aal_ocd_excess_quantity` | `int aal_ocd_excess_quantity(item it, int keep_amount)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | Compute copies above a configured keep quantity. |
| `aal_ocd_owned_total` | `int aal_ocd_owned_total(item it)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | Count copies across common personal item locations for disposition planning. |
| `aal_profit_item_state` | `agent_item_state aal_profit_item_state(item it)` | SOURCE 13: ProfitTracking.ash | READ_ONLY | Capture an item's quantities across major account locations. |

## Items

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_functionlib_consumption_kind` | `string aal_functionlib_consumption_kind(item it)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Describe likely consumption channel from native item metadata. |
| `aal_functionlib_wand_inventory` | `string aal_functionlib_wand_inventory()` | SOURCE 31: FunctionLib.ash | READ_ONLY | Serialize all five zap-wand IDs currently owned/available. |
| `aal_gain_item_source_cost` | `int aal_gain_item_source_cost(item it)` | SOURCE 19: Ezandora Gain | READ_ONLY | Estimate acquisition cost of an item source without acquiring it. |
| `aal_helper_wand_state` | `string aal_helper_wand_state()` | SOURCE 34: helper.ash | READ_ONLY | Return compact zap-wand ownership state. |
| `aal_profit_price_estimate` | `int aal_profit_price_estimate(item it, int max_historical_age)` | SOURCE 13: ProfitTracking.ash | READ_ONLY | Estimate an item value with fresh historical price fallback to mall/autosell. |
| `aal_rollover_wand_candidate` | `item aal_rollover_wand_candidate()` | SOURCE 23: rollover.ash | READ_ONLY | Return the first known wand item currently available. |

## LLM Context

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ascend_agent_context` | `string aal_ascend_agent_context(string config_csv, string post_script)` | SOURCE 07: c2t_ascend | READ_ONLY | Build compact current-state plus configured-plan context for an ascension agent. |
| `aal_astrogain_agent_context` | `string aal_astrogain_agent_context(effect e, string modifier_name)` | SOURCE 20: Astro3207 Gain | READ_ONLY | Build effect/source/modifier context suitable for an agent planning buff acquisition. |
| `aal_batbrain_agent_context` | `string aal_batbrain_agent_context(int value_of_adventure)` | SOURCE 29: BatBrain.ash | READ_ONLY | Build compact BatBrain-inspired combat context for an LLM without producing/executing a macro. |
| `aal_bootstrap_agent_context` | `string aal_bootstrap_agent_context()` | SOURCE 25: bootstrap.ash | READ_ONLY | Build compact initial-ascension setup context. |
| `aal_c2eco_agent_context` | `string aal_c2eco_agent_context(string[int] repo_names, string dependencies_text, int max_repos)` | SOURCE 01: C2Talon repository ecosystem | PURE | Build a compact deterministic ecosystem context for an agent selecting reusable C2Talon components. |
| `aal_c2scripts_agent_context` | `string aal_c2scripts_agent_context(location where, monster target, int choice_id)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Build compact choice/cartography/resource context inspired by c2t_kol_scripts. |
| `aal_checklist_agent_context` | `string aal_checklist_agent_context(string checklist_name, item[int] items, int max_entries)` | SOURCE 16: pChecklist | READ_ONLY | Build compact checklist completion/missing context for an agent. |
| `aal_choiceoverride_agent_context` | `string aal_choiceoverride_agent_context(string page_text)` | SOURCE 39: Choice-Override | PURE | Build compact choice context from page text without visiting or submitting choice.php. |
| `aal_consume_agent_context` | `string aal_consume_agent_context(int value_of_adventure)` | SOURCE 21: Consume | READ_ONLY | Build compact organ/value context for a consumption planner. |
| `aal_dics_agent_context` | `string aal_dics_agent_context(item[int] items, int max_entries, int fresh_days, float multiplier)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Build bounded item/value context inspired by DicsLibrary's broad utility role. |
| `aal_dics_item_context` | `string aal_dics_item_context(item it, int fresh_days, float multiplier)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Build compact ownership/valuation context for one item. |
| `aal_ezeco_advice_budget` | `string aal_ezeco_advice_budget(string[int] advisory_lines, int max_entries)` | SOURCE 04: Ezandora repository ecosystem | PURE | Cap a potentially large advisory list for context-budget-aware agent use. |
| `aal_ezeco_agent_context` | `string aal_ezeco_agent_context(string section_name, string[int] current_tasks, string[int] resources, int max_each)` | SOURCE 04: Ezandora repository ecosystem | PURE | Build a Guide-inspired compact tasks/resources section for an LLM. |
| `aal_functionlib_agent_context` | `string aal_functionlib_agent_context(item it, familiar fam, skill s)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Build compact utility context combining ownership, familiar, and skill readiness. |
| `aal_gain_agent_context` | `string aal_gain_agent_context(string modifier_name, float target, int max_effects)` | SOURCE 19: Ezandora Gain | READ_ONLY | Build bounded context of current modifier and active effects contributing to it. |
| `aal_guide_advisory_merge` | `string aal_guide_advisory_merge(string[int] mandatory, string[int] optional, string[int] future, int max_each)` | SOURCE 18: Guide | PURE | Merge Guide-like task lanes into bounded labeled context. |
| `aal_guide_agent_context` | `string aal_guide_agent_context(string[int] quest_properties, int max_entries)` | SOURCE 18: Guide | READ_ONLY | Build compact quest-preference context using Guide's advisory orientation. |
| `aal_hccs_pretest_context` | `string aal_hccs_pretest_context(string test_name, string modifier_name, int predicted_turns, int allowed_turns)` | SOURCE 06: c2t_hccs | READ_ONLY | Build compact pre-test context with modifier state, health, and threshold. |
| `aal_helper_agent_context` | `string aal_helper_agent_context(string goal)` | SOURCE 34: helper.ash | READ_ONLY | Build compact ascension-helper context around pulls, fax/yellow-ray and basic resources. |
| `aal_htmlform_agent_context` | `string aal_htmlform_agent_context(string[string] fields, int max_entries)` | SOURCE 28: htmlform.ash | PURE | Serialize submitted form fields with deterministic key ordering and bounded size. |
| `aal_iron_scripts_agent_context` | `string aal_iron_scripts_agent_context(string source_name, string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Build a compact migration context for an agent reviewing historical IronTetsubo scripts. |
| `aal_liba_micro_context` | `string aal_liba_micro_context(string label, string[int] preference_names, item[int] items)` | SOURCE 30: liba | READ_ONLY | Compose tiny reusable preference/item context in the spirit of liba's focused modules. |
| `aal_liba_resource_module_context` | `string aal_liba_resource_module_context(item key_item, string[int] preference_names)` | SOURCE 30: liba | READ_ONLY | Build generic context for one of liba's resource-specific IOTM modules. |
| `aal_lowerstats_agent_context` | `string aal_lowerstats_agent_context(int cap)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Build compact all-stat state plus relevant source-inspired negative effects for an agent. |
| `aal_networth_agent_context` | `string aal_networth_agent_context(boolean include_storage, int max_historical_age, int historical_cap)` | SOURCE 22: networth.ash | READ_ONLY | Build compact valuation policy/current-total context. |
| `aal_ocd_agent_context` | `string aal_ocd_agent_context(item[int] items, string[item] actions, int[item] keep_amounts, int max_entries)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | Build bounded disposition context for policy review before execution. |
| `aal_ploop_reentry_context` | `string aal_ploop_reentry_context(string event_list)` | SOURCE 08: pLooper | READ_ONLY | Describe current loop re-entry position without executing a phase. |
| `aal_profit_agent_context` | `string aal_profit_agent_context(agent_value_snapshot snap)` | SOURCE 13: ProfitTracking.ash | PURE | Serialize a profit snapshot as compact key=value state. |
| `aal_profit_top_inventory_context` | `string aal_profit_top_inventory_context(int min_unit_value, int max_entries, int max_historical_age)` | SOURCE 13: ProfitTracking.ash | READ_ONLY | Emit bounded valuable-item context without logging to disk. |
| `aal_ptrack_agent_context` | `string aal_ptrack_agent_context(string event_list, agent_breakpoint latest)` | SOURCE 09: pTrack repository | PURE | Build compact tracker state for an LLM deciding what interval to compare next. |
| `aal_ptrack_rate_context` | `string aal_ptrack_rate_context(agent_breakpoint before, agent_breakpoint after)` | SOURCE 09: pTrack repository | PURE | Build compact interval-rate context for an agent interpreting pTrack data. |
| `aal_ptrackcli_agent_context` | `string aal_ptrackcli_agent_context(string event_list, string stored_date)` | SOURCE 15: ptrack.ash | READ_ONLY | Build compact user-facing tracker orchestration context. |
| `aal_pupdates_agent_context` | `string aal_pupdates_agent_context(string[int] scripts, int[int] current_versions)` | SOURCE 10: pUpdates repository | READ_ONLY | Build compact multi-script update state without acknowledging any update. |
| `aal_pupdateslog_agent_context` | `string aal_pupdateslog_agent_context(string script_name, string[int] update_lines, int seen_version, int max_entries)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Build compact unseen-changelog context without reading/writing preferences. |
| `aal_pwrapper_agent_context` | `string aal_pwrapper_agent_context(int attempt, int max_attempts, string event_list)` | SOURCE 12: pwrapper | READ_ONLY | Build compact wrapper/recovery context for an agent deciding whether to retry. |
| `aal_quest_agent_context` | `string aal_quest_agent_context(string[int] quest_properties, int max_entries)` | SOURCE 35: QuestLib.ash | READ_ONLY | Build bounded quest-state context without invoking old mood/gear automation. |
| `aal_rollover_agent_context` | `string aal_rollover_agent_context(int expected_rollover_mp)` | SOURCE 23: rollover.ash | READ_ONLY | Build compact rollover state for an agent/user reminder surface. |
| `aal_select2_agent_context` | `string aal_select2_agent_context(agent_option[int] options, string query, int max_entries)` | SOURCE 27: insertSelect2-relays | PURE | Build compact searchable option context for an agent choosing a relay value. |
| `aal_sims_agent_context` | `string aal_sims_agent_context(familiar[int] candidates, string goal, int combat_bias)` | SOURCE 36: sims_lib.ash | READ_ONLY | Build compact familiar recommendation context without switching familiars. |
| `aal_smash_agent_context` | `string aal_smash_agent_context(item it)` | SOURCE 33: SmashLib.ash | READ_ONLY | Build compact pulverization context without loading old data maps or smashing. |
| `aal_stash_agent_context` | `string aal_stash_agent_context(int[item] expected, int max_entries)` | SOURCE 17: pStash | READ_ONLY | Build compact stash health context centered on deficits/surpluses. |
| `aal_testout_agent_context` | `string aal_testout_agent_context(agent_diagnostic[int] results)` | SOURCE 24: testout.ash | PURE | Build concise machine-readable test context. |
| `aal_time_agent_context` | `string aal_time_agent_context(string from_event, string to_event, int turns, int elapsed_ms)` | SOURCE 14: TimeTracking.ash | PURE | Build compact timing/throughput context for an agent. |
| `aal_twisted_source_context` | `string aal_twisted_source_context(string source_name, string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Build a compact static-analysis context for an agent modernizing a twistedmage-era script. |
| `aal_zlib_agent_context` | `string aal_zlib_agent_context(string[string] setting_values, int max_entries)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Build bounded deterministic setting context from a ZLib-like settings map. |
| `aal_zman_agent_context` | `string aal_zman_agent_context(string[string] values, string[string] docs, string query, int max_entries)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Build bounded searchable setting context for agent-assisted configuration. |

## Math

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_liba_clamp_normalized` | `float aal_liba_clamp_normalized(float value, float low, float high)` | SOURCE 30: liba | PURE | Clamp while safely normalizing reversed bounds. |
| `aal_zlib_clamp` | `float aal_zlib_clamp(float value, float low, float high)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Clamp value with normalized lower/upper bounds. |

## Modifiers

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_astrogain_modifier_names` | `string aal_astrogain_modifier_names(effect e)` | SOURCE 20: Astro3207 Gain | READ_ONLY | Parse an effect's Modifiers string into normalized modifier names. |
| `aal_astrogain_percentage_stat_value` | `float aal_astrogain_percentage_stat_value(effect e, stat s)` | SOURCE 20: Astro3207 Gain | READ_ONLY | Combine flat and percent stat modifiers against current base stat for planning. |
| `aal_gain_effect_modifier` | `float aal_gain_effect_modifier(effect e, string modifier_name)` | SOURCE 19: Ezandora Gain | READ_ONLY | Read one effect's contribution to a modifier. |
| `aal_gain_modifier_state` | `agent_modifier_state aal_gain_modifier_state(string modifier_name, float target)` | SOURCE 19: Ezandora Gain | READ_ONLY | Capture current modifier value and target gap. |

## Normalization

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ascend_config_value` | `string aal_ascend_config_value(string csv, int index)` | SOURCE 07: c2t_ascend | PURE | Safely read an indexed value from a comma-delimited ascension configuration. |
| `aal_c2eco_dependency_lines` | `string aal_c2eco_dependency_lines(string dependencies_text)` | SOURCE 01: C2Talon repository ecosystem | PURE | Normalize dependencies.txt-style content into deterministic dependency lines without comments/blank rows. |
| `aal_c2lib_maximize_key` | `string aal_c2lib_maximize_key(string maximizer_expression)` | SOURCE 32: c2t_lib | PURE | Normalize a maximizer expression into a lightweight cache-comparison key. |
| `aal_c2lib_pilcrow_items` | `string aal_c2lib_pilcrow_items(string maximizer_expression)` | SOURCE 32: c2t_lib | PURE | Decode pilcrow item tokens from a maximizer expression into typed item rows for troubleshooting. |
| `aal_choiceoverride_script_base` | `string aal_choiceoverride_script_base(int choice_id)` | SOURCE 39: Choice-Override | PURE | Generate the canonical override script basename for a choice. |
| `aal_ezeco_advice_dedupe` | `string aal_ezeco_advice_dedupe(string[int] advisory_lines)` | SOURCE 04: Ezandora repository ecosystem | PURE | De-duplicate Guide-like advisory lines while retaining deterministic lexical order. |
| `aal_hccs_thresholds_parse` | `string aal_hccs_thresholds_parse(string thresholds_csv)` | SOURCE 06: c2t_hccs | PURE | Normalize ten Community Service threshold values into indexed TSV. |
| `aal_htmlform_bool_normalize` | `boolean aal_htmlform_bool_normalize(string value)` | SOURCE 28: htmlform.ash | PURE | Normalize common form boolean encodings. |
| `aal_ptrack_checkpoint_key` | `string aal_ptrack_checkpoint_key(string date, string event)` | SOURCE 09: pTrack repository | PURE | Create an unambiguous breakpoint key from date and event. |
| `aal_ptrack_event_list_normalize` | `string aal_ptrack_event_list_normalize(string event_list)` | SOURCE 09: pTrack repository | PURE | De-duplicate a comma-delimited breakpoint list while preserving stable lexical output. |
| `aal_ptrackcli_parse_breakpoints` | `string aal_ptrackcli_parse_breakpoints(string event_list)` | SOURCE 15: ptrack.ash | PURE | Normalize the pTrack breakpoint property into one event per line. |
| `aal_pupdates_property_name` | `string aal_pupdates_property_name(string script_name)` | SOURCE 10: pUpdates repository | PURE | Generate the canonical local-version preference name used by pUpdates. |
| `aal_pupdates_update_key` | `string aal_pupdates_update_key(string script_name, int version)` | SOURCE 10: pUpdates repository | PURE | Create a stable key for one script/version update entry. |
| `aal_select2_query_tokens` | `string aal_select2_query_tokens(string query)` | SOURCE 27: insertSelect2-relays | PURE | Normalize whitespace-separated query tokens for relay search. |
| `aal_zlib_list_unique` | `string aal_zlib_list_unique(string list_text, string glue)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | De-duplicate a delimited list using deterministic lexical output. |
| `aal_zlib_normalize_bool` | `string aal_zlib_normalize_bool(string value)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Normalize boolean-like setting text to canonical true/false. |
| `aal_zlib_normalize_int` | `string aal_zlib_normalize_int(string value)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Normalize integer setting text. |
| `aal_zlib_normalize_item` | `string aal_zlib_normalize_item(string value)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Normalize item setting text through KoLmafia's typed item parser. |

## Planning

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ascend_karma_budget` | `agent_range_state aal_ascend_karma_budget(int planned_perm_cost)` | SOURCE 07: c2t_ascend | READ_ONLY | Compare banked karma with planned perm expenditure. |
| `aal_ascend_perm_candidates` | `string aal_ascend_perm_candidates(skill[int] skills, int max_entries)` | SOURCE 07: c2t_ascend | READ_ONLY | Filter caller-supplied perm candidates to skills actually known by the character. |
| `aal_ascend_post_script_preview` | `agent_action_preview aal_ascend_post_script_preview(string command_text)` | SOURCE 07: c2t_ascend | PURE | Describe the configured post-ascension command without executing it. |
| `aal_astrogain_combat_rate_softcap` | `float aal_astrogain_combat_rate_softcap(float current, float raw_delta)` | SOURCE 20: Astro3207 Gain | PURE | Approximate Gain-style combat-rate soft-cap conversion for simulation. |
| `aal_batbrain_action_preview` | `agent_action_preview aal_batbrain_action_preview(string action_label, int expected_damage, int mp_cost_value, int value_cost)` | SOURCE 29: BatBrain.ash | READ_ONLY | Create a non-mutating combat action preview with HP/MP/value checks. |
| `aal_bootstrap_missing_steps` | `string aal_bootstrap_missing_steps()` | SOURCE 25: bootstrap.ash | READ_ONLY | List obvious remaining bootstrap targets without executing them. |
| `aal_bootstrap_pull_need` | `int aal_bootstrap_pull_need(item it, int required)` | SOURCE 25: bootstrap.ash | READ_ONLY | Calculate how many copies would need to be pulled from storage to meet a bootstrap requirement. |
| `aal_bootstrap_use_preview` | `agent_action_preview aal_bootstrap_use_preview(item it)` | SOURCE 25: bootstrap.ash | READ_ONLY | Preview whether a starter item is currently in inventory for use. |
| `aal_c2lib_purchase_budget` | `agent_action_preview aal_c2lib_purchase_budget(item it, int quantity, int max_unit_price)` | SOURCE 32: c2t_lib | READ_ONLY | Estimate mall cost/budget fit without invoking c2t_buy. |
| `aal_c2scripts_cast_resource_preview` | `agent_action_preview aal_c2scripts_cast_resource_preview(skill s, int casts)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Preview MP and skill-availability requirements for repeated casting without casting. |
| `aal_checklist_missing_value` | `int aal_checklist_missing_value(item[int] items)` | SOURCE 16: pChecklist | READ_ONLY | Estimate mall acquisition value of currently missing tradeable checklist items without buying them. |
| `aal_choiceoverride_handler_candidates` | `string aal_choiceoverride_handler_candidates(int choice_id)` | SOURCE 39: Choice-Override | PURE | Return exact ASH/JS handler candidates plus fallback names in lookup order. |
| `aal_choiceoverride_route_preview` | `string aal_choiceoverride_route_preview(string page_text, boolean specific_handler_exists, boolean fallback_handler_exists)` | SOURCE 39: Choice-Override | PURE | Describe Choice-Override routing decision without dispatching a script. |
| `aal_consume_candidate_density` | `float aal_consume_candidate_density(agent_consumption_candidate c, int value_of_adventure)` | SOURCE 21: Consume | PURE | Estimate net value per organ point. |
| `aal_consume_candidate_value` | `float aal_consume_candidate_value(agent_consumption_candidate c, int value_of_adventure)` | SOURCE 21: Consume | PURE | Estimate net adventure value after purchase cost. |
| `aal_dics_stock_reorder` | `int aal_dics_stock_reorder(item it, int target_amount)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Calculate reorder quantity to reach a target personal stock. |
| `aal_ezeco_future_task_state` | `agent_check aal_ezeco_future_task_state(string unlock_property, string complete_property)` | SOURCE 04: Ezandora repository ecosystem | READ_ONLY | Describe future-task eligibility from explicit unlock/completion preferences. |
| `aal_ezeco_task_priority` | `int aal_ezeco_task_priority(boolean mandatory, boolean available_now, int turns_until_relevant)` | SOURCE 04: Ezandora repository ecosystem | PURE | Calculate a stable task-priority signal inspired by Guide task/resource/future-task separation. |
| `aal_functionlib_acquisition_gap` | `string aal_functionlib_acquisition_gap(item it, int desired)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Compute inventory shortfall and nearby source counts without acquiring anything. |
| `aal_functionlib_stash_transfer_preview` | `agent_action_preview aal_functionlib_stash_transfer_preview(string direction, item it, int quantity)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Preview a stash take/put operation and available quantity without moving items. |
| `aal_gain_candidate_score` | `float aal_gain_candidate_score(float modifier_gain, int turns, int cost)` | SOURCE 19: Ezandora Gain | PURE | Score a modifier source by gain-turns per meat; higher is better. |
| `aal_gain_simulate_additive` | `float aal_gain_simulate_additive(string modifier_name, float additional_value)` | SOURCE 19: Ezandora Gain | READ_ONLY | Compute a simple non-mutating additive modifier simulation. |
| `aal_guide_future_task` | `agent_check aal_guide_future_task(string title, boolean unlocked, boolean completed, string prerequisite)` | SOURCE 18: Guide | PURE | Represent future/optional task state without executing it. |
| `aal_guide_location_task` | `agent_plan aal_guide_location_task(location loc, string title)` | SOURCE 18: Guide | READ_ONLY | Describe whether a location-based task is currently actionable. |
| `aal_hccs_stop_reason` | `string aal_hccs_stop_reason(int predicted_turns, int allowed_turns, boolean resource_ready, boolean health_ready)` | SOURCE 06: c2t_hccs | PURE | Explain whether an HCCS agent should stop before a test without performing it. |
| `aal_helper_consumable_pull_context` | `string aal_helper_consumable_pull_context(item[int] candidates, int max_entries)` | SOURCE 34: helper.ash | READ_ONLY | List missing candidate consumables with storage counts/mall prices for pull decisions. |
| `aal_helper_pull_need_score` | `int aal_helper_pull_need_score(item it, int target_quantity, int strategic_weight)` | SOURCE 34: helper.ash | READ_ONLY | Score a potential pull by ownership gap times caller strategic weight. |
| `aal_iron_scripts_modernization_pressure` | `int aal_iron_scripts_modernization_pressure(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Combine parsing, command, network, and direct-page indicators into one modernization pressure metric. |
| `aal_iron_scripts_read_plan_split` | `string aal_iron_scripts_read_plan_split(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Suggest explicit read/plan/execute split points based on legacy primitives found. |
| `aal_liba_property_increment_preview` | `agent_delta aal_liba_property_increment_preview(string property_name, int delta)` | SOURCE 30: liba | READ_ONLY | Preview integer preference increment without writing it. |
| `aal_lowerstats_budget_preview` | `agent_action_preview aal_lowerstats_budget_preview(item it, int max_price)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Compare a stat-lowering item's mall price with a caller budget without buying it. |
| `aal_lowerstats_item_option` | `string aal_lowerstats_item_option(stat s)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Describe source-inspired low-stat consumable/item options without acquiring or using them. |
| `aal_lowerstats_plan` | `string aal_lowerstats_plan(stat s, int cap)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Build a compact read-only stat-lowering plan for one stat. |
| `aal_lowerstats_shrug_candidates` | `string aal_lowerstats_shrug_candidates(stat s, int cap, int max_entries)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | List active positive-stat effects that are plausible shrug candidates under the source's protection rules. |
| `aal_ocd_disposition_preview` | `agent_action_preview aal_ocd_disposition_preview(item it, string action, int keep_amount)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | Preview quantity and action for an OCD-style inventory rule. |
| `aal_ploop_next_phase` | `string aal_ploop_next_phase(string event_list)` | SOURCE 08: pLooper | PURE | Choose the next canonical pLooper-inspired phase from observed breakpoint history. |
| `aal_ploop_phase_preview` | `string aal_ploop_phase_preview(string event_list, string configured_ascend_command)` | SOURCE 08: pLooper | READ_ONLY | Describe the next loop phase and relevant state without executing it. |
| `aal_ptrack_adjacent_pairs` | `string aal_ptrack_adjacent_pairs(string event_list)` | SOURCE 09: pTrack repository | PURE | Turn a breakpoint list into adjacent comparison pairs. |
| `aal_ptrackcli_compare_plan` | `string aal_ptrackcli_compare_plan(string event_list)` | SOURCE 15: ptrack.ash | PURE | Generate all adjacent comparison pairs from the current breakpoint order. |
| `aal_ptrackcli_next_breakpoint` | `string aal_ptrackcli_next_breakpoint(string event_list, string[int] expected_order)` | SOURCE 15: ptrack.ash | PURE | Return first expected breakpoint not yet present. |
| `aal_pupdates_pending_range` | `string aal_pupdates_pending_range(string script_name, int current_version)` | SOURCE 10: pUpdates repository | READ_ONLY | Describe inclusive unseen changelog version range. |
| `aal_pupdates_update_preview` | `agent_action_preview aal_pupdates_update_preview(string script_name, int current_version)` | SOURCE 10: pUpdates repository | READ_ONLY | Build a non-mutating update-check preview. |
| `aal_pwrapper_retry_decision` | `string aal_pwrapper_retry_decision(int attempt, int max_attempts, boolean completed, boolean safe_state)` | SOURCE 12: pwrapper | PURE | Return the next wrapper action without executing it. |
| `aal_quest_combat_rate_goal` | `string aal_quest_combat_rate_goal(string mode)` | SOURCE 35: QuestLib.ash | PURE | Translate legacy request_combat/request_noncombat intent into a descriptive maximizer goal. |
| `aal_quest_resource_gap` | `agent_delta aal_quest_resource_gap(item it, int required)` | SOURCE 35: QuestLib.ash | READ_ONLY | Measure quest-item shortfall across available amount. |
| `aal_rollover_readiness_score` | `int aal_rollover_readiness_score(int expected_rollover_mp)` | SOURCE 23: rollover.ash | READ_ONLY | Compute a simple reminder pressure score from organ gaps, MP waste, stills, and pulls. |
| `aal_rollover_warning_lines` | `string aal_rollover_warning_lines(int expected_rollover_mp)` | SOURCE 23: rollover.ash | READ_ONLY | Build deterministic rollover warnings without changing equipment/resources. |
| `aal_sims_goal_candidates` | `string aal_sims_goal_candidates(familiar[int] candidates, string goal, int combat_bias, int max_entries)` | SOURCE 36: sims_lib.ash | READ_ONLY | Emit bounded familiar candidate evidence in caller order. |
| `aal_stash_reconcile_plan` | `string aal_stash_reconcile_plan(int[item] expected, int[item] personal_baseline, int max_entries)` | SOURCE 17: pStash | READ_ONLY | Build bounded reconciliation recommendations without moving stash items. |
| `aal_stash_return_preview` | `agent_action_preview aal_stash_return_preview(item it, int expected, int personal_owned)` | SOURCE 17: pStash | READ_ONLY | Preview how many inventory copies could be returned without crossing a personal-ownership protection floor. |
| `aal_twisted_import_depth_hint` | `int aal_twisted_import_depth_hint(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Estimate dependency pressure from import count and nested executor usage. |
| `aal_twisted_modernization_todo` | `string aal_twisted_modernization_todo(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Create a deterministic modernization checklist based on patterns actually present. |
| `aal_zman_change_preview` | `agent_plan aal_zman_change_preview(string name, string old_value, string new_value, string kind)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Validate and preview one settings edit without writing files/properties. |
| `aal_zman_delete_preview` | `agent_plan aal_zman_delete_preview(string name, boolean confirmed)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Represent queued variable deletion explicitly before persistence. |
| `aal_zman_save_plan` | `string aal_zman_save_plan(string[string] old_values, string[string] new_values, string[string] types)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Generate only changed, valid setting rows for a save operation. |

## Player

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_lowerstats_pressure` | `agent_range_state aal_lowerstats_pressure(stat s, int cap)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Measure how far a buffed stat exceeds a desired cap. |
| `aal_ploop_organ_snapshot` | `agent_organ_state aal_ploop_organ_snapshot()` | SOURCE 08: pLooper | READ_ONLY | Capture organs for phase-boundary planning. |

## Properties

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_dics_pref_int` | `int aal_dics_pref_int(string property_name, int default_value)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Read an integer preference with explicit default for missing/empty values. |

## Query

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2eco_dependency_count` | `int aal_c2eco_dependency_count(string dependencies_text)` | SOURCE 01: C2Talon repository ecosystem | PURE | Count unique non-comment dependency declarations in a dependencies file. |
| `aal_c2eco_library_candidates` | `string aal_c2eco_library_candidates(string[int] repo_names)` | SOURCE 01: C2Talon repository ecosystem | PURE | Extract likely reusable library repositories from a mixed account repository list. |
| `aal_c2eco_select_repos_for_task` | `string aal_c2eco_select_repos_for_task(string[int] repo_names, string task_text)` | SOURCE 01: C2Talon repository ecosystem | PURE | Select ecosystem repositories whose names/roles plausibly match a task description. |
| `aal_ezeco_advice_filter` | `string aal_ezeco_advice_filter(string[int] advisory_lines, string query)` | SOURCE 04: Ezandora repository ecosystem | PURE | Filter advisory lines case-insensitively for an agent/user query. |
| `aal_guide_task_filter` | `string aal_guide_task_filter(string[int] tasks, string query, int max_entries)` | SOURCE 18: Guide | PURE | Filter/bound task text for a user or LLM query. |
| `aal_hccs_threshold_for` | `int aal_hccs_threshold_for(string thresholds_csv, int test_index)` | SOURCE 06: c2t_hccs | PURE | Read one test threshold safely from the configured ten-value CSV. |
| `aal_liba_tokens_all_present` | `boolean aal_liba_tokens_all_present(string haystack, string[int] tokens)` | SOURCE 30: liba | PURE | Check that every non-empty token occurs case-insensitively in text. |
| `aal_ploop_breakpoint_seen` | `boolean aal_ploop_breakpoint_seen(string event_list, string breakpoint)` | SOURCE 08: pLooper | PURE | Check exact breakpoint membership in a comma-delimited event list. |
| `aal_ptrackcli_breakpoint_count` | `int aal_ptrackcli_breakpoint_count(string event_list)` | SOURCE 15: ptrack.ash | PURE | Count non-empty breakpoints in an event-list property. |
| `aal_ptrackcli_breakpoint_exists` | `boolean aal_ptrackcli_breakpoint_exists(string event_list, string name)` | SOURCE 15: ptrack.ash | PURE | Test exact breakpoint membership. |
| `aal_pupdateslog_search` | `string aal_pupdateslog_search(string[int] update_lines, string query, int max_entries)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Search changelog entries case-insensitively. |
| `aal_select2_all_tokens_match` | `boolean aal_select2_all_tokens_match(agent_option o, string query)` | SOURCE 27: insertSelect2-relays | PURE | Require every normalized query token to appear in option value or label. |
| `aal_select2_match_score` | `int aal_select2_match_score(agent_option o, string query)` | SOURCE 27: insertSelect2-relays | PURE | Score an option against a case-insensitive query using exact/prefix/substring matches. |
| `aal_zlib_list_contains_exact` | `boolean aal_zlib_list_contains_exact(string list_text, string needle, string glue)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Perform exact case-insensitive membership check over a delimited list. |
| `aal_zman_filter_match` | `boolean aal_zman_filter_match(string setting_name, string documentation, string query)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Filter settings by name or documentation, not name alone. |
| `aal_zman_group_settings` | `string aal_zman_group_settings(string[string] scripts_for_setting, string script_filter)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | List setting names associated with a script tag. |

## Quests

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_guide_quest_property` | `string aal_guide_quest_property(string quest_property)` | SOURCE 18: Guide | READ_ONLY | Expose one KoLmafia quest preference in normalized lowercase form. |
| `aal_quest_progress_rank` | `int aal_quest_progress_rank(string quest_state)` | SOURCE 35: QuestLib.ash | PURE | Convert common quest states into a coarse monotonic progress rank. |
| `aal_quest_property_state` | `string aal_quest_property_state(string quest_property)` | SOURCE 35: QuestLib.ash | READ_ONLY | Return normalized KoLmafia quest preference text. |

## Recovery

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_dics_recovery_state` | `string aal_dics_recovery_state()` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Expose HP/MP recovery targets and current state. |
| `aal_functionlib_recovery_gap` | `string aal_functionlib_recovery_gap(int target_hp)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Measure HP recovery gap and Beaten Up state without recovering. |
| `aal_hccs_recovery_state` | `string aal_hccs_recovery_state()` | SOURCE 06: c2t_hccs | READ_ONLY | Expose non-mutating HP/MP/beaten-up state relevant to c2t_hccs recovery. |

## Relay / UI

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_htmlform_escape` | `string aal_htmlform_escape(string value)` | SOURCE 28: htmlform.ash | PURE | Escape basic HTML-sensitive characters for form output. |
| `aal_select2_filter` | `string aal_select2_filter(agent_option[int] options, string query, int max_entries)` | SOURCE 27: insertSelect2-relays | PURE | Filter select options into deterministic TSV rows for search/autocomplete. |
| `aal_select2_option` | `agent_option aal_select2_option(string value, string label, boolean selected, boolean enabled)` | SOURCE 27: insertSelect2-relays | PURE | Create a normalized searchable select option record. |
| `aal_select2_selected_value` | `string aal_select2_selected_value(agent_option[int] options)` | SOURCE 27: insertSelect2-relays | PURE | Return the first selected enabled option value. |
| `aal_zman_field_kind` | `string aal_zman_field_kind(string value)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Infer a simple editor control kind from persisted setting text. |

## Resources

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2scripts_cold_medicine_state` | `string aal_c2scripts_cold_medicine_state()` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Summarize Cold Medicine Cabinet consultation state from tracked preferences. |
| `aal_ezeco_resource_remaining` | `agent_resource_state aal_ezeco_resource_remaining(string used_property, int limit_value)` | SOURCE 04: Ezandora repository ecosystem | READ_ONLY | Return remaining uses for a preference-backed daily resource. |
| `aal_guide_resource_from_property` | `agent_resource_state aal_guide_resource_from_property(string label, string used_property, int limit_value)` | SOURCE 18: Guide | READ_ONLY | Convert a Guide-like daily counter into a structured remaining-resource record. |
| `aal_hccs_resource_budget` | `agent_resource_state aal_hccs_resource_budget(string used_property, int cap)` | SOURCE 06: c2t_hccs | READ_ONLY | Describe a daily resource budget for a Community Service preparation step. |
| `aal_rollover_daily_resource` | `agent_resource_state aal_rollover_daily_resource(string label, string used_property, int limit_value)` | SOURCE 23: rollover.ash | READ_ONLY | Normalize a rollover-relevant daily preference into remaining-use state. |
| `aal_rollover_pull_state` | `agent_resource_state aal_rollover_pull_state()` | SOURCE 23: rollover.ash | READ_ONLY | Expose remaining pulls as rollover context. |
| `aal_rollover_still_state` | `agent_resource_state aal_rollover_still_state()` | SOURCE 23: rollover.ash | READ_ONLY | Expose remaining still uses as a rollover resource. |

## Rollover

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_rollover_mp_waste` | `int aal_rollover_mp_waste(int expected_rollover_mp)` | SOURCE 23: rollover.ash | READ_ONLY | Estimate rollover MP that would exceed current maximum MP. |
| `aal_rollover_organ_gaps` | `string aal_rollover_organ_gaps()` | SOURCE 23: rollover.ash | READ_ONLY | Serialize unused organ capacity before rollover. |

## Serialization

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ascend_resource_snapshot` | `string aal_ascend_resource_snapshot()` | SOURCE 07: c2t_ascend | READ_ONLY | Serialize compact pre-ascension currencies/resources useful for planning. |
| `aal_astrogain_source_rank_line` | `string aal_astrogain_source_rank_line(string source_name, float efficiency, float modifier_value, int turns)` | SOURCE 20: Astro3207 Gain | PURE | Serialize a modifier-source ranking row for external sorting/LLM consumption. |
| `aal_bootstrap_step_status` | `string aal_bootstrap_step_status(string step_name, boolean complete, string evidence)` | SOURCE 25: bootstrap.ash | PURE | Serialize one bootstrap step and its evidence. |
| `aal_c2eco_repo_manifest` | `string aal_c2eco_repo_manifest(string[int] repo_names)` | SOURCE 01: C2Talon repository ecosystem | PURE | Normalize a repository-name list into stable one-name-per-line manifest text. |
| `aal_c2scripts_tracker_fingerprint` | `string aal_c2scripts_tracker_fingerprint(string[int] preference_names)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Serialize a caller-selected tracker preference set in stable lexical order. |
| `aal_checklist_status_tsv` | `string aal_checklist_status_tsv(item[int] items, int max_entries)` | SOURCE 16: pChecklist | READ_ONLY | Serialize checklist item status in deterministic input order. |
| `aal_choiceoverride_decode_payload` | `string aal_choiceoverride_decode_payload(string encoded)` | SOURCE 39: Choice-Override | PURE | Decode a Choice-Override-style page payload. |
| `aal_choiceoverride_encode_payload` | `string aal_choiceoverride_encode_payload(string page_text)` | SOURCE 39: Choice-Override | PURE | URL-encode choice page text for safe argument transport, mirroring the source's transport idea. |
| `aal_consume_plan_line` | `string aal_consume_plan_line(agent_consumption_candidate c, string organ_name, int value_of_adventure)` | SOURCE 21: Consume | READ_ONLY | Serialize a candidate's fit and economic density for planner/agent sorting. |
| `aal_dics_pref_snapshot` | `string aal_dics_pref_snapshot(string[int] property_names, int max_entries)` | SOURCE 38: DicsLibrary.ash | READ_ONLY | Serialize a bounded caller-selected preference set as deterministic key=value context. |
| `aal_ezeco_advisory_entry` | `string aal_ezeco_advisory_entry(string title, string url, string[int] details)` | SOURCE 04: Ezandora repository ecosystem | PURE | Serialize one Guide-like advisory entry as compact deterministic text. |
| `aal_guide_resource_line` | `string aal_guide_resource_line(string title, int remaining, string url)` | SOURCE 18: Guide | PURE | Serialize a Guide-inspired daily-resource entry. |
| `aal_guide_task_line` | `string aal_guide_task_line(string title, string status, string url, int priority)` | SOURCE 18: Guide | PURE | Serialize a Guide-inspired task entry for machine consumption. |
| `aal_hccs_property_snapshot` | `string aal_hccs_property_snapshot(string[int] names)` | SOURCE 06: c2t_hccs | READ_ONLY | Serialize selected HCCS configuration/preferences deterministically. |
| `aal_htmlform_change_line` | `string aal_htmlform_change_line(string name, string old_value, string submitted_value)` | SOURCE 28: htmlform.ash | PURE | Serialize a proposed form change without applying it. |
| `aal_htmlform_field_schema` | `string aal_htmlform_field_schema(string name, string type_name, string default_value, string description)` | SOURCE 28: htmlform.ash | PURE | Serialize a form field schema for human/agent tooling. |
| `aal_iron_scripts_import_manifest` | `string aal_iron_scripts_import_manifest(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Extract legacy imports for migration dependency auditing. |
| `aal_iron_scripts_property_manifest` | `string aal_iron_scripts_property_manifest(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Extract quoted properties referenced by get_property/set_property. |
| `aal_lowerstats_all_pressure` | `string aal_lowerstats_all_pressure(int cap)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Serialize over-cap pressure for all three stats. |
| `aal_networth_item_line` | `string aal_networth_item_line(item it, boolean include_storage, int max_historical_age, int historical_cap)` | SOURCE 22: networth.ash | READ_ONLY | Serialize one item's net-worth contribution. |
| `aal_ocd_rule_line` | `string aal_ocd_rule_line(item it, string action, int keep_amount)` | SOURCE 26: OCD Inventory Control.ash | READ_ONLY | Serialize rule plus current ownership/excess as TSV. |
| `aal_ptrackcli_summary` | `string aal_ptrackcli_summary(string event_list)` | SOURCE 15: ptrack.ash | PURE | Serialize breakpoint-list health and endpoints. |
| `aal_pupdates_status_line` | `string aal_pupdates_status_line(string script_name, int current_version)` | SOURCE 10: pUpdates repository | READ_ONLY | Serialize one update status as TSV. |
| `aal_pupdateslog_tsv` | `string aal_pupdateslog_tsv(string script_name, string[int] update_lines)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Serialize an entire changelog as versioned TSV. |
| `aal_pwrapper_log_line` | `string aal_pwrapper_log_line(int attempt, string error_message, string last_encounter, string last_result)` | SOURCE 12: pwrapper | PURE | Serialize one retry failure as a compact deterministic log line. |
| `aal_quest_plan_line` | `string aal_quest_plan_line(string quest_property, location loc, item required_item)` | SOURCE 35: QuestLib.ash | READ_ONLY | Serialize one quest planning row from preference, location and item state. |
| `aal_select2_option_tsv` | `string aal_select2_option_tsv(agent_option o)` | SOURCE 27: insertSelect2-relays | PURE | Serialize one select option. |
| `aal_sims_familiar_line` | `string aal_sims_familiar_line(familiar fam, string goal, int combat_bias)` | SOURCE 36: sims_lib.ash | READ_ONLY | Serialize familiar recommendation evidence. |
| `aal_smash_plan_line` | `string aal_smash_plan_line(item it, int estimated_yield_value)` | SOURCE 33: SmashLib.ash | READ_ONLY | Serialize one smash candidate with economic risk context. |
| `aal_stash_map_summary` | `string aal_stash_map_summary(int[item] expected)` | SOURCE 17: pStash | READ_ONLY | Serialize expected/actual/delta for a tracked stash map. |
| `aal_testout_line` | `string aal_testout_line(agent_diagnostic d)` | SOURCE 24: testout.ash | PURE | Serialize a diagnostic in compact TSV form. |
| `aal_time_breakpoint_line` | `string aal_time_breakpoint_line(string date, string event, int stamp)` | SOURCE 14: TimeTracking.ash | PURE | Serialize one time breakpoint as TSV. |
| `aal_time_format_duration` | `string aal_time_format_duration(int elapsed_ms)` | SOURCE 14: TimeTracking.ash | PURE | Format a millisecond duration as deterministic HH:MM:SS. |
| `aal_zlib_setting_schema_line` | `string aal_zlib_setting_schema_line(string name, string type_name, string default_value, string documentation)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Serialize a typed setting schema row for modern agent/UI consumption. |
| `aal_zman_schema_tsv` | `string aal_zman_schema_tsv(string[string] values, string[string] types, string[string] docs)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Serialize editable settings schema/value/doc rows. |

## Skills

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_functionlib_skill_preflight` | `agent_check aal_functionlib_skill_preflight(skill s, int casts)` | SOURCE 31: FunctionLib.ash | READ_ONLY | Check ownership and MP for repeated skill use without casting. |
| `aal_gain_skill_source_cost` | `int aal_gain_skill_source_cost(skill s, int meat_per_mp)` | SOURCE 19: Ezandora Gain | READ_ONLY | Estimate a skill buff's MP opportunity cost. |

## Stash

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_stash_deficit` | `int aal_stash_deficit(item it, int expected)` | SOURCE 17: pStash | READ_ONLY | Return number missing from stash relative to a baseline. |
| `aal_stash_state` | `agent_stash_state aal_stash_state(item it, int expected, boolean personal_overlap)` | SOURCE 17: pStash | READ_ONLY | Capture expected versus current stash quantity with personal-overlap marker. |
| `aal_stash_surplus` | `int aal_stash_surplus(item it, int expected)` | SOURCE 17: pStash | READ_ONLY | Return surplus above a recorded stash baseline. |

## Static Analysis

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_iron_scripts_cli_command_literals` | `string aal_iron_scripts_cli_command_literals(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Extract straightforward quoted cli_execute command literals for review. |
| `aal_iron_scripts_network_scan` | `agent_check aal_iron_scripts_network_scan(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Detect external HTTP-era dependencies separately from in-game page access. |
| `aal_iron_scripts_side_effect_scan` | `string aal_iron_scripts_side_effect_scan(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | List mutation-oriented primitives in an IronTetsubo-era script. |
| `aal_twisted_entrypoint_count` | `int aal_twisted_entrypoint_count(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Count likely main-function entrypoints in source text. |
| `aal_twisted_imports` | `string aal_twisted_imports(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Extract imported ASH filenames from legacy script text. |
| `aal_twisted_mutation_surface` | `string aal_twisted_mutation_surface(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Describe potentially mutating primitives present in a legacy ASH script. |
| `aal_twisted_preference_refs` | `string aal_twisted_preference_refs(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Extract get_property/set_property preference names from straightforward quoted calls. |
| `aal_twisted_url_endpoints` | `string aal_twisted_url_endpoints(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Extract quoted .php endpoints referenced by a legacy script. |

## Time

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_time_elapsed_ms` | `int aal_time_elapsed_ms(int before_stamp, int after_stamp)` | SOURCE 14: TimeTracking.ash | PURE | Compute non-negative elapsed milliseconds between two stored timestamps. |
| `aal_time_elapsed_seconds` | `float aal_time_elapsed_seconds(int before_stamp, int after_stamp)` | SOURCE 14: TimeTracking.ash | PURE | Compute elapsed seconds between stored millisecond timestamps. |

## Tracking

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_networth_snapshot` | `agent_value_snapshot aal_networth_snapshot(boolean include_storage, int max_historical_age, int historical_cap, int stamp)` | SOURCE 22: networth.ash | READ_ONLY | Capture a net-worth snapshot suitable for later delta comparison. |
| `aal_profit_snapshot` | `agent_value_snapshot aal_profit_snapshot(int stamp, int max_historical_age)` | SOURCE 13: ProfitTracking.ash | READ_ONLY | Capture liquid meat, item value, total value, turns and caller timestamp. |
| `aal_ptrack_snapshot` | `agent_breakpoint aal_ptrack_snapshot(string name, int stamp)` | SOURCE 09: pTrack repository | READ_ONLY | Capture a compact in-memory breakpoint snapshot without writing files. |

## Updates

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_pupdates_pending_count` | `int aal_pupdates_pending_count(string script_name, int current_version)` | SOURCE 10: pUpdates repository | READ_ONLY | Compute how many update entries are unseen without changing the local version. |
| `aal_pupdates_seen_version` | `int aal_pupdates_seen_version(string script_name)` | SOURCE 10: pUpdates repository | READ_ONLY | Return normalized seen update version for a script. |
| `aal_pupdates_state` | `agent_kv aal_pupdates_state(string script_name)` | SOURCE 10: pUpdates repository | READ_ONLY | Read the local seen-version property for a pUpdates-style script. |
| `aal_pupdateslog_entry` | `string aal_pupdateslog_entry(string[int] update_lines, int version)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Return one changelog entry by version. |
| `aal_pupdateslog_parse_header` | `int aal_pupdateslog_parse_header(string[int] update_lines)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Extract current version from a pUpdates-style map representation where index -1 stores version. |
| `aal_pupdateslog_since` | `string aal_pupdateslog_since(string[int] update_lines, int seen_version, int max_entries)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Serialize changelog entries newer than a seen version. |

## Validation

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ascend_plan_validate` | `agent_check aal_ascend_plan_validate(string path_name, string class_name, string sign_name)` | SOURCE 07: c2t_ascend | PURE | Validate that configured path/class/sign strings resolve to current KoLmafia typed values. |
| `aal_astrogain_dynamic_modifier_hint` | `agent_check aal_astrogain_dynamic_modifier_hint(effect e)` | SOURCE 20: Astro3207 Gain | READ_ONLY | Flag effect modifier text that contains bracket/quoted expressions and should not be blindly cached. |
| `aal_astrogain_mutual_exclusion_state` | `string aal_astrogain_mutual_exclusion_state(effect[int] set_members)` | SOURCE 20: Astro3207 Gain | READ_ONLY | List active effects in one caller-defined mutually exclusive set. |
| `aal_batbrain_action_resource_check` | `agent_check aal_batbrain_action_resource_check(skill s, int casts)` | SOURCE 29: BatBrain.ash | READ_ONLY | Validate skill ownership and MP for a hypothetical combat action. |
| `aal_bootstrap_readiness` | `agent_check aal_bootstrap_readiness()` | SOURCE 25: bootstrap.ash | READ_ONLY | Check whether core bootstrap travel/setup targets are already present. |
| `aal_c2eco_ecosystem_health` | `agent_check aal_c2eco_ecosystem_health(string[int] repo_names, string dependencies_text)` | SOURCE 01: C2Talon repository ecosystem | PURE | Summarize whether a repository ecosystem exposes both reusable libraries and explicit dependency metadata. |
| `aal_c2lib_choice_expectation` | `agent_check aal_c2lib_choice_expectation(int expected_choice)` | SOURCE 32: c2t_lib | READ_ONLY | Validate exact active choice ID. |
| `aal_c2lib_free_adventure_preflight` | `agent_check aal_c2lib_free_adventure_preflight(location loc)` | SOURCE 32: c2t_lib | READ_ONLY | Snapshot turn count and accessibility before a caller attempts a supposedly free adventure. |
| `aal_c2scripts_choice_preflight` | `agent_check aal_c2scripts_choice_preflight(int choice_id, int intended_option)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Validate an intended choice against current choice state without submitting it. |
| `aal_c2scripts_resource_readiness` | `agent_check aal_c2scripts_resource_readiness(item required_item, skill required_skill)` | SOURCE 03: c2t_kol_scripts | READ_ONLY | Combine item and skill availability into one reusable resource readiness check. |
| `aal_checklist_duplicate_ids` | `string aal_checklist_duplicate_ids(int[int] ids)` | SOURCE 16: pChecklist | PURE | Report duplicate item IDs in a custom checklist definition. |
| `aal_checklist_item_check` | `agent_check aal_checklist_item_check(item it, int required)` | SOURCE 16: pChecklist | READ_ONLY | Check whether cross-location ownership satisfies a required checklist quantity. |
| `aal_choiceoverride_validate_page` | `agent_check aal_choiceoverride_validate_page(string page_text)` | SOURCE 39: Choice-Override | PURE | Validate that a page contains an identifiable choice and at least one option. |
| `aal_consume_budget_check` | `agent_check aal_consume_budget_check(agent_consumption_candidate c, int meat_budget)` | SOURCE 21: Consume | PURE | Check candidate price against a caller budget. |
| `aal_consume_candidate_fits` | `boolean aal_consume_candidate_fits(agent_consumption_candidate c, string organ_name)` | SOURCE 21: Consume | READ_ONLY | Check whether a candidate fits the requested organ's remaining capacity. |
| `aal_consume_overdrink_risk` | `agent_check aal_consume_overdrink_risk(int drink_size)` | SOURCE 21: Consume | READ_ONLY | Describe whether consuming a drink of the given size would exceed the normal liver limit. |
| `aal_gain_conflict_hint` | `string aal_gain_conflict_hint(effect desired, effect[int] exclusive_set)` | SOURCE 19: Ezandora Gain | READ_ONLY | Report active mutually-exclusive effects from a caller-supplied conflict set. |
| `aal_gain_limited_effect_check` | `agent_check aal_gain_limited_effect_check(effect e, boolean allow_limited)` | SOURCE 19: Ezandora Gain | PURE | Apply explicit limited-effect policy to a candidate. |
| `aal_guide_quest_status_check` | `agent_check aal_guide_quest_status_check(string quest_property, string expected_state)` | SOURCE 18: Guide | READ_ONLY | Compare a quest preference with an expected state. |
| `aal_hccs_test_readiness` | `agent_modifier_state aal_hccs_test_readiness(string modifier_name, float target_value)` | SOURCE 06: c2t_hccs | READ_ONLY | Compare a current numeric modifier against a requested Community Service pre-test target. |
| `aal_hccs_turn_threshold_check` | `agent_check aal_hccs_turn_threshold_check(int predicted_turns, int allowed_turns, string test_name)` | SOURCE 06: c2t_hccs | PURE | Validate a predicted Community Service test duration against configured threshold. |
| `aal_helper_access_check` | `agent_check aal_helper_access_check(location loc, item required_item)` | SOURCE 34: helper.ash | READ_ONLY | Combine location accessibility with a required-item condition. |
| `aal_helper_fax_readiness` | `agent_check aal_helper_fax_readiness()` | SOURCE 34: helper.ash | READ_ONLY | Expose photocopy-use/path conditions relevant to legacy fax advisories. |
| `aal_helper_yellow_ray_readiness` | `agent_check aal_helper_yellow_ray_readiness()` | SOURCE 34: helper.ash | READ_ONLY | Check broad yellow-ray readiness signals used by legacy advisories. |
| `aal_htmlform_error_summary` | `string aal_htmlform_error_summary(agent_check[int] checks)` | SOURCE 28: htmlform.ash | PURE | Serialize failing field validations. |
| `aal_htmlform_field_validate` | `agent_check aal_htmlform_field_validate(string name, string value, boolean required)` | SOURCE 28: htmlform.ash | PURE | Validate basic relay form field presence. |
| `aal_htmlform_int_validate` | `agent_check aal_htmlform_int_validate(string name, string value, int minimum, int maximum)` | SOURCE 28: htmlform.ash | PURE | Validate an integer form value against inclusive bounds. |
| `aal_htmlform_select_validate` | `agent_check aal_htmlform_select_validate(string value, string[int] allowed_values)` | SOURCE 28: htmlform.ash | PURE | Check that a submitted select value belongs to the allowed set. |
| `aal_iron_scripts_import_safe_hint` | `agent_check aal_iron_scripts_import_safe_hint(string source_text)` | SOURCE 05: IronTetsubo KoLmafia-ash scripts | PURE | Flag likely top-level side effects by comparing early executable tokens with function declarations. |
| `aal_liba_equip_cast_preflight` | `agent_check aal_liba_equip_cast_preflight(item gear, skill s, int casts)` | SOURCE 30: liba | READ_ONLY | Check equip/cast prerequisites and MP without changing equipment. |
| `aal_liba_raw_use_preflight` | `agent_check aal_liba_raw_use_preflight(item it)` | SOURCE 30: liba | READ_ONLY | Describe whether an item is present for low-level/raw-use logic, without using it. |
| `aal_lowerstats_effect_safety` | `agent_check aal_lowerstats_effect_safety(effect e)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Explain whether an active positive-stat effect also carries protected economic/familiar/smithsness modifiers. |
| `aal_lowerstats_postcondition` | `agent_check aal_lowerstats_postcondition(stat s, int cap)` | SOURCE 11: pLooper lowerstats.ash | READ_ONLY | Check the postcondition the original helper ultimately wanted: buffed stat at or below cap. |
| `aal_ocd_policy_validate` | `agent_check aal_ocd_policy_validate(string action, int keep_amount)` | SOURCE 26: OCD Inventory Control.ash | PURE | Validate a disposition action/keep quantity without performing inventory changes. |
| `aal_ocd_rule_conflict` | `agent_check aal_ocd_rule_conflict(string action_a, int keep_a, string action_b, int keep_b)` | SOURCE 26: OCD Inventory Control.ash | PURE | Detect conflicting duplicate disposition rules. |
| `aal_ploop_completion_check` | `agent_check aal_ploop_completion_check(string event_list)` | SOURCE 08: pLooper | PURE | Return structured completion status from event-list evidence. |
| `aal_ploop_workshed_preflight` | `agent_check aal_ploop_workshed_preflight(item desired_workshed)` | SOURCE 08: pLooper | READ_ONLY | Check whether a desired workshed item is already available before a loop would attempt installation. |
| `aal_ptrack_checkpoint_validate` | `agent_check aal_ptrack_checkpoint_validate(agent_breakpoint b)` | SOURCE 09: pTrack repository | PURE | Validate a breakpoint record before persistence/comparison. |
| `aal_ptrack_daily_reset_needed` | `boolean aal_ptrack_daily_reset_needed(string stored_date)` | SOURCE 09: pTrack repository | READ_ONLY | Determine whether a tracker's stored date differs from KoLmafia's current date. |
| `aal_ptrackcli_breakpoint_duplicates` | `string aal_ptrackcli_breakpoint_duplicates(string event_list)` | SOURCE 15: ptrack.ash | PURE | Report duplicate breakpoint names that could confuse interval comparisons. |
| `aal_ptrackcli_name_validate` | `agent_check aal_ptrackcli_name_validate(string breakpoint_name)` | SOURCE 15: ptrack.ash | PURE | Validate breakpoint names for comma-delimited storage. |
| `aal_ptrackcli_reset_check` | `agent_check aal_ptrackcli_reset_check(string stored_date)` | SOURCE 15: ptrack.ash | READ_ONLY | Check whether daily tracking should be reset based on KoL date. |
| `aal_pupdates_version_check` | `agent_check aal_pupdates_version_check(string script_name, int current_version)` | SOURCE 10: pUpdates repository | READ_ONLY | Return structured up-to-date status without marking updates as read. |
| `aal_pupdateslog_contiguous` | `boolean aal_pupdateslog_contiguous(string[int] update_lines)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Check whether all changelog versions through current are present. |
| `aal_pupdateslog_missing_versions` | `string aal_pupdateslog_missing_versions(string[int] update_lines)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Report gaps between version 0 and declared current version. |
| `aal_pupdateslog_validate` | `agent_check aal_pupdateslog_validate(string[int] update_lines)` | SOURCE 37: pUpdates repository (second supplied entry) | PURE | Validate header/version continuity for a changelog map. |
| `aal_pwrapper_choice_recovery_preflight` | `agent_check aal_pwrapper_choice_recovery_preflight(boolean fail_unset)` | SOURCE 12: pwrapper | READ_ONLY | Validate whether wrapper-style automatic choice recovery can proceed. |
| `aal_pwrapper_completion_evidence` | `agent_check aal_pwrapper_completion_evidence(string event_list, string completion_token)` | SOURCE 12: pwrapper | PURE | Check exact completion-token evidence in the wrapper's breakpoint list. |
| `aal_pwrapper_safe_state_check` | `agent_check aal_pwrapper_safe_state_check()` | SOURCE 12: pwrapper | READ_ONLY | Check a conservative safe-state condition: not in a choice and not Beaten Up. |
| `aal_quest_mcd_preflight` | `agent_check aal_quest_mcd_preflight(int desired)` | SOURCE 35: QuestLib.ash | READ_ONLY | Validate desired MCD against source-inspired practical ceiling. |
| `aal_quest_underwater_preflight` | `agent_check aal_quest_underwater_preflight()` | SOURCE 35: QuestLib.ash | READ_ONLY | Check ownership of common underwater breathing gear without changing outfit. |
| `aal_rollover_ready_check` | `agent_check aal_rollover_ready_check(int expected_rollover_mp)` | SOURCE 23: rollover.ash | READ_ONLY | Return ready only when the source-inspired warning set is empty. |
| `aal_select2_duplicate_values` | `string aal_select2_duplicate_values(agent_option[int] options)` | SOURCE 27: insertSelect2-relays | PURE | Report duplicate option values that make selection ambiguous. |
| `aal_select2_option_validate` | `agent_check aal_select2_option_validate(agent_option o)` | SOURCE 27: insertSelect2-relays | PURE | Validate a searchable option has stable value/label fields. |
| `aal_sims_path_constraint` | `agent_check aal_sims_path_constraint(familiar fam)` | SOURCE 36: sims_lib.ash | READ_ONLY | Check whether a familiar is usable in the current path by ownership plus path-level familiar availability. |
| `aal_smash_candidate_check` | `agent_check aal_smash_candidate_check(item it)` | SOURCE 33: SmashLib.ash | READ_ONLY | Validate an item as an ordinary equipment pulverization candidate without smashing it. |
| `aal_smash_loss_risk` | `agent_check aal_smash_loss_risk(item it, int estimated_yield_value)` | SOURCE 33: SmashLib.ash | READ_ONLY | Compare estimated smash-yield value with keeping/selling value. |
| `aal_stash_personal_overlap` | `agent_check aal_stash_personal_overlap(item it, int personal_baseline)` | SOURCE 17: pStash | READ_ONLY | Check whether current personal ownership is at/below a recorded personal floor. |
| `aal_stash_verify` | `agent_check aal_stash_verify(item it, int expected)` | SOURCE 17: pStash | READ_ONLY | Validate a single stash baseline. |
| `aal_testout_cardinality` | `agent_diagnostic aal_testout_cardinality(string name, int actual_count, int minimum_count, int maximum_count)` | SOURCE 24: testout.ash | PURE | Create a structured collection-cardinality diagnostic with explicit bounds. |
| `aal_testout_required_keys` | `agent_diagnostic aal_testout_required_keys(string name, string[string] fields, string[int] required_keys)` | SOURCE 24: testout.ash | PURE | Validate that a string map contains every required schema key and report missing keys. |
| `aal_time_budget_state` | `agent_range_state aal_time_budget_state(int elapsed_ms, int budget_ms)` | SOURCE 14: TimeTracking.ash | PURE | Describe elapsed-time budget consumption and remaining milliseconds. |
| `aal_time_pace_check` | `agent_check aal_time_pace_check(int turns, int elapsed_ms, float max_seconds_per_turn)` | SOURCE 14: TimeTracking.ash | PURE | Check whether an interval stays under a caller-defined seconds-per-turn threshold. |
| `aal_twisted_raw_html_dependency` | `agent_check aal_twisted_raw_html_dependency(string source_text)` | SOURCE 02: twistedmage assorted scripts | PURE | Flag scripts whose decisions appear coupled to raw HTML text matching. |
| `aal_zlib_type_validate` | `agent_check aal_zlib_type_validate(string value, string type_name)` | SOURCE 40: zlib.ash (fixed historical commit) | PURE | Validate a subset of common ZLib setting types with current KoLmafia coercions. |
| `aal_zman_field_validate` | `agent_check aal_zman_field_validate(string name, string value, string kind)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Validate a setting according to inferred/editor kind. |
| `aal_zman_validation_errors` | `string aal_zman_validation_errors(string[string] values, string[string] types)` | SOURCE 41: relay_zlib_manager.ash (fixed historical commit) | PURE | Validate an entire settings map and emit only errors. |

## Wanderers

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_c2lib_sausage_odds` | `float aal_c2lib_sausage_odds()` | SOURCE 32: c2t_lib | READ_ONLY | Recompute c2t_lib-inspired sausage goblin odds without equipping or adventuring. |
| `aal_c2lib_sausage_ready` | `boolean aal_c2lib_sausage_ready()` | SOURCE 32: c2t_lib | READ_ONLY | Check whether the sausage wanderer threshold is currently met. |
| `aal_c2lib_void_state` | `string aal_c2lib_void_state()` | SOURCE 32: c2t_lib | READ_ONLY | Expose cursed magnifying glass charge/free-fight state. |

## Workflow

| Function | Signature | Source | Side effects | Purpose |
|---|---|---|---|---|
| `aal_ploop_ascension_leg` | `int aal_ploop_ascension_leg()` | SOURCE 08: pLooper | READ_ONLY | Normalize ascensionsToday into a simple loop leg number. |
| `aal_ploop_phase_index` | `int aal_ploop_phase_index(string event_list)` | SOURCE 08: pLooper | PURE | Infer furthest completed loop phase from named breakpoint text. |
| `aal_ploop_phase_names` | `string aal_ploop_phase_names()` | SOURCE 08: pLooper | PURE | Return deterministic pLooper-inspired full-day phase names. |
| `aal_pwrapper_retry_state` | `agent_range_state aal_pwrapper_retry_state(int attempt, int max_attempts)` | SOURCE 12: pwrapper | PURE | Normalize wrapper retry counters. |
