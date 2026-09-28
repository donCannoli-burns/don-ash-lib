# Source Analysis and Per-URL Candidate Tables

These tables are the design inventory used before implementation. Every row corresponds to one implemented export.
Side-effect classes follow the requested PURE / READ_ONLY / STATEFUL_LOCAL / MUTATING taxonomy.

## SOURCE 01

**URL:** https://github.com/C2Talon?tab=repositories
**PROJECT:** C2Talon repository ecosystem
**SOURCE PURPOSE:** Repository collection spanning reusable ASH libraries, resource modules, ascension automation, trackers, relays, and KoLmafia tooling.
**INTERESTING EXISTING CAPABILITIES:** Reusable micro-libraries, run automation, relay tooling, and resource modules coexist across the account.
**MISSING ABSTRACTIONS:** Account-level source has no single runtime API; the missing abstraction is a package/dependency/capability view.
**LLM-RUNTIME OPPORTUNITIES:** Repository manifest normalization, dependency selection, and task-to-component routing.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_c2eco_repo_manifest(string[int] repo_names)` | Serialization | PURE | Normalize a repository-name list into stable one-name-per-line manifest text. | HIGH |
| 02 | `string aal_c2eco_repo_role(string repo_name)` | Classification | PURE | Classify a C2Talon-style repository by its name into a useful runtime role. | HIGH |
| 03 | `string aal_c2eco_dependency_lines(string dependencies_text)` | Normalization | PURE | Normalize dependencies.txt-style content into deterministic dependency lines without comments/blank rows. | HIGH |
| 04 | `int aal_c2eco_dependency_count(string dependencies_text)` | Query | PURE | Count unique non-comment dependency declarations in a dependencies file. | HIGH |
| 05 | `string aal_c2eco_repo_capability_tags(string repo_name)` | Describe | PURE | Produce compact capability tags inferred from ecosystem naming conventions. | HIGH |
| 06 | `string aal_c2eco_select_repos_for_task(string[int] repo_names, string task_text)` | Query | PURE | Select ecosystem repositories whose names/roles plausibly match a task description. | HIGH |
| 07 | `string aal_c2eco_manifest_delta(string[int] before_repos, string[int] after_repos)` | Diff / Change Detection | PURE | Compare two repository manifests and report added/removed names. | HIGH |
| 08 | `string aal_c2eco_library_candidates(string[int] repo_names)` | Query | PURE | Extract likely reusable library repositories from a mixed account repository list. | HIGH |
| 09 | `agent_check aal_c2eco_ecosystem_health(string[int] repo_names, string dependencies_text)` | Validation | PURE | Summarize whether a repository ecosystem exposes both reusable libraries and explicit dependency metadata. | HIGH |
| 10 | `string aal_c2eco_agent_context(string[int] repo_names, string dependencies_text, int max_repos)` | LLM Context | PURE | Build a compact deterministic ecosystem context for an agent selecting reusable C2Talon components. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_c2eco_repo_manifest` — Normalize a repository-name list into stable one-name-per-line manifest text.
02. `aal_c2eco_repo_role` — Classify a C2Talon-style repository by its name into a useful runtime role.
03. `aal_c2eco_dependency_lines` — Normalize dependencies.txt-style content into deterministic dependency lines without comments/blank rows.
04. `aal_c2eco_dependency_count` — Count unique non-comment dependency declarations in a dependencies file.
05. `aal_c2eco_repo_capability_tags` — Produce compact capability tags inferred from ecosystem naming conventions.
06. `aal_c2eco_select_repos_for_task` — Select ecosystem repositories whose names/roles plausibly match a task description.
07. `aal_c2eco_manifest_delta` — Compare two repository manifests and report added/removed names.
08. `aal_c2eco_library_candidates` — Extract likely reusable library repositories from a mixed account repository list.
09. `aal_c2eco_ecosystem_health` — Summarize whether a repository ecosystem exposes both reusable libraries and explicit dependency metadata.
10. `aal_c2eco_agent_context` — Build a compact deterministic ecosystem context for an agent selecting reusable C2Talon components.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_c2eco_repo_manifest`, `aal_c2eco_repo_role`, `aal_c2eco_dependency_lines`, `aal_c2eco_dependency_count`, `aal_c2eco_repo_capability_tags`, `aal_c2eco_select_repos_for_task`, `aal_c2eco_manifest_delta`, `aal_c2eco_library_candidates`, `aal_c2eco_ecosystem_health`, `aal_c2eco_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s01_c2eco.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 02

**URL:** https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
**PROJECT:** twistedmage assorted scripts
**SOURCE PURPOSE:** Large legacy ASH script collection with questing, utilities, helpers, combat, crafting, and relay-era patterns.
**INTERESTING EXISTING CAPABILITIES:** The directory mixes quest automation, utility imports, relay-era assumptions, and direct executor/page calls.
**MISSING ABSTRACTIONS:** Legacy scripts expose behavior but little machine-readable static analysis.
**LLM-RUNTIME OPPORTUNITIES:** Import, preference, endpoint, mutation-surface, and modernization summaries.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_twisted_imports(string source_text)` | Static Analysis | PURE | Extract imported ASH filenames from legacy script text. | HIGH |
| 02 | `string aal_twisted_mutation_surface(string source_text)` | Static Analysis | PURE | Describe potentially mutating primitives present in a legacy ASH script. | HIGH |
| 03 | `int aal_twisted_legacy_risk_score(string source_text)` | Debugging | PURE | Compute a coarse modernization risk score from legacy execution and page-scraping patterns. | HIGH |
| 04 | `string aal_twisted_preference_refs(string source_text)` | Static Analysis | PURE | Extract get_property/set_property preference names from straightforward quoted calls. | HIGH |
| 05 | `string aal_twisted_url_endpoints(string source_text)` | Static Analysis | PURE | Extract quoted .php endpoints referenced by a legacy script. | HIGH |
| 06 | `int aal_twisted_entrypoint_count(string source_text)` | Static Analysis | PURE | Count likely main-function entrypoints in source text. | HIGH |
| 07 | `agent_check aal_twisted_raw_html_dependency(string source_text)` | Validation | PURE | Flag scripts whose decisions appear coupled to raw HTML text matching. | HIGH |
| 08 | `int aal_twisted_import_depth_hint(string source_text)` | Planning | PURE | Estimate dependency pressure from import count and nested executor usage. | HIGH |
| 09 | `string aal_twisted_modernization_todo(string source_text)` | Planning | PURE | Create a deterministic modernization checklist based on patterns actually present. | HIGH |
| 10 | `string aal_twisted_source_context(string source_name, string source_text)` | LLM Context | PURE | Build a compact static-analysis context for an agent modernizing a twistedmage-era script. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_twisted_imports` — Extract imported ASH filenames from legacy script text.
02. `aal_twisted_mutation_surface` — Describe potentially mutating primitives present in a legacy ASH script.
03. `aal_twisted_legacy_risk_score` — Compute a coarse modernization risk score from legacy execution and page-scraping patterns.
04. `aal_twisted_preference_refs` — Extract get_property/set_property preference names from straightforward quoted calls.
05. `aal_twisted_url_endpoints` — Extract quoted .php endpoints referenced by a legacy script.
06. `aal_twisted_entrypoint_count` — Count likely main-function entrypoints in source text.
07. `aal_twisted_raw_html_dependency` — Flag scripts whose decisions appear coupled to raw HTML text matching.
08. `aal_twisted_import_depth_hint` — Estimate dependency pressure from import count and nested executor usage.
09. `aal_twisted_modernization_todo` — Create a deterministic modernization checklist based on patterns actually present.
10. `aal_twisted_source_context` — Build a compact static-analysis context for an agent modernizing a twistedmage-era script.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_twisted_imports`, `aal_twisted_mutation_surface`, `aal_twisted_legacy_risk_score`, `aal_twisted_preference_refs`, `aal_twisted_url_endpoints`, `aal_twisted_entrypoint_count`, `aal_twisted_raw_html_dependency`, `aal_twisted_import_depth_hint`, `aal_twisted_modernization_todo`, `aal_twisted_source_context`

**FILES CREATED/MODIFIED:** `lib/aal_s02_twisted.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 03

**URL:** https://github.com/C2Talon/c2t_kol_scripts
**PROJECT:** c2t_kol_scripts
**SOURCE PURPOSE:** Focused modern ASH scripts for resource use, trackers, choices, cartography, casting, and item-of-the-month workflows.
**INTERESTING EXISTING CAPABILITIES:** Modern focused scripts include choice helpers, trackers, cartography hunts, casting, and resource automation.
**MISSING ABSTRACTIONS:** Many scripts expose task-specific behavior but not a common non-mutating preflight/context layer.
**LLM-RUNTIME OPPORTUNITIES:** Choice/resource/tracker snapshots and map/cast preconditions.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_choice_state aal_c2scripts_choice_state(int choice_id)` | Choices | READ_ONLY | Describe whether KoLmafia is currently handling a requested choice and its configured choiceAdventure preference. | HIGH |
| 02 | `agent_check aal_c2scripts_choice_preflight(int choice_id, int intended_option)` | Validation | READ_ONLY | Validate an intended choice against current choice state without submitting it. | HIGH |
| 03 | `string aal_c2scripts_cold_medicine_state()` | Resources | READ_ONLY | Summarize Cold Medicine Cabinet consultation state from tracked preferences. | HIGH |
| 04 | `string aal_c2scripts_shavings_state()` | Effects | READ_ONLY | Expose the Daylight Shavings Helmet tracking preferences as compact machine context. | HIGH |
| 05 | `agent_check aal_c2scripts_map_monster_preflight(location where, monster target)` | Adventure / Validation | READ_ONLY | Check non-mutating prerequisites for using Map the Monsters at a requested location. | HIGH |
| 06 | `agent_action_preview aal_c2scripts_cast_resource_preview(skill s, int casts)` | Planning | READ_ONLY | Preview MP and skill-availability requirements for repeated casting without casting. | HIGH |
| 07 | `agent_check aal_c2scripts_resource_readiness(item required_item, skill required_skill)` | Validation | READ_ONLY | Combine item and skill availability into one reusable resource readiness check. | HIGH |
| 08 | `string aal_c2scripts_tracker_fingerprint(string[int] preference_names)` | Serialization | READ_ONLY | Serialize a caller-selected tracker preference set in stable lexical order. | HIGH |
| 09 | `agent_delta aal_c2scripts_resource_delta(string property_name, int before_value)` | Diff / Change Detection | READ_ONLY | Compare a numeric tracked preference to an earlier captured value. | HIGH |
| 10 | `string aal_c2scripts_agent_context(location where, monster target, int choice_id)` | LLM Context | READ_ONLY | Build compact choice/cartography/resource context inspired by c2t_kol_scripts. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_c2scripts_choice_state` — Describe whether KoLmafia is currently handling a requested choice and its configured choiceAdventure preference.
02. `aal_c2scripts_choice_preflight` — Validate an intended choice against current choice state without submitting it.
03. `aal_c2scripts_cold_medicine_state` — Summarize Cold Medicine Cabinet consultation state from tracked preferences.
04. `aal_c2scripts_shavings_state` — Expose the Daylight Shavings Helmet tracking preferences as compact machine context.
05. `aal_c2scripts_map_monster_preflight` — Check non-mutating prerequisites for using Map the Monsters at a requested location.
06. `aal_c2scripts_cast_resource_preview` — Preview MP and skill-availability requirements for repeated casting without casting.
07. `aal_c2scripts_resource_readiness` — Combine item and skill availability into one reusable resource readiness check.
08. `aal_c2scripts_tracker_fingerprint` — Serialize a caller-selected tracker preference set in stable lexical order.
09. `aal_c2scripts_resource_delta` — Compare a numeric tracked preference to an earlier captured value.
10. `aal_c2scripts_agent_context` — Build compact choice/cartography/resource context inspired by c2t_kol_scripts.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_c2scripts_choice_state`, `aal_c2scripts_choice_preflight`, `aal_c2scripts_cold_medicine_state`, `aal_c2scripts_shavings_state`, `aal_c2scripts_map_monster_preflight`, `aal_c2scripts_cast_resource_preview`, `aal_c2scripts_resource_readiness`, `aal_c2scripts_tracker_fingerprint`, `aal_c2scripts_resource_delta`, `aal_c2scripts_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s03_c2scripts.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 04

**URL:** https://github.com/Ezandora?tab=repositories
**PROJECT:** Ezandora repository ecosystem
**SOURCE PURPOSE:** Large ecosystem of relay advisers, optimizers, choice overrides, consumption/buff tools, and modular KoLmafia projects.
**INTERESTING EXISTING CAPABILITIES:** Ezandora projects repeatedly separate task/resource generation, simulation, and relay presentation.
**MISSING ABSTRACTIONS:** Cross-project advisory data lacks a tiny common machine-readable representation.
**LLM-RUNTIME OPPORTUNITIES:** Bounded task/resource context and capability summaries.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_ezeco_advisory_entry(string title, string url, string[int] details)` | Serialization | PURE | Serialize one Guide-like advisory entry as compact deterministic text. | HIGH |
| 02 | `int aal_ezeco_task_priority(boolean mandatory, boolean available_now, int turns_until_relevant)` | Planning | PURE | Calculate a stable task-priority signal inspired by Guide task/resource/future-task separation. | HIGH |
| 03 | `agent_resource_state aal_ezeco_resource_remaining(string used_property, int limit_value)` | Resources | READ_ONLY | Return remaining uses for a preference-backed daily resource. | HIGH |
| 04 | `agent_check aal_ezeco_future_task_state(string unlock_property, string complete_property)` | Planning | READ_ONLY | Describe future-task eligibility from explicit unlock/completion preferences. | HIGH |
| 05 | `string aal_ezeco_location_advice(location loc)` | Adventure | READ_ONLY | Expose location accessibility and recent turn count as advisory context. | HIGH |
| 06 | `agent_check aal_ezeco_iotm_presence(item key_item, familiar key_familiar, skill key_skill)` | Capability Discovery | READ_ONLY | Describe whether a feature is present through any of its item/familiar/skill surfaces. | HIGH |
| 07 | `string aal_ezeco_advice_dedupe(string[int] advisory_lines)` | Normalization | PURE | De-duplicate Guide-like advisory lines while retaining deterministic lexical order. | HIGH |
| 08 | `string aal_ezeco_advice_filter(string[int] advisory_lines, string query)` | Query | PURE | Filter advisory lines case-insensitively for an agent/user query. | HIGH |
| 09 | `string aal_ezeco_advice_budget(string[int] advisory_lines, int max_entries)` | LLM Context | PURE | Cap a potentially large advisory list for context-budget-aware agent use. | HIGH |
| 10 | `string aal_ezeco_agent_context(string section_name, string[int] current_tasks, string[int] resources, int max_each)` | LLM Context | PURE | Build a Guide-inspired compact tasks/resources section for an LLM. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_ezeco_advisory_entry` — Serialize one Guide-like advisory entry as compact deterministic text.
02. `aal_ezeco_task_priority` — Calculate a stable task-priority signal inspired by Guide task/resource/future-task separation.
03. `aal_ezeco_resource_remaining` — Return remaining uses for a preference-backed daily resource.
04. `aal_ezeco_future_task_state` — Describe future-task eligibility from explicit unlock/completion preferences.
05. `aal_ezeco_location_advice` — Expose location accessibility and recent turn count as advisory context.
06. `aal_ezeco_iotm_presence` — Describe whether a feature is present through any of its item/familiar/skill surfaces.
07. `aal_ezeco_advice_dedupe` — De-duplicate Guide-like advisory lines while retaining deterministic lexical order.
08. `aal_ezeco_advice_filter` — Filter advisory lines case-insensitively for an agent/user query.
09. `aal_ezeco_advice_budget` — Cap a potentially large advisory list for context-budget-aware agent use.
10. `aal_ezeco_agent_context` — Build a Guide-inspired compact tasks/resources section for an LLM.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_ezeco_advisory_entry`, `aal_ezeco_task_priority`, `aal_ezeco_resource_remaining`, `aal_ezeco_future_task_state`, `aal_ezeco_location_advice`, `aal_ezeco_iotm_presence`, `aal_ezeco_advice_dedupe`, `aal_ezeco_advice_filter`, `aal_ezeco_advice_budget`, `aal_ezeco_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s04_ezeco.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 05

**URL:** https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
**PROJECT:** IronTetsubo KoLmafia-ash scripts
**SOURCE PURPOSE:** Historical ASH collection including BatBrain, net worth, rollover, bootstrap, OCD inventory, recovery, and automation scripts.
**INTERESTING EXISTING CAPABILITIES:** The scripts tree contains historical page scraping, command strings, version/update code, and automation.
**MISSING ABSTRACTIONS:** Migration pressure is hard to see without static source summaries.
**LLM-RUNTIME OPPORTUNITIES:** Static mutation/network/import/property analysis for modernization agents.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_iron_scripts_side_effect_scan(string source_text)` | Static Analysis | PURE | List mutation-oriented primitives in an IronTetsubo-era script. | HIGH |
| 02 | `agent_check aal_iron_scripts_network_scan(string source_text)` | Static Analysis | PURE | Detect external HTTP-era dependencies separately from in-game page access. | HIGH |
| 03 | `int aal_iron_scripts_html_parse_score(string source_text)` | Debugging | PURE | Score reliance on substring/excise/matcher parsing around page requests. | HIGH |
| 04 | `string aal_iron_scripts_import_manifest(string source_text)` | Serialization | PURE | Extract legacy imports for migration dependency auditing. | HIGH |
| 05 | `string aal_iron_scripts_property_manifest(string source_text)` | Serialization | PURE | Extract quoted properties referenced by get_property/set_property. | HIGH |
| 06 | `string aal_iron_scripts_cli_command_literals(string source_text)` | Static Analysis | PURE | Extract straightforward quoted cli_execute command literals for review. | HIGH |
| 07 | `int aal_iron_scripts_modernization_pressure(string source_text)` | Planning | PURE | Combine parsing, command, network, and direct-page indicators into one modernization pressure metric. | HIGH |
| 08 | `agent_check aal_iron_scripts_import_safe_hint(string source_text)` | Validation | PURE | Flag likely top-level side effects by comparing early executable tokens with function declarations. | HIGH |
| 09 | `string aal_iron_scripts_read_plan_split(string source_text)` | Planning | PURE | Suggest explicit read/plan/execute split points based on legacy primitives found. | HIGH |
| 10 | `string aal_iron_scripts_agent_context(string source_name, string source_text)` | LLM Context | PURE | Build a compact migration context for an agent reviewing historical IronTetsubo scripts. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_iron_scripts_side_effect_scan` — List mutation-oriented primitives in an IronTetsubo-era script.
02. `aal_iron_scripts_network_scan` — Detect external HTTP-era dependencies separately from in-game page access.
03. `aal_iron_scripts_html_parse_score` — Score reliance on substring/excise/matcher parsing around page requests.
04. `aal_iron_scripts_import_manifest` — Extract legacy imports for migration dependency auditing.
05. `aal_iron_scripts_property_manifest` — Extract quoted properties referenced by get_property/set_property.
06. `aal_iron_scripts_cli_command_literals` — Extract straightforward quoted cli_execute command literals for review.
07. `aal_iron_scripts_modernization_pressure` — Combine parsing, command, network, and direct-page indicators into one modernization pressure metric.
08. `aal_iron_scripts_import_safe_hint` — Flag likely top-level side effects by comparing early executable tokens with function declarations.
09. `aal_iron_scripts_read_plan_split` — Suggest explicit read/plan/execute split points based on legacy primitives found.
10. `aal_iron_scripts_agent_context` — Build a compact migration context for an agent reviewing historical IronTetsubo scripts.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_iron_scripts_side_effect_scan`, `aal_iron_scripts_network_scan`, `aal_iron_scripts_html_parse_score`, `aal_iron_scripts_import_manifest`, `aal_iron_scripts_property_manifest`, `aal_iron_scripts_cli_command_literals`, `aal_iron_scripts_modernization_pressure`, `aal_iron_scripts_import_safe_hint`, `aal_iron_scripts_read_plan_split`, `aal_iron_scripts_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s05_iron.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 06

**URL:** https://github.com/C2Talon/c2t_hccs
**PROJECT:** c2t_hccs
**SOURCE PURPOSE:** Community Service automation with test thresholds, resources, recovery, combat, pre-adventure hooks, and relay configuration.
**INTERESTING EXISTING CAPABILITIES:** c2t_hccs models ten CS tests, thresholds, resources, recovery, combat and relay configuration.
**MISSING ABSTRACTIONS:** Threshold/readiness decisions can be exposed separately from test execution.
**LLM-RUNTIME OPPORTUNITIES:** Test readiness, resource budgets, stop reasons and pre-test context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_hccs_test_order()` | Community Service | PURE | Return Community Service test order used by c2t_hccs as a deterministic machine-readable list. | HIGH |
| 02 | `string aal_hccs_thresholds_parse(string thresholds_csv)` | Normalization | PURE | Normalize ten Community Service threshold values into indexed TSV. | HIGH |
| 03 | `int aal_hccs_threshold_for(string thresholds_csv, int test_index)` | Query | PURE | Read one test threshold safely from the configured ten-value CSV. | HIGH |
| 04 | `agent_modifier_state aal_hccs_test_readiness(string modifier_name, float target_value)` | Validation | READ_ONLY | Compare a current numeric modifier against a requested Community Service pre-test target. | HIGH |
| 05 | `agent_check aal_hccs_turn_threshold_check(int predicted_turns, int allowed_turns, string test_name)` | Validation | PURE | Validate a predicted Community Service test duration against configured threshold. | HIGH |
| 06 | `string aal_hccs_recovery_state()` | Recovery | READ_ONLY | Expose non-mutating HP/MP/beaten-up state relevant to c2t_hccs recovery. | HIGH |
| 07 | `agent_resource_state aal_hccs_resource_budget(string used_property, int cap)` | Resources | READ_ONLY | Describe a daily resource budget for a Community Service preparation step. | HIGH |
| 08 | `string aal_hccs_pretest_context(string test_name, string modifier_name, int predicted_turns, int allowed_turns)` | LLM Context | READ_ONLY | Build compact pre-test context with modifier state, health, and threshold. | HIGH |
| 09 | `string aal_hccs_property_snapshot(string[int] names)` | Serialization | READ_ONLY | Serialize selected HCCS configuration/preferences deterministically. | HIGH |
| 10 | `string aal_hccs_stop_reason(int predicted_turns, int allowed_turns, boolean resource_ready, boolean health_ready)` | Planning | PURE | Explain whether an HCCS agent should stop before a test without performing it. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_hccs_test_order` — Return Community Service test order used by c2t_hccs as a deterministic machine-readable list.
02. `aal_hccs_thresholds_parse` — Normalize ten Community Service threshold values into indexed TSV.
03. `aal_hccs_threshold_for` — Read one test threshold safely from the configured ten-value CSV.
04. `aal_hccs_test_readiness` — Compare a current numeric modifier against a requested Community Service pre-test target.
05. `aal_hccs_turn_threshold_check` — Validate a predicted Community Service test duration against configured threshold.
06. `aal_hccs_recovery_state` — Expose non-mutating HP/MP/beaten-up state relevant to c2t_hccs recovery.
07. `aal_hccs_resource_budget` — Describe a daily resource budget for a Community Service preparation step.
08. `aal_hccs_pretest_context` — Build compact pre-test context with modifier state, health, and threshold.
09. `aal_hccs_property_snapshot` — Serialize selected HCCS configuration/preferences deterministically.
10. `aal_hccs_stop_reason` — Explain whether an HCCS agent should stop before a test without performing it.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_hccs_test_order`, `aal_hccs_thresholds_parse`, `aal_hccs_threshold_for`, `aal_hccs_test_readiness`, `aal_hccs_turn_threshold_check`, `aal_hccs_recovery_state`, `aal_hccs_resource_budget`, `aal_hccs_pretest_context`, `aal_hccs_property_snapshot`, `aal_hccs_stop_reason`

**FILES CREATED/MODIFIED:** `lib/aal_s06_hccs.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 07

**URL:** https://github.com/C2Talon/c2t_ascend
**PROJECT:** c2t_ascend
**SOURCE PURPOSE:** Valhalla/ascension automation with relay-configured path/class/sign/astral/perm choices and validation.
**INTERESTING EXISTING CAPABILITIES:** c2t_ascend validates relay-configured Valhalla settings and automates ascension choices.
**MISSING ABSTRACTIONS:** Configuration validation and preflight can be made inspectable before any irreversible ascension action.
**LLM-RUNTIME OPPORTUNITIES:** Karma/config fingerprints, prerequisites, candidate perms and post-script previews.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_ascend_config_fields()` | Ascension | PURE | Return stable names for a minimal Valhalla/ascension plan schema. | HIGH |
| 02 | `string aal_ascend_config_value(string csv, int index)` | Normalization | PURE | Safely read an indexed value from a comma-delimited ascension configuration. | HIGH |
| 03 | `agent_range_state aal_ascend_karma_budget(int planned_perm_cost)` | Planning | READ_ONLY | Compare banked karma with planned perm expenditure. | HIGH |
| 04 | `string aal_ascend_prerequisite_state()` | Ascension | READ_ONLY | Expose current aftercore/interaction/king state relevant to entering Valhalla. | HIGH |
| 05 | `agent_check aal_ascend_plan_validate(string path_name, string class_name, string sign_name)` | Validation | PURE | Validate that configured path/class/sign strings resolve to current KoLmafia typed values. | HIGH |
| 06 | `string aal_ascend_perm_candidates(skill[int] skills, int max_entries)` | Planning | READ_ONLY | Filter caller-supplied perm candidates to skills actually known by the character. | HIGH |
| 07 | `string aal_ascend_resource_snapshot()` | Serialization | READ_ONLY | Serialize compact pre-ascension currencies/resources useful for planning. | HIGH |
| 08 | `agent_action_preview aal_ascend_post_script_preview(string command_text)` | Planning | PURE | Describe the configured post-ascension command without executing it. | HIGH |
| 09 | `int aal_ascend_config_fingerprint(string config_csv)` | Debugging | PURE | Produce a stable lightweight fingerprint for detecting ascension-config drift. | HIGH |
| 10 | `string aal_ascend_agent_context(string config_csv, string post_script)` | LLM Context | READ_ONLY | Build compact current-state plus configured-plan context for an ascension agent. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_ascend_config_fields` — Return stable names for a minimal Valhalla/ascension plan schema.
02. `aal_ascend_config_value` — Safely read an indexed value from a comma-delimited ascension configuration.
03. `aal_ascend_karma_budget` — Compare banked karma with planned perm expenditure.
04. `aal_ascend_prerequisite_state` — Expose current aftercore/interaction/king state relevant to entering Valhalla.
05. `aal_ascend_plan_validate` — Validate that configured path/class/sign strings resolve to current KoLmafia typed values.
06. `aal_ascend_perm_candidates` — Filter caller-supplied perm candidates to skills actually known by the character.
07. `aal_ascend_resource_snapshot` — Serialize compact pre-ascension currencies/resources useful for planning.
08. `aal_ascend_post_script_preview` — Describe the configured post-ascension command without executing it.
09. `aal_ascend_config_fingerprint` — Produce a stable lightweight fingerprint for detecting ascension-config drift.
10. `aal_ascend_agent_context` — Build compact current-state plus configured-plan context for an ascension agent.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_ascend_config_fields`, `aal_ascend_config_value`, `aal_ascend_karma_budget`, `aal_ascend_prerequisite_state`, `aal_ascend_plan_validate`, `aal_ascend_perm_candidates`, `aal_ascend_resource_snapshot`, `aal_ascend_post_script_preview`, `aal_ascend_config_fingerprint`, `aal_ascend_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s07_ascend.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 08

**URL:** https://github.com/Prusias-kol/pLooper
**PROJECT:** pLooper
**SOURCE PURPOSE:** Re-entrant full-day loop orchestration around breakfast, farming, prep, ascension, post-run work, nightcap, and checkpoints.
**INTERESTING EXISTING CAPABILITIES:** pLooper is explicitly re-entrant and uses named breakpoints to resume a multi-phase day.
**MISSING ABSTRACTIONS:** The phase state machine is implicit in procedural control flow.
**LLM-RUNTIME OPPORTUNITIES:** Phase inference, re-entry context, next-phase planning and completion evidence.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_ploop_phase_names()` | Workflow | PURE | Return deterministic pLooper-inspired full-day phase names. | HIGH |
| 02 | `boolean aal_ploop_breakpoint_seen(string event_list, string breakpoint)` | Query | PURE | Check exact breakpoint membership in a comma-delimited event list. | HIGH |
| 03 | `int aal_ploop_phase_index(string event_list)` | Workflow | PURE | Infer furthest completed loop phase from named breakpoint text. | HIGH |
| 04 | `string aal_ploop_reentry_context(string event_list)` | LLM Context | READ_ONLY | Describe current loop re-entry position without executing a phase. | HIGH |
| 05 | `string aal_ploop_next_phase(string event_list)` | Planning | PURE | Choose the next canonical pLooper-inspired phase from observed breakpoint history. | HIGH |
| 06 | `agent_organ_state aal_ploop_organ_snapshot()` | Player | READ_ONLY | Capture organs for phase-boundary planning. | HIGH |
| 07 | `agent_check aal_ploop_workshed_preflight(item desired_workshed)` | Validation | READ_ONLY | Check whether a desired workshed item is already available before a loop would attempt installation. | HIGH |
| 08 | `int aal_ploop_ascension_leg()` | Workflow | READ_ONLY | Normalize ascensionsToday into a simple loop leg number. | HIGH |
| 09 | `agent_check aal_ploop_completion_check(string event_list)` | Validation | PURE | Return structured completion status from event-list evidence. | HIGH |
| 10 | `string aal_ploop_phase_preview(string event_list, string configured_ascend_command)` | Planning | READ_ONLY | Describe the next loop phase and relevant state without executing it. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_ploop_phase_names` — Return deterministic pLooper-inspired full-day phase names.
02. `aal_ploop_breakpoint_seen` — Check exact breakpoint membership in a comma-delimited event list.
03. `aal_ploop_phase_index` — Infer furthest completed loop phase from named breakpoint text.
04. `aal_ploop_reentry_context` — Describe current loop re-entry position without executing a phase.
05. `aal_ploop_next_phase` — Choose the next canonical pLooper-inspired phase from observed breakpoint history.
06. `aal_ploop_organ_snapshot` — Capture organs for phase-boundary planning.
07. `aal_ploop_workshed_preflight` — Check whether a desired workshed item is already available before a loop would attempt installation.
08. `aal_ploop_ascension_leg` — Normalize ascensionsToday into a simple loop leg number.
09. `aal_ploop_completion_check` — Return structured completion status from event-list evidence.
10. `aal_ploop_phase_preview` — Describe the next loop phase and relevant state without executing it.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_ploop_phase_names`, `aal_ploop_breakpoint_seen`, `aal_ploop_phase_index`, `aal_ploop_reentry_context`, `aal_ploop_next_phase`, `aal_ploop_organ_snapshot`, `aal_ploop_workshed_preflight`, `aal_ploop_ascension_leg`, `aal_ploop_completion_check`, `aal_ploop_phase_preview`

**FILES CREATED/MODIFIED:** `lib/aal_s08_ploop.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 09

**URL:** https://github.com/Prusias-kol/pTrack
**PROJECT:** pTrack repository
**SOURCE PURPOSE:** Profit/time/breakpoint tracking suite combining inventory, meat, time, account value, and named checkpoints.
**INTERESTING EXISTING CAPABILITIES:** pTrack combines time, turns, meat, account value and named checkpoints.
**MISSING ABSTRACTIONS:** File-backed data can be represented in-memory for agent comparisons.
**LLM-RUNTIME OPPORTUNITIES:** Breakpoint snapshots, deltas, rates and interval context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_ptrack_checkpoint_key(string date, string event)` | Normalization | PURE | Create an unambiguous breakpoint key from date and event. | HIGH |
| 02 | `agent_breakpoint aal_ptrack_snapshot(string name, int stamp)` | Tracking | READ_ONLY | Capture a compact in-memory breakpoint snapshot without writing files. | HIGH |
| 03 | `string aal_ptrack_breakpoint_delta(agent_breakpoint before, agent_breakpoint after)` | Diff / Change Detection | PURE | Serialize meat/turn/time deltas between two in-memory breakpoints. | HIGH |
| 04 | `float aal_ptrack_meat_per_adventure(agent_breakpoint before, agent_breakpoint after)` | Analytics | PURE | Compute liquid-meat delta per turn for a checkpoint interval. | HIGH |
| 05 | `string aal_ptrack_event_list_normalize(string event_list)` | Normalization | PURE | De-duplicate a comma-delimited breakpoint list while preserving stable lexical output. | HIGH |
| 06 | `string aal_ptrack_adjacent_pairs(string event_list)` | Planning | PURE | Turn a breakpoint list into adjacent comparison pairs. | HIGH |
| 07 | `agent_check aal_ptrack_checkpoint_validate(agent_breakpoint b)` | Validation | PURE | Validate a breakpoint record before persistence/comparison. | HIGH |
| 08 | `string aal_ptrack_rate_context(agent_breakpoint before, agent_breakpoint after)` | LLM Context | PURE | Build compact interval-rate context for an agent interpreting pTrack data. | HIGH |
| 09 | `boolean aal_ptrack_daily_reset_needed(string stored_date)` | Validation | READ_ONLY | Determine whether a tracker's stored date differs from KoLmafia's current date. | HIGH |
| 10 | `string aal_ptrack_agent_context(string event_list, agent_breakpoint latest)` | LLM Context | PURE | Build compact tracker state for an LLM deciding what interval to compare next. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_ptrack_checkpoint_key` — Create an unambiguous breakpoint key from date and event.
02. `aal_ptrack_snapshot` — Capture a compact in-memory breakpoint snapshot without writing files.
03. `aal_ptrack_breakpoint_delta` — Serialize meat/turn/time deltas between two in-memory breakpoints.
04. `aal_ptrack_meat_per_adventure` — Compute liquid-meat delta per turn for a checkpoint interval.
05. `aal_ptrack_event_list_normalize` — De-duplicate a comma-delimited breakpoint list while preserving stable lexical output.
06. `aal_ptrack_adjacent_pairs` — Turn a breakpoint list into adjacent comparison pairs.
07. `aal_ptrack_checkpoint_validate` — Validate a breakpoint record before persistence/comparison.
08. `aal_ptrack_rate_context` — Build compact interval-rate context for an agent interpreting pTrack data.
09. `aal_ptrack_daily_reset_needed` — Determine whether a tracker's stored date differs from KoLmafia's current date.
10. `aal_ptrack_agent_context` — Build compact tracker state for an LLM deciding what interval to compare next.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_ptrack_checkpoint_key`, `aal_ptrack_snapshot`, `aal_ptrack_breakpoint_delta`, `aal_ptrack_meat_per_adventure`, `aal_ptrack_event_list_normalize`, `aal_ptrack_adjacent_pairs`, `aal_ptrack_checkpoint_validate`, `aal_ptrack_rate_context`, `aal_ptrack_daily_reset_needed`, `aal_ptrack_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s09_ptrack.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 10

**URL:** https://github.com/Prusias-kol/pUpdates
**PROJECT:** pUpdates repository
**SOURCE PURPOSE:** Small file-backed update/changelog library with per-script versions and local seen-version tracking.
**INTERESTING EXISTING CAPABILITIES:** pUpdates tracks a current version and a per-script seen version.
**MISSING ABSTRACTIONS:** Checking and acknowledging updates are coupled in the original workflow.
**LLM-RUNTIME OPPORTUNITIES:** Non-mutating pending/update state and review previews.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_kv aal_pupdates_state(string script_name)` | Updates | READ_ONLY | Read the local seen-version property for a pUpdates-style script. | HIGH |
| 02 | `int aal_pupdates_seen_version(string script_name)` | Updates | READ_ONLY | Return normalized seen update version for a script. | HIGH |
| 03 | `int aal_pupdates_pending_count(string script_name, int current_version)` | Updates | READ_ONLY | Compute how many update entries are unseen without changing the local version. | HIGH |
| 04 | `string aal_pupdates_pending_range(string script_name, int current_version)` | Planning | READ_ONLY | Describe inclusive unseen changelog version range. | HIGH |
| 05 | `agent_check aal_pupdates_version_check(string script_name, int current_version)` | Validation | READ_ONLY | Return structured up-to-date status without marking updates as read. | HIGH |
| 06 | `string aal_pupdates_property_name(string script_name)` | Normalization | PURE | Generate the canonical local-version preference name used by pUpdates. | HIGH |
| 07 | `string aal_pupdates_update_key(string script_name, int version)` | Normalization | PURE | Create a stable key for one script/version update entry. | HIGH |
| 08 | `agent_action_preview aal_pupdates_update_preview(string script_name, int current_version)` | Planning | READ_ONLY | Build a non-mutating update-check preview. | HIGH |
| 09 | `string aal_pupdates_status_line(string script_name, int current_version)` | Serialization | READ_ONLY | Serialize one update status as TSV. | HIGH |
| 10 | `string aal_pupdates_agent_context(string[int] scripts, int[int] current_versions)` | LLM Context | READ_ONLY | Build compact multi-script update state without acknowledging any update. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_pupdates_state` — Read the local seen-version property for a pUpdates-style script.
02. `aal_pupdates_seen_version` — Return normalized seen update version for a script.
03. `aal_pupdates_pending_count` — Compute how many update entries are unseen without changing the local version.
04. `aal_pupdates_pending_range` — Describe inclusive unseen changelog version range.
05. `aal_pupdates_version_check` — Return structured up-to-date status without marking updates as read.
06. `aal_pupdates_property_name` — Generate the canonical local-version preference name used by pUpdates.
07. `aal_pupdates_update_key` — Create a stable key for one script/version update entry.
08. `aal_pupdates_update_preview` — Build a non-mutating update-check preview.
09. `aal_pupdates_status_line` — Serialize one update status as TSV.
10. `aal_pupdates_agent_context` — Build compact multi-script update state without acknowledging any update.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_pupdates_state`, `aal_pupdates_seen_version`, `aal_pupdates_pending_count`, `aal_pupdates_pending_range`, `aal_pupdates_version_check`, `aal_pupdates_property_name`, `aal_pupdates_update_key`, `aal_pupdates_update_preview`, `aal_pupdates_status_line`, `aal_pupdates_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s10_pupdates.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 11

**URL:** https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
**PROJECT:** pLooper lowerstats.ash
**SOURCE PURPOSE:** Stat-lowering helper that identifies buffed stats over a target, applies negative effects/items, shrugs positive stat effects, and aborts on failure.
**INTERESTING EXISTING CAPABILITIES:** lowerstats.ash actively suppresses buffed stats and protects some valuable effects.
**MISSING ABSTRACTIONS:** Planning which effects/items to alter should be separate from actually shrugging/using them.
**LLM-RUNTIME OPPORTUNITIES:** Pressure, candidate effects, budget previews and postcondition checks.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_range_state aal_lowerstats_pressure(stat s, int cap)` | Player | READ_ONLY | Measure how far a buffed stat exceeds a desired cap. | HIGH |
| 02 | `string aal_lowerstats_all_pressure(int cap)` | Serialization | READ_ONLY | Serialize over-cap pressure for all three stats. | HIGH |
| 03 | `string aal_lowerstats_positive_effects(stat s, int max_entries)` | Effects | READ_ONLY | List active effects that positively modify the requested stat, bounded for agent context. | HIGH |
| 04 | `agent_check aal_lowerstats_effect_safety(effect e)` | Validation | READ_ONLY | Explain whether an active positive-stat effect also carries protected economic/familiar/smithsness modifiers. | HIGH |
| 05 | `string aal_lowerstats_shrug_candidates(stat s, int cap, int max_entries)` | Planning | READ_ONLY | List active positive-stat effects that are plausible shrug candidates under the source's protection rules. | HIGH |
| 06 | `string aal_lowerstats_item_option(stat s)` | Planning | READ_ONLY | Describe source-inspired low-stat consumable/item options without acquiring or using them. | HIGH |
| 07 | `agent_action_preview aal_lowerstats_budget_preview(item it, int max_price)` | Planning | READ_ONLY | Compare a stat-lowering item's mall price with a caller budget without buying it. | HIGH |
| 08 | `string aal_lowerstats_plan(stat s, int cap)` | Planning | READ_ONLY | Build a compact read-only stat-lowering plan for one stat. | HIGH |
| 09 | `agent_check aal_lowerstats_postcondition(stat s, int cap)` | Validation | READ_ONLY | Check the postcondition the original helper ultimately wanted: buffed stat at or below cap. | HIGH |
| 10 | `string aal_lowerstats_agent_context(int cap)` | LLM Context | READ_ONLY | Build compact all-stat state plus relevant source-inspired negative effects for an agent. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_lowerstats_pressure` — Measure how far a buffed stat exceeds a desired cap.
02. `aal_lowerstats_all_pressure` — Serialize over-cap pressure for all three stats.
03. `aal_lowerstats_positive_effects` — List active effects that positively modify the requested stat, bounded for agent context.
04. `aal_lowerstats_effect_safety` — Explain whether an active positive-stat effect also carries protected economic/familiar/smithsness modifiers.
05. `aal_lowerstats_shrug_candidates` — List active positive-stat effects that are plausible shrug candidates under the source's protection rules.
06. `aal_lowerstats_item_option` — Describe source-inspired low-stat consumable/item options without acquiring or using them.
07. `aal_lowerstats_budget_preview` — Compare a stat-lowering item's mall price with a caller budget without buying it.
08. `aal_lowerstats_plan` — Build a compact read-only stat-lowering plan for one stat.
09. `aal_lowerstats_postcondition` — Check the postcondition the original helper ultimately wanted: buffed stat at or below cap.
10. `aal_lowerstats_agent_context` — Build compact all-stat state plus relevant source-inspired negative effects for an agent.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_lowerstats_pressure`, `aal_lowerstats_all_pressure`, `aal_lowerstats_positive_effects`, `aal_lowerstats_effect_safety`, `aal_lowerstats_shrug_candidates`, `aal_lowerstats_item_option`, `aal_lowerstats_budget_preview`, `aal_lowerstats_plan`, `aal_lowerstats_postcondition`, `aal_lowerstats_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s11_lowerstats.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 12

**URL:** https://github.com/Prusias-kol/pwrapper
**PROJECT:** pwrapper
**SOURCE PURPOSE:** Retry wrapper for a loop script with error logging, choice/combat safe-state recovery, refresh, and completion detection.
**INTERESTING EXISTING CAPABILITIES:** pwrapper retries an external loop script and recovers from choices/combat error states.
**MISSING ABSTRACTIONS:** Recovery actions can be preceded by explicit state classification.
**LLM-RUNTIME OPPORTUNITIES:** Retry decisions, choice preflight, safe-state checks and diagnostic context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_range_state aal_pwrapper_retry_state(int attempt, int max_attempts)` | Workflow | PURE | Normalize wrapper retry counters. | HIGH |
| 02 | `string aal_pwrapper_error_context(string error_message)` | Debugging | READ_ONLY | Combine a caught wrapper error with KoLmafia's latest combat/encounter diagnostics. | HIGH |
| 03 | `agent_choice_state aal_pwrapper_choice_recovery_state()` | Choices | READ_ONLY | Describe current choice and configured option without submitting it. | HIGH |
| 04 | `agent_check aal_pwrapper_choice_recovery_preflight(boolean fail_unset)` | Validation | READ_ONLY | Validate whether wrapper-style automatic choice recovery can proceed. | HIGH |
| 05 | `string aal_pwrapper_combat_recovery_state()` | Combat | READ_ONLY | Describe whether wrapper recovery is currently in combat-like state using tracked combat signals. | HIGH |
| 06 | `agent_check aal_pwrapper_safe_state_check()` | Validation | READ_ONLY | Check a conservative safe-state condition: not in a choice and not Beaten Up. | HIGH |
| 07 | `agent_check aal_pwrapper_completion_evidence(string event_list, string completion_token)` | Validation | PURE | Check exact completion-token evidence in the wrapper's breakpoint list. | HIGH |
| 08 | `string aal_pwrapper_retry_decision(int attempt, int max_attempts, boolean completed, boolean safe_state)` | Planning | PURE | Return the next wrapper action without executing it. | HIGH |
| 09 | `string aal_pwrapper_log_line(int attempt, string error_message, string last_encounter, string last_result)` | Serialization | PURE | Serialize one retry failure as a compact deterministic log line. | HIGH |
| 10 | `string aal_pwrapper_agent_context(int attempt, int max_attempts, string event_list)` | LLM Context | READ_ONLY | Build compact wrapper/recovery context for an agent deciding whether to retry. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_pwrapper_retry_state` — Normalize wrapper retry counters.
02. `aal_pwrapper_error_context` — Combine a caught wrapper error with KoLmafia's latest combat/encounter diagnostics.
03. `aal_pwrapper_choice_recovery_state` — Describe current choice and configured option without submitting it.
04. `aal_pwrapper_choice_recovery_preflight` — Validate whether wrapper-style automatic choice recovery can proceed.
05. `aal_pwrapper_combat_recovery_state` — Describe whether wrapper recovery is currently in combat-like state using tracked combat signals.
06. `aal_pwrapper_safe_state_check` — Check a conservative safe-state condition: not in a choice and not Beaten Up.
07. `aal_pwrapper_completion_evidence` — Check exact completion-token evidence in the wrapper's breakpoint list.
08. `aal_pwrapper_retry_decision` — Return the next wrapper action without executing it.
09. `aal_pwrapper_log_line` — Serialize one retry failure as a compact deterministic log line.
10. `aal_pwrapper_agent_context` — Build compact wrapper/recovery context for an agent deciding whether to retry.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_pwrapper_retry_state`, `aal_pwrapper_error_context`, `aal_pwrapper_choice_recovery_state`, `aal_pwrapper_choice_recovery_preflight`, `aal_pwrapper_combat_recovery_state`, `aal_pwrapper_safe_state_check`, `aal_pwrapper_completion_evidence`, `aal_pwrapper_retry_decision`, `aal_pwrapper_log_line`, `aal_pwrapper_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s12_pwrapper.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 13

**URL:** https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
**PROJECT:** ProfitTracking.ash
**SOURCE PURPOSE:** Inventory/meat/net-worth checkpoint logging, accountval parsing, item delta valuation, and profit-per-adventure comparison.
**INTERESTING EXISTING CAPABILITIES:** ProfitTracking logs inventory, liquid meat, account value, turns and comparisons.
**MISSING ABSTRACTIONS:** The useful economics can exist as in-memory records rather than mandatory files.
**LLM-RUNTIME OPPORTUNITIES:** Value snapshots, item deltas, rate calculations and bounded valuable-item context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_profit_liquid_meat()` | Finance | READ_ONLY | Return liquid meat across inventory, closet, and storage. | HIGH |
| 02 | `agent_item_state aal_profit_item_state(item it)` | Inventory | READ_ONLY | Capture an item's quantities across major account locations. | HIGH |
| 03 | `int aal_profit_price_estimate(item it, int max_historical_age)` | Items | READ_ONLY | Estimate an item value with fresh historical price fallback to mall/autosell. | HIGH |
| 04 | `int aal_profit_inventory_value(int max_historical_age)` | Finance | READ_ONLY | Estimate total value of currently held inventory/closet/storage/display/shop/equipped items. | HIGH |
| 05 | `agent_value_snapshot aal_profit_snapshot(int stamp, int max_historical_age)` | Tracking | READ_ONLY | Capture liquid meat, item value, total value, turns and caller timestamp. | HIGH |
| 06 | `string aal_profit_snapshot_delta(agent_value_snapshot before, agent_value_snapshot after)` | Diff / Change Detection | PURE | Serialize value/turn/time changes between two profit snapshots. | HIGH |
| 07 | `float aal_profit_value_per_turn(agent_value_snapshot before, agent_value_snapshot after)` | Analytics | PURE | Compute total-value delta per turn. | HIGH |
| 08 | `agent_delta aal_profit_item_delta(item it, int before_total)` | Diff / Change Detection | READ_ONLY | Compare current cross-location item total against an earlier captured total. | HIGH |
| 09 | `string aal_profit_top_inventory_context(int min_unit_value, int max_entries, int max_historical_age)` | LLM Context | READ_ONLY | Emit bounded valuable-item context without logging to disk. | HIGH |
| 10 | `string aal_profit_agent_context(agent_value_snapshot snap)` | LLM Context | PURE | Serialize a profit snapshot as compact key=value state. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_profit_liquid_meat` — Return liquid meat across inventory, closet, and storage.
02. `aal_profit_item_state` — Capture an item's quantities across major account locations.
03. `aal_profit_price_estimate` — Estimate an item value with fresh historical price fallback to mall/autosell.
04. `aal_profit_inventory_value` — Estimate total value of currently held inventory/closet/storage/display/shop/equipped items.
05. `aal_profit_snapshot` — Capture liquid meat, item value, total value, turns and caller timestamp.
06. `aal_profit_snapshot_delta` — Serialize value/turn/time changes between two profit snapshots.
07. `aal_profit_value_per_turn` — Compute total-value delta per turn.
08. `aal_profit_item_delta` — Compare current cross-location item total against an earlier captured total.
09. `aal_profit_top_inventory_context` — Emit bounded valuable-item context without logging to disk.
10. `aal_profit_agent_context` — Serialize a profit snapshot as compact key=value state.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_profit_liquid_meat`, `aal_profit_item_state`, `aal_profit_price_estimate`, `aal_profit_inventory_value`, `aal_profit_snapshot`, `aal_profit_snapshot_delta`, `aal_profit_value_per_turn`, `aal_profit_item_delta`, `aal_profit_top_inventory_context`, `aal_profit_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s13_profit.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 14

**URL:** https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
**PROJECT:** TimeTracking.ash
**SOURCE PURPOSE:** Named timestamp checkpoints, elapsed-time comparison, event-list tracking, and combined profit/time breakpoints.
**INTERESTING EXISTING CAPABILITIES:** TimeTracking stores timestamps and compares named events.
**MISSING ABSTRACTIONS:** Timing math is reusable independent of file persistence.
**LLM-RUNTIME OPPORTUNITIES:** Duration/pace metrics, adjacent interval serialization and anomaly checks.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_time_elapsed_ms(int before_stamp, int after_stamp)` | Time | PURE | Compute non-negative elapsed milliseconds between two stored timestamps. | HIGH |
| 02 | `float aal_time_elapsed_seconds(int before_stamp, int after_stamp)` | Time | PURE | Compute elapsed seconds between stored millisecond timestamps. | HIGH |
| 03 | `agent_range_state aal_time_budget_state(int elapsed_ms, int budget_ms)` | Validation | PURE | Describe elapsed-time budget consumption and remaining milliseconds. | HIGH |
| 04 | `string aal_time_format_duration(int elapsed_ms)` | Serialization | PURE | Format a millisecond duration as deterministic HH:MM:SS. | HIGH |
| 05 | `float aal_time_turns_per_hour(int turns, int elapsed_ms)` | Analytics | PURE | Calculate turn throughput for a timed interval. | HIGH |
| 06 | `float aal_time_seconds_per_turn(int turns, int elapsed_ms)` | Analytics | PURE | Calculate average seconds per turn. | HIGH |
| 07 | `agent_check aal_time_pace_check(int turns, int elapsed_ms, float max_seconds_per_turn)` | Validation | PURE | Check whether an interval stays under a caller-defined seconds-per-turn threshold. | HIGH |
| 08 | `string aal_time_breakpoint_line(string date, string event, int stamp)` | Serialization | PURE | Serialize one time breakpoint as TSV. | HIGH |
| 09 | `string aal_time_adjacent_durations(string[int] names, int[int] stamps)` | Diff / Change Detection | PURE | Serialize elapsed time between adjacent named breakpoints. | HIGH |
| 10 | `string aal_time_agent_context(string from_event, string to_event, int turns, int elapsed_ms)` | LLM Context | PURE | Build compact timing/throughput context for an agent. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_time_elapsed_ms` — Compute non-negative elapsed milliseconds between two stored timestamps.
02. `aal_time_elapsed_seconds` — Compute elapsed seconds between stored millisecond timestamps.
03. `aal_time_budget_state` — Describe elapsed-time budget consumption and remaining milliseconds.
04. `aal_time_format_duration` — Format a millisecond duration as deterministic HH:MM:SS.
05. `aal_time_turns_per_hour` — Calculate turn throughput for a timed interval.
06. `aal_time_seconds_per_turn` — Calculate average seconds per turn.
07. `aal_time_pace_check` — Check whether an interval stays under a caller-defined seconds-per-turn threshold.
08. `aal_time_breakpoint_line` — Serialize one time breakpoint as TSV.
09. `aal_time_adjacent_durations` — Serialize elapsed time between adjacent named breakpoints.
10. `aal_time_agent_context` — Build compact timing/throughput context for an agent.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_time_elapsed_ms`, `aal_time_elapsed_seconds`, `aal_time_budget_state`, `aal_time_format_duration`, `aal_time_turns_per_hour`, `aal_time_seconds_per_turn`, `aal_time_pace_check`, `aal_time_breakpoint_line`, `aal_time_adjacent_durations`, `aal_time_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s14_time.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 15

**URL:** https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
**PROJECT:** ptrack.ash
**SOURCE PURPOSE:** User-facing breakpoint orchestration over profit and time trackers, daily reset, comparison, and breakpoint lists.
**INTERESTING EXISTING CAPABILITIES:** ptrack.ash orchestrates named breakpoints over the time/profit sublibraries.
**MISSING ABSTRACTIONS:** Breakpoint-list integrity and next-comparison planning are implicit.
**LLM-RUNTIME OPPORTUNITIES:** List validation, duplicate detection, compare pairs and next-breakpoint planning.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_ptrackcli_parse_breakpoints(string event_list)` | Normalization | PURE | Normalize the pTrack breakpoint property into one event per line. | HIGH |
| 02 | `int aal_ptrackcli_breakpoint_count(string event_list)` | Query | PURE | Count non-empty breakpoints in an event-list property. | HIGH |
| 03 | `boolean aal_ptrackcli_breakpoint_exists(string event_list, string name)` | Query | PURE | Test exact breakpoint membership. | HIGH |
| 04 | `string aal_ptrackcli_breakpoint_duplicates(string event_list)` | Validation | PURE | Report duplicate breakpoint names that could confuse interval comparisons. | HIGH |
| 05 | `string aal_ptrackcli_compare_plan(string event_list)` | Planning | PURE | Generate all adjacent comparison pairs from the current breakpoint order. | HIGH |
| 06 | `agent_check aal_ptrackcli_reset_check(string stored_date)` | Validation | READ_ONLY | Check whether daily tracking should be reset based on KoL date. | HIGH |
| 07 | `agent_check aal_ptrackcli_name_validate(string breakpoint_name)` | Validation | PURE | Validate breakpoint names for comma-delimited storage. | HIGH |
| 08 | `string aal_ptrackcli_next_breakpoint(string event_list, string[int] expected_order)` | Planning | PURE | Return first expected breakpoint not yet present. | HIGH |
| 09 | `string aal_ptrackcli_summary(string event_list)` | Serialization | PURE | Serialize breakpoint-list health and endpoints. | HIGH |
| 10 | `string aal_ptrackcli_agent_context(string event_list, string stored_date)` | LLM Context | READ_ONLY | Build compact user-facing tracker orchestration context. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_ptrackcli_parse_breakpoints` — Normalize the pTrack breakpoint property into one event per line.
02. `aal_ptrackcli_breakpoint_count` — Count non-empty breakpoints in an event-list property.
03. `aal_ptrackcli_breakpoint_exists` — Test exact breakpoint membership.
04. `aal_ptrackcli_breakpoint_duplicates` — Report duplicate breakpoint names that could confuse interval comparisons.
05. `aal_ptrackcli_compare_plan` — Generate all adjacent comparison pairs from the current breakpoint order.
06. `aal_ptrackcli_reset_check` — Check whether daily tracking should be reset based on KoL date.
07. `aal_ptrackcli_name_validate` — Validate breakpoint names for comma-delimited storage.
08. `aal_ptrackcli_next_breakpoint` — Return first expected breakpoint not yet present.
09. `aal_ptrackcli_summary` — Serialize breakpoint-list health and endpoints.
10. `aal_ptrackcli_agent_context` — Build compact user-facing tracker orchestration context.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_ptrackcli_parse_breakpoints`, `aal_ptrackcli_breakpoint_count`, `aal_ptrackcli_breakpoint_exists`, `aal_ptrackcli_breakpoint_duplicates`, `aal_ptrackcli_compare_plan`, `aal_ptrackcli_reset_check`, `aal_ptrackcli_name_validate`, `aal_ptrackcli_next_breakpoint`, `aal_ptrackcli_summary`, `aal_ptrackcli_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s15_ptrackcli.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 16

**URL:** https://github.com/Prusias-kol/pChecklist
**PROJECT:** pChecklist
**SOURCE PURPOSE:** File-backed item checklists supporting ranges/custom ID lists and ownership checks across multiple item locations.
**INTERESTING EXISTING CAPABILITIES:** pChecklist checks item ownership across multiple locations for ranges/custom lists.
**MISSING ABSTRACTIONS:** Completion and missing-value analysis can be returned structurally.
**LLM-RUNTIME OPPORTUNITIES:** Cross-location ownership, completion ratios, missing sets and value context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_checklist_total_owned(item it)` | Inventory | READ_ONLY | Count an item across inventory, closet, display, equipment, shop, and storage. | HIGH |
| 02 | `agent_item_state aal_checklist_item_state(item it)` | Inventory | READ_ONLY | Capture checklist ownership state across storage locations. | HIGH |
| 03 | `agent_check aal_checklist_item_check(item it, int required)` | Validation | READ_ONLY | Check whether cross-location ownership satisfies a required checklist quantity. | HIGH |
| 04 | `string aal_checklist_range_missing(int first_id, int last_id, int max_entries)` | Inventory | READ_ONLY | List missing valid items from an inclusive item-ID range. | HIGH |
| 05 | `string aal_checklist_custom_missing(item[int] items, int max_entries)` | Inventory | READ_ONLY | List missing items from a caller-defined checklist. | HIGH |
| 06 | `float aal_checklist_completion_ratio(item[int] items)` | Analytics | READ_ONLY | Calculate fraction of valid checklist items owned at least once. | HIGH |
| 07 | `string aal_checklist_duplicate_ids(int[int] ids)` | Validation | PURE | Report duplicate item IDs in a custom checklist definition. | HIGH |
| 08 | `string aal_checklist_status_tsv(item[int] items, int max_entries)` | Serialization | READ_ONLY | Serialize checklist item status in deterministic input order. | HIGH |
| 09 | `int aal_checklist_missing_value(item[int] items)` | Planning | READ_ONLY | Estimate mall acquisition value of currently missing tradeable checklist items without buying them. | HIGH |
| 10 | `string aal_checklist_agent_context(string checklist_name, item[int] items, int max_entries)` | LLM Context | READ_ONLY | Build compact checklist completion/missing context for an agent. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_checklist_total_owned` — Count an item across inventory, closet, display, equipment, shop, and storage.
02. `aal_checklist_item_state` — Capture checklist ownership state across storage locations.
03. `aal_checklist_item_check` — Check whether cross-location ownership satisfies a required checklist quantity.
04. `aal_checklist_range_missing` — List missing valid items from an inclusive item-ID range.
05. `aal_checklist_custom_missing` — List missing items from a caller-defined checklist.
06. `aal_checklist_completion_ratio` — Calculate fraction of valid checklist items owned at least once.
07. `aal_checklist_duplicate_ids` — Report duplicate item IDs in a custom checklist definition.
08. `aal_checklist_status_tsv` — Serialize checklist item status in deterministic input order.
09. `aal_checklist_missing_value` — Estimate mall acquisition value of currently missing tradeable checklist items without buying them.
10. `aal_checklist_agent_context` — Build compact checklist completion/missing context for an agent.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_checklist_total_owned`, `aal_checklist_item_state`, `aal_checklist_item_check`, `aal_checklist_range_missing`, `aal_checklist_custom_missing`, `aal_checklist_completion_ratio`, `aal_checklist_duplicate_ids`, `aal_checklist_status_tsv`, `aal_checklist_missing_value`, `aal_checklist_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s16_checklist.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 17

**URL:** https://github.com/Prusias-kol/pStash
**PROJECT:** pStash
**SOURCE PURPOSE:** Clan stash baseline, expected-vs-actual verification, personal-overlap protection, return workflows, and activity logging.
**INTERESTING EXISTING CAPABILITIES:** pStash records a clan-stash baseline, personal overlap, deficits, returns and logs.
**MISSING ABSTRACTIONS:** Return/reconciliation decisions benefit from a non-mutating preview.
**LLM-RUNTIME OPPORTUNITIES:** Expected-vs-actual state, safe return quantity and reconciliation context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_stash_state aal_stash_state(item it, int expected, boolean personal_overlap)` | Stash | READ_ONLY | Capture expected versus current stash quantity with personal-overlap marker. | HIGH |
| 02 | `int aal_stash_deficit(item it, int expected)` | Stash | READ_ONLY | Return number missing from stash relative to a baseline. | HIGH |
| 03 | `int aal_stash_surplus(item it, int expected)` | Stash | READ_ONLY | Return surplus above a recorded stash baseline. | HIGH |
| 04 | `agent_check aal_stash_verify(item it, int expected)` | Validation | READ_ONLY | Validate a single stash baseline. | HIGH |
| 05 | `agent_action_preview aal_stash_return_preview(item it, int expected, int personal_owned)` | Planning | READ_ONLY | Preview how many inventory copies could be returned without crossing a personal-ownership protection floor. | HIGH |
| 06 | `string aal_stash_map_summary(int[item] expected)` | Serialization | READ_ONLY | Serialize expected/actual/delta for a tracked stash map. | HIGH |
| 07 | `int aal_stash_missing_count(int[item] expected)` | Analytics | READ_ONLY | Count tracked stash entries below baseline. | HIGH |
| 08 | `agent_check aal_stash_personal_overlap(item it, int personal_baseline)` | Validation | READ_ONLY | Check whether current personal ownership is at/below a recorded personal floor. | HIGH |
| 09 | `string aal_stash_reconcile_plan(int[item] expected, int[item] personal_baseline, int max_entries)` | Planning | READ_ONLY | Build bounded reconciliation recommendations without moving stash items. | HIGH |
| 10 | `string aal_stash_agent_context(int[item] expected, int max_entries)` | LLM Context | READ_ONLY | Build compact stash health context centered on deficits/surpluses. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_stash_state` — Capture expected versus current stash quantity with personal-overlap marker.
02. `aal_stash_deficit` — Return number missing from stash relative to a baseline.
03. `aal_stash_surplus` — Return surplus above a recorded stash baseline.
04. `aal_stash_verify` — Validate a single stash baseline.
05. `aal_stash_return_preview` — Preview how many inventory copies could be returned without crossing a personal-ownership protection floor.
06. `aal_stash_map_summary` — Serialize expected/actual/delta for a tracked stash map.
07. `aal_stash_missing_count` — Count tracked stash entries below baseline.
08. `aal_stash_personal_overlap` — Check whether current personal ownership is at/below a recorded personal floor.
09. `aal_stash_reconcile_plan` — Build bounded reconciliation recommendations without moving stash items.
10. `aal_stash_agent_context` — Build compact stash health context centered on deficits/surpluses.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_stash_state`, `aal_stash_deficit`, `aal_stash_surplus`, `aal_stash_verify`, `aal_stash_return_preview`, `aal_stash_map_summary`, `aal_stash_missing_count`, `aal_stash_personal_overlap`, `aal_stash_reconcile_plan`, `aal_stash_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s17_stash.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 18

**URL:** https://github.com/Ezandora/Guide
**PROJECT:** Guide
**SOURCE PURPOSE:** Large modular relay adviser that generates tasks/resources/future tasks from quest, item, IOTM, path, and availability state.
**INTERESTING EXISTING CAPABILITIES:** Guide generates mandatory, optional, future tasks and resources from modular state providers.
**MISSING ABSTRACTIONS:** Its rich relay model can be compressed for machine consumers.
**LLM-RUNTIME OPPORTUNITIES:** Task/resource rows, quest checks, actionability and bounded advisory context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_guide_task_line(string title, string status, string url, int priority)` | Serialization | PURE | Serialize a Guide-inspired task entry for machine consumption. | HIGH |
| 02 | `string aal_guide_resource_line(string title, int remaining, string url)` | Serialization | PURE | Serialize a Guide-inspired daily-resource entry. | HIGH |
| 03 | `string aal_guide_quest_property(string quest_property)` | Quests | READ_ONLY | Expose one KoLmafia quest preference in normalized lowercase form. | HIGH |
| 04 | `agent_check aal_guide_quest_status_check(string quest_property, string expected_state)` | Validation | READ_ONLY | Compare a quest preference with an expected state. | HIGH |
| 05 | `agent_resource_state aal_guide_resource_from_property(string label, string used_property, int limit_value)` | Resources | READ_ONLY | Convert a Guide-like daily counter into a structured remaining-resource record. | HIGH |
| 06 | `agent_plan aal_guide_location_task(location loc, string title)` | Planning | READ_ONLY | Describe whether a location-based task is currently actionable. | HIGH |
| 07 | `string aal_guide_task_filter(string[int] tasks, string query, int max_entries)` | Query | PURE | Filter/bound task text for a user or LLM query. | HIGH |
| 08 | `agent_check aal_guide_future_task(string title, boolean unlocked, boolean completed, string prerequisite)` | Planning | PURE | Represent future/optional task state without executing it. | HIGH |
| 09 | `string aal_guide_advisory_merge(string[int] mandatory, string[int] optional, string[int] future, int max_each)` | LLM Context | PURE | Merge Guide-like task lanes into bounded labeled context. | HIGH |
| 10 | `string aal_guide_agent_context(string[int] quest_properties, int max_entries)` | LLM Context | READ_ONLY | Build compact quest-preference context using Guide's advisory orientation. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_guide_task_line` — Serialize a Guide-inspired task entry for machine consumption.
02. `aal_guide_resource_line` — Serialize a Guide-inspired daily-resource entry.
03. `aal_guide_quest_property` — Expose one KoLmafia quest preference in normalized lowercase form.
04. `aal_guide_quest_status_check` — Compare a quest preference with an expected state.
05. `aal_guide_resource_from_property` — Convert a Guide-like daily counter into a structured remaining-resource record.
06. `aal_guide_location_task` — Describe whether a location-based task is currently actionable.
07. `aal_guide_task_filter` — Filter/bound task text for a user or LLM query.
08. `aal_guide_future_task` — Represent future/optional task state without executing it.
09. `aal_guide_advisory_merge` — Merge Guide-like task lanes into bounded labeled context.
10. `aal_guide_agent_context` — Build compact quest-preference context using Guide's advisory orientation.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_guide_task_line`, `aal_guide_resource_line`, `aal_guide_quest_property`, `aal_guide_quest_status_check`, `aal_guide_resource_from_property`, `aal_guide_location_task`, `aal_guide_task_filter`, `aal_guide_future_task`, `aal_guide_advisory_merge`, `aal_guide_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s18_guide.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 19

**URL:** https://github.com/Ezandora/Gain
**PROJECT:** Ezandora Gain
**SOURCE PURPOSE:** Modifier optimizer that indexes effect sources, models costs/efficiency, handles conflicts/limited buffs, and supports simulation.
**INTERESTING EXISTING CAPABILITIES:** Ezandora Gain indexes effect sources, costs, conflicts, limited buffs and simulation.
**MISSING ABSTRACTIONS:** Candidate economics and target gaps can be exposed without acquiring buffs.
**LLM-RUNTIME OPPORTUNITIES:** Modifier gaps, effect efficiency, source cost, conflicts and simulation context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_modifier_state aal_gain_modifier_state(string modifier_name, float target)` | Modifiers | READ_ONLY | Capture current modifier value and target gap. | HIGH |
| 02 | `float aal_gain_effect_modifier(effect e, string modifier_name)` | Modifiers | READ_ONLY | Read one effect's contribution to a modifier. | HIGH |
| 03 | `float aal_gain_effect_efficiency(effect e, string modifier_name, int turns, int estimated_cost)` | Analytics | READ_ONLY | Compute simple cost per modifier-turn for an effect candidate. | HIGH |
| 04 | `string aal_gain_conflict_hint(effect desired, effect[int] exclusive_set)` | Validation | READ_ONLY | Report active mutually-exclusive effects from a caller-supplied conflict set. | HIGH |
| 05 | `agent_check aal_gain_limited_effect_check(effect e, boolean allow_limited)` | Validation | PURE | Apply explicit limited-effect policy to a candidate. | HIGH |
| 06 | `int aal_gain_item_source_cost(item it)` | Items | READ_ONLY | Estimate acquisition cost of an item source without acquiring it. | HIGH |
| 07 | `int aal_gain_skill_source_cost(skill s, int meat_per_mp)` | Skills | READ_ONLY | Estimate a skill buff's MP opportunity cost. | HIGH |
| 08 | `float aal_gain_simulate_additive(string modifier_name, float additional_value)` | Planning | READ_ONLY | Compute a simple non-mutating additive modifier simulation. | HIGH |
| 09 | `float aal_gain_candidate_score(float modifier_gain, int turns, int cost)` | Planning | PURE | Score a modifier source by gain-turns per meat; higher is better. | HIGH |
| 10 | `string aal_gain_agent_context(string modifier_name, float target, int max_effects)` | LLM Context | READ_ONLY | Build bounded context of current modifier and active effects contributing to it. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_gain_modifier_state` — Capture current modifier value and target gap.
02. `aal_gain_effect_modifier` — Read one effect's contribution to a modifier.
03. `aal_gain_effect_efficiency` — Compute simple cost per modifier-turn for an effect candidate.
04. `aal_gain_conflict_hint` — Report active mutually-exclusive effects from a caller-supplied conflict set.
05. `aal_gain_limited_effect_check` — Apply explicit limited-effect policy to a candidate.
06. `aal_gain_item_source_cost` — Estimate acquisition cost of an item source without acquiring it.
07. `aal_gain_skill_source_cost` — Estimate a skill buff's MP opportunity cost.
08. `aal_gain_simulate_additive` — Compute a simple non-mutating additive modifier simulation.
09. `aal_gain_candidate_score` — Score a modifier source by gain-turns per meat; higher is better.
10. `aal_gain_agent_context` — Build bounded context of current modifier and active effects contributing to it.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_gain_modifier_state`, `aal_gain_effect_modifier`, `aal_gain_effect_efficiency`, `aal_gain_conflict_hint`, `aal_gain_limited_effect_check`, `aal_gain_item_source_cost`, `aal_gain_skill_source_cost`, `aal_gain_simulate_additive`, `aal_gain_candidate_score`, `aal_gain_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s19_gain.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 20

**URL:** https://github.com/Astro3207/Gain
**PROJECT:** Astro3207 Gain
**SOURCE PURPOSE:** Gain fork with effect-modifier indexing, source discovery, percentage handling, mutual exclusion, limits, and simulation machinery.
**INTERESTING EXISTING CAPABILITIES:** Astro3207 Gain emphasizes modifier metadata, percent contributions, dynamic expressions and source scoring.
**MISSING ABSTRACTIONS:** Metadata/caching safety and soft-cap math are reusable beyond the CLI optimizer.
**LLM-RUNTIME OPPORTUNITIES:** Modifier-name extraction, source discovery, dynamic hints and soft-cap simulation.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_astrogain_modifier_names(effect e)` | Modifiers | READ_ONLY | Parse an effect's Modifiers string into normalized modifier names. | HIGH |
| 02 | `float aal_astrogain_percentage_stat_value(effect e, stat s)` | Modifiers | READ_ONLY | Combine flat and percent stat modifiers against current base stat for planning. | HIGH |
| 03 | `agent_check aal_astrogain_dynamic_modifier_hint(effect e)` | Validation | READ_ONLY | Flag effect modifier text that contains bracket/quoted expressions and should not be blindly cached. | HIGH |
| 04 | `string aal_astrogain_effect_source_items(effect e, int max_entries)` | Capability Discovery | READ_ONLY | Find bounded item sources whose Effect modifier matches the requested effect. | HIGH |
| 05 | `string aal_astrogain_effect_source_skills(effect e, int max_entries)` | Capability Discovery | READ_ONLY | Find bounded skill sources that map to the requested effect. | HIGH |
| 06 | `float aal_astrogain_combat_rate_softcap(float current, float raw_delta)` | Planning | PURE | Approximate Gain-style combat-rate soft-cap conversion for simulation. | HIGH |
| 07 | `float aal_astrogain_source_efficiency(float modifier_value, int turns, int meat_cost, int mp_cost_value, int meat_per_mp)` | Analytics | PURE | Score a buff source with combined item/meat and MP opportunity costs. | HIGH |
| 08 | `string aal_astrogain_mutual_exclusion_state(effect[int] set_members)` | Validation | READ_ONLY | List active effects in one caller-defined mutually exclusive set. | HIGH |
| 09 | `string aal_astrogain_source_rank_line(string source_name, float efficiency, float modifier_value, int turns)` | Serialization | PURE | Serialize a modifier-source ranking row for external sorting/LLM consumption. | HIGH |
| 10 | `string aal_astrogain_agent_context(effect e, string modifier_name)` | LLM Context | READ_ONLY | Build effect/source/modifier context suitable for an agent planning buff acquisition. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_astrogain_modifier_names` — Parse an effect's Modifiers string into normalized modifier names.
02. `aal_astrogain_percentage_stat_value` — Combine flat and percent stat modifiers against current base stat for planning.
03. `aal_astrogain_dynamic_modifier_hint` — Flag effect modifier text that contains bracket/quoted expressions and should not be blindly cached.
04. `aal_astrogain_effect_source_items` — Find bounded item sources whose Effect modifier matches the requested effect.
05. `aal_astrogain_effect_source_skills` — Find bounded skill sources that map to the requested effect.
06. `aal_astrogain_combat_rate_softcap` — Approximate Gain-style combat-rate soft-cap conversion for simulation.
07. `aal_astrogain_source_efficiency` — Score a buff source with combined item/meat and MP opportunity costs.
08. `aal_astrogain_mutual_exclusion_state` — List active effects in one caller-defined mutually exclusive set.
09. `aal_astrogain_source_rank_line` — Serialize a modifier-source ranking row for external sorting/LLM consumption.
10. `aal_astrogain_agent_context` — Build effect/source/modifier context suitable for an agent planning buff acquisition.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_astrogain_modifier_names`, `aal_astrogain_percentage_stat_value`, `aal_astrogain_dynamic_modifier_hint`, `aal_astrogain_effect_source_items`, `aal_astrogain_effect_source_skills`, `aal_astrogain_combat_rate_softcap`, `aal_astrogain_source_efficiency`, `aal_astrogain_mutual_exclusion_state`, `aal_astrogain_source_rank_line`, `aal_astrogain_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s20_astrogain.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 21

**URL:** https://github.com/Ezandora/Consume
**PROJECT:** Consume
**SOURCE PURPOSE:** Consumption optimizer for food/booze/spleen planning with value-of-adventure and resource-aware selection.
**INTERESTING EXISTING CAPABILITIES:** Consume solves organ-constrained value optimization.
**MISSING ABSTRACTIONS:** Candidate fit/value/density should be inspectable before eating/drinking/using anything.
**LLM-RUNTIME OPPORTUNITIES:** Organ state, candidate records, value density, budget and overdrink risk.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_organ_state aal_consume_organ_state()` | Consumption | READ_ONLY | Capture current fullness, inebriety, and spleen usage/limits. | HIGH |
| 02 | `int aal_consume_organ_remaining(string organ_name)` | Consumption | READ_ONLY | Return remaining capacity for fullness, liver, or spleen by normalized organ name. | HIGH |
| 03 | `agent_consumption_candidate aal_consume_candidate(item it, int size, float expected_adventures, int price)` | Consumption | PURE | Create a normalized consumable candidate with density/value fields. | HIGH |
| 04 | `boolean aal_consume_candidate_fits(agent_consumption_candidate c, string organ_name)` | Validation | READ_ONLY | Check whether a candidate fits the requested organ's remaining capacity. | HIGH |
| 05 | `float aal_consume_candidate_value(agent_consumption_candidate c, int value_of_adventure)` | Planning | PURE | Estimate net adventure value after purchase cost. | HIGH |
| 06 | `float aal_consume_candidate_density(agent_consumption_candidate c, int value_of_adventure)` | Planning | PURE | Estimate net value per organ point. | HIGH |
| 07 | `agent_check aal_consume_budget_check(agent_consumption_candidate c, int meat_budget)` | Validation | PURE | Check candidate price against a caller budget. | HIGH |
| 08 | `agent_check aal_consume_overdrink_risk(int drink_size)` | Validation | READ_ONLY | Describe whether consuming a drink of the given size would exceed the normal liver limit. | HIGH |
| 09 | `string aal_consume_plan_line(agent_consumption_candidate c, string organ_name, int value_of_adventure)` | Serialization | READ_ONLY | Serialize a candidate's fit and economic density for planner/agent sorting. | HIGH |
| 10 | `string aal_consume_agent_context(int value_of_adventure)` | LLM Context | READ_ONLY | Build compact organ/value context for a consumption planner. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_consume_organ_state` — Capture current fullness, inebriety, and spleen usage/limits.
02. `aal_consume_organ_remaining` — Return remaining capacity for fullness, liver, or spleen by normalized organ name.
03. `aal_consume_candidate` — Create a normalized consumable candidate with density/value fields.
04. `aal_consume_candidate_fits` — Check whether a candidate fits the requested organ's remaining capacity.
05. `aal_consume_candidate_value` — Estimate net adventure value after purchase cost.
06. `aal_consume_candidate_density` — Estimate net value per organ point.
07. `aal_consume_budget_check` — Check candidate price against a caller budget.
08. `aal_consume_overdrink_risk` — Describe whether consuming a drink of the given size would exceed the normal liver limit.
09. `aal_consume_plan_line` — Serialize a candidate's fit and economic density for planner/agent sorting.
10. `aal_consume_agent_context` — Build compact organ/value context for a consumption planner.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_consume_organ_state`, `aal_consume_organ_remaining`, `aal_consume_candidate`, `aal_consume_candidate_fits`, `aal_consume_candidate_value`, `aal_consume_candidate_density`, `aal_consume_budget_check`, `aal_consume_overdrink_risk`, `aal_consume_plan_line`, `aal_consume_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s21_consume.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 22

**URL:** https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
**PROJECT:** networth.ash
**SOURCE PURPOSE:** Legacy account valuation using historical/mall/autosell pricing and item-location totals.
**INTERESTING EXISTING CAPABILITIES:** networth.ash values account locations using historical/mall/autosell fallbacks.
**MISSING ABSTRACTIONS:** Pricing policy, quantity scope and snapshots can be explicit and reusable.
**LLM-RUNTIME OPPORTUNITIES:** Unit-price policy, item/account values and valuation snapshots.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_networth_unit_price(item it, int max_historical_age, int historical_cap)` | Finance | READ_ONLY | Modernize networth.ash pricing: autosell for untradeable, fresh historical price when sane, otherwise mall. | HIGH |
| 02 | `int aal_networth_quantity(item it, boolean include_storage)` | Inventory | READ_ONLY | Count relevant item copies for a net-worth calculation. | HIGH |
| 03 | `int aal_networth_item_value(item it, boolean include_storage, int max_historical_age, int historical_cap)` | Finance | READ_ONLY | Value one item's included quantity with the normalized unit-price heuristic. | HIGH |
| 04 | `int aal_networth_location_value(item it, string location_name, int max_historical_age, int historical_cap)` | Finance | READ_ONLY | Value one item in one named account location for explainable net-worth decomposition. | HIGH |
| 05 | `int aal_networth_inventory_value(boolean include_storage, int max_historical_age, int historical_cap)` | Finance | READ_ONLY | Estimate total item value across the source-inspired account locations. | HIGH |
| 06 | `int aal_networth_total(boolean include_storage, int max_historical_age, int historical_cap)` | Finance | READ_ONLY | Estimate liquid meat plus item value. | HIGH |
| 07 | `string aal_networth_item_line(item it, boolean include_storage, int max_historical_age, int historical_cap)` | Serialization | READ_ONLY | Serialize one item's net-worth contribution. | HIGH |
| 08 | `int aal_networth_value_floor(item it)` | Finance | READ_ONLY | Return a conservative non-negative value floor from autosell/NPC pricing. | HIGH |
| 09 | `agent_value_snapshot aal_networth_snapshot(boolean include_storage, int max_historical_age, int historical_cap, int stamp)` | Tracking | READ_ONLY | Capture a net-worth snapshot suitable for later delta comparison. | HIGH |
| 10 | `string aal_networth_agent_context(boolean include_storage, int max_historical_age, int historical_cap)` | LLM Context | READ_ONLY | Build compact valuation policy/current-total context. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_networth_unit_price` — Modernize networth.ash pricing: autosell for untradeable, fresh historical price when sane, otherwise mall.
02. `aal_networth_quantity` — Count relevant item copies for a net-worth calculation.
03. `aal_networth_item_value` — Value one item's included quantity with the normalized unit-price heuristic.
04. `aal_networth_location_value` — Value one item in one named account location for explainable net-worth decomposition.
05. `aal_networth_inventory_value` — Estimate total item value across the source-inspired account locations.
06. `aal_networth_total` — Estimate liquid meat plus item value.
07. `aal_networth_item_line` — Serialize one item's net-worth contribution.
08. `aal_networth_value_floor` — Return a conservative non-negative value floor from autosell/NPC pricing.
09. `aal_networth_snapshot` — Capture a net-worth snapshot suitable for later delta comparison.
10. `aal_networth_agent_context` — Build compact valuation policy/current-total context.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_networth_unit_price`, `aal_networth_quantity`, `aal_networth_item_value`, `aal_networth_location_value`, `aal_networth_inventory_value`, `aal_networth_total`, `aal_networth_item_line`, `aal_networth_value_floor`, `aal_networth_snapshot`, `aal_networth_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s22_networth.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 23

**URL:** https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
**PROJECT:** rollover.ash
**SOURCE PURPOSE:** Rollover optimizer/reminder checking rollover gear, unused daily resources, organ capacity, wand state, VIP actions, and MP waste.
**INTERESTING EXISTING CAPABILITIES:** rollover.ash checks equipment/resources/organs/MP and warns before rollover.
**MISSING ABSTRACTIONS:** Reminder evidence can be expressed without changing gear or spending resources.
**LLM-RUNTIME OPPORTUNITIES:** Organ gaps, MP waste, resource counters and readiness warnings.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_rollover_organ_gaps()` | Rollover | READ_ONLY | Serialize unused organ capacity before rollover. | HIGH |
| 02 | `int aal_rollover_mp_waste(int expected_rollover_mp)` | Rollover | READ_ONLY | Estimate rollover MP that would exceed current maximum MP. | HIGH |
| 03 | `agent_resource_state aal_rollover_still_state()` | Resources | READ_ONLY | Expose remaining still uses as a rollover resource. | HIGH |
| 04 | `agent_resource_state aal_rollover_pull_state()` | Resources | READ_ONLY | Expose remaining pulls as rollover context. | HIGH |
| 05 | `item aal_rollover_wand_candidate()` | Items | READ_ONLY | Return the first known wand item currently available. | HIGH |
| 06 | `agent_resource_state aal_rollover_daily_resource(string label, string used_property, int limit_value)` | Resources | READ_ONLY | Normalize a rollover-relevant daily preference into remaining-use state. | HIGH |
| 07 | `int aal_rollover_readiness_score(int expected_rollover_mp)` | Planning | READ_ONLY | Compute a simple reminder pressure score from organ gaps, MP waste, stills, and pulls. | HIGH |
| 08 | `string aal_rollover_warning_lines(int expected_rollover_mp)` | Planning | READ_ONLY | Build deterministic rollover warnings without changing equipment/resources. | HIGH |
| 09 | `agent_check aal_rollover_ready_check(int expected_rollover_mp)` | Validation | READ_ONLY | Return ready only when the source-inspired warning set is empty. | HIGH |
| 10 | `string aal_rollover_agent_context(int expected_rollover_mp)` | LLM Context | READ_ONLY | Build compact rollover state for an agent/user reminder surface. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_rollover_organ_gaps` — Serialize unused organ capacity before rollover.
02. `aal_rollover_mp_waste` — Estimate rollover MP that would exceed current maximum MP.
03. `aal_rollover_still_state` — Expose remaining still uses as a rollover resource.
04. `aal_rollover_pull_state` — Expose remaining pulls as rollover context.
05. `aal_rollover_wand_candidate` — Return the first known wand item currently available.
06. `aal_rollover_daily_resource` — Normalize a rollover-relevant daily preference into remaining-use state.
07. `aal_rollover_readiness_score` — Compute a simple reminder pressure score from organ gaps, MP waste, stills, and pulls.
08. `aal_rollover_warning_lines` — Build deterministic rollover warnings without changing equipment/resources.
09. `aal_rollover_ready_check` — Return ready only when the source-inspired warning set is empty.
10. `aal_rollover_agent_context` — Build compact rollover state for an agent/user reminder surface.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_rollover_organ_gaps`, `aal_rollover_mp_waste`, `aal_rollover_still_state`, `aal_rollover_pull_state`, `aal_rollover_wand_candidate`, `aal_rollover_daily_resource`, `aal_rollover_readiness_score`, `aal_rollover_warning_lines`, `aal_rollover_ready_check`, `aal_rollover_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s23_rollover.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 24

**URL:** https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
**PROJECT:** testout.ash
**SOURCE PURPOSE:** Minimal vprint test script; useful as inspiration for standardized diagnostics and smoke probes.
**INTERESTING EXISTING CAPABILITIES:** testout.ash is intentionally minimal and tests output plumbing.
**MISSING ABSTRACTIONS:** A reusable diagnostics record is more valuable than a one-line print.
**LLM-RUNTIME OPPORTUNITIES:** Typed smoke results, summaries, failure filtering and runtime probes.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_diagnostic aal_testout_bool(string name, boolean actual, boolean expected)` | Debugging | PURE | Create a structured boolean smoke-test result. | HIGH |
| 02 | `agent_diagnostic aal_testout_cardinality(string name, int actual_count, int minimum_count, int maximum_count)` | Validation | PURE | Create a structured collection-cardinality diagnostic with explicit bounds. | HIGH |
| 03 | `agent_diagnostic aal_testout_required_keys(string name, string[string] fields, string[int] required_keys)` | Validation | PURE | Validate that a string map contains every required schema key and report missing keys. | HIGH |
| 04 | `agent_diagnostic aal_testout_range(string name, float actual, float minimum, float maximum)` | Debugging | PURE | Create a diagnostic for an inclusive numeric range. | HIGH |
| 05 | `string aal_testout_line(agent_diagnostic d)` | Serialization | PURE | Serialize a diagnostic in compact TSV form. | HIGH |
| 06 | `int aal_testout_assertion_count(agent_diagnostic[int] results, boolean passed)` | Debugging | PURE | Count passing or failing diagnostics. | HIGH |
| 07 | `string aal_testout_summary(agent_diagnostic[int] results)` | Debugging | PURE | Summarize diagnostic pass/fail counts. | HIGH |
| 08 | `string aal_testout_failures(agent_diagnostic[int] results, int max_entries)` | Debugging | PURE | Emit bounded failing diagnostic rows. | HIGH |
| 09 | `string aal_testout_runtime_probe()` | Debugging | READ_ONLY | Capture a harmless runtime probe replacing the original one-line vprint smoke idea with structured state. | HIGH |
| 10 | `string aal_testout_agent_context(agent_diagnostic[int] results)` | LLM Context | PURE | Build concise machine-readable test context. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_testout_bool` — Create a structured boolean smoke-test result.
02. `aal_testout_cardinality` — Create a structured collection-cardinality diagnostic with explicit bounds.
03. `aal_testout_required_keys` — Validate that a string map contains every required schema key and report missing keys.
04. `aal_testout_range` — Create a diagnostic for an inclusive numeric range.
05. `aal_testout_line` — Serialize a diagnostic in compact TSV form.
06. `aal_testout_assertion_count` — Count passing or failing diagnostics.
07. `aal_testout_summary` — Summarize diagnostic pass/fail counts.
08. `aal_testout_failures` — Emit bounded failing diagnostic rows.
09. `aal_testout_runtime_probe` — Capture a harmless runtime probe replacing the original one-line vprint smoke idea with structured state.
10. `aal_testout_agent_context` — Build concise machine-readable test context.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_testout_bool`, `aal_testout_cardinality`, `aal_testout_required_keys`, `aal_testout_range`, `aal_testout_line`, `aal_testout_assertion_count`, `aal_testout_summary`, `aal_testout_failures`, `aal_testout_runtime_probe`, `aal_testout_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s24_testout.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 25

**URL:** https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
**PROJECT:** bootstrap.ash
**SOURCE PURPOSE:** Legacy initial-ascension setup that pulls/uses starter items, visits tutorial, builds meatcar, and buys detuned radio.
**INTERESTING EXISTING CAPABILITIES:** bootstrap.ash performs one-time early-run pulls, uses, crafting and purchases.
**MISSING ABSTRACTIONS:** The initial-state checklist should be observable before mutation.
**LLM-RUNTIME OPPORTUNITIES:** Starter item state, pull needs, use previews and setup readiness.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_bootstrap_starter_items()` | Ascension | PURE | Return the legacy bootstrap's starter-item targets in deterministic order. | HIGH |
| 02 | `string aal_bootstrap_item_state(item it)` | Inventory | READ_ONLY | Describe inventory/storage availability of a bootstrap target. | HIGH |
| 03 | `int aal_bootstrap_pull_need(item it, int required)` | Planning | READ_ONLY | Calculate how many copies would need to be pulled from storage to meet a bootstrap requirement. | HIGH |
| 04 | `agent_action_preview aal_bootstrap_use_preview(item it)` | Planning | READ_ONLY | Preview whether a starter item is currently in inventory for use. | HIGH |
| 05 | `string aal_bootstrap_meatcar_state()` | Ascension | READ_ONLY | Describe whether the meatcar is owned or creatable before attempting construction. | HIGH |
| 06 | `string aal_bootstrap_radio_state()` | Ascension | READ_ONLY | Describe detuned-radio ownership and NPC price context. | HIGH |
| 07 | `string aal_bootstrap_step_status(string step_name, boolean complete, string evidence)` | Serialization | PURE | Serialize one bootstrap step and its evidence. | HIGH |
| 08 | `string aal_bootstrap_missing_steps()` | Planning | READ_ONLY | List obvious remaining bootstrap targets without executing them. | HIGH |
| 09 | `agent_check aal_bootstrap_readiness()` | Validation | READ_ONLY | Check whether core bootstrap travel/setup targets are already present. | HIGH |
| 10 | `string aal_bootstrap_agent_context()` | LLM Context | READ_ONLY | Build compact initial-ascension setup context. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_bootstrap_starter_items` — Return the legacy bootstrap's starter-item targets in deterministic order.
02. `aal_bootstrap_item_state` — Describe inventory/storage availability of a bootstrap target.
03. `aal_bootstrap_pull_need` — Calculate how many copies would need to be pulled from storage to meet a bootstrap requirement.
04. `aal_bootstrap_use_preview` — Preview whether a starter item is currently in inventory for use.
05. `aal_bootstrap_meatcar_state` — Describe whether the meatcar is owned or creatable before attempting construction.
06. `aal_bootstrap_radio_state` — Describe detuned-radio ownership and NPC price context.
07. `aal_bootstrap_step_status` — Serialize one bootstrap step and its evidence.
08. `aal_bootstrap_missing_steps` — List obvious remaining bootstrap targets without executing them.
09. `aal_bootstrap_readiness` — Check whether core bootstrap travel/setup targets are already present.
10. `aal_bootstrap_agent_context` — Build compact initial-ascension setup context.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_bootstrap_starter_items`, `aal_bootstrap_item_state`, `aal_bootstrap_pull_need`, `aal_bootstrap_use_preview`, `aal_bootstrap_meatcar_state`, `aal_bootstrap_radio_state`, `aal_bootstrap_step_status`, `aal_bootstrap_missing_steps`, `aal_bootstrap_readiness`, `aal_bootstrap_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s25_bootstrap.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 26

**URL:** https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
**PROJECT:** OCD Inventory Control.ash
**SOURCE PURPOSE:** Malformed supplied URL resolved by GitHub code search to scripts/OCD Inventory Control.ash; inventory disposition and cleanup policy engine.
**INTERESTING EXISTING CAPABILITIES:** OCD Inventory Control applies per-item disposition rules to excess inventory.
**MISSING ABSTRACTIONS:** Rule conflicts, excess counts and liquidation impact should be previewable.
**LLM-RUNTIME OPPORTUNITIES:** Disposition policy validation, excess/value previews and missing-rule context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_ocd_owned_total(item it)` | Inventory | READ_ONLY | Count copies across common personal item locations for disposition planning. | HIGH |
| 02 | `int aal_ocd_excess_quantity(item it, int keep_amount)` | Inventory | READ_ONLY | Compute copies above a configured keep quantity. | HIGH |
| 03 | `agent_check aal_ocd_policy_validate(string action, int keep_amount)` | Validation | PURE | Validate a disposition action/keep quantity without performing inventory changes. | HIGH |
| 04 | `agent_action_preview aal_ocd_disposition_preview(item it, string action, int keep_amount)` | Planning | READ_ONLY | Preview quantity and action for an OCD-style inventory rule. | HIGH |
| 05 | `int aal_ocd_liquidation_value(item it, string action, int keep_amount)` | Finance | READ_ONLY | Estimate gross liquidation value of an OCD rule without executing it. | HIGH |
| 06 | `agent_check aal_ocd_rule_conflict(string action_a, int keep_a, string action_b, int keep_b)` | Validation | PURE | Detect conflicting duplicate disposition rules. | HIGH |
| 07 | `string aal_ocd_missing_rule_context(item[int] inventory_items, boolean[item] ruled_items, int max_entries)` | Debugging | READ_ONLY | List owned items lacking a caller-provided OCD policy map. | HIGH |
| 08 | `int aal_ocd_cleanup_count(item[int] items, int[item] keep_amounts)` | Analytics | READ_ONLY | Count total copies above configured keep amounts across a caller item list. | HIGH |
| 09 | `string aal_ocd_rule_line(item it, string action, int keep_amount)` | Serialization | READ_ONLY | Serialize rule plus current ownership/excess as TSV. | HIGH |
| 10 | `string aal_ocd_agent_context(item[int] items, string[item] actions, int[item] keep_amounts, int max_entries)` | LLM Context | READ_ONLY | Build bounded disposition context for policy review before execution. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_ocd_owned_total` — Count copies across common personal item locations for disposition planning.
02. `aal_ocd_excess_quantity` — Compute copies above a configured keep quantity.
03. `aal_ocd_policy_validate` — Validate a disposition action/keep quantity without performing inventory changes.
04. `aal_ocd_disposition_preview` — Preview quantity and action for an OCD-style inventory rule.
05. `aal_ocd_liquidation_value` — Estimate gross liquidation value of an OCD rule without executing it.
06. `aal_ocd_rule_conflict` — Detect conflicting duplicate disposition rules.
07. `aal_ocd_missing_rule_context` — List owned items lacking a caller-provided OCD policy map.
08. `aal_ocd_cleanup_count` — Count total copies above configured keep amounts across a caller item list.
09. `aal_ocd_rule_line` — Serialize rule plus current ownership/excess as TSV.
10. `aal_ocd_agent_context` — Build bounded disposition context for policy review before execution.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_ocd_owned_total`, `aal_ocd_excess_quantity`, `aal_ocd_policy_validate`, `aal_ocd_disposition_preview`, `aal_ocd_liquidation_value`, `aal_ocd_rule_conflict`, `aal_ocd_missing_rule_context`, `aal_ocd_cleanup_count`, `aal_ocd_rule_line`, `aal_ocd_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s26_ocd.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 27

**URL:** https://github.com/C2Talon/insertSelect2-relays
**PROJECT:** insertSelect2-relays
**SOURCE PURPOSE:** Relay enhancement project for select controls/searchability; inspiration for deterministic option filtering and selection descriptions.
**INTERESTING EXISTING CAPABILITIES:** insertSelect2-relays enhances large relay selects with search/filter UX.
**MISSING ABSTRACTIONS:** The search semantics can be shared with agents without depending on browser JavaScript.
**LLM-RUNTIME OPPORTUNITIES:** Normalized option records, token matching, duplicate validation and compact search context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_option aal_select2_option(string value, string label, boolean selected, boolean enabled)` | Relay / UI | PURE | Create a normalized searchable select option record. | HIGH |
| 02 | `int aal_select2_match_score(agent_option o, string query)` | Query | PURE | Score an option against a case-insensitive query using exact/prefix/substring matches. | HIGH |
| 03 | `string aal_select2_filter(agent_option[int] options, string query, int max_entries)` | Relay / UI | PURE | Filter select options into deterministic TSV rows for search/autocomplete. | HIGH |
| 04 | `string aal_select2_selected_value(agent_option[int] options)` | Relay / UI | PURE | Return the first selected enabled option value. | HIGH |
| 05 | `string aal_select2_duplicate_values(agent_option[int] options)` | Validation | PURE | Report duplicate option values that make selection ambiguous. | HIGH |
| 06 | `agent_check aal_select2_option_validate(agent_option o)` | Validation | PURE | Validate a searchable option has stable value/label fields. | HIGH |
| 07 | `string aal_select2_query_tokens(string query)` | Normalization | PURE | Normalize whitespace-separated query tokens for relay search. | HIGH |
| 08 | `boolean aal_select2_all_tokens_match(agent_option o, string query)` | Query | PURE | Require every normalized query token to appear in option value or label. | HIGH |
| 09 | `string aal_select2_option_tsv(agent_option o)` | Serialization | PURE | Serialize one select option. | HIGH |
| 10 | `string aal_select2_agent_context(agent_option[int] options, string query, int max_entries)` | LLM Context | PURE | Build compact searchable option context for an agent choosing a relay value. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_select2_option` — Create a normalized searchable select option record.
02. `aal_select2_match_score` — Score an option against a case-insensitive query using exact/prefix/substring matches.
03. `aal_select2_filter` — Filter select options into deterministic TSV rows for search/autocomplete.
04. `aal_select2_selected_value` — Return the first selected enabled option value.
05. `aal_select2_duplicate_values` — Report duplicate option values that make selection ambiguous.
06. `aal_select2_option_validate` — Validate a searchable option has stable value/label fields.
07. `aal_select2_query_tokens` — Normalize whitespace-separated query tokens for relay search.
08. `aal_select2_all_tokens_match` — Require every normalized query token to appear in option value or label.
09. `aal_select2_option_tsv` — Serialize one select option.
10. `aal_select2_agent_context` — Build compact searchable option context for an agent choosing a relay value.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_select2_option`, `aal_select2_match_score`, `aal_select2_filter`, `aal_select2_selected_value`, `aal_select2_duplicate_values`, `aal_select2_option_validate`, `aal_select2_query_tokens`, `aal_select2_all_tokens_match`, `aal_select2_option_tsv`, `aal_select2_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s27_select2.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 28

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
**PROJECT:** htmlform.ash
**SOURCE PURPOSE:** Relay HTML form construction, field helpers, validation, attributes, and save/cancel interactions.
**INTERESTING EXISTING CAPABILITIES:** htmlform.ash centralizes relay form field construction/validation.
**MISSING ABSTRACTIONS:** Modern callers benefit from schema and change-plan representations separate from rendering.
**LLM-RUNTIME OPPORTUNITIES:** Escaping, typed validation, change rows, error summaries and field context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_htmlform_escape(string value)` | Relay / UI | PURE | Escape basic HTML-sensitive characters for form output. | HIGH |
| 02 | `agent_check aal_htmlform_field_validate(string name, string value, boolean required)` | Validation | PURE | Validate basic relay form field presence. | HIGH |
| 03 | `agent_check aal_htmlform_int_validate(string name, string value, int minimum, int maximum)` | Validation | PURE | Validate an integer form value against inclusive bounds. | HIGH |
| 04 | `boolean aal_htmlform_bool_normalize(string value)` | Normalization | PURE | Normalize common form boolean encodings. | HIGH |
| 05 | `string aal_htmlform_field_schema(string name, string type_name, string default_value, string description)` | Serialization | PURE | Serialize a form field schema for human/agent tooling. | HIGH |
| 06 | `agent_check aal_htmlform_select_validate(string value, string[int] allowed_values)` | Validation | PURE | Check that a submitted select value belongs to the allowed set. | HIGH |
| 07 | `boolean aal_htmlform_changed(string old_value, string submitted_value)` | Diff / Change Detection | PURE | Check whether a submitted field actually changes persisted value. | HIGH |
| 08 | `string aal_htmlform_change_line(string name, string old_value, string submitted_value)` | Serialization | PURE | Serialize a proposed form change without applying it. | HIGH |
| 09 | `string aal_htmlform_error_summary(agent_check[int] checks)` | Validation | PURE | Serialize failing field validations. | HIGH |
| 10 | `string aal_htmlform_agent_context(string[string] fields, int max_entries)` | LLM Context | PURE | Serialize submitted form fields with deterministic key ordering and bounded size. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_htmlform_escape` — Escape basic HTML-sensitive characters for form output.
02. `aal_htmlform_field_validate` — Validate basic relay form field presence.
03. `aal_htmlform_int_validate` — Validate an integer form value against inclusive bounds.
04. `aal_htmlform_bool_normalize` — Normalize common form boolean encodings.
05. `aal_htmlform_field_schema` — Serialize a form field schema for human/agent tooling.
06. `aal_htmlform_select_validate` — Check that a submitted select value belongs to the allowed set.
07. `aal_htmlform_changed` — Check whether a submitted field actually changes persisted value.
08. `aal_htmlform_change_line` — Serialize a proposed form change without applying it.
09. `aal_htmlform_error_summary` — Serialize failing field validations.
10. `aal_htmlform_agent_context` — Serialize submitted form fields with deterministic key ordering and bounded size.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_htmlform_escape`, `aal_htmlform_field_validate`, `aal_htmlform_int_validate`, `aal_htmlform_bool_normalize`, `aal_htmlform_field_schema`, `aal_htmlform_select_validate`, `aal_htmlform_changed`, `aal_htmlform_change_line`, `aal_htmlform_error_summary`, `aal_htmlform_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s28_htmlform.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 29

**URL:** https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
**PROJECT:** BatBrain.ash
**SOURCE PURPOSE:** Combat reasoning engine with event/spread modeling, adjusted stats, action valuation, resource costs, monster value, and combat environment construction.
**INTERESTING EXISTING CAPABILITIES:** BatBrain models combat events, stats, costs and action value.
**MISSING ABSTRACTIONS:** A modern agent needs a smaller observation/planning subset without importing the whole combat engine.
**LLM-RUNTIME OPPORTUNITIES:** Combat snapshots, resource/survival checks, value estimates and action previews.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `agent_combat_state aal_batbrain_combat_state()` | Combat | READ_ONLY | Capture current combat-relevant monster/player stats without taking an action. | HIGH |
| 02 | `int aal_batbrain_hit_survival_margin(int expected_damage)` | Combat | READ_ONLY | Compute player HP remaining after hypothetical damage. | HIGH |
| 03 | `int aal_batbrain_skill_mp_margin(skill s, int casts)` | Combat | READ_ONLY | Compute MP remaining after hypothetical repeated skill use. | HIGH |
| 04 | `agent_check aal_batbrain_action_resource_check(skill s, int casts)` | Validation | READ_ONLY | Validate skill ownership and MP for a hypothetical combat action. | HIGH |
| 05 | `float aal_batbrain_monster_meat_value(monster m)` | Combat / Finance | READ_ONLY | Estimate base monster meat value after current meat-drop modifier. | HIGH |
| 06 | `float aal_batbrain_runaway_value(monster m, int value_of_adventure)` | Combat / Planning | READ_ONLY | Estimate opportunity cost of running away as monster base meat plus one adventure value. | HIGH |
| 07 | `int aal_batbrain_beaten_up_turn_cost(int value_of_adventure)` | Combat / Planning | PURE | Value the canonical three-adventure Beaten Up opportunity cost floor. | HIGH |
| 08 | `string aal_batbrain_element_context(monster m)` | Combat | READ_ONLY | Serialize monster element and player elemental resistances for combat planning. | HIGH |
| 09 | `agent_action_preview aal_batbrain_action_preview(string action_label, int expected_damage, int mp_cost_value, int value_cost)` | Planning | READ_ONLY | Create a non-mutating combat action preview with HP/MP/value checks. | HIGH |
| 10 | `string aal_batbrain_agent_context(int value_of_adventure)` | LLM Context | READ_ONLY | Build compact BatBrain-inspired combat context for an LLM without producing/executing a macro. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_batbrain_combat_state` — Capture current combat-relevant monster/player stats without taking an action.
02. `aal_batbrain_hit_survival_margin` — Compute player HP remaining after hypothetical damage.
03. `aal_batbrain_skill_mp_margin` — Compute MP remaining after hypothetical repeated skill use.
04. `aal_batbrain_action_resource_check` — Validate skill ownership and MP for a hypothetical combat action.
05. `aal_batbrain_monster_meat_value` — Estimate base monster meat value after current meat-drop modifier.
06. `aal_batbrain_runaway_value` — Estimate opportunity cost of running away as monster base meat plus one adventure value.
07. `aal_batbrain_beaten_up_turn_cost` — Value the canonical three-adventure Beaten Up opportunity cost floor.
08. `aal_batbrain_element_context` — Serialize monster element and player elemental resistances for combat planning.
09. `aal_batbrain_action_preview` — Create a non-mutating combat action preview with HP/MP/value checks.
10. `aal_batbrain_agent_context` — Build compact BatBrain-inspired combat context for an LLM without producing/executing a macro.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_batbrain_combat_state`, `aal_batbrain_hit_survival_margin`, `aal_batbrain_skill_mp_margin`, `aal_batbrain_action_resource_check`, `aal_batbrain_monster_meat_value`, `aal_batbrain_runaway_value`, `aal_batbrain_beaten_up_turn_cost`, `aal_batbrain_element_context`, `aal_batbrain_action_preview`, `aal_batbrain_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s29_batbrain.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 30

**URL:** https://github.com/C2Talon/liba
**PROJECT:** liba
**SOURCE PURPOSE:** Modern small composable ASH helpers plus resource-specific modules for choices, combat checks, equip-cast, properties, priorities, and IOTMs.
**INTERESTING EXISTING CAPABILITIES:** liba favors small composable helpers and narrow resource modules.
**MISSING ABSTRACTIONS:** The micro-helper pattern can add explainability and context without duplicating thin aliases.
**LLM-RUNTIME OPPORTUNITIES:** Normalized clamp/tokens, explainable priorities, preflights and resource context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `float aal_liba_clamp_normalized(float value, float low, float high)` | Math | PURE | Clamp while safely normalizing reversed bounds. | HIGH |
| 02 | `boolean aal_liba_tokens_all_present(string haystack, string[int] tokens)` | Query | PURE | Check that every non-empty token occurs case-insensitively in text. | HIGH |
| 03 | `agent_delta aal_liba_property_increment_preview(string property_name, int delta)` | Planning | READ_ONLY | Preview integer preference increment without writing it. | HIGH |
| 04 | `string aal_liba_priority_item_reason(item[int] candidates)` | Capability Discovery | READ_ONLY | Select the first available item and explain the priority position. | HIGH |
| 05 | `string aal_liba_choice_context()` | Choices | READ_ONLY | Return compact current-choice context inspired by liba_inChoice. | HIGH |
| 06 | `string aal_liba_combat_context()` | Combat | READ_ONLY | Return compact combat indicators inspired by liba_inCombat without executing requests. | HIGH |
| 07 | `agent_check aal_liba_equip_cast_preflight(item gear, skill s, int casts)` | Validation | READ_ONLY | Check equip/cast prerequisites and MP without changing equipment. | HIGH |
| 08 | `agent_check aal_liba_raw_use_preflight(item it)` | Validation | READ_ONLY | Describe whether an item is present for low-level/raw-use logic, without using it. | HIGH |
| 09 | `string aal_liba_resource_module_context(item key_item, string[int] preference_names)` | LLM Context | READ_ONLY | Build generic context for one of liba's resource-specific IOTM modules. | HIGH |
| 10 | `string aal_liba_micro_context(string label, string[int] preference_names, item[int] items)` | LLM Context | READ_ONLY | Compose tiny reusable preference/item context in the spirit of liba's focused modules. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_liba_clamp_normalized` — Clamp while safely normalizing reversed bounds.
02. `aal_liba_tokens_all_present` — Check that every non-empty token occurs case-insensitively in text.
03. `aal_liba_property_increment_preview` — Preview integer preference increment without writing it.
04. `aal_liba_priority_item_reason` — Select the first available item and explain the priority position.
05. `aal_liba_choice_context` — Return compact current-choice context inspired by liba_inChoice.
06. `aal_liba_combat_context` — Return compact combat indicators inspired by liba_inCombat without executing requests.
07. `aal_liba_equip_cast_preflight` — Check equip/cast prerequisites and MP without changing equipment.
08. `aal_liba_raw_use_preflight` — Describe whether an item is present for low-level/raw-use logic, without using it.
09. `aal_liba_resource_module_context` — Build generic context for one of liba's resource-specific IOTM modules.
10. `aal_liba_micro_context` — Compose tiny reusable preference/item context in the spirit of liba's focused modules.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_liba_clamp_normalized`, `aal_liba_tokens_all_present`, `aal_liba_property_increment_preview`, `aal_liba_priority_item_reason`, `aal_liba_choice_context`, `aal_liba_combat_context`, `aal_liba_equip_cast_preflight`, `aal_liba_raw_use_preflight`, `aal_liba_resource_module_context`, `aal_liba_micro_context`

**FILES CREATED/MODIFIED:** `lib/aal_s30_liba.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 31

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
**PROJECT:** FunctionLib.ash
**SOURCE PURPOSE:** Legacy general utility library for ownership, acquisition/use, stash/shop, recovery, equipment, familiars, still, and resistance.
**INTERESTING EXISTING CAPABILITIES:** FunctionLib.ash bundles ownership, acquisition/use, stash, recovery, gear, familiar and wand helpers.
**MISSING ABSTRACTIONS:** Legacy mutating convenience calls benefit from read/plan separation.
**LLM-RUNTIME OPPORTUNITIES:** Ownership locations, acquisition gaps, transfer/recovery/cast previews.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_functionlib_ownership_locations(item it)` | Inventory | READ_ONLY | Expose where an item is currently held instead of collapsing ownership to a boolean. | HIGH |
| 02 | `string aal_functionlib_acquisition_gap(item it, int desired)` | Planning | READ_ONLY | Compute inventory shortfall and nearby source counts without acquiring anything. | HIGH |
| 03 | `string aal_functionlib_consumption_kind(item it)` | Items | READ_ONLY | Describe likely consumption channel from native item metadata. | HIGH |
| 04 | `agent_range_state aal_functionlib_familiar_training_gap(familiar fam, int target_weight)` | Familiar | READ_ONLY | Measure familiar base-weight gap before any training action. | HIGH |
| 05 | `agent_check aal_functionlib_equipment_preflight(item it)` | Equipment | READ_ONLY | Check possession/equipability and current equip state without equipping. | HIGH |
| 06 | `agent_action_preview aal_functionlib_stash_transfer_preview(string direction, item it, int quantity)` | Planning | READ_ONLY | Preview a stash take/put operation and available quantity without moving items. | HIGH |
| 07 | `string aal_functionlib_recovery_gap(int target_hp)` | Recovery | READ_ONLY | Measure HP recovery gap and Beaten Up state without recovering. | HIGH |
| 08 | `agent_check aal_functionlib_skill_preflight(skill s, int casts)` | Skills | READ_ONLY | Check ownership and MP for repeated skill use without casting. | HIGH |
| 09 | `string aal_functionlib_wand_inventory()` | Items | READ_ONLY | Serialize all five zap-wand IDs currently owned/available. | HIGH |
| 10 | `string aal_functionlib_agent_context(item it, familiar fam, skill s)` | LLM Context | READ_ONLY | Build compact utility context combining ownership, familiar, and skill readiness. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_functionlib_ownership_locations` — Expose where an item is currently held instead of collapsing ownership to a boolean.
02. `aal_functionlib_acquisition_gap` — Compute inventory shortfall and nearby source counts without acquiring anything.
03. `aal_functionlib_consumption_kind` — Describe likely consumption channel from native item metadata.
04. `aal_functionlib_familiar_training_gap` — Measure familiar base-weight gap before any training action.
05. `aal_functionlib_equipment_preflight` — Check possession/equipability and current equip state without equipping.
06. `aal_functionlib_stash_transfer_preview` — Preview a stash take/put operation and available quantity without moving items.
07. `aal_functionlib_recovery_gap` — Measure HP recovery gap and Beaten Up state without recovering.
08. `aal_functionlib_skill_preflight` — Check ownership and MP for repeated skill use without casting.
09. `aal_functionlib_wand_inventory` — Serialize all five zap-wand IDs currently owned/available.
10. `aal_functionlib_agent_context` — Build compact utility context combining ownership, familiar, and skill readiness.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_functionlib_ownership_locations`, `aal_functionlib_acquisition_gap`, `aal_functionlib_consumption_kind`, `aal_functionlib_familiar_training_gap`, `aal_functionlib_equipment_preflight`, `aal_functionlib_stash_transfer_preview`, `aal_functionlib_recovery_gap`, `aal_functionlib_skill_preflight`, `aal_functionlib_wand_inventory`, `aal_functionlib_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s31_functionlib.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 32

**URL:** https://github.com/C2Talon/c2t_lib
**PROJECT:** c2t_lib
**SOURCE PURPOSE:** Shared modern helper library covering assertions, clans, wanderers, choices, priorities, maximizer caching, equip-cast, buying, and macro building.
**INTERESTING EXISTING CAPABILITIES:** c2t_lib covers wanderers, choices, priority, maximizer tricks, free adventures, buying and macro building.
**MISSING ABSTRACTIONS:** These can expose predictions/diagnostics before calling low-level actions.
**LLM-RUNTIME OPPORTUNITIES:** Wanderer readiness, pilcrow decoding, free-adventure/purchase preflights and macro descriptions.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `float aal_c2lib_sausage_odds()` | Wanderers | READ_ONLY | Recompute c2t_lib-inspired sausage goblin odds without equipping or adventuring. | HIGH |
| 02 | `boolean aal_c2lib_sausage_ready()` | Wanderers | READ_ONLY | Check whether the sausage wanderer threshold is currently met. | HIGH |
| 03 | `string aal_c2lib_void_state()` | Wanderers | READ_ONLY | Expose cursed magnifying glass charge/free-fight state. | HIGH |
| 04 | `agent_check aal_c2lib_choice_expectation(int expected_choice)` | Validation | READ_ONLY | Validate exact active choice ID. | HIGH |
| 05 | `string aal_c2lib_pilcrow_items(string maximizer_expression)` | Normalization | PURE | Decode pilcrow item tokens from a maximizer expression into typed item rows for troubleshooting. | HIGH |
| 06 | `string aal_c2lib_priority_item_context(item[int] candidates)` | Capability Discovery | READ_ONLY | Return first available item plus all candidate availability for explainable priority. | HIGH |
| 07 | `string aal_c2lib_maximize_key(string maximizer_expression)` | Normalization | PURE | Normalize a maximizer expression into a lightweight cache-comparison key. | HIGH |
| 08 | `agent_check aal_c2lib_free_adventure_preflight(location loc)` | Validation | READ_ONLY | Snapshot turn count and accessibility before a caller attempts a supposedly free adventure. | HIGH |
| 09 | `agent_action_preview aal_c2lib_purchase_budget(item it, int quantity, int max_unit_price)` | Planning | READ_ONLY | Estimate mall cost/budget fit without invoking c2t_buy. | HIGH |
| 10 | `string aal_c2lib_macro_description(string macro_text)` | Combat / Describe | PURE | Describe BALLS-style combat macro structure without submitting it. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_c2lib_sausage_odds` — Recompute c2t_lib-inspired sausage goblin odds without equipping or adventuring.
02. `aal_c2lib_sausage_ready` — Check whether the sausage wanderer threshold is currently met.
03. `aal_c2lib_void_state` — Expose cursed magnifying glass charge/free-fight state.
04. `aal_c2lib_choice_expectation` — Validate exact active choice ID.
05. `aal_c2lib_pilcrow_items` — Decode pilcrow item tokens from a maximizer expression into typed item rows for troubleshooting.
06. `aal_c2lib_priority_item_context` — Return first available item plus all candidate availability for explainable priority.
07. `aal_c2lib_maximize_key` — Normalize a maximizer expression into a lightweight cache-comparison key.
08. `aal_c2lib_free_adventure_preflight` — Snapshot turn count and accessibility before a caller attempts a supposedly free adventure.
09. `aal_c2lib_purchase_budget` — Estimate mall cost/budget fit without invoking c2t_buy.
10. `aal_c2lib_macro_description` — Describe BALLS-style combat macro structure without submitting it.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_c2lib_sausage_odds`, `aal_c2lib_sausage_ready`, `aal_c2lib_void_state`, `aal_c2lib_choice_expectation`, `aal_c2lib_pilcrow_items`, `aal_c2lib_priority_item_context`, `aal_c2lib_maximize_key`, `aal_c2lib_free_adventure_preflight`, `aal_c2lib_purchase_budget`, `aal_c2lib_macro_description`

**FILES CREATED/MODIFIED:** `lib/aal_s32_c2lib.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 33

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
**PROJECT:** SmashLib.ash
**SOURCE PURPOSE:** Pulverization library modeling smashability, malus upgrades, elemental outputs, tiers, and expected yields.
**INTERESTING EXISTING CAPABILITIES:** SmashLib calculates pulverization eligibility, elemental profile, tiers and expected yield.
**MISSING ABSTRACTIONS:** Modern scripts need economics/risk context before smashing.
**LLM-RUNTIME OPPORTUNITIES:** Power bands, element summaries, candidate lists, value floors and loss checks.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `boolean aal_smash_slot_candidate(item it)` | Crafting | READ_ONLY | Check whether an item occupies an equipment slot commonly eligible for pulverization. | HIGH |
| 02 | `string aal_smash_power_band(item it)` | Crafting | READ_ONLY | Map equipment power to legacy pulverization power bands. | HIGH |
| 03 | `string aal_smash_element_profile(item it)` | Crafting | READ_ONLY | Summarize elemental damage/resistance signals relevant to pulverization output. | HIGH |
| 04 | `int aal_smash_value_floor(item it)` | Crafting / Finance | READ_ONLY | Compute the immediate economic floor an item should beat before smashing. | HIGH |
| 05 | `agent_check aal_smash_candidate_check(item it)` | Validation | READ_ONLY | Validate an item as an ordinary equipment pulverization candidate without smashing it. | HIGH |
| 06 | `string aal_smash_expected_material_tier(item it)` | Crafting | READ_ONLY | Normalize power band to powder/nugget/wad family. | HIGH |
| 07 | `agent_check aal_smash_loss_risk(item it, int estimated_yield_value)` | Validation | READ_ONLY | Compare estimated smash-yield value with keeping/selling value. | HIGH |
| 08 | `string aal_smash_inventory_candidates(int min_power, int max_entries)` | Crafting | READ_ONLY | List owned ordinary equipment at/above a power threshold for later smash analysis. | HIGH |
| 09 | `string aal_smash_plan_line(item it, int estimated_yield_value)` | Serialization | READ_ONLY | Serialize one smash candidate with economic risk context. | HIGH |
| 10 | `string aal_smash_agent_context(item it)` | LLM Context | READ_ONLY | Build compact pulverization context without loading old data maps or smashing. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_smash_slot_candidate` — Check whether an item occupies an equipment slot commonly eligible for pulverization.
02. `aal_smash_power_band` — Map equipment power to legacy pulverization power bands.
03. `aal_smash_element_profile` — Summarize elemental damage/resistance signals relevant to pulverization output.
04. `aal_smash_value_floor` — Compute the immediate economic floor an item should beat before smashing.
05. `aal_smash_candidate_check` — Validate an item as an ordinary equipment pulverization candidate without smashing it.
06. `aal_smash_expected_material_tier` — Normalize power band to powder/nugget/wad family.
07. `aal_smash_loss_risk` — Compare estimated smash-yield value with keeping/selling value.
08. `aal_smash_inventory_candidates` — List owned ordinary equipment at/above a power threshold for later smash analysis.
09. `aal_smash_plan_line` — Serialize one smash candidate with economic risk context.
10. `aal_smash_agent_context` — Build compact pulverization context without loading old data maps or smashing.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_smash_slot_candidate`, `aal_smash_power_band`, `aal_smash_element_profile`, `aal_smash_value_floor`, `aal_smash_candidate_check`, `aal_smash_expected_material_tier`, `aal_smash_loss_risk`, `aal_smash_inventory_candidates`, `aal_smash_plan_line`, `aal_smash_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s33_smash.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 34

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
**PROJECT:** helper.ash
**SOURCE PURPOSE:** Legacy ascension adviser/helpers for pulls, fax/yellow-ray opportunities, access checks, consumables, weapons, and familiar suggestions.
**INTERESTING EXISTING CAPABILITIES:** helper.ash prints ascension advice for pulls, yellow rays, faxes, access and familiars.
**MISSING ABSTRACTIONS:** Printed recommendations are hard for agents to query or compose.
**LLM-RUNTIME OPPORTUNITIES:** Structured readiness/score/access/pull context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_helper_epic_weapon_state()` | Equipment | READ_ONLY | Summarize class-relevant Epic/Legendary/Ultimate weapon ownership without changing equipment. | HIGH |
| 02 | `string aal_helper_wand_state()` | Items | READ_ONLY | Return compact zap-wand ownership state. | HIGH |
| 03 | `int aal_helper_pull_need_score(item it, int target_quantity, int strategic_weight)` | Planning | READ_ONLY | Score a potential pull by ownership gap times caller strategic weight. | HIGH |
| 04 | `agent_check aal_helper_yellow_ray_readiness()` | Validation | READ_ONLY | Check broad yellow-ray readiness signals used by legacy advisories. | HIGH |
| 05 | `agent_check aal_helper_fax_readiness()` | Validation | READ_ONLY | Expose photocopy-use/path conditions relevant to legacy fax advisories. | HIGH |
| 06 | `string aal_helper_pirate_access_context()` | Adventure | READ_ONLY | Summarize pirate access items/outfit rather than temporarily equipping them. | HIGH |
| 07 | `float aal_helper_familiar_goal_score(familiar fam, string goal)` | Familiar | READ_ONLY | Create an explainable familiar-goal score using weight and broad native modifiers. | HIGH |
| 08 | `string aal_helper_consumable_pull_context(item[int] candidates, int max_entries)` | Planning | READ_ONLY | List missing candidate consumables with storage counts/mall prices for pull decisions. | HIGH |
| 09 | `agent_check aal_helper_access_check(location loc, item required_item)` | Validation | READ_ONLY | Combine location accessibility with a required-item condition. | HIGH |
| 10 | `string aal_helper_agent_context(string goal)` | LLM Context | READ_ONLY | Build compact ascension-helper context around pulls, fax/yellow-ray and basic resources. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_helper_epic_weapon_state` — Summarize class-relevant Epic/Legendary/Ultimate weapon ownership without changing equipment.
02. `aal_helper_wand_state` — Return compact zap-wand ownership state.
03. `aal_helper_pull_need_score` — Score a potential pull by ownership gap times caller strategic weight.
04. `aal_helper_yellow_ray_readiness` — Check broad yellow-ray readiness signals used by legacy advisories.
05. `aal_helper_fax_readiness` — Expose photocopy-use/path conditions relevant to legacy fax advisories.
06. `aal_helper_pirate_access_context` — Summarize pirate access items/outfit rather than temporarily equipping them.
07. `aal_helper_familiar_goal_score` — Create an explainable familiar-goal score using weight and broad native modifiers.
08. `aal_helper_consumable_pull_context` — List missing candidate consumables with storage counts/mall prices for pull decisions.
09. `aal_helper_access_check` — Combine location accessibility with a required-item condition.
10. `aal_helper_agent_context` — Build compact ascension-helper context around pulls, fax/yellow-ray and basic resources.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_helper_epic_weapon_state`, `aal_helper_wand_state`, `aal_helper_pull_need_score`, `aal_helper_yellow_ray_readiness`, `aal_helper_fax_readiness`, `aal_helper_pirate_access_context`, `aal_helper_familiar_goal_score`, `aal_helper_consumable_pull_context`, `aal_helper_access_check`, `aal_helper_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s34_helper.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 35

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
**PROJECT:** QuestLib.ash
**SOURCE PURPOSE:** Legacy quest automation with combat-rate/mood/MCD requests, gear setup, underwater handling, acquisition/pulls, and quest flow.
**INTERESTING EXISTING CAPABILITIES:** QuestLib.ash couples quest flow with moods, familiar changes, MCD and equipment.
**MISSING ABSTRACTIONS:** Quest state and preparation intent can be separated from mutation.
**LLM-RUNTIME OPPORTUNITIES:** Quest ranks, combat-rate goals, MCD/access checks and plan rows.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_quest_property_state(string quest_property)` | Quests | READ_ONLY | Return normalized KoLmafia quest preference text. | HIGH |
| 02 | `int aal_quest_progress_rank(string quest_state)` | Quests | PURE | Convert common quest states into a coarse monotonic progress rank. | HIGH |
| 03 | `string aal_quest_combat_rate_goal(string mode)` | Planning | PURE | Translate legacy request_combat/request_noncombat intent into a descriptive maximizer goal. | HIGH |
| 04 | `int aal_quest_mcd_ceiling()` | Adventure | READ_ONLY | Return the legacy practical MCD ceiling implied by sign. | HIGH |
| 05 | `agent_check aal_quest_mcd_preflight(int desired)` | Validation | READ_ONLY | Validate desired MCD against source-inspired practical ceiling. | HIGH |
| 06 | `agent_check aal_quest_underwater_preflight()` | Validation | READ_ONLY | Check ownership of common underwater breathing gear without changing outfit. | HIGH |
| 07 | `string aal_quest_location_state(location loc)` | Adventure | READ_ONLY | Describe quest location accessibility/turn history. | HIGH |
| 08 | `agent_delta aal_quest_resource_gap(item it, int required)` | Planning | READ_ONLY | Measure quest-item shortfall across available amount. | HIGH |
| 09 | `string aal_quest_plan_line(string quest_property, location loc, item required_item)` | Serialization | READ_ONLY | Serialize one quest planning row from preference, location and item state. | HIGH |
| 10 | `string aal_quest_agent_context(string[int] quest_properties, int max_entries)` | LLM Context | READ_ONLY | Build bounded quest-state context without invoking old mood/gear automation. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_quest_property_state` — Return normalized KoLmafia quest preference text.
02. `aal_quest_progress_rank` — Convert common quest states into a coarse monotonic progress rank.
03. `aal_quest_combat_rate_goal` — Translate legacy request_combat/request_noncombat intent into a descriptive maximizer goal.
04. `aal_quest_mcd_ceiling` — Return the legacy practical MCD ceiling implied by sign.
05. `aal_quest_mcd_preflight` — Validate desired MCD against source-inspired practical ceiling.
06. `aal_quest_underwater_preflight` — Check ownership of common underwater breathing gear without changing outfit.
07. `aal_quest_location_state` — Describe quest location accessibility/turn history.
08. `aal_quest_resource_gap` — Measure quest-item shortfall across available amount.
09. `aal_quest_plan_line` — Serialize one quest planning row from preference, location and item state.
10. `aal_quest_agent_context` — Build bounded quest-state context without invoking old mood/gear automation.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_quest_property_state`, `aal_quest_progress_rank`, `aal_quest_combat_rate_goal`, `aal_quest_mcd_ceiling`, `aal_quest_mcd_preflight`, `aal_quest_underwater_preflight`, `aal_quest_location_state`, `aal_quest_resource_gap`, `aal_quest_plan_line`, `aal_quest_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s35_quest.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 36

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
**PROJECT:** sims_lib.ash
**SOURCE PURPOSE:** Legacy recommendation/simulation helpers, especially familiar selection by goal, runaways, delay, item/meat/combat priorities.
**INTERESTING EXISTING CAPABILITIES:** sims_lib.ash recommends familiars by goal/runaway/delay/combat heuristics.
**MISSING ABSTRACTIONS:** Recommendations are mostly printed rather than returned.
**LLM-RUNTIME OPPORTUNITIES:** Scored familiar candidates, runaway capacity and explainable recommendations.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_sims_familiar_weight(familiar fam)` | Familiar | READ_ONLY | Return current effective familiar weight basis for recommendation logic. | HIGH |
| 02 | `int aal_sims_runaway_capacity(familiar fam)` | Familiar | READ_ONLY | Estimate weight-based free-runaway capacity using the legacy 5-weight-per-runaway heuristic. | HIGH |
| 03 | `agent_resource_state aal_sims_delay_state()` | Adventure | READ_ONLY | Expose Mini-Hipster free-adventure usage relevant to delay-zone recommendations. | HIGH |
| 04 | `float aal_sims_goal_score(familiar fam, string goal, int combat_bias)` | Familiar | READ_ONLY | Score owned familiars by weight plus broad goal/combat heuristics. | HIGH |
| 05 | `familiar aal_sims_best_familiar(familiar[int] candidates, string goal, int combat_bias)` | Familiar | READ_ONLY | Select highest-scoring candidate familiar without switching it. | HIGH |
| 06 | `string aal_sims_familiar_line(familiar fam, string goal, int combat_bias)` | Serialization | READ_ONLY | Serialize familiar recommendation evidence. | HIGH |
| 07 | `string aal_sims_goal_candidates(familiar[int] candidates, string goal, int combat_bias, int max_entries)` | Planning | READ_ONLY | Emit bounded familiar candidate evidence in caller order. | HIGH |
| 08 | `agent_check aal_sims_path_constraint(familiar fam)` | Validation | READ_ONLY | Check whether a familiar is usable in the current path by ownership plus path-level familiar availability. | HIGH |
| 09 | `string aal_sims_recommendation_reason(familiar fam, string goal)` | Describe | READ_ONLY | Generate concise human/agent-readable rationale for common familiar goals. | HIGH |
| 10 | `string aal_sims_agent_context(familiar[int] candidates, string goal, int combat_bias)` | LLM Context | READ_ONLY | Build compact familiar recommendation context without switching familiars. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_sims_familiar_weight` — Return current effective familiar weight basis for recommendation logic.
02. `aal_sims_runaway_capacity` — Estimate weight-based free-runaway capacity using the legacy 5-weight-per-runaway heuristic.
03. `aal_sims_delay_state` — Expose Mini-Hipster free-adventure usage relevant to delay-zone recommendations.
04. `aal_sims_goal_score` — Score owned familiars by weight plus broad goal/combat heuristics.
05. `aal_sims_best_familiar` — Select highest-scoring candidate familiar without switching it.
06. `aal_sims_familiar_line` — Serialize familiar recommendation evidence.
07. `aal_sims_goal_candidates` — Emit bounded familiar candidate evidence in caller order.
08. `aal_sims_path_constraint` — Check whether a familiar is usable in the current path by ownership plus path-level familiar availability.
09. `aal_sims_recommendation_reason` — Generate concise human/agent-readable rationale for common familiar goals.
10. `aal_sims_agent_context` — Build compact familiar recommendation context without switching familiars.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_sims_familiar_weight`, `aal_sims_runaway_capacity`, `aal_sims_delay_state`, `aal_sims_goal_score`, `aal_sims_best_familiar`, `aal_sims_familiar_line`, `aal_sims_goal_candidates`, `aal_sims_path_constraint`, `aal_sims_recommendation_reason`, `aal_sims_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s36_sims.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 37

**URL:** https://github.com/Prusias-kol/pUpdates
**PROJECT:** pUpdates repository (second supplied entry)
**SOURCE PURPOSE:** Same upstream supplied again; this entry focuses on pure changelog parsing/serialization rather than operational seen-version state.
**INTERESTING EXISTING CAPABILITIES:** The repeated pUpdates source is intentionally reused for a different abstraction layer: changelog data itself.
**MISSING ABSTRACTIONS:** Versioned changelog parsing/validation can be pure and independent of user preferences.
**LLM-RUNTIME OPPORTUNITIES:** Continuity checks, search, checksums and unseen-entry serialization.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_pupdateslog_parse_header(string[int] update_lines)` | Updates | PURE | Extract current version from a pUpdates-style map representation where index -1 stores version. | HIGH |
| 02 | `string aal_pupdateslog_entry(string[int] update_lines, int version)` | Updates | PURE | Return one changelog entry by version. | HIGH |
| 03 | `string aal_pupdateslog_since(string[int] update_lines, int seen_version, int max_entries)` | Updates | PURE | Serialize changelog entries newer than a seen version. | HIGH |
| 04 | `string aal_pupdateslog_missing_versions(string[int] update_lines)` | Validation | PURE | Report gaps between version 0 and declared current version. | HIGH |
| 05 | `boolean aal_pupdateslog_contiguous(string[int] update_lines)` | Validation | PURE | Check whether all changelog versions through current are present. | HIGH |
| 06 | `int aal_pupdateslog_checksum(string[int] update_lines)` | Debugging | PURE | Produce a deterministic lightweight checksum from version numbers and line lengths. | HIGH |
| 07 | `string aal_pupdateslog_search(string[int] update_lines, string query, int max_entries)` | Query | PURE | Search changelog entries case-insensitively. | HIGH |
| 08 | `string aal_pupdateslog_tsv(string script_name, string[int] update_lines)` | Serialization | PURE | Serialize an entire changelog as versioned TSV. | HIGH |
| 09 | `agent_check aal_pupdateslog_validate(string[int] update_lines)` | Validation | PURE | Validate header/version continuity for a changelog map. | HIGH |
| 10 | `string aal_pupdateslog_agent_context(string script_name, string[int] update_lines, int seen_version, int max_entries)` | LLM Context | PURE | Build compact unseen-changelog context without reading/writing preferences. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_pupdateslog_parse_header` — Extract current version from a pUpdates-style map representation where index -1 stores version.
02. `aal_pupdateslog_entry` — Return one changelog entry by version.
03. `aal_pupdateslog_since` — Serialize changelog entries newer than a seen version.
04. `aal_pupdateslog_missing_versions` — Report gaps between version 0 and declared current version.
05. `aal_pupdateslog_contiguous` — Check whether all changelog versions through current are present.
06. `aal_pupdateslog_checksum` — Produce a deterministic lightweight checksum from version numbers and line lengths.
07. `aal_pupdateslog_search` — Search changelog entries case-insensitively.
08. `aal_pupdateslog_tsv` — Serialize an entire changelog as versioned TSV.
09. `aal_pupdateslog_validate` — Validate header/version continuity for a changelog map.
10. `aal_pupdateslog_agent_context` — Build compact unseen-changelog context without reading/writing preferences.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_pupdateslog_parse_header`, `aal_pupdateslog_entry`, `aal_pupdateslog_since`, `aal_pupdateslog_missing_versions`, `aal_pupdateslog_contiguous`, `aal_pupdateslog_checksum`, `aal_pupdateslog_search`, `aal_pupdateslog_tsv`, `aal_pupdateslog_validate`, `aal_pupdateslog_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s37_pupdateslog.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 38

**URL:** https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
**PROJECT:** DicsLibrary.ash
**SOURCE PURPOSE:** Large shared library with typed property reads, item valuation, stock-up, ownership, healing, songs, workshed/garden and utility logic.
**INTERESTING EXISTING CAPABILITIES:** DicsLibrary.ash provides typed preferences, broad ownership, valuation, recovery, stock and song helpers.
**MISSING ABSTRACTIONS:** Some helpers mix acquisition and valuation; typed safe reads/context can be isolated.
**LLM-RUNTIME OPPORTUNITIES:** Defaulted preference reads, price confidence, reorder math, recovery/song/item context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_dics_pref_int(string property_name, int default_value)` | Properties | READ_ONLY | Read an integer preference with explicit default for missing/empty values. | HIGH |
| 02 | `string aal_dics_pref_snapshot(string[int] property_names, int max_entries)` | Serialization | READ_ONLY | Serialize a bounded caller-selected preference set as deterministic key=value context. | HIGH |
| 03 | `int aal_dics_total_amount(item it, boolean include_stash)` | Inventory | READ_ONLY | Count item ownership across inventory/equipment/closet/storage/display/shop and optionally stash. | HIGH |
| 04 | `string aal_dics_market_confidence(item it, int fresh_days)` | Finance | READ_ONLY | Classify price confidence from tradeability, historical age, historical price, and mall fallback. | HIGH |
| 05 | `int aal_dics_value_estimate(item it, int fresh_days, float multiplier)` | Finance | READ_ONLY | Estimate item value with a configurable sell-realization multiplier. | HIGH |
| 06 | `int aal_dics_stock_reorder(item it, int target_amount)` | Planning | READ_ONLY | Calculate reorder quantity to reach a target personal stock. | HIGH |
| 07 | `string aal_dics_recovery_state()` | Recovery | READ_ONLY | Expose HP/MP recovery targets and current state. | HIGH |
| 08 | `string aal_dics_song_state()` | Effects | READ_ONLY | Summarize active Accordion Thief song effects and durations. | HIGH |
| 09 | `string aal_dics_item_context(item it, int fresh_days, float multiplier)` | LLM Context | READ_ONLY | Build compact ownership/valuation context for one item. | HIGH |
| 10 | `string aal_dics_agent_context(item[int] items, int max_entries, int fresh_days, float multiplier)` | LLM Context | READ_ONLY | Build bounded item/value context inspired by DicsLibrary's broad utility role. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_dics_pref_int` — Read an integer preference with explicit default for missing/empty values.
02. `aal_dics_pref_snapshot` — Serialize a bounded caller-selected preference set as deterministic key=value context.
03. `aal_dics_total_amount` — Count item ownership across inventory/equipment/closet/storage/display/shop and optionally stash.
04. `aal_dics_market_confidence` — Classify price confidence from tradeability, historical age, historical price, and mall fallback.
05. `aal_dics_value_estimate` — Estimate item value with a configurable sell-realization multiplier.
06. `aal_dics_stock_reorder` — Calculate reorder quantity to reach a target personal stock.
07. `aal_dics_recovery_state` — Expose HP/MP recovery targets and current state.
08. `aal_dics_song_state` — Summarize active Accordion Thief song effects and durations.
09. `aal_dics_item_context` — Build compact ownership/valuation context for one item.
10. `aal_dics_agent_context` — Build bounded item/value context inspired by DicsLibrary's broad utility role.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_dics_pref_int`, `aal_dics_pref_snapshot`, `aal_dics_total_amount`, `aal_dics_market_confidence`, `aal_dics_value_estimate`, `aal_dics_stock_reorder`, `aal_dics_recovery_state`, `aal_dics_song_state`, `aal_dics_item_context`, `aal_dics_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s38_dics.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 39

**URL:** https://github.com/Ezandora/Choice-Override
**PROJECT:** Choice-Override
**SOURCE PURPOSE:** Public-domain relay choice dispatcher that parses choice IDs, finds choice.<id>.ash/js handlers, encodes page text, and supports choice.0 fallback.
**INTERESTING EXISTING CAPABILITIES:** Choice-Override parses choice IDs and dispatches choice-specific ASH/JS handlers with fallback.
**MISSING ABSTRACTIONS:** Parsing/routing can be exposed without dispatching or POSTing choices.
**LLM-RUNTIME OPPORTUNITIES:** Choice/options parsing, handler candidates, fingerprints and route previews.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `int aal_choiceoverride_choice_id(string page_text)` | Choices | PURE | Parse a choice ID from common whichchoice HTML/query patterns without issuing a request. | HIGH |
| 02 | `string aal_choiceoverride_option_ids(string page_text)` | Choices | PURE | Extract unique positive option values from choice-page HTML. | HIGH |
| 03 | `string aal_choiceoverride_script_base(int choice_id)` | Normalization | PURE | Generate the canonical override script basename for a choice. | HIGH |
| 04 | `string aal_choiceoverride_handler_candidates(int choice_id)` | Planning | PURE | Return exact ASH/JS handler candidates plus fallback names in lookup order. | HIGH |
| 05 | `string aal_choiceoverride_page_fingerprint(string page_text)` | Debugging | PURE | Build a lightweight deterministic choice-page fingerprint from parsed ID/length/option list. | HIGH |
| 06 | `agent_check aal_choiceoverride_validate_page(string page_text)` | Validation | PURE | Validate that a page contains an identifiable choice and at least one option. | HIGH |
| 07 | `string aal_choiceoverride_route_preview(string page_text, boolean specific_handler_exists, boolean fallback_handler_exists)` | Planning | PURE | Describe Choice-Override routing decision without dispatching a script. | HIGH |
| 08 | `string aal_choiceoverride_encode_payload(string page_text)` | Serialization | PURE | URL-encode choice page text for safe argument transport, mirroring the source's transport idea. | HIGH |
| 09 | `string aal_choiceoverride_decode_payload(string encoded)` | Serialization | PURE | Decode a Choice-Override-style page payload. | HIGH |
| 10 | `string aal_choiceoverride_agent_context(string page_text)` | LLM Context | PURE | Build compact choice context from page text without visiting or submitting choice.php. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_choiceoverride_choice_id` — Parse a choice ID from common whichchoice HTML/query patterns without issuing a request.
02. `aal_choiceoverride_option_ids` — Extract unique positive option values from choice-page HTML.
03. `aal_choiceoverride_script_base` — Generate the canonical override script basename for a choice.
04. `aal_choiceoverride_handler_candidates` — Return exact ASH/JS handler candidates plus fallback names in lookup order.
05. `aal_choiceoverride_page_fingerprint` — Build a lightweight deterministic choice-page fingerprint from parsed ID/length/option list.
06. `aal_choiceoverride_validate_page` — Validate that a page contains an identifiable choice and at least one option.
07. `aal_choiceoverride_route_preview` — Describe Choice-Override routing decision without dispatching a script.
08. `aal_choiceoverride_encode_payload` — URL-encode choice page text for safe argument transport, mirroring the source's transport idea.
09. `aal_choiceoverride_decode_payload` — Decode a Choice-Override-style page payload.
10. `aal_choiceoverride_agent_context` — Build compact choice context from page text without visiting or submitting choice.php.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_choiceoverride_choice_id`, `aal_choiceoverride_option_ids`, `aal_choiceoverride_script_base`, `aal_choiceoverride_handler_candidates`, `aal_choiceoverride_page_fingerprint`, `aal_choiceoverride_validate_page`, `aal_choiceoverride_route_preview`, `aal_choiceoverride_encode_payload`, `aal_choiceoverride_decode_payload`, `aal_choiceoverride_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s39_choiceoverride.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 40

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
**PROJECT:** zlib.ash (fixed historical commit)
**SOURCE PURPOSE:** Zarqon's general library: typed setting normalization, string/list utilities, verbosity, numeric helpers, averages, expression evaluation, map/version/update infrastructure.
**INTERESTING EXISTING CAPABILITIES:** ZLib provides normalization, list helpers, settings, verbosity, math and update machinery.
**MISSING ABSTRACTIONS:** Settings normalization/schema/diff can be modernized without old network/SVN behavior.
**LLM-RUNTIME OPPORTUNITIES:** Typed normalization, exact list operations, validation and setting context.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_zlib_normalize_bool(string value)` | Normalization | PURE | Normalize boolean-like setting text to canonical true/false. | HIGH |
| 02 | `string aal_zlib_normalize_int(string value)` | Normalization | PURE | Normalize integer setting text. | HIGH |
| 03 | `string aal_zlib_normalize_item(string value)` | Normalization | PURE | Normalize item setting text through KoLmafia's typed item parser. | HIGH |
| 04 | `string aal_zlib_list_unique(string list_text, string glue)` | Normalization | PURE | De-duplicate a delimited list using deterministic lexical output. | HIGH |
| 05 | `boolean aal_zlib_list_contains_exact(string list_text, string needle, string glue)` | Query | PURE | Perform exact case-insensitive membership check over a delimited list. | HIGH |
| 06 | `float aal_zlib_clamp(float value, float low, float high)` | Math | PURE | Clamp value with normalized lower/upper bounds. | HIGH |
| 07 | `string aal_zlib_setting_diff(string name, string old_value, string new_value)` | Diff / Change Detection | PURE | Serialize one settings change instead of directly persisting it. | HIGH |
| 08 | `agent_check aal_zlib_type_validate(string value, string type_name)` | Validation | PURE | Validate a subset of common ZLib setting types with current KoLmafia coercions. | HIGH |
| 09 | `string aal_zlib_setting_schema_line(string name, string type_name, string default_value, string documentation)` | Serialization | PURE | Serialize a typed setting schema row for modern agent/UI consumption. | HIGH |
| 10 | `string aal_zlib_agent_context(string[string] setting_values, int max_entries)` | LLM Context | PURE | Build bounded deterministic setting context from a ZLib-like settings map. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_zlib_normalize_bool` — Normalize boolean-like setting text to canonical true/false.
02. `aal_zlib_normalize_int` — Normalize integer setting text.
03. `aal_zlib_normalize_item` — Normalize item setting text through KoLmafia's typed item parser.
04. `aal_zlib_list_unique` — De-duplicate a delimited list using deterministic lexical output.
05. `aal_zlib_list_contains_exact` — Perform exact case-insensitive membership check over a delimited list.
06. `aal_zlib_clamp` — Clamp value with normalized lower/upper bounds.
07. `aal_zlib_setting_diff` — Serialize one settings change instead of directly persisting it.
08. `aal_zlib_type_validate` — Validate a subset of common ZLib setting types with current KoLmafia coercions.
09. `aal_zlib_setting_schema_line` — Serialize a typed setting schema row for modern agent/UI consumption.
10. `aal_zlib_agent_context` — Build bounded deterministic setting context from a ZLib-like settings map.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_zlib_normalize_bool`, `aal_zlib_normalize_int`, `aal_zlib_normalize_item`, `aal_zlib_list_unique`, `aal_zlib_list_contains_exact`, `aal_zlib_clamp`, `aal_zlib_setting_diff`, `aal_zlib_type_validate`, `aal_zlib_setting_schema_line`, `aal_zlib_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s40_zlib.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.

## SOURCE 41

**URL:** https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
**PROJECT:** relay_zlib_manager.ash (fixed historical commit)
**SOURCE PURPOSE:** Relay UI for ZLib settings with descriptions, typed controls, validators, filtering, delete queues, and save feedback.
**INTERESTING EXISTING CAPABILITIES:** relay_zlib_manager turns ZLib settings/docs into editable relay controls with validation/filter/delete/save behavior.
**MISSING ABSTRACTIONS:** UI rendering and persistence are tightly coupled.
**LLM-RUNTIME OPPORTUNITIES:** Field-kind inference, searchable schema, validation, change/delete/save plans.

| # | Function | Category | Side effects | Purpose | LLM usefulness |
|---:|---|---|---|---|---|
| 01 | `string aal_zman_field_kind(string value)` | Relay / UI | PURE | Infer a simple editor control kind from persisted setting text. | HIGH |
| 02 | `agent_check aal_zman_field_validate(string name, string value, string kind)` | Validation | PURE | Validate a setting according to inferred/editor kind. | HIGH |
| 03 | `boolean aal_zman_filter_match(string setting_name, string documentation, string query)` | Query | PURE | Filter settings by name or documentation, not name alone. | HIGH |
| 04 | `agent_plan aal_zman_change_preview(string name, string old_value, string new_value, string kind)` | Planning | PURE | Validate and preview one settings edit without writing files/properties. | HIGH |
| 05 | `agent_plan aal_zman_delete_preview(string name, boolean confirmed)` | Planning | PURE | Represent queued variable deletion explicitly before persistence. | HIGH |
| 06 | `string aal_zman_group_settings(string[string] scripts_for_setting, string script_filter)` | Query | PURE | List setting names associated with a script tag. | HIGH |
| 07 | `string aal_zman_schema_tsv(string[string] values, string[string] types, string[string] docs)` | Serialization | PURE | Serialize editable settings schema/value/doc rows. | HIGH |
| 08 | `string aal_zman_validation_errors(string[string] values, string[string] types)` | Validation | PURE | Validate an entire settings map and emit only errors. | HIGH |
| 09 | `string aal_zman_save_plan(string[string] old_values, string[string] new_values, string[string] types)` | Planning | PURE | Generate only changed, valid setting rows for a save operation. | HIGH |
| 10 | `string aal_zman_agent_context(string[string] values, string[string] docs, string query, int max_entries)` | LLM Context | PURE | Build bounded searchable setting context for agent-assisted configuration. | HIGH |

**10 NEW FUNCTIONS**

01. `aal_zman_field_kind` — Infer a simple editor control kind from persisted setting text.
02. `aal_zman_field_validate` — Validate a setting according to inferred/editor kind.
03. `aal_zman_filter_match` — Filter settings by name or documentation, not name alone.
04. `aal_zman_change_preview` — Validate and preview one settings edit without writing files/properties.
05. `aal_zman_delete_preview` — Represent queued variable deletion explicitly before persistence.
06. `aal_zman_group_settings` — List setting names associated with a script tag.
07. `aal_zman_schema_tsv` — Serialize editable settings schema/value/doc rows.
08. `aal_zman_validation_errors` — Validate an entire settings map and emit only errors.
09. `aal_zman_save_plan` — Generate only changed, valid setting rows for a save operation.
10. `aal_zman_agent_context` — Build bounded searchable setting context for agent-assisted configuration.

**LLM-RUNTIME FUNCTIONS:** 10 — `aal_zman_field_kind`, `aal_zman_field_validate`, `aal_zman_filter_match`, `aal_zman_change_preview`, `aal_zman_delete_preview`, `aal_zman_group_settings`, `aal_zman_schema_tsv`, `aal_zman_validation_errors`, `aal_zman_save_plan`, `aal_zman_agent_context`

**FILES CREATED/MODIFIED:** `lib/aal_s41_zman.ash`

**VERIFY RESULT:** Live KoLmafia `verify` not run in this environment; static checks are reported in `VERIFY_REPORT.md`.

**TEST RESULT:** Included in static corpus checks and read-only smoke import coverage.

**DEPRECATIONS FOUND:** Legacy sources contain era-specific direct URL/CLI/SVN/page-scrape patterns where noted; generated functions avoid depending on those mutation paths.

**SOURCE / LICENSE NOTES:** Newly implemented conceptual inspiration only; upstream authorship/license remains with the linked project. No upstream function body was copied into the generated module.

**KNOWN LIMITATIONS:** Runtime-dependent values are only as current as KoLmafia's local state/cache; pricing helpers may cause read-only mall lookups. Run local `verify` on the installed KoLmafia build.
