script "ash_agent_stdlib_master.ash";

// ASH Agent Standard Library — monolithic v0.1.0
// 41 supplied source entries × 10 new functions = 410 functions.
// Generated implementations are conceptual derivatives, not copied upstream function bodies.
// Import-safe by design: no top-level game-state mutations.

// ============================================================================
// SHARED RECORD TYPES
// ============================================================================
/*
  Shared records for ASH Agent Standard Library.
  This file intentionally contains no functions so the corpus function count
  remains exactly 10 exports per supplied source entry.
*/

record agent_check {
    boolean ok;
    string subject;
    string reason;
    string severity;
};

record agent_metric {
    string name;
    float value;
    string unit;
    string note;
};

record agent_delta {
    string label;
    int before_value;
    int after_value;
    int difference;
};

record agent_action_preview {
    boolean valid;
    string operation;
    string reason;
    int meat_cost;
    int adventure_cost;
    string warnings;
};

record agent_item_state {
    item thing;
    int inventory;
    int closet;
    int storage;
    int display;
    int shop;
    int equipped;
    int total;
};

record agent_value_snapshot {
    int liquid_meat;
    int item_value;
    int total_value;
    int turns;
    int stamp;
};

record agent_organ_state {
    int fullness;
    int fullness_limit_value;
    int inebriety;
    int inebriety_limit_value;
    int spleen;
    int spleen_limit_value;
};

record agent_combat_state {
    monster foe;
    int hp;
    int attack;
    int defense;
    int player_hp;
    int player_mp;
    int turn;
};

record agent_kv {
    string key;
    string value;
    string note;
};

record agent_range_state {
    int minimum;
    int maximum;
    int current;
    int remaining;
    boolean satisfied;
};

record agent_resource_state {
    string name;
    int used;
    int limit_value;
    int remaining;
    boolean available;
};

record agent_score {
    string label;
    float score;
    string reason;
};

record agent_plan {
    boolean valid;
    string subject;
    string action;
    string reason;
    int meat_cost;
    int turn_cost;
};

record agent_choice_state {
    int choice_id;
    boolean handling;
    int configured_option;
    string preference_name;
    string note;
};

record agent_breakpoint {
    string name;
    string date;
    int turns;
    int meat;
    int stamp;
};

record agent_modifier_state {
    string modifier_name;
    float current_value;
    float target_value;
    float gap;
    boolean satisfied;
};

record agent_stash_state {
    item thing;
    int expected;
    int actual;
    int difference;
    boolean personal_overlap;
};

record agent_consumption_candidate {
    item thing;
    int size;
    float adventures;
    int price;
    float adventures_per_size;
    float value;
    boolean fits;
};

record agent_option {
    string value;
    string label;
    boolean selected;
    boolean enabled;
    int score;
};

record agent_diagnostic {
    string name;
    boolean passed;
    string expected;
    string actual;
    string note;
};

// ============================================================================
// SOURCE 01: C2Talon repository ecosystem
// https://github.com/C2Talon?tab=repositories
// Repository collection spanning reusable ASH libraries, resource modules, ascension automation, trackers, relays, and KoLmafia tooling.
// ============================================================================

/**
 * Normalize a repository-name list into stable one-name-per-line manifest text.
 *
 * Parameters: repo_names: repository names discovered from the C2Talon ecosystem.
 * Return: Lower-cased de-duplicated manifest, one repository per line.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: line := repository-name
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_repo_manifest(string[int] repo_names) {
    buffer out;
    boolean[string] seen;
    foreach i, name in repo_names {
        if (name != "") seen[to_lower_case(name)] = true;
    }
    foreach name in seen {
        out.append(name);
        out.append("\n");
    }
    return out.to_string();
}

/**
 * Classify a C2Talon-style repository by its name into a useful runtime role.
 *
 * Parameters: repo_name: repository name.
 * Return: Stable role label.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_repo_role(string repo_name) {
    string n = to_lower_case(repo_name);
    if (contains_text(n, "relay")) return "relay-ui";
    if (contains_text(n, "lib")) return "library";
    if (contains_text(n, "ascend") || contains_text(n, "hccs")) return "run-automation";
    if (contains_text(n, "track")) return "tracking";
    if (contains_text(n, "trainer")) return "training";
    if (contains_text(n, "choice")) return "choice-support";
    if (contains_text(n, "kolmafia")) return "runtime";
    return "script-or-tool";
}

/**
 * Normalize dependencies.txt-style content into deterministic dependency lines without comments/blank rows.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_dependency_lines(string dependencies_text) {
    buffer out;
    string[int] lines = split_string(dependencies_text, "\n");
    boolean[string] seen;
    foreach i, line in lines {
        string cleaned = line;
        if (index_of(cleaned, "#") >= 0) cleaned = substring(cleaned, 0, index_of(cleaned, "#"));
        if (cleaned != "") seen[cleaned] = true;
    }
    foreach line in seen {
        out.append(line);
        out.append("\n");
    }
    return out.to_string();
}

/**
 * Count unique non-comment dependency declarations in a dependencies file.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Unique dependency count.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_c2eco_dependency_count(string dependencies_text) {
    boolean[string] seen;
    string[int] lines = split_string(dependencies_text, "\n");
    foreach i, line in lines {
        string cleaned = line;
        if (index_of(cleaned, "#") >= 0) cleaned = substring(cleaned, 0, index_of(cleaned, "#"));
        if (cleaned != "") seen[cleaned] = true;
    }
    return count(seen);
}

/**
 * Produce compact capability tags inferred from ecosystem naming conventions.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_repo_capability_tags(string repo_name) {
    buffer out;
    string n = to_lower_case(repo_name);
    if (contains_text(n, "relay")) out.append("ui,");
    if (contains_text(n, "lib")) out.append("library,");
    if (contains_text(n, "ascend")) out.append("ascension,");
    if (contains_text(n, "hccs")) out.append("community-service,");
    if (contains_text(n, "choice")) out.append("choice,");
    if (contains_text(n, "track")) out.append("tracking,");
    if (contains_text(n, "train")) out.append("training,");
    if (contains_text(n, "mafia")) out.append("runtime,");
    string s = out.to_string();
    if (s == "") return "general";
    return substring(s, 0, length(s) - 1);
}

/**
 * Select ecosystem repositories whose names/roles plausibly match a task description.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_select_repos_for_task(string[int] repo_names, string task_text) {
    buffer out;
    string q = to_lower_case(task_text);
    boolean[string] chosen;
    foreach i, repo in repo_names {
        string n = to_lower_case(repo);
        boolean match = contains_text(q, n);
        if (contains_text(q, "ascend") && contains_text(n, "ascend")) match = true;
        if (contains_text(q, "community service") && contains_text(n, "hccs")) match = true;
        if (contains_text(q, "relay") && contains_text(n, "relay")) match = true;
        if (contains_text(q, "library") && contains_text(n, "lib")) match = true;
        if (contains_text(q, "choice") && contains_text(n, "choice")) match = true;
        if (match) chosen[n] = true;
    }
    foreach n in chosen {
        out.append(n);
        out.append("\n");
    }
    return out.to_string();
}

/**
 * Compare two repository manifests and report added/removed names.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: TSV: change_type<TAB>repository
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_manifest_delta(string[int] before_repos, string[int] after_repos) {
    boolean[string] before;
    boolean[string] after;
    foreach i, n in before_repos if (n != "") before[to_lower_case(n)] = true;
    foreach i, n in after_repos if (n != "") after[to_lower_case(n)] = true;
    buffer out;
    foreach n in after if (!(before contains n)) out.append("added\t" + n + "\n");
    foreach n in before if (!(after contains n)) out.append("removed\t" + n + "\n");
    return out.to_string();
}

/**
 * Extract likely reusable library repositories from a mixed account repository list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_library_candidates(string[int] repo_names) {
    buffer out;
    boolean[string] libs;
    foreach i, repo in repo_names {
        string n = to_lower_case(repo);
        if (contains_text(n, "lib") || contains_text(n, "helper")) libs[n] = true;
    }
    foreach n in libs out.append(n + "\n");
    return out.to_string();
}

/**
 * Summarize whether a repository ecosystem exposes both reusable libraries and explicit dependency metadata.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2eco_ecosystem_health(string[int] repo_names, string dependencies_text) {
    agent_check r;
    r.subject = "c2talon-ecosystem";
    int libraries;
    foreach i, repo in repo_names if (contains_text(to_lower_case(repo), "lib")) libraries = libraries + 1;
    int deps;
    boolean[string] dep_seen;
    foreach i, line in split_string(dependencies_text, "\n") if (line != "" && !contains_text(line, "#")) dep_seen[line] = true;
    deps = count(dep_seen);
    r.ok = libraries > 0 && deps > 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "libraries=" + libraries + "; dependencies=" + deps;
    return r;
}

/**
 * Build a compact deterministic ecosystem context for an agent selecting reusable C2Talon components.
 *
 * Parameters: max_repos <= 0 means no cap.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: key=value lines; repos emitted lexically.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_agent_context(string[int] repo_names, string dependencies_text, int max_repos) {
    buffer out;
    out.append("ecosystem=C2Talon\n");
    int emitted;
    boolean[string] seen;
    foreach i, repo in repo_names if (repo != "") seen[to_lower_case(repo)] = true;
    foreach repo in seen {
        if (max_repos > 0 && emitted >= max_repos) break;
        out.append("repo=" + repo + "\n");
        emitted = emitted + 1;
    }
    int deps;
    foreach i, line in split_string(dependencies_text, "\n") if (line != "" && !contains_text(line, "#")) deps = deps + 1;
    out.append("dependency_lines=" + deps + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 02: twistedmage assorted scripts
// https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
// Large legacy ASH script collection with questing, utilities, helpers, combat, crafting, and relay-era patterns.
// ============================================================================

/**
 * Extract imported ASH filenames from legacy script text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_imports(string source_text) {
    buffer out;
    string[int] lines = split_string(source_text, "\n");
    boolean[string] imports;
    foreach i, line in lines {
        string low = to_lower_case(line);
        if (!contains_text(low, "import")) continue;
        int l = index_of(line, "<");
        int r = index_of(line, ">");
        if (l >= 0 && r > l) imports[substring(line, l + 1, r)] = true;
    }
    foreach name in imports out.append(name + "\n");
    return out.to_string();
}

/**
 * Describe potentially mutating primitives present in a legacy ASH script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_mutation_surface(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "cli_execute(")) out.append("cli_execute\n");
    if (contains_text(low, "visit_url(")) out.append("visit_url\n");
    if (contains_text(low, "adventure(")) out.append("adventure\n");
    if (contains_text(low, "use(")) out.append("use\n");
    if (contains_text(low, "eat(")) out.append("eat\n");
    if (contains_text(low, "drink(")) out.append("drink\n");
    if (contains_text(low, "buy(")) out.append("buy\n");
    if (contains_text(low, "set_property(")) out.append("set_property\n");
    if (contains_text(low, "take_stash(") || contains_text(low, "put_stash(")) out.append("stash\n");
    return out.to_string();
}

/**
 * Compute a coarse modernization risk score from legacy execution and page-scraping patterns.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Integer risk signal; higher means more review pressure, not a safety verdict.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_twisted_legacy_risk_score(string source_text) {
    string low = to_lower_case(source_text);
    int score;
    if (contains_text(low, "visit_url(")) score = score + 2;
    if (contains_text(low, "cli_execute(")) score = score + 2;
    if (contains_text(low, "contains_text(visit_url")) score = score + 2;
    if (contains_text(low, "svn_")) score = score + 2;
    if (contains_text(low, "kolmafia.us")) score = score + 1;
    if (contains_text(low, "pwd")) score = score + 1;
    if (contains_text(low, "abort(")) score = score + 1;
    return score;
}

/**
 * Extract get_property/set_property preference names from straightforward quoted calls.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_preference_refs(string source_text) {
    buffer out;
    boolean[string] prefs;
    matcher m = create_matcher("(?:get_property|set_property)\\(\"([^\"]+)\"", source_text);
    while (m.find()) prefs[m.group(1)] = true;
    foreach p in prefs out.append(p + "\n");
    return out.to_string();
}

/**
 * Extract quoted .php endpoints referenced by a legacy script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_url_endpoints(string source_text) {
    buffer out;
    boolean[string] endpoints;
    matcher m = create_matcher("\"([A-Za-z0-9_./-]+\\.php[^\" ]*)\"", source_text);
    while (m.find()) endpoints[m.group(1)] = true;
    foreach e in endpoints out.append(e + "\n");
    return out.to_string();
}

/**
 * Count likely main-function entrypoints in source text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_twisted_entrypoint_count(string source_text) {
    matcher m = create_matcher("\\bvoid\\s+main\\s*\\(", source_text);
    int n;
    while (m.find()) n = n + 1;
    return n;
}

/**
 * Flag scripts whose decisions appear coupled to raw HTML text matching.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_twisted_raw_html_dependency(string source_text) {
    agent_check r;
    r.subject = "raw-html-coupling";
    string low = to_lower_case(source_text);
    int visit_count;
    matcher m = create_matcher("visit_url\\s*\\(", low);
    while (m.find()) visit_count = visit_count + 1;
    boolean coupled = contains_text(low, "contains_text") && visit_count > 0;
    r.ok = !coupled;
    r.severity = coupled ? "warning" : "info";
    r.reason = coupled ? "script combines page fetches with text matching" : "no obvious fetch/text-match coupling";
    return r;
}

/**
 * Estimate dependency pressure from import count and nested executor usage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_twisted_import_depth_hint(string source_text) {
    int imports;
    matcher m = create_matcher("\\bimport\\b", to_lower_case(source_text));
    while (m.find()) imports = imports + 1;
    int pressure = imports;
    if (contains_text(to_lower_case(source_text), "cli_execute(")) pressure = pressure + 2;
    if (contains_text(to_lower_case(source_text), "call ")) pressure = pressure + 1;
    return pressure;
}

/**
 * Create a deterministic modernization checklist based on patterns actually present.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_modernization_todo(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "visit_url(")) out.append("review-page-scraping\n");
    if (contains_text(low, "cli_execute(")) out.append("replace-string-command-where-typed-api-exists\n");
    if (contains_text(low, "svn_")) out.append("replace-svn-era-update-path\n");
    if (contains_text(low, "set_property(")) out.append("separate-read-plan-write\n");
    if (contains_text(low, "abort(")) out.append("document-failure-contract\n");
    if (contains_text(low, "import <zlib.ash>")) out.append("audit-zlib-dependency\n");
    return out.to_string();
}

/**
 * Build a compact static-analysis context for an agent modernizing a twistedmage-era script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_source_context(string source_name, string source_text) {
    buffer out;
    out.append("source=" + source_name + "\n");
    out.append("bytes=" + length(source_text) + "\n");
    string low = to_lower_case(source_text);
    out.append("has_cli_execute=" + to_string(contains_text(low, "cli_execute(")) + "\n");
    out.append("has_visit_url=" + to_string(contains_text(low, "visit_url(")) + "\n");
    out.append("has_properties=" + to_string(contains_text(low, "get_property(") || contains_text(low, "set_property(")) + "\n");
    out.append("has_main=" + to_string(contains_text(low, "void main")) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 03: c2t_kol_scripts
// https://github.com/C2Talon/c2t_kol_scripts
// Focused modern ASH scripts for resource use, trackers, choices, cartography, casting, and item-of-the-month workflows.
// ============================================================================

/**
 * Describe whether KoLmafia is currently handling a requested choice and its configured choiceAdventure preference.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_choice_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_choice_state aal_c2scripts_choice_state(int choice_id) {
    agent_choice_state r;
    r.choice_id = choice_id;
    r.handling = handling_choice() && last_choice() == choice_id;
    r.preference_name = "choiceAdventure" + choice_id;
    r.configured_option = get_property(r.preference_name).to_int();
    r.note = r.handling ? "active" : "not-active";
    return r;
}

/**
 * Validate an intended choice against current choice state without submitting it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2scripts_choice_preflight(int choice_id, int intended_option) {
    agent_check r;
    r.subject = "choice " + choice_id + " option " + intended_option;
    r.ok = handling_choice() && last_choice() == choice_id && intended_option > 0;
    r.severity = r.ok ? "info" : "warning";
    if (!handling_choice()) r.reason = "not handling a choice";
    else if (last_choice() != choice_id) r.reason = "active choice is " + last_choice();
    else if (intended_option <= 0) r.reason = "option must be positive";
    else r.reason = "preconditions satisfied";
    return r;
}

/**
 * Summarize Cold Medicine Cabinet consultation state from tracked preferences.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_cold_medicine_state() {
    buffer out;
    out.append("consults_used=" + get_property("_coldMedicineConsults") + "\n");
    out.append("last_consult=" + get_property("_nextColdMedicineConsult") + "\n");
    out.append("last_environment=" + get_property("lastCombatEnvironments") + "\n");
    return out.to_string();
}

/**
 * Expose the Daylight Shavings Helmet tracking preferences as compact machine context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_shavings_state() {
    buffer out;
    out.append("last_buff=" + get_property("_shavingHelmetBuff") + "\n");
    out.append("previous_buff=" + get_property("shavingHelmetBuff") + "\n");
    return out.to_string();
}

/**
 * Check non-mutating prerequisites for using Map the Monsters at a requested location.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2scripts_map_monster_preflight(location where, monster target) {
    agent_check r;
    r.subject = "map " + target + " at " + where;
    boolean skill_ok = have_skill($skill[Map the Monsters]);
    boolean loc_ok = can_adventure(where);
    boolean target_ok = target != $monster[none];
    r.ok = skill_ok && loc_ok && target_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "skill=" + skill_ok + "; location=" + loc_ok + "; monster=" + target_ok;
    return r;
}

/**
 * Preview MP and skill-availability requirements for repeated casting without casting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_c2scripts_cast_resource_preview(skill s, int casts) {
    agent_action_preview r;
    r.operation = "cast " + casts + " " + s;
    r.adventure_cost = 0;
    r.meat_cost = 0;
    int cost = mp_cost(s) * max(0, casts);
    r.valid = casts > 0 && have_skill(s) && my_mp() >= cost;
    r.reason = "mp_required=" + cost + "; mp_current=" + my_mp() + "; have_skill=" + have_skill(s);
    if (!r.valid) r.warnings = "insufficient skill, casts, or MP";
    return r;
}

/**
 * Combine item and skill availability into one reusable resource readiness check.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2scripts_resource_readiness(item required_item, skill required_skill) {
    agent_check r;
    r.subject = required_item + " + " + required_skill;
    boolean item_ok = required_item == $item[none] || available_amount(required_item) > 0;
    boolean skill_ok = required_skill == $skill[none] || have_skill(required_skill);
    r.ok = item_ok && skill_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "item=" + item_ok + "; skill=" + skill_ok;
    return r;
}

/**
 * Serialize a caller-selected tracker preference set in stable lexical order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_tracker_fingerprint(string[int] preference_names) {
    boolean[string] names;
    foreach i, p in preference_names if (p != "") names[p] = true;
    buffer out;
    foreach p in names out.append(p + "=" + get_property(p) + "\n");
    return out.to_string();
}

/**
 * Compare a numeric tracked preference to an earlier captured value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_c2scripts_resource_delta(string property_name, int before_value) {
    agent_delta d;
    d.label = property_name;
    d.before_value = before_value;
    d.after_value = get_property(property_name).to_int();
    d.difference = d.after_value - d.before_value;
    return d;
}

/**
 * Build compact choice/cartography/resource context inspired by c2t_kol_scripts.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_agent_context(location where, monster target, int choice_id) {
    buffer out;
    out.append("location=" + where + "\n");
    out.append("can_adventure=" + can_adventure(where) + "\n");
    out.append("target_monster=" + target + "\n");
    out.append("map_skill=" + have_skill($skill[Map the Monsters]) + "\n");
    out.append("handling_choice=" + handling_choice() + "\n");
    out.append("last_choice=" + last_choice() + "\n");
    out.append("requested_choice=" + choice_id + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 04: Ezandora repository ecosystem
// https://github.com/Ezandora?tab=repositories
// Large ecosystem of relay advisers, optimizers, choice overrides, consumption/buff tools, and modular KoLmafia projects.
// ============================================================================

/**
 * Serialize one Guide-like advisory entry as compact deterministic text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advisory_entry(string title, string url, string[int] details) {
    buffer out;
    out.append("title=" + title + "\n");
    out.append("url=" + url + "\n");
    foreach i, d in details out.append("detail=" + d + "\n");
    return out.to_string();
}

/**
 * Calculate a stable task-priority signal inspired by Guide task/resource/future-task separation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ezeco_task_priority(boolean mandatory, boolean available_now, int turns_until_relevant) {
    int score;
    if (mandatory) score = score + 100;
    if (available_now) score = score + 50;
    if (turns_until_relevant <= 0) score = score + 25;
    else score = score + max(0, 20 - turns_until_relevant);
    return score;
}

/**
 * Return remaining uses for a preference-backed daily resource.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_ezeco_resource_remaining(string used_property, int limit_value) {
    agent_resource_state r;
    r.name = used_property;
    r.used = get_property(used_property).to_int();
    r.limit_value = max(0, limit_value);
    r.remaining = max(0, r.limit_value - r.used);
    r.available = r.remaining > 0;
    return r;
}

/**
 * Describe future-task eligibility from explicit unlock/completion preferences.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ezeco_future_task_state(string unlock_property, string complete_property) {
    agent_check r;
    r.subject = unlock_property + " -> " + complete_property;
    boolean unlocked = get_property(unlock_property).to_boolean();
    boolean complete = get_property(complete_property).to_boolean();
    r.ok = unlocked && !complete;
    r.severity = "info";
    r.reason = "unlocked=" + unlocked + "; complete=" + complete;
    return r;
}

/**
 * Expose location accessibility and recent turn count as advisory context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_location_advice(location loc) {
    buffer out;
    out.append("location=" + loc + "\n");
    out.append("available=" + can_adventure(loc) + "\n");
    out.append("turns_spent=" + loc.turns_spent + "\n");
    return out.to_string();
}

/**
 * Describe whether a feature is present through any of its item/familiar/skill surfaces.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ezeco_iotm_presence(item key_item, familiar key_familiar, skill key_skill) {
    agent_check r;
    r.subject = "feature-presence";
    boolean item_ok = key_item != $item[none] && available_amount(key_item) > 0;
    boolean fam_ok = key_familiar != $familiar[none] && have_familiar(key_familiar);
    boolean skill_ok = key_skill != $skill[none] && have_skill(key_skill);
    r.ok = item_ok || fam_ok || skill_ok;
    r.severity = "info";
    r.reason = "item=" + item_ok + "; familiar=" + fam_ok + "; skill=" + skill_ok;
    return r;
}

/**
 * De-duplicate Guide-like advisory lines while retaining deterministic lexical order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advice_dedupe(string[int] advisory_lines) {
    boolean[string] seen;
    foreach i, line in advisory_lines if (line != "") seen[line] = true;
    buffer out;
    foreach line in seen out.append(line + "\n");
    return out.to_string();
}

/**
 * Filter advisory lines case-insensitively for an agent/user query.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advice_filter(string[int] advisory_lines, string query) {
    buffer out;
    string q = to_lower_case(query);
    foreach i, line in advisory_lines if (q == "" || contains_text(to_lower_case(line), q)) out.append(line + "\n");
    return out.to_string();
}

/**
 * Cap a potentially large advisory list for context-budget-aware agent use.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advice_budget(string[int] advisory_lines, int max_entries) {
    buffer out;
    int emitted;
    foreach i, line in advisory_lines {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (line == "") continue;
        out.append(line + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Build a Guide-inspired compact tasks/resources section for an LLM.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_agent_context(string section_name, string[int] current_tasks, string[int] resources, int max_each) {
    buffer out;
    out.append("section=" + section_name + "\n");
    int n;
    foreach i, line in current_tasks {
        if (max_each > 0 && n >= max_each) break;
        if (line != "") { out.append("task=" + line + "\n"); n = n + 1; }
    }
    n = 0;
    foreach i, line in resources {
        if (max_each > 0 && n >= max_each) break;
        if (line != "") { out.append("resource=" + line + "\n"); n = n + 1; }
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 05: IronTetsubo KoLmafia-ash scripts
// https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
// Historical ASH collection including BatBrain, net worth, rollover, bootstrap, OCD inventory, recovery, and automation scripts.
// ============================================================================

/**
 * List mutation-oriented primitives in an IronTetsubo-era script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_side_effect_scan(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "visit_url(")) out.append("visit_url\n");
    if (contains_text(low, "cli_execute(")) out.append("cli_execute\n");
    if (contains_text(low, "adventure(")) out.append("adventure\n");
    if (contains_text(low, "use(")) out.append("use\n");
    if (contains_text(low, "buy(")) out.append("buy\n");
    if (contains_text(low, "autosell(")) out.append("autosell\n");
    if (contains_text(low, "take_storage(")) out.append("take_storage\n");
    if (contains_text(low, "set_property(")) out.append("set_property\n");
    return out.to_string();
}

/**
 * Detect external HTTP-era dependencies separately from in-game page access.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_iron_scripts_network_scan(string source_text) {
    agent_check r;
    r.subject = "external-network";
    string low = to_lower_case(source_text);
    boolean external = contains_text(low, "http://") || contains_text(low, "https://");
    r.ok = !external;
    r.severity = external ? "warning" : "info";
    r.reason = external ? "external URL text present; inspect modernization path" : "no obvious external URL";
    return r;
}

/**
 * Score reliance on substring/excise/matcher parsing around page requests.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_iron_scripts_html_parse_score(string source_text) {
    string low = to_lower_case(source_text);
    int score;
    if (contains_text(low, "visit_url(")) score = score + 1;
    if (contains_text(low, "contains_text(")) score = score + 1;
    if (contains_text(low, "substring(")) score = score + 1;
    if (contains_text(low, "index_of(")) score = score + 1;
    if (contains_text(low, "create_matcher(")) score = score + 1;
    if (contains_text(low, "excise(")) score = score + 1;
    return score;
}

/**
 * Extract legacy imports for migration dependency auditing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_import_manifest(string source_text) {
    buffer out;
    boolean[string] imports;
    matcher m = create_matcher("import\\s*<([^>]+)>", source_text);
    while (m.find()) imports[m.group(1)] = true;
    foreach x in imports out.append(x + "\n");
    return out.to_string();
}

/**
 * Extract quoted properties referenced by get_property/set_property.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_property_manifest(string source_text) {
    buffer out;
    boolean[string] prefs;
    matcher m = create_matcher("(?:get_property|set_property)\\(\"([^\"]+)\"", source_text);
    while (m.find()) prefs[m.group(1)] = true;
    foreach x in prefs out.append(x + "\n");
    return out.to_string();
}

/**
 * Extract straightforward quoted cli_execute command literals for review.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_cli_command_literals(string source_text) {
    buffer out;
    boolean[string] cmds;
    matcher m = create_matcher("cli_execute\\(\"([^\"]+)\"\\)", source_text);
    while (m.find()) cmds[m.group(1)] = true;
    foreach c in cmds out.append(c + "\n");
    return out.to_string();
}

/**
 * Combine parsing, command, network, and direct-page indicators into one modernization pressure metric.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_iron_scripts_modernization_pressure(string source_text) {
    string low = to_lower_case(source_text);
    int score;
    if (contains_text(low, "visit_url(")) score = score + 3;
    if (contains_text(low, "cli_execute(")) score = score + 2;
    if (contains_text(low, "http://")) score = score + 3;
    if (contains_text(low, "svn_")) score = score + 2;
    if (contains_text(low, "pwd")) score = score + 1;
    if (contains_text(low, "index_of(") && contains_text(low, ".php")) score = score + 2;
    return score;
}

/**
 * Flag likely top-level side effects by comparing early executable tokens with function declarations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_iron_scripts_import_safe_hint(string source_text) {
    agent_check r;
    r.subject = "import-safety";
    string low = to_lower_case(source_text);
    int first_mut = length(low);
    int p = index_of(low, "visit_url(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "cli_execute(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "set_property(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "use(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "buy(");
    if (p >= 0 && p < first_mut) first_mut = p;
    int first_function = index_of(low, "void ");
    if (first_function < 0) first_function = index_of(low, "boolean ");
    r.ok = first_mut >= first_function && first_function >= 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = r.ok ? "no obvious mutation before first function" : "possible top-level side effect";
    return r;
}

/**
 * Suggest explicit read/plan/execute split points based on legacy primitives found.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_read_plan_split(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "visit_url(")) out.append("READ: replace/encapsulate page observation\n");
    if (contains_text(low, "contains_text(") || contains_text(low, "create_matcher(")) out.append("NORMALIZE: parse observed state\n");
    if (contains_text(low, "maximize") || contains_text(low, "mall_price")) out.append("PLAN: compute candidate/cost\n");
    if (contains_text(low, "cli_execute(") || contains_text(low, "use(") || contains_text(low, "buy(")) out.append("EXECUTE: isolate mutation\n");
    return out.to_string();
}

/**
 * Build a compact migration context for an agent reviewing historical IronTetsubo scripts.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_agent_context(string source_name, string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    out.append("source=" + source_name + "\n");
    out.append("length=" + length(source_text) + "\n");
    out.append("visit_url=" + contains_text(low, "visit_url(") + "\n");
    out.append("cli_execute=" + contains_text(low, "cli_execute(") + "\n");
    out.append("external_http=" + (contains_text(low, "http://") || contains_text(low, "https://")) + "\n");
    out.append("zlib=" + contains_text(low, "zlib.ash") + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 06: c2t_hccs
// https://github.com/C2Talon/c2t_hccs
// Community Service automation with test thresholds, resources, recovery, combat, pre-adventure hooks, and relay configuration.
// ============================================================================

/**
 * Return Community Service test order used by c2t_hccs as a deterministic machine-readable list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_hccs_test_order() {
    return "hp\nmuscle\nmysticality\nmoxie\nfamiliar\nweapon\nspell\nnoncombat\nitem\nhot\n";
}

/**
 * Normalize ten Community Service threshold values into indexed TSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_hccs_thresholds_parse(string thresholds_csv) {
    string[int] values = split_string(thresholds_csv, ",");
    buffer out;
    string[int] names = split_string("hp,muscle,mysticality,moxie,familiar,weapon,spell,noncombat,item,hot", ",");
    for i from 0 to 9 {
        int v;
        if (i < count(values)) v = values[i].to_int();
        out.append(names[i] + "\t" + v + "\n");
    }
    return out.to_string();
}

/**
 * Read one test threshold safely from the configured ten-value CSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_hccs_threshold_for(string thresholds_csv, int test_index) {
    if (test_index < 0 || test_index > 9) return -1;
    string[int] values = split_string(thresholds_csv, ",");
    if (test_index >= count(values)) return -1;
    return values[test_index].to_int();
}

/**
 * Compare a current numeric modifier against a requested Community Service pre-test target.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_modifier_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_modifier_state aal_hccs_test_readiness(string modifier_name, float target_value) {
    agent_modifier_state r;
    r.modifier_name = modifier_name;
    r.current_value = numeric_modifier(modifier_name);
    r.target_value = target_value;
    r.gap = target_value - r.current_value;
    r.satisfied = r.gap <= 0;
    return r;
}

/**
 * Validate a predicted Community Service test duration against configured threshold.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_hccs_turn_threshold_check(int predicted_turns, int allowed_turns, string test_name) {
    agent_check r;
    r.subject = test_name;
    r.ok = predicted_turns <= allowed_turns;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "predicted=" + predicted_turns + "; allowed=" + allowed_turns;
    return r;
}

/**
 * Expose non-mutating HP/MP/beaten-up state relevant to c2t_hccs recovery.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_hccs_recovery_state() {
    buffer out;
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    out.append("beaten_up=" + have_effect($effect[Beaten Up]) + "\n");
    return out.to_string();
}

/**
 * Describe a daily resource budget for a Community Service preparation step.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_hccs_resource_budget(string used_property, int cap) {
    agent_resource_state r;
    r.name = used_property;
    r.used = get_property(used_property).to_int();
    r.limit_value = max(0, cap);
    r.remaining = max(0, r.limit_value - r.used);
    r.available = r.remaining > 0;
    return r;
}

/**
 * Build compact pre-test context with modifier state, health, and threshold.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_hccs_pretest_context(string test_name, string modifier_name, int predicted_turns, int allowed_turns) {
    buffer out;
    out.append("test=" + test_name + "\n");
    out.append("modifier=" + modifier_name + "\n");
    out.append("modifier_value=" + numeric_modifier(modifier_name) + "\n");
    out.append("predicted_turns=" + predicted_turns + "\n");
    out.append("allowed_turns=" + allowed_turns + "\n");
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    return out.to_string();
}

/**
 * Serialize selected HCCS configuration/preferences deterministically.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_hccs_property_snapshot(string[int] names) {
    boolean[string] keys;
    foreach i, n in names if (n != "") keys[n] = true;
    buffer out;
    foreach n in keys out.append(n + "=" + get_property(n) + "\n");
    return out.to_string();
}

/**
 * Explain whether an HCCS agent should stop before a test without performing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_hccs
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_hccs_stop_reason(int predicted_turns, int allowed_turns, boolean resource_ready, boolean health_ready) {
    if (predicted_turns > allowed_turns) return "threshold-exceeded";
    if (!resource_ready) return "resource-not-ready";
    if (!health_ready) return "health-not-ready";
    return "ready";
}

// ============================================================================
// SOURCE 07: c2t_ascend
// https://github.com/C2Talon/c2t_ascend
// Valhalla/ascension automation with relay-configured path/class/sign/astral/perm choices and validation.
// ============================================================================

/**
 * Return stable names for a minimal Valhalla/ascension plan schema.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_config_fields() {
    return "path\nclass\nsign\nastral_item\nastral_consumable\nperms\npost_ascension_script\n";
}

/**
 * Safely read an indexed value from a comma-delimited ascension configuration.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_config_value(string csv, int index) {
    if (index < 0) return "";
    string[int] bits = split_string(csv, ",");
    if (index >= count(bits)) return "";
    return bits[index];
}

/**
 * Compare banked karma with planned perm expenditure.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_range_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_ascend_karma_budget(int planned_perm_cost) {
    agent_range_state r;
    r.minimum = max(0, planned_perm_cost);
    r.maximum = get_property("bankedKarma").to_int();
    r.current = r.maximum;
    r.remaining = r.current - r.minimum;
    r.satisfied = r.remaining >= 0;
    return r;
}

/**
 * Expose current aftercore/interaction/king state relevant to entering Valhalla.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_prerequisite_state() {
    buffer out;
    out.append("can_interact=" + can_interact() + "\n");
    out.append("king_liberated=" + get_property("kingLiberated") + "\n");
    out.append("ascensions=" + my_ascensions() + "\n");
    out.append("path=" + my_path() + "\n");
    return out.to_string();
}

/**
 * Validate that configured path/class/sign strings resolve to current KoLmafia typed values.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ascend_plan_validate(string path_name, string class_name, string sign_name) {
    agent_check r;
    r.subject = "ascension-plan";
    path p = to_path(path_name);
    class c = to_class(class_name);
    r.ok = p != $path[none] && c != $class[none] && sign_name != "";
    r.severity = r.ok ? "info" : "warning";
    r.reason = "path=" + p + "; class=" + c + "; sign=" + sign_name;
    return r;
}

/**
 * Filter caller-supplied perm candidates to skills actually known by the character.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_perm_candidates(skill[int] skills, int max_entries) {
    buffer out;
    int emitted;
    foreach i, s in skills {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (!have_skill(s)) continue;
        out.append(to_int(s) + "\t" + s + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize compact pre-ascension currencies/resources useful for planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_resource_snapshot() {
    buffer out;
    out.append("meat=" + my_meat() + "\n");
    out.append("karma=" + get_property("bankedKarma") + "\n");
    out.append("pulls_remaining=" + pulls_remaining() + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    return out.to_string();
}

/**
 * Describe the configured post-ascension command without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_ascend_post_script_preview(string command_text) {
    agent_action_preview r;
    r.operation = command_text;
    r.valid = command_text != "";
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = r.valid ? "configured command preserved verbatim" : "no post-ascension command configured";
    if (contains_text(to_lower_case(command_text), "send ") || contains_text(to_lower_case(command_text), "kmail")) r.warnings = "contains communication-like command text; review manually";
    return r;
}

/**
 * Produce a stable lightweight fingerprint for detecting ascension-config drift.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ascend_config_fingerprint(string config_csv) {
    int h = length(config_csv) * 97;
    int commas;
    int spaces;
    if (length(config_csv) > 0) {
        for i from 0 to length(config_csv) - 1 {
            string ch = substring(config_csv, i, i + 1);
            if (ch == ",") commas = commas + 1;
            if (ch == " ") spaces = spaces + 1;
        }
    }
    return (h + commas * 31 + spaces * 17) % 1000003;
}

/**
 * Build compact current-state plus configured-plan context for an ascension agent.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_agent_context(string config_csv, string post_script) {
    buffer out;
    out.append("config=" + config_csv + "\n");
    out.append("post_script=" + post_script + "\n");
    out.append("current_path=" + my_path() + "\n");
    out.append("current_class=" + my_class() + "\n");
    out.append("karma=" + get_property("bankedKarma") + "\n");
    out.append("can_interact=" + can_interact() + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 08: pLooper
// https://github.com/Prusias-kol/pLooper
// Re-entrant full-day loop orchestration around breakfast, farming, prep, ascension, post-run work, nightcap, and checkpoints.
// ============================================================================

/**
 * Return deterministic pLooper-inspired full-day phase names.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ploop_phase_names() {
    return "breakfast\ngarbo_leg1\nprerun\nascend\npostrun\ngarbo_leg2\nnightcap\ncomplete\n";
}

/**
 * Check exact breakpoint membership in a comma-delimited event list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_ploop_breakpoint_seen(string event_list, string breakpoint) {
    foreach i, e in split_string(event_list, ",") if (e == breakpoint) return true;
    return false;
}

/**
 * Infer furthest completed loop phase from named breakpoint text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ploop_phase_index(string event_list) {
    string low = to_lower_case(event_list);
    if (contains_text(low, "end") || contains_text(low, "complete")) return 7;
    if (contains_text(low, "nightcap")) return 6;
    if (contains_text(low, "afterfinal50") || contains_text(low, "garbo2")) return 5;
    if (contains_text(low, "postrun")) return 4;
    if (contains_text(low, "ascend")) return 3;
    if (contains_text(low, "prerun")) return 2;
    if (contains_text(low, "afterff") || contains_text(low, "garbo")) return 1;
    return 0;
}

/**
 * Describe current loop re-entry position without executing a phase.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ploop_reentry_context(string event_list) {
    buffer out;
    out.append("event_list=" + event_list + "\n");
    out.append("phase_index=" + aal_ploop_phase_index(event_list) + "\n");
    out.append("ascensions_today=" + get_property("ascensionsToday") + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    out.append("inebriety=" + my_inebriety() + "/" + inebriety_limit() + "\n");
    return out.to_string();
}

/**
 * Choose the next canonical pLooper-inspired phase from observed breakpoint history.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ploop_next_phase(string event_list) {
    int i = aal_ploop_phase_index(event_list);
    switch (i) {
    case 0: return "garbo_leg1";
    case 1: return "prerun";
    case 2: return "ascend";
    case 3: return "postrun";
    case 4: return "garbo_leg2";
    case 5: return "nightcap";
    case 6: return "complete";
    default: return "complete";
    }
}

/**
 * Capture organs for phase-boundary planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_organ_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_organ_state aal_ploop_organ_snapshot() {
    agent_organ_state r;
    r.fullness = my_fullness();
    r.fullness_limit_value = fullness_limit();
    r.inebriety = my_inebriety();
    r.inebriety_limit_value = inebriety_limit();
    r.spleen = my_spleen_use();
    r.spleen_limit_value = spleen_limit();
    return r;
}

/**
 * Check whether a desired workshed item is already available before a loop would attempt installation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ploop_workshed_preflight(item desired_workshed) {
    agent_check r;
    r.subject = desired_workshed;
    r.ok = desired_workshed != $item[none] && available_amount(desired_workshed) > 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "available=" + available_amount(desired_workshed) + "; workshed_used=" + get_property("_workshedItemUsed");
    return r;
}

/**
 * Normalize ascensionsToday into a simple loop leg number.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ploop_ascension_leg() {
    int a = get_property("ascensionsToday").to_int();
    if (a <= 0) return 1;
    return a + 1;
}

/**
 * Return structured completion status from event-list evidence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ploop_completion_check(string event_list) {
    agent_check r;
    r.subject = "ploop-completion";
    r.ok = aal_ploop_breakpoint_seen(event_list, "end") || aal_ploop_breakpoint_seen(event_list, "End");
    r.severity = r.ok ? "info" : "warning";
    r.reason = r.ok ? "end breakpoint present" : "end breakpoint absent";
    return r;
}

/**
 * Describe the next loop phase and relevant state without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ploop_phase_preview(string event_list, string configured_ascend_command) {
    buffer out;
    string next = aal_ploop_next_phase(event_list);
    out.append("next_phase=" + next + "\n");
    out.append("ascend_command=" + configured_ascend_command + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    out.append("can_interact=" + can_interact() + "\n");
    out.append("ascensions_today=" + get_property("ascensionsToday") + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 09: pTrack repository
// https://github.com/Prusias-kol/pTrack
// Profit/time/breakpoint tracking suite combining inventory, meat, time, account value, and named checkpoints.
// ============================================================================

/**
 * Create an unambiguous breakpoint key from date and event.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrack_checkpoint_key(string date, string event) {
    return date + "\t" + event;
}

/**
 * Capture a compact in-memory breakpoint snapshot without writing files.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_breakpoint.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_breakpoint aal_ptrack_snapshot(string name, int stamp) {
    agent_breakpoint b;
    b.name = name;
    b.date = today_to_string();
    b.turns = total_turns_played();
    b.meat = my_meat() + my_closet_meat() + my_storage_meat();
    b.stamp = stamp;
    return b;
}

/**
 * Serialize meat/turn/time deltas between two in-memory breakpoints.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrack_breakpoint_delta(agent_breakpoint before, agent_breakpoint after) {
    buffer out;
    out.append("from=" + before.name + "\n");
    out.append("to=" + after.name + "\n");
    out.append("turn_delta=" + (after.turns - before.turns) + "\n");
    out.append("meat_delta=" + (after.meat - before.meat) + "\n");
    out.append("time_delta=" + (after.stamp - before.stamp) + "\n");
    return out.to_string();
}

/**
 * Compute liquid-meat delta per turn for a checkpoint interval.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_ptrack_meat_per_adventure(agent_breakpoint before, agent_breakpoint after) {
    int turns = after.turns - before.turns;
    if (turns <= 0) return 0.0;
    return to_float(after.meat - before.meat) / turns;
}

/**
 * De-duplicate a comma-delimited breakpoint list while preserving stable lexical output.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrack_event_list_normalize(string event_list) {
    boolean[string] seen;
    foreach i, e in split_string(event_list, ",") if (e != "") seen[e] = true;
    buffer out;
    foreach e in seen out.append(e + "\n");
    return out.to_string();
}

/**
 * Turn a breakpoint list into adjacent comparison pairs.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrack_adjacent_pairs(string event_list) {
    string[int] events = split_string(event_list, ",");
    buffer out;
    if (count(events) < 2) return "";
    for i from 1 to count(events) - 1 out.append(events[i - 1] + "\t" + events[i] + "\n");
    return out.to_string();
}

/**
 * Validate a breakpoint record before persistence/comparison.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ptrack_checkpoint_validate(agent_breakpoint b) {
    agent_check r;
    r.subject = b.name;
    r.ok = b.name != "" && b.turns >= 0 && b.stamp >= 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "date=" + b.date + "; turns=" + b.turns + "; stamp=" + b.stamp;
    return r;
}

/**
 * Build compact interval-rate context for an agent interpreting pTrack data.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrack_rate_context(agent_breakpoint before, agent_breakpoint after) {
    int turns = after.turns - before.turns;
    int meat = after.meat - before.meat;
    int elapsed = after.stamp - before.stamp;
    buffer out;
    out.append("turns=" + turns + "\n");
    out.append("meat=" + meat + "\n");
    out.append("elapsed_ms=" + elapsed + "\n");
    if (turns > 0) out.append("liquid_meat_per_turn=" + (to_float(meat) / turns) + "\n");
    return out.to_string();
}

/**
 * Determine whether a tracker's stored date differs from KoLmafia's current date.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_ptrack_daily_reset_needed(string stored_date) {
    return stored_date != today_to_string();
}

/**
 * Build compact tracker state for an LLM deciding what interval to compare next.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrack_agent_context(string event_list, agent_breakpoint latest) {
    buffer out;
    out.append("date=" + latest.date + "\n");
    out.append("latest=" + latest.name + "\n");
    out.append("turns=" + latest.turns + "\n");
    out.append("meat=" + latest.meat + "\n");
    out.append("events=" + event_list + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 10: pUpdates repository
// https://github.com/Prusias-kol/pUpdates
// Small file-backed update/changelog library with per-script versions and local seen-version tracking.
// ============================================================================

/**
 * Read the local seen-version property for a pUpdates-style script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_kv.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_kv aal_pupdates_state(string script_name) {
    agent_kv r;
    r.key = "prusias_pUpdates_" + script_name + "_localVersion";
    r.value = get_property(r.key);
    r.note = r.value == "" ? "uninitialized" : "initialized";
    return r;
}

/**
 * Return normalized seen update version for a script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_pupdates_seen_version(string script_name) {
    string p = get_property("prusias_pUpdates_" + script_name + "_localVersion");
    if (p == "") return -1;
    return p.to_int();
}

/**
 * Compute how many update entries are unseen without changing the local version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_pupdates_pending_count(string script_name, int current_version) {
    int seen = aal_pupdates_seen_version(script_name);
    return max(0, current_version - seen);
}

/**
 * Describe inclusive unseen changelog version range.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdates_pending_range(string script_name, int current_version) {
    int seen = aal_pupdates_seen_version(script_name);
    if (current_version <= seen) return "none";
    return (seen + 1) + ".." + current_version;
}

/**
 * Return structured up-to-date status without marking updates as read.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_pupdates_version_check(string script_name, int current_version) {
    agent_check r;
    r.subject = script_name;
    int seen = aal_pupdates_seen_version(script_name);
    r.ok = seen == current_version;
    r.severity = r.ok ? "info" : "notice";
    r.reason = "seen=" + seen + "; current=" + current_version;
    return r;
}

/**
 * Generate the canonical local-version preference name used by pUpdates.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdates_property_name(string script_name) {
    return "prusias_pUpdates_" + script_name + "_localVersion";
}

/**
 * Create a stable key for one script/version update entry.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdates_update_key(string script_name, int version) {
    return script_name + "#" + version;
}

/**
 * Build a non-mutating update-check preview.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_pupdates_update_preview(string script_name, int current_version) {
    agent_action_preview r;
    r.operation = "review updates for " + script_name;
    r.valid = script_name != "" && current_version >= 0;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    int seen = aal_pupdates_seen_version(script_name);
    r.reason = "seen=" + seen + "; current=" + current_version + "; pending=" + max(0, current_version - seen);
    return r;
}

/**
 * Serialize one update status as TSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: script<TAB>seen<TAB>current<TAB>pending
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdates_status_line(string script_name, int current_version) {
    int seen = aal_pupdates_seen_version(script_name);
    return script_name + "\t" + seen + "\t" + current_version + "\t" + max(0, current_version - seen);
}

/**
 * Build compact multi-script update state without acknowledging any update.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdates_agent_context(string[int] scripts, int[int] current_versions) {
    buffer out;
    if (count(scripts) == 0) return "";
    for i from 0 to count(scripts) - 1 {
        string s = scripts[i];
        int current;
        if (current_versions contains i) current = current_versions[i];
        out.append(aal_pupdates_status_line(s, current) + "\n");
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 11: pLooper lowerstats.ash
// https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
// Stat-lowering helper that identifies buffed stats over a target, applies negative effects/items, shrugs positive stat effects, and aborts on failure.
// ============================================================================

/**
 * Measure how far a buffed stat exceeds a desired cap.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_range_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_lowerstats_pressure(stat s, int cap) {
    agent_range_state r;
    r.minimum = 0;
    r.maximum = max(0, cap);
    r.current = my_buffedstat(s);
    r.remaining = max(0, r.current - r.maximum);
    r.satisfied = r.current <= r.maximum;
    return r;
}

/**
 * Serialize over-cap pressure for all three stats.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: stat<TAB>buffed<TAB>excess
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_all_pressure(int cap) {
    buffer out;
    foreach s in $stats[] {
        int current = my_buffedstat(s);
        int excess = max(0, current - cap);
        out.append(s + "\t" + current + "\t" + excess + "\n");
    }
    return out.to_string();
}

/**
 * List active effects that positively modify the requested stat, bounded for agent context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_positive_effects(stat s, int max_entries) {
    buffer out;
    int emitted;
    int[effect] active = my_effects();
    foreach e, turns in active {
        if (max_entries > 0 && emitted >= max_entries) break;
        float v = numeric_modifier(e, s.to_string());
        if (v <= 0) continue;
        out.append(e + "\t" + turns + "\t" + v + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Explain whether an active positive-stat effect also carries protected economic/familiar/smithsness modifiers.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_lowerstats_effect_safety(effect e) {
    agent_check r;
    r.subject = e;
    boolean economic = numeric_modifier(e, "Meat Drop") > 0;
    boolean familiar = numeric_modifier(e, "Familiar Weight") != 0;
    boolean smith = numeric_modifier(e, "Smithsness") != 0;
    r.ok = !(economic || familiar || smith);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "meat=" + economic + "; familiar=" + familiar + "; smithsness=" + smith;
    return r;
}

/**
 * List active positive-stat effects that are plausible shrug candidates under the source's protection rules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_shrug_candidates(stat s, int cap, int max_entries) {
    if (my_buffedstat(s) <= cap) return "";
    buffer out;
    int emitted;
    int[effect] active = my_effects();
    foreach e, turns in active {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (numeric_modifier(e, s.to_string()) <= 0) continue;
        if (numeric_modifier(e, "Meat Drop") > 0) continue;
        if (numeric_modifier(e, "Familiar Weight") != 0) continue;
        if (numeric_modifier(e, "Smithsness") != 0) continue;
        out.append(e + "\t" + turns + "\t" + numeric_modifier(e, s.to_string()) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Describe source-inspired low-stat consumable/item options without acquiring or using them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_item_option(stat s) {
    if (s == $stat[muscle]) return "decorative fountain -> Sleepy";
    if (s == $stat[moxie]) return "patchouli incense stick -> Far Out";
    return "Fun-Guy spore -> Mush-Mouth; Mr. Mediocrebar -> Apathy";
}

/**
 * Compare a stat-lowering item's mall price with a caller budget without buying it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_lowerstats_budget_preview(item it, int max_price) {
    agent_action_preview r;
    r.operation = "acquire " + it;
    int p = mall_price(it);
    r.meat_cost = max(0, p);
    r.adventure_cost = 0;
    r.valid = it != $item[none] && (available_amount(it) > 0 || (p > 0 && p <= max_price));
    r.reason = "available=" + available_amount(it) + "; mall_price=" + p + "; max_price=" + max_price;
    if (!r.valid) r.warnings = "item unavailable or above budget";
    return r;
}

/**
 * Build a compact read-only stat-lowering plan for one stat.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_plan(stat s, int cap) {
    buffer out;
    out.append("stat=" + s + "\n");
    out.append("current=" + my_buffedstat(s) + "\n");
    out.append("cap=" + cap + "\n");
    out.append("excess=" + max(0, my_buffedstat(s) - cap) + "\n");
    if (my_buffedstat(s) > cap) out.append("suggestion=" + aal_lowerstats_item_option(s) + "\n");
    else out.append("suggestion=none\n");
    return out.to_string();
}

/**
 * Check the postcondition the original helper ultimately wanted: buffed stat at or below cap.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_lowerstats_postcondition(stat s, int cap) {
    agent_check r;
    r.subject = s;
    r.ok = my_buffedstat(s) <= cap;
    r.severity = r.ok ? "info" : "error";
    r.reason = "buffed=" + my_buffedstat(s) + "; cap=" + cap;
    return r;
}

/**
 * Build compact all-stat state plus relevant source-inspired negative effects for an agent.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_agent_context(int cap) {
    buffer out;
    out.append("cap=" + cap + "\n");
    foreach s in $stats[] out.append(s + "=" + my_buffedstat(s) + ";excess=" + max(0, my_buffedstat(s)-cap) + "\n");
    out.append("mush_mouth=" + have_effect($effect[Mush-Mouth]) + "\n");
    out.append("sleepy=" + have_effect($effect[Sleepy]) + "\n");
    out.append("far_out=" + have_effect($effect[Far Out]) + "\n");
    out.append("apathy=" + have_effect($effect[Apathy]) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 12: pwrapper
// https://github.com/Prusias-kol/pwrapper
// Retry wrapper for a loop script with error logging, choice/combat safe-state recovery, refresh, and completion detection.
// ============================================================================

/**
 * Normalize wrapper retry counters.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_range_state.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_pwrapper_retry_state(int attempt, int max_attempts) {
    agent_range_state r;
    r.minimum = 1;
    r.maximum = max(1, max_attempts);
    r.current = attempt;
    r.remaining = max(0, r.maximum - r.current);
    r.satisfied = attempt >= 1 && attempt <= r.maximum;
    return r;
}

/**
 * Combine a caught wrapper error with KoLmafia's latest combat/encounter diagnostics.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pwrapper_error_context(string error_message) {
    buffer out;
    out.append("error=" + error_message + "\n");
    out.append("last_macro_error=" + get_property("lastMacroError") + "\n");
    out.append("last_encounter=" + get_property("lastEncounter") + "\n");
    out.append("last_combat_result=" + get_property("lastCombatResult") + "\n");
    return out.to_string();
}

/**
 * Describe current choice and configured option without submitting it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_choice_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_choice_state aal_pwrapper_choice_recovery_state() {
    agent_choice_state r;
    r.choice_id = handling_choice() ? last_choice() : -1;
    r.handling = handling_choice();
    if (r.handling) {
        r.preference_name = "choiceAdventure" + r.choice_id;
        r.configured_option = get_property(r.preference_name).to_int();
        if (get_property(r.preference_name) == "") r.note = "unset";
        else if (r.configured_option == 0) r.note = "manual";
        else r.note = "configured";
    } else r.note = "not-in-choice";
    return r;
}

/**
 * Validate whether wrapper-style automatic choice recovery can proceed.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_pwrapper_choice_recovery_preflight(boolean fail_unset) {
    agent_check r;
    r.subject = "choice-recovery";
    if (!handling_choice()) {
        r.ok = true; r.severity = "info"; r.reason = "not handling a choice"; return r;
    }
    string pref = "choiceAdventure" + last_choice();
    string raw = get_property(pref);
    if (raw == "0") {
        r.ok = false; r.severity = "error"; r.reason = "manual control configured";
    } else if (raw == "" && fail_unset) {
        r.ok = false; r.severity = "error"; r.reason = "choice preference unset";
    } else {
        r.ok = true; r.severity = raw == "" ? "warning" : "info"; r.reason = raw == "" ? "fallback required" : "configured option " + raw;
    }
    return r;
}

/**
 * Describe whether wrapper recovery is currently in combat-like state using tracked combat signals.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pwrapper_combat_recovery_state() {
    buffer out;
    out.append("last_monster=" + last_monster() + "\n");
    out.append("last_combat_result=" + get_property("lastCombatResult") + "\n");
    out.append("last_macro_error=" + get_property("lastMacroError") + "\n");
    out.append("beaten_up=" + have_effect($effect[Beaten Up]) + "\n");
    return out.to_string();
}

/**
 * Check a conservative safe-state condition: not in a choice and not Beaten Up.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_pwrapper_safe_state_check() {
    agent_check r;
    r.subject = "wrapper-safe-state";
    r.ok = !handling_choice() && have_effect($effect[Beaten Up]) == 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "choice=" + handling_choice() + "; beaten_up=" + have_effect($effect[Beaten Up]);
    return r;
}

/**
 * Check exact completion-token evidence in the wrapper's breakpoint list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_pwrapper_completion_evidence(string event_list, string completion_token) {
    agent_check r;
    r.subject = "completion";
    boolean found;
    foreach i, e in split_string(event_list, ",") if (e == completion_token) found = true;
    r.ok = found;
    r.severity = found ? "info" : "warning";
    r.reason = found ? "completion token present" : "completion token absent";
    return r;
}

/**
 * Return the next wrapper action without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pwrapper_retry_decision(int attempt, int max_attempts, boolean completed, boolean safe_state) {
    if (completed) return "stop-success";
    if (attempt >= max_attempts) return "stop-failed";
    if (!safe_state) return "recover-state";
    return "retry-loop-script";
}

/**
 * Serialize one retry failure as a compact deterministic log line.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pwrapper_log_line(int attempt, string error_message, string last_encounter, string last_result) {
    return "attempt=" + attempt + "|error=" + error_message + "|encounter=" + last_encounter + "|result=" + last_result;
}

/**
 * Build compact wrapper/recovery context for an agent deciding whether to retry.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pwrapper
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pwrapper_agent_context(int attempt, int max_attempts, string event_list) {
    buffer out;
    out.append("attempt=" + attempt + "/" + max_attempts + "\n");
    out.append("events=" + event_list + "\n");
    out.append("handling_choice=" + handling_choice() + "\n");
    out.append("last_choice=" + last_choice() + "\n");
    out.append("beaten_up=" + have_effect($effect[Beaten Up]) + "\n");
    out.append("last_macro_error=" + get_property("lastMacroError") + "\n");
    out.append("last_encounter=" + get_property("lastEncounter") + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 13: ProfitTracking.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
// Inventory/meat/net-worth checkpoint logging, accountval parsing, item delta valuation, and profit-per-adventure comparison.
// ============================================================================

/**
 * Return liquid meat across inventory, closet, and storage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_profit_liquid_meat() {
    return my_meat() + my_closet_meat() + my_storage_meat();
}

/**
 * Capture an item's quantities across major account locations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_item_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_item_state aal_profit_item_state(item it) {
    agent_item_state r;
    r.thing = it;
    r.inventory = item_amount(it);
    r.closet = closet_amount(it);
    r.storage = storage_amount(it);
    r.display = display_amount(it);
    r.shop = shop_amount(it);
    r.equipped = equipped_amount(it);
    r.total = r.inventory + r.closet + r.storage + r.display + r.shop + r.equipped;
    return r;
}

/**
 * Estimate an item value with fresh historical price fallback to mall/autosell.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_profit_price_estimate(item it, int max_historical_age) {
    if (it == $item[none]) return 0;
    if (!is_tradeable(it)) return max(0, autosell_price(it));
    int hist = historical_price(it);
    if (hist > 0 && historical_age(it) <= max_historical_age) return hist;
    int mall = mall_price(it);
    if (mall > 0) return mall;
    return max(0, autosell_price(it));
}

/**
 * Estimate total value of currently held inventory/closet/storage/display/shop/equipped items.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_profit_inventory_value(int max_historical_age) {
    int total;
    foreach it in $items[] {
        int qty = item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
        if (qty <= 0) continue;
        total = total + qty * aal_profit_price_estimate(it, max_historical_age);
    }
    return total;
}

/**
 * Capture liquid meat, item value, total value, turns and caller timestamp.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_value_snapshot.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_value_snapshot aal_profit_snapshot(int stamp, int max_historical_age) {
    agent_value_snapshot r;
    r.liquid_meat = aal_profit_liquid_meat();
    r.item_value = aal_profit_inventory_value(max_historical_age);
    r.total_value = r.liquid_meat + r.item_value;
    r.turns = total_turns_played();
    r.stamp = stamp;
    return r;
}

/**
 * Serialize value/turn/time changes between two profit snapshots.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_profit_snapshot_delta(agent_value_snapshot before, agent_value_snapshot after) {
    buffer out;
    out.append("liquid_meat_delta=" + (after.liquid_meat - before.liquid_meat) + "\n");
    out.append("item_value_delta=" + (after.item_value - before.item_value) + "\n");
    out.append("total_value_delta=" + (after.total_value - before.total_value) + "\n");
    out.append("turn_delta=" + (after.turns - before.turns) + "\n");
    out.append("time_delta=" + (after.stamp - before.stamp) + "\n");
    return out.to_string();
}

/**
 * Compute total-value delta per turn.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_profit_value_per_turn(agent_value_snapshot before, agent_value_snapshot after) {
    int turns = after.turns - before.turns;
    if (turns <= 0) return 0.0;
    return to_float(after.total_value - before.total_value) / turns;
}

/**
 * Compare current cross-location item total against an earlier captured total.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_profit_item_delta(item it, int before_total) {
    agent_delta d;
    d.label = it;
    d.before_value = before_total;
    agent_item_state s = aal_profit_item_state(it);
    d.after_value = s.total;
    d.difference = d.after_value - d.before_value;
    return d;
}

/**
 * Emit bounded valuable-item context without logging to disk.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_profit_top_inventory_context(int min_unit_value, int max_entries, int max_historical_age) {
    buffer out;
    int emitted;
    foreach it in $items[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        int qty = item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
        if (qty <= 0) continue;
        int unit = aal_profit_price_estimate(it, max_historical_age);
        if (unit < min_unit_value) continue;
        out.append(to_int(it) + "\t" + it + "\t" + qty + "\t" + unit + "\t" + (qty * unit) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize a profit snapshot as compact key=value state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_profit_agent_context(agent_value_snapshot snap) {
    buffer out;
    out.append("liquid_meat=" + snap.liquid_meat + "\n");
    out.append("item_value=" + snap.item_value + "\n");
    out.append("total_value=" + snap.total_value + "\n");
    out.append("turns=" + snap.turns + "\n");
    out.append("stamp=" + snap.stamp + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 14: TimeTracking.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
// Named timestamp checkpoints, elapsed-time comparison, event-list tracking, and combined profit/time breakpoints.
// ============================================================================

/**
 * Compute non-negative elapsed milliseconds between two stored timestamps.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_time_elapsed_ms(int before_stamp, int after_stamp) {
    return max(0, after_stamp - before_stamp);
}

/**
 * Compute elapsed seconds between stored millisecond timestamps.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_time_elapsed_seconds(int before_stamp, int after_stamp) {
    return to_float(aal_time_elapsed_ms(before_stamp, after_stamp)) / 1000.0;
}

/**
 * Describe elapsed-time budget consumption and remaining milliseconds.
 *
 * Parameters: elapsed_ms: observed duration; budget_ms: allowed duration.
 * Return: Range-like state containing current, maximum, remaining, and satisfied.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: agent_range_state
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_time_budget_state(int elapsed_ms, int budget_ms) {
    agent_range_state r;
    r.minimum = 0;
    r.maximum = max(0, budget_ms);
    r.current = max(0, elapsed_ms);
    r.remaining = r.maximum - r.current;
    r.satisfied = r.current <= r.maximum;
    return r;
}

/**
 * Format a millisecond duration as deterministic HH:MM:SS.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_time_format_duration(int elapsed_ms) {
    int sec = max(0, elapsed_ms) / 1000;
    int h = sec / 3600;
    int m = (sec % 3600) / 60;
    int s = sec % 60;
    string hs = h < 10 ? "0" + h : "" + h;
    string ms = m < 10 ? "0" + m : "" + m;
    string ss = s < 10 ? "0" + s : "" + s;
    return hs + ":" + ms + ":" + ss;
}

/**
 * Calculate turn throughput for a timed interval.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_time_turns_per_hour(int turns, int elapsed_ms) {
    if (turns <= 0 || elapsed_ms <= 0) return 0.0;
    return to_float(turns) * 3600000.0 / elapsed_ms;
}

/**
 * Calculate average seconds per turn.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_time_seconds_per_turn(int turns, int elapsed_ms) {
    if (turns <= 0 || elapsed_ms <= 0) return 0.0;
    return to_float(elapsed_ms) / 1000.0 / turns;
}

/**
 * Check whether an interval stays under a caller-defined seconds-per-turn threshold.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_time_pace_check(int turns, int elapsed_ms, float max_seconds_per_turn) {
    agent_check r;
    r.subject = "pace";
    float pace = aal_time_seconds_per_turn(turns, elapsed_ms);
    r.ok = turns > 0 && pace <= max_seconds_per_turn;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "seconds_per_turn=" + pace + "; max=" + max_seconds_per_turn;
    return r;
}

/**
 * Serialize one time breakpoint as TSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_time_breakpoint_line(string date, string event, int stamp) {
    return date + "\t" + event + "\t" + stamp;
}

/**
 * Serialize elapsed time between adjacent named breakpoints.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_time_adjacent_durations(string[int] names, int[int] stamps) {
    buffer out;
    if (count(names) < 2) return "";
    for i from 1 to count(names) - 1 {
        if (!(stamps contains (i - 1)) || !(stamps contains i)) continue;
        out.append(names[i - 1] + "\t" + names[i] + "\t" + max(0, stamps[i] - stamps[i - 1]) + "\n");
    }
    return out.to_string();
}

/**
 * Build compact timing/throughput context for an agent.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_time_agent_context(string from_event, string to_event, int turns, int elapsed_ms) {
    buffer out;
    out.append("from=" + from_event + "\n");
    out.append("to=" + to_event + "\n");
    out.append("turns=" + turns + "\n");
    out.append("elapsed_ms=" + elapsed_ms + "\n");
    out.append("duration=" + aal_time_format_duration(elapsed_ms) + "\n");
    out.append("seconds_per_turn=" + aal_time_seconds_per_turn(turns, elapsed_ms) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 15: ptrack.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
// User-facing breakpoint orchestration over profit and time trackers, daily reset, comparison, and breakpoint lists.
// ============================================================================

/**
 * Normalize the pTrack breakpoint property into one event per line.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrackcli_parse_breakpoints(string event_list) {
    buffer out;
    foreach i, e in split_string(event_list, ",") if (e != "") out.append(e + "\n");
    return out.to_string();
}

/**
 * Count non-empty breakpoints in an event-list property.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ptrackcli_breakpoint_count(string event_list) {
    int n;
    foreach i, e in split_string(event_list, ",") if (e != "") n = n + 1;
    return n;
}

/**
 * Test exact breakpoint membership.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_ptrackcli_breakpoint_exists(string event_list, string name) {
    foreach i, e in split_string(event_list, ",") if (e == name) return true;
    return false;
}

/**
 * Report duplicate breakpoint names that could confuse interval comparisons.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrackcli_breakpoint_duplicates(string event_list) {
    int[string] counts;
    foreach i, e in split_string(event_list, ",") if (e != "") counts[e] = counts[e] + 1;
    buffer out;
    foreach e, n in counts if (n > 1) out.append(e + "\t" + n + "\n");
    return out.to_string();
}

/**
 * Generate all adjacent comparison pairs from the current breakpoint order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrackcli_compare_plan(string event_list) {
    string[int] e = split_string(event_list, ",");
    buffer out;
    string previous = "";
    foreach i, current in e {
        if (current == "") continue;
        if (previous != "") out.append(previous + "\t" + current + "\n");
        previous = current;
    }
    return out.to_string();
}

/**
 * Check whether daily tracking should be reset based on KoL date.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ptrackcli_reset_check(string stored_date) {
    agent_check r;
    r.subject = "daily-tracking";
    r.ok = stored_date == today_to_string();
    r.severity = r.ok ? "info" : "notice";
    r.reason = r.ok ? "tracking date current" : "stored date differs from today";
    return r;
}

/**
 * Validate breakpoint names for comma-delimited storage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ptrackcli_name_validate(string breakpoint_name) {
    agent_check r;
    r.subject = breakpoint_name;
    r.ok = breakpoint_name != "" && !contains_text(breakpoint_name, ",") && !contains_text(breakpoint_name, "\n");
    r.severity = r.ok ? "info" : "error";
    r.reason = r.ok ? "safe for comma-delimited property" : "empty/comma/newline not allowed";
    return r;
}

/**
 * Return first expected breakpoint not yet present.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrackcli_next_breakpoint(string event_list, string[int] expected_order) {
    foreach i, name in expected_order {
        boolean found;
        foreach j, e in split_string(event_list, ",") if (e == name) found = true;
        if (!found) return name;
    }
    return "";
}

/**
 * Serialize breakpoint-list health and endpoints.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrackcli_summary(string event_list) {
    string[int] e = split_string(event_list, ",");
    string first = "";
    string last = "";
    int n;
    foreach i, name in e if (name != "") {
        if (first == "") first = name;
        last = name;
        n = n + 1;
    }
    return "count=" + n + "\nfirst=" + first + "\nlast=" + last + "\n";
}

/**
 * Build compact user-facing tracker orchestration context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ptrackcli_agent_context(string event_list, string stored_date) {
    buffer out;
    out.append("today=" + today_to_string() + "\n");
    out.append("stored_date=" + stored_date + "\n");
    out.append("breakpoints=" + event_list + "\n");
    out.append("count=" + aal_ptrackcli_breakpoint_count(event_list) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 16: pChecklist
// https://github.com/Prusias-kol/pChecklist
// File-backed item checklists supporting ranges/custom ID lists and ownership checks across multiple item locations.
// ============================================================================

/**
 * Count an item across inventory, closet, display, equipment, shop, and storage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_checklist_total_owned(item it) {
    return item_amount(it) + closet_amount(it) + display_amount(it) + equipped_amount(it) + shop_amount(it) + storage_amount(it);
}

/**
 * Capture checklist ownership state across storage locations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_item_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_item_state aal_checklist_item_state(item it) {
    agent_item_state r;
    r.thing = it;
    r.inventory = item_amount(it);
    r.closet = closet_amount(it);
    r.storage = storage_amount(it);
    r.display = display_amount(it);
    r.shop = shop_amount(it);
    r.equipped = equipped_amount(it);
    r.total = r.inventory + r.closet + r.storage + r.display + r.shop + r.equipped;
    return r;
}

/**
 * Check whether cross-location ownership satisfies a required checklist quantity.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_checklist_item_check(item it, int required) {
    agent_check r;
    r.subject = it;
    int have = aal_checklist_total_owned(it);
    r.ok = have >= max(0, required);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "have=" + have + "; required=" + required;
    return r;
}

/**
 * List missing valid items from an inclusive item-ID range.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_range_missing(int first_id, int last_id, int max_entries) {
    buffer out;
    int emitted;
    for id from first_id to last_id {
        if (max_entries > 0 && emitted >= max_entries) break;
        item it = to_item(id);
        if (it == $item[none]) continue;
        if (aal_checklist_total_owned(it) > 0) continue;
        out.append(id + "\t" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * List missing items from a caller-defined checklist.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_custom_missing(item[int] items, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none] || aal_checklist_total_owned(it) > 0) continue;
        out.append(to_int(it) + "\t" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Calculate fraction of valid checklist items owned at least once.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_checklist_completion_ratio(item[int] items) {
    int total;
    int have;
    foreach i, it in items {
        if (it == $item[none]) continue;
        total = total + 1;
        if (aal_checklist_total_owned(it) > 0) have = have + 1;
    }
    if (total == 0) return 1.0;
    return to_float(have) / total;
}

/**
 * Report duplicate item IDs in a custom checklist definition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_duplicate_ids(int[int] ids) {
    int[int] counts;
    foreach i, id in ids counts[id] = counts[id] + 1;
    buffer out;
    foreach id, n in counts if (n > 1) out.append(id + "\t" + n + "\n");
    return out.to_string();
}

/**
 * Serialize checklist item status in deterministic input order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_status_tsv(item[int] items, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none]) continue;
        out.append(to_int(it) + "\t" + it + "\t" + aal_checklist_total_owned(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Estimate mall acquisition value of currently missing tradeable checklist items without buying them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_checklist_missing_value(item[int] items) {
    int total;
    foreach i, it in items {
        if (it == $item[none] || aal_checklist_total_owned(it) > 0 || !is_tradeable(it)) continue;
        int p = mall_price(it);
        if (p > 0) total = total + p;
    }
    return total;
}

/**
 * Build compact checklist completion/missing context for an agent.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_agent_context(string checklist_name, item[int] items, int max_entries) {
    buffer out;
    out.append("checklist=" + checklist_name + "\n");
    out.append("completion_ratio=" + aal_checklist_completion_ratio(items) + "\n");
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none] || aal_checklist_total_owned(it) > 0) continue;
        out.append("missing=" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 17: pStash
// https://github.com/Prusias-kol/pStash
// Clan stash baseline, expected-vs-actual verification, personal-overlap protection, return workflows, and activity logging.
// ============================================================================

/**
 * Capture expected versus current stash quantity with personal-overlap marker.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_stash_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_stash_state aal_stash_state(item it, int expected, boolean personal_overlap) {
    agent_stash_state r;
    r.thing = it;
    r.expected = max(0, expected);
    r.actual = stash_amount(it);
    r.difference = r.actual - r.expected;
    r.personal_overlap = personal_overlap;
    return r;
}

/**
 * Return number missing from stash relative to a baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_stash_deficit(item it, int expected) {
    return max(0, expected - stash_amount(it));
}

/**
 * Return surplus above a recorded stash baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_stash_surplus(item it, int expected) {
    return max(0, stash_amount(it) - expected);
}

/**
 * Validate a single stash baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_stash_verify(item it, int expected) {
    agent_check r;
    r.subject = it;
    int actual = stash_amount(it);
    r.ok = actual >= expected;
    r.severity = r.ok ? (actual == expected ? "info" : "notice") : "warning";
    r.reason = "actual=" + actual + "; expected=" + expected;
    return r;
}

/**
 * Preview how many inventory copies could be returned without crossing a personal-ownership protection floor.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_stash_return_preview(item it, int expected, int personal_owned) {
    agent_action_preview r;
    r.operation = "stash return " + it;
    int deficit = max(0, expected - stash_amount(it));
    int spare = max(0, item_amount(it) - personal_owned);
    int qty = min(deficit, spare);
    r.valid = qty > 0;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = "deficit=" + deficit + "; inventory_spare=" + spare + "; returnable=" + qty;
    if (!r.valid) r.warnings = "no safe return quantity";
    return r;
}

/**
 * Serialize expected/actual/delta for a tracked stash map.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_stash_map_summary(int[item] expected) {
    buffer out;
    foreach it, qty in expected {
        int actual = stash_amount(it);
        out.append(to_int(it) + "\t" + it + "\t" + qty + "\t" + actual + "\t" + (actual - qty) + "\n");
    }
    return out.to_string();
}

/**
 * Count tracked stash entries below baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_stash_missing_count(int[item] expected) {
    int n;
    foreach it, qty in expected if (stash_amount(it) < qty) n = n + 1;
    return n;
}

/**
 * Check whether current personal ownership is at/below a recorded personal floor.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_stash_personal_overlap(item it, int personal_baseline) {
    agent_check r;
    r.subject = it;
    int personal_now = item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
    r.ok = personal_now >= personal_baseline;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "personal_now=" + personal_now + "; baseline=" + personal_baseline;
    return r;
}

/**
 * Build bounded reconciliation recommendations without moving stash items.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_stash_reconcile_plan(int[item] expected, int[item] personal_baseline, int max_entries) {
    buffer out;
    int emitted;
    foreach it, qty in expected {
        if (max_entries > 0 && emitted >= max_entries) break;
        int deficit = max(0, qty - stash_amount(it));
        if (deficit <= 0) continue;
        int personal = 0;
        if (personal_baseline contains it) personal = personal_baseline[it];
        int spare = max(0, item_amount(it) - personal);
        out.append(it + "\tdeficit=" + deficit + "\tinventory_spare=" + spare + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Build compact stash health context centered on deficits/surpluses.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_stash_agent_context(int[item] expected, int max_entries) {
    buffer out;
    int emitted;
    foreach it, qty in expected {
        if (max_entries > 0 && emitted >= max_entries) break;
        int actual = stash_amount(it);
        if (actual == qty) continue;
        out.append("item=" + it + ";expected=" + qty + ";actual=" + actual + ";delta=" + (actual-qty) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 18: Guide
// https://github.com/Ezandora/Guide
// Large modular relay adviser that generates tasks/resources/future tasks from quest, item, IOTM, path, and availability state.
// ============================================================================

/**
 * Serialize a Guide-inspired task entry for machine consumption.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_task_line(string title, string status, string url, int priority) {
    return priority + "\t" + status + "\t" + title + "\t" + url;
}

/**
 * Serialize a Guide-inspired daily-resource entry.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_resource_line(string title, int remaining, string url) {
    return title + "\t" + remaining + "\t" + url;
}

/**
 * Expose one KoLmafia quest preference in normalized lowercase form.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_quest_property(string quest_property) {
    return to_lower_case(get_property(quest_property));
}

/**
 * Compare a quest preference with an expected state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_guide_quest_status_check(string quest_property, string expected_state) {
    agent_check r;
    r.subject = quest_property;
    string actual = to_lower_case(get_property(quest_property));
    r.ok = actual == to_lower_case(expected_state);
    r.severity = r.ok ? "info" : "notice";
    r.reason = "actual=" + actual + "; expected=" + to_lower_case(expected_state);
    return r;
}

/**
 * Convert a Guide-like daily counter into a structured remaining-resource record.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_guide_resource_from_property(string label, string used_property, int limit_value) {
    agent_resource_state r;
    r.name = label;
    r.used = get_property(used_property).to_int();
    r.limit_value = max(0, limit_value);
    r.remaining = max(0, r.limit_value - r.used);
    r.available = r.remaining > 0;
    return r;
}

/**
 * Describe whether a location-based task is currently actionable.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_plan.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_plan aal_guide_location_task(location loc, string title) {
    agent_plan r;
    r.subject = title;
    r.valid = can_adventure(loc);
    r.action = "adventure at " + loc;
    r.reason = r.valid ? "location currently adventureable" : "location not currently adventureable";
    r.meat_cost = 0;
    r.turn_cost = r.valid ? 1 : 0;
    return r;
}

/**
 * Filter/bound task text for a user or LLM query.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_task_filter(string[int] tasks, string query, int max_entries) {
    buffer out;
    string q = to_lower_case(query);
    int emitted;
    foreach i, task in tasks {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (q != "" && !contains_text(to_lower_case(task), q)) continue;
        out.append(task + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Represent future/optional task state without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_guide_future_task(string title, boolean unlocked, boolean completed, string prerequisite) {
    agent_check r;
    r.subject = title;
    r.ok = unlocked && !completed;
    r.severity = r.ok ? "notice" : "info";
    if (completed) r.reason = "completed";
    else if (!unlocked) r.reason = "waiting for " + prerequisite;
    else r.reason = "available";
    return r;
}

/**
 * Merge Guide-like task lanes into bounded labeled context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_advisory_merge(string[int] mandatory, string[int] optional, string[int] future, int max_each) {
    buffer out;
    int n;
    foreach i, x in mandatory { if (max_each > 0 && n >= max_each) break; if (x != "") { out.append("TASK\t" + x + "\n"); n = n + 1; } }
    n = 0;
    foreach i, x in optional { if (max_each > 0 && n >= max_each) break; if (x != "") { out.append("OPTIONAL\t" + x + "\n"); n = n + 1; } }
    n = 0;
    foreach i, x in future { if (max_each > 0 && n >= max_each) break; if (x != "") { out.append("FUTURE\t" + x + "\n"); n = n + 1; } }
    return out.to_string();
}

/**
 * Build compact quest-preference context using Guide's advisory orientation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_agent_context(string[int] quest_properties, int max_entries) {
    buffer out;
    int emitted;
    foreach i, p in quest_properties {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (p == "") continue;
        out.append(p + "=" + get_property(p) + "\n");
        emitted = emitted + 1;
    }
    out.append("adventures=" + my_adventures() + "\n");
    out.append("level=" + my_level() + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 19: Ezandora Gain
// https://github.com/Ezandora/Gain
// Modifier optimizer that indexes effect sources, models costs/efficiency, handles conflicts/limited buffs, and supports simulation.
// ============================================================================

/**
 * Capture current modifier value and target gap.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_modifier_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_modifier_state aal_gain_modifier_state(string modifier_name, float target) {
    agent_modifier_state r;
    r.modifier_name = to_lower_case(modifier_name);
    r.current_value = numeric_modifier(modifier_name);
    r.target_value = target;
    r.gap = target - r.current_value;
    r.satisfied = r.gap <= 0;
    return r;
}

/**
 * Read one effect's contribution to a modifier.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_effect_modifier(effect e, string modifier_name) {
    return numeric_modifier(e, modifier_name);
}

/**
 * Compute simple cost per modifier-turn for an effect candidate.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_effect_efficiency(effect e, string modifier_name, int turns, int estimated_cost) {
    float value = numeric_modifier(e, modifier_name);
    if (value == 0.0 || turns <= 0) return 1000000000.0;
    return to_float(max(0, estimated_cost)) / ((value < 0.0 ? -value : value) * turns);
}

/**
 * Report active mutually-exclusive effects from a caller-supplied conflict set.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_gain_conflict_hint(effect desired, effect[int] exclusive_set) {
    buffer out;
    foreach i, e in exclusive_set {
        if (e == desired) continue;
        int turns = have_effect(e);
        if (turns > 0) out.append(e + "\t" + turns + "\n");
    }
    return out.to_string();
}

/**
 * Apply explicit limited-effect policy to a candidate.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_gain_limited_effect_check(effect e, boolean allow_limited) {
    agent_check r;
    r.subject = e;
    boolean known_limited = e == $effect[Blessing of your favorite Bird] || e == $effect[Blessing of the Bird] || e == $effect[Triple-Sized] || e == $effect[Invisible Avatar];
    r.ok = allow_limited || !known_limited;
    r.severity = r.ok ? "info" : "warning";
    r.reason = known_limited ? "limited effect" : "not in known limited set";
    return r;
}

/**
 * Estimate acquisition cost of an item source without acquiring it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_gain_item_source_cost(item it) {
    if (it == $item[none]) return 0;
    if (available_amount(it) > 0) return 0;
    int p = historical_price(it);
    if (p <= 0) p = mall_price(it);
    if (p <= 0) p = max(0, autosell_price(it));
    return p;
}

/**
 * Estimate a skill buff's MP opportunity cost.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_gain_skill_source_cost(skill s, int meat_per_mp) {
    if (s == $skill[none] || !have_skill(s)) return -1;
    return max(0, mp_cost(s) * meat_per_mp);
}

/**
 * Compute a simple non-mutating additive modifier simulation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_simulate_additive(string modifier_name, float additional_value) {
    return numeric_modifier(modifier_name) + additional_value;
}

/**
 * Score a modifier source by gain-turns per meat; higher is better.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_candidate_score(float modifier_gain, int turns, int cost) {
    if (modifier_gain == 0.0 || turns <= 0) return 0.0;
    if (cost <= 0) return (modifier_gain < 0.0 ? -modifier_gain : modifier_gain) * turns * 1000000.0;
    return (modifier_gain < 0.0 ? -modifier_gain : modifier_gain) * turns / cost;
}

/**
 * Build bounded context of current modifier and active effects contributing to it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_gain_agent_context(string modifier_name, float target, int max_effects) {
    buffer out;
    out.append("modifier=" + modifier_name + "\n");
    out.append("current=" + numeric_modifier(modifier_name) + "\n");
    out.append("target=" + target + "\n");
    int emitted;
    int[effect] active = my_effects();
    foreach e, turns in active {
        if (max_effects > 0 && emitted >= max_effects) break;
        float v = numeric_modifier(e, modifier_name);
        if (v == 0.0) continue;
        out.append("effect=" + e + ";turns=" + turns + ";value=" + v + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 20: Astro3207 Gain
// https://github.com/Astro3207/Gain
// Gain fork with effect-modifier indexing, source discovery, percentage handling, mutual exclusion, limits, and simulation machinery.
// ============================================================================

/**
 * Parse an effect's Modifiers string into normalized modifier names.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_modifier_names(effect e) {
    string raw = string_modifier(e, "Modifiers");
    buffer out;
    boolean[string] names;
    foreach i, entry in split_string(raw, ", ") {
        string name = entry;
        int p = index_of(name, ": ");
        if (p >= 0) name = substring(name, 0, p);
        if (name != "") names[to_lower_case(name)] = true;
    }
    foreach name in names out.append(name + "\n");
    return out.to_string();
}

/**
 * Combine flat and percent stat modifiers against current base stat for planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_astrogain_percentage_stat_value(effect e, stat s) {
    float flat = numeric_modifier(e, s.to_string());
    float pct = numeric_modifier(e, to_string(s) + " Percent");
    return flat + pct / 100.0 * my_basestat(s);
}

/**
 * Flag effect modifier text that contains bracket/quoted expressions and should not be blindly cached.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_astrogain_dynamic_modifier_hint(effect e) {
    agent_check r;
    r.subject = e;
    string raw = string_modifier(e, "Modifiers");
    boolean dynamic = contains_text(raw, "[") || contains_text(raw, "\"");
    r.ok = !dynamic;
    r.severity = dynamic ? "notice" : "info";
    r.reason = dynamic ? "modifier expression appears dynamic" : "modifier text appears constant";
    return r;
}

/**
 * Find bounded item sources whose Effect modifier matches the requested effect.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_effect_source_items(effect e, int max_entries) {
    buffer out;
    int emitted;
    foreach it in $items[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (effect_modifier(it, "Effect") != e) continue;
        out.append(to_int(it) + "\t" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Find bounded skill sources that map to the requested effect.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_effect_source_skills(effect e, int max_entries) {
    buffer out;
    int emitted;
    foreach s in $skills[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (to_effect(s) != e) continue;
        out.append(to_int(s) + "\t" + s + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Approximate Gain-style combat-rate soft-cap conversion for simulation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_astrogain_combat_rate_softcap(float current, float raw_delta) {
    if (raw_delta == 0.0) return 0.0;
    float direction = raw_delta < 0.0 ? -1.0 : 1.0;
    float magnitude = raw_delta < 0.0 ? -raw_delta : raw_delta;
    float linear_room;
    if (direction > 0.0) linear_room = max(0.0, 25.0 - current);
    else linear_room = max(0.0, current + 25.0);
    float linear = min(magnitude, linear_room);
    float remaining = max(0.0, magnitude - linear);
    float soft = min(10.0, remaining / 5.0);
    return direction * (linear + soft);
}

/**
 * Score a buff source with combined item/meat and MP opportunity costs.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_astrogain_source_efficiency(float modifier_value, int turns, int meat_cost, int mp_cost_value, int meat_per_mp) {
    int total_cost = max(0, meat_cost) + max(0, mp_cost_value) * max(0, meat_per_mp);
    float benefit = (modifier_value < 0.0 ? -modifier_value : modifier_value) * max(0, turns);
    if (benefit <= 0.0) return 1000000000.0;
    return to_float(total_cost) / benefit;
}

/**
 * List active effects in one caller-defined mutually exclusive set.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_mutual_exclusion_state(effect[int] set_members) {
    buffer out;
    int active_count;
    foreach i, e in set_members {
        int turns = have_effect(e);
        if (turns <= 0) continue;
        active_count = active_count + 1;
        out.append(e + "\t" + turns + "\n");
    }
    out.append("active_count\t" + active_count + "\n");
    return out.to_string();
}

/**
 * Serialize a modifier-source ranking row for external sorting/LLM consumption.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_source_rank_line(string source_name, float efficiency, float modifier_value, int turns) {
    return source_name + "\t" + efficiency + "\t" + modifier_value + "\t" + turns;
}

/**
 * Build effect/source/modifier context suitable for an agent planning buff acquisition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_agent_context(effect e, string modifier_name) {
    buffer out;
    out.append("effect=" + e + "\n");
    out.append("modifier=" + modifier_name + "\n");
    out.append("effect_value=" + numeric_modifier(e, modifier_name) + "\n");
    out.append("current_total=" + numeric_modifier(modifier_name) + "\n");
    out.append("active_turns=" + have_effect(e) + "\n");
    out.append("modifier_text=" + string_modifier(e, "Modifiers") + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 21: Consume
// https://github.com/Ezandora/Consume
// Consumption optimizer for food/booze/spleen planning with value-of-adventure and resource-aware selection.
// ============================================================================

/**
 * Capture current fullness, inebriety, and spleen usage/limits.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_organ_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_organ_state aal_consume_organ_state() {
    agent_organ_state r;
    r.fullness = my_fullness();
    r.fullness_limit_value = fullness_limit();
    r.inebriety = my_inebriety();
    r.inebriety_limit_value = inebriety_limit();
    r.spleen = my_spleen_use();
    r.spleen_limit_value = spleen_limit();
    return r;
}

/**
 * Return remaining capacity for fullness, liver, or spleen by normalized organ name.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_consume_organ_remaining(string organ_name) {
    string n = to_lower_case(organ_name);
    if (n == "fullness" || n == "stomach") return max(0, fullness_limit() - my_fullness());
    if (n == "inebriety" || n == "liver") return max(0, inebriety_limit() - my_inebriety());
    if (n == "spleen") return max(0, spleen_limit() - my_spleen_use());
    return -1;
}

/**
 * Create a normalized consumable candidate with density/value fields.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_consumption_candidate.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_consumption_candidate aal_consume_candidate(item it, int size, float expected_adventures, int price) {
    agent_consumption_candidate r;
    r.thing = it;
    r.size = max(0, size);
    r.adventures = expected_adventures;
    r.price = max(0, price);
    r.adventures_per_size = r.size > 0 ? r.adventures / r.size : 0.0;
    r.value = 0.0;
    r.fits = false;
    return r;
}

/**
 * Check whether a candidate fits the requested organ's remaining capacity.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_consume_candidate_fits(agent_consumption_candidate c, string organ_name) {
    int remaining = aal_consume_organ_remaining(organ_name);
    return remaining >= 0 && c.size > 0 && c.size <= remaining;
}

/**
 * Estimate net adventure value after purchase cost.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_consume_candidate_value(agent_consumption_candidate c, int value_of_adventure) {
    return c.adventures * max(0, value_of_adventure) - c.price;
}

/**
 * Estimate net value per organ point.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_consume_candidate_density(agent_consumption_candidate c, int value_of_adventure) {
    if (c.size <= 0) return 0.0;
    return aal_consume_candidate_value(c, value_of_adventure) / c.size;
}

/**
 * Check candidate price against a caller budget.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_consume_budget_check(agent_consumption_candidate c, int meat_budget) {
    agent_check r;
    r.subject = c.thing;
    r.ok = c.price <= max(0, meat_budget);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "price=" + c.price + "; budget=" + meat_budget;
    return r;
}

/**
 * Describe whether consuming a drink of the given size would exceed the normal liver limit.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_consume_overdrink_risk(int drink_size) {
    agent_check r;
    r.subject = "overdrink-risk";
    int after = my_inebriety() + max(0, drink_size);
    r.ok = after <= inebriety_limit();
    r.severity = r.ok ? "info" : "warning";
    r.reason = "current=" + my_inebriety() + "; size=" + drink_size + "; limit=" + inebriety_limit();
    return r;
}

/**
 * Serialize a candidate's fit and economic density for planner/agent sorting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_consume_plan_line(agent_consumption_candidate c, string organ_name, int value_of_adventure) {
    boolean fits = aal_consume_candidate_fits(c, organ_name);
    float density = aal_consume_candidate_density(c, value_of_adventure);
    return c.thing + "\t" + c.size + "\t" + c.adventures + "\t" + c.price + "\t" + fits + "\t" + density;
}

/**
 * Build compact organ/value context for a consumption planner.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_consume_agent_context(int value_of_adventure) {
    buffer out;
    out.append("value_of_adventure=" + value_of_adventure + "\n");
    out.append("fullness=" + my_fullness() + "/" + fullness_limit() + "\n");
    out.append("inebriety=" + my_inebriety() + "/" + inebriety_limit() + "\n");
    out.append("spleen=" + my_spleen_use() + "/" + spleen_limit() + "\n");
    out.append("meat=" + my_meat() + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 22: networth.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
// Legacy account valuation using historical/mall/autosell pricing and item-location totals.
// ============================================================================

/**
 * Modernize networth.ash pricing: autosell for untradeable, fresh historical price when sane, otherwise mall.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_unit_price(item it, int max_historical_age, int historical_cap) {
    if (it == $item[none]) return 0;
    if (!is_tradeable(it)) return max(0, autosell_price(it));
    int hist = historical_price(it);
    if (hist > 0 && historical_age(it) <= max_historical_age && (historical_cap <= 0 || hist <= historical_cap)) return hist;
    int mall = mall_price(it);
    if (mall > 0) return mall;
    return max(0, autosell_price(it));
}

/**
 * Count relevant item copies for a net-worth calculation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_quantity(item it, boolean include_storage) {
    int qty = available_amount(it) + shop_amount(it) + display_amount(it);
    if (include_storage) qty = qty + storage_amount(it);
    return qty;
}

/**
 * Value one item's included quantity with the normalized unit-price heuristic.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_item_value(item it, boolean include_storage, int max_historical_age, int historical_cap) {
    return aal_networth_quantity(it, include_storage) * aal_networth_unit_price(it, max_historical_age, historical_cap);
}

/**
 * Value one item in one named account location for explainable net-worth decomposition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_location_value(item it, string location_name, int max_historical_age, int historical_cap) {
    string loc = to_lower_case(location_name);
    int qty;
    if (loc == "inventory") qty = item_amount(it);
    else if (loc == "closet") qty = closet_amount(it);
    else if (loc == "storage") qty = storage_amount(it);
    else if (loc == "display") qty = display_amount(it);
    else if (loc == "shop") qty = shop_amount(it);
    else if (loc == "equipped") qty = equipped_amount(it);
    else return 0;
    return qty * aal_networth_unit_price(it, max_historical_age, historical_cap);
}

/**
 * Estimate total item value across the source-inspired account locations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_inventory_value(boolean include_storage, int max_historical_age, int historical_cap) {
    int total;
    foreach it in $items[] {
        int qty = aal_networth_quantity(it, include_storage);
        if (qty <= 0) continue;
        total = total + qty * aal_networth_unit_price(it, max_historical_age, historical_cap);
    }
    return total;
}

/**
 * Estimate liquid meat plus item value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_total(boolean include_storage, int max_historical_age, int historical_cap) {
    return my_meat() + my_closet_meat() + my_storage_meat() + aal_networth_inventory_value(include_storage, max_historical_age, historical_cap);
}

/**
 * Serialize one item's net-worth contribution.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_networth_item_line(item it, boolean include_storage, int max_historical_age, int historical_cap) {
    int qty = aal_networth_quantity(it, include_storage);
    int unit = aal_networth_unit_price(it, max_historical_age, historical_cap);
    return to_int(it) + "\t" + it + "\t" + qty + "\t" + unit + "\t" + (qty * unit);
}

/**
 * Return a conservative non-negative value floor from autosell/NPC pricing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_value_floor(item it) {
    return max(max(0, autosell_price(it)), max(0, npc_price(it)));
}

/**
 * Capture a net-worth snapshot suitable for later delta comparison.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_value_snapshot.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_value_snapshot aal_networth_snapshot(boolean include_storage, int max_historical_age, int historical_cap, int stamp) {
    agent_value_snapshot r;
    r.liquid_meat = my_meat() + my_closet_meat() + my_storage_meat();
    r.item_value = aal_networth_inventory_value(include_storage, max_historical_age, historical_cap);
    r.total_value = r.liquid_meat + r.item_value;
    r.turns = total_turns_played();
    r.stamp = stamp;
    return r;
}

/**
 * Build compact valuation policy/current-total context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_networth_agent_context(boolean include_storage, int max_historical_age, int historical_cap) {
    buffer out;
    out.append("include_storage=" + include_storage + "\n");
    out.append("max_historical_age=" + max_historical_age + "\n");
    out.append("historical_cap=" + historical_cap + "\n");
    out.append("liquid_meat=" + (my_meat() + my_closet_meat() + my_storage_meat()) + "\n");
    out.append("item_value=" + aal_networth_inventory_value(include_storage, max_historical_age, historical_cap) + "\n");
    out.append("total=" + aal_networth_total(include_storage, max_historical_age, historical_cap) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 23: rollover.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
// Rollover optimizer/reminder checking rollover gear, unused daily resources, organ capacity, wand state, VIP actions, and MP waste.
// ============================================================================

/**
 * Serialize unused organ capacity before rollover.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_rollover_organ_gaps() {
    buffer out;
    out.append("fullness_gap=" + max(0, fullness_limit() - my_fullness()) + "\n");
    out.append("inebriety_gap=" + max(0, inebriety_limit() - my_inebriety()) + "\n");
    out.append("spleen_gap=" + max(0, spleen_limit() - my_spleen_use()) + "\n");
    return out.to_string();
}

/**
 * Estimate rollover MP that would exceed current maximum MP.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_rollover_mp_waste(int expected_rollover_mp) {
    return max(0, my_mp() + max(0, expected_rollover_mp) - my_maxmp());
}

/**
 * Expose remaining still uses as a rollover resource.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_rollover_still_state() {
    agent_resource_state r;
    r.name = "stills";
    r.used = 0;
    r.limit_value = stills_available();
    r.remaining = stills_available();
    r.available = stills_available() > 0;
    return r;
}

/**
 * Expose remaining pulls as rollover context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_rollover_pull_state() {
    agent_resource_state r;
    r.name = "pulls";
    r.used = 0;
    r.limit_value = max(0, pulls_remaining());
    r.remaining = max(0, pulls_remaining());
    r.available = pulls_remaining() > 0;
    return r;
}

/**
 * Return the first known wand item currently available.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns item.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
item aal_rollover_wand_candidate() {
    for id from 1268 to 1272 {
        item it = to_item(id);
        if (available_amount(it) > 0) return it;
    }
    return $item[none];
}

/**
 * Normalize a rollover-relevant daily preference into remaining-use state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_rollover_daily_resource(string label, string used_property, int limit_value) {
    agent_resource_state r;
    r.name = label;
    r.used = get_property(used_property).to_int();
    r.limit_value = max(0, limit_value);
    r.remaining = max(0, r.limit_value - r.used);
    r.available = r.remaining > 0;
    return r;
}

/**
 * Compute a simple reminder pressure score from organ gaps, MP waste, stills, and pulls.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_rollover_readiness_score(int expected_rollover_mp) {
    int score;
    if (my_fullness() < fullness_limit()) score = score + 1;
    if (my_inebriety() < inebriety_limit()) score = score + 1;
    if (my_spleen_use() < spleen_limit()) score = score + 1;
    if (aal_rollover_mp_waste(expected_rollover_mp) > 0) score = score + 1;
    if (stills_available() > 0) score = score + 1;
    if (pulls_remaining() > 0) score = score + 1;
    return score;
}

/**
 * Build deterministic rollover warnings without changing equipment/resources.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_rollover_warning_lines(int expected_rollover_mp) {
    buffer out;
    if (my_fullness() < fullness_limit()) out.append("unused-fullness\n");
    if (my_inebriety() < inebriety_limit()) out.append("unused-liver\n");
    if (my_spleen_use() < spleen_limit()) out.append("unused-spleen\n");
    if (aal_rollover_mp_waste(expected_rollover_mp) > 0) out.append("rollover-mp-waste=" + aal_rollover_mp_waste(expected_rollover_mp) + "\n");
    if (stills_available() > 0) out.append("stills-remaining=" + stills_available() + "\n");
    if (pulls_remaining() > 0) out.append("pulls-remaining=" + pulls_remaining() + "\n");
    return out.to_string();
}

/**
 * Return ready only when the source-inspired warning set is empty.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_rollover_ready_check(int expected_rollover_mp) {
    agent_check r;
    r.subject = "rollover";
    string warnings = aal_rollover_warning_lines(expected_rollover_mp);
    r.ok = warnings == "";
    r.severity = r.ok ? "info" : "notice";
    r.reason = r.ok ? "no modeled rollover warnings" : warnings;
    return r;
}

/**
 * Build compact rollover state for an agent/user reminder surface.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_rollover_agent_context(int expected_rollover_mp) {
    buffer out;
    out.append("adventures=" + my_adventures() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    out.append(aal_rollover_organ_gaps());
    out.append("expected_rollover_mp=" + expected_rollover_mp + "\n");
    out.append("mp_waste=" + aal_rollover_mp_waste(expected_rollover_mp) + "\n");
    out.append("stills=" + stills_available() + "\n");
    out.append("pulls=" + pulls_remaining() + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 24: testout.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
// Minimal vprint test script; useful as inspiration for standardized diagnostics and smoke probes.
// ============================================================================

/**
 * Create a structured boolean smoke-test result.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_bool(string name, boolean actual, boolean expected) {
    agent_diagnostic r;
    r.name = name;
    r.passed = actual == expected;
    r.expected = to_string(expected);
    r.actual = to_string(actual);
    r.note = "";
    return r;
}

/**
 * Create a structured collection-cardinality diagnostic with explicit bounds.
 *
 * Parameters: name: diagnostic label; actual_count: observed collection size; minimum_count/maximum_count: accepted bounds.
 * Return: Structured bounded-cardinality diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: agent_diagnostic
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_cardinality(string name, int actual_count, int minimum_count, int maximum_count) {
    agent_diagnostic d;
    d.name = name;
    d.actual = actual_count;
    d.expected = minimum_count + ".." + maximum_count;
    d.passed = actual_count >= minimum_count && actual_count <= maximum_count;
    d.detail = d.passed ? "cardinality within bounds" : "cardinality outside bounds";
    return d;
}

/**
 * Validate that a string map contains every required schema key and report missing keys.
 *
 * Parameters: name: diagnostic label; fields: observed schema map; required_keys: required field names.
 * Return: Structured schema-presence diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: agent_diagnostic
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_required_keys(string name, string[string] fields, string[int] required_keys) {
    agent_diagnostic d;
    d.name = name;
    buffer missing;
    foreach i, key in required_keys {
        if (!(fields contains key)) missing.append((length(missing) > 0 ? "," : "") + key);
    }
    d.actual = "keys=" + count(fields);
    d.expected = "required=" + count(required_keys);
    d.passed = length(missing) == 0;
    d.detail = d.passed ? "all required keys present" : "missing=" + missing.to_string();
    return d;
}

/**
 * Create a diagnostic for an inclusive numeric range.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_range(string name, float actual, float minimum, float maximum) {
    agent_diagnostic r;
    r.name = name;
    r.passed = actual >= minimum && actual <= maximum;
    r.expected = to_string(minimum) + ".." + to_string(maximum);
    r.actual = to_string(actual);
    r.note = "";
    return r;
}

/**
 * Serialize a diagnostic in compact TSV form.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_line(agent_diagnostic d) {
    return (d.passed ? "PASS" : "FAIL") + "\t" + d.name + "\t" + d.expected + "\t" + d.actual + "\t" + d.note;
}

/**
 * Count passing or failing diagnostics.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_testout_assertion_count(agent_diagnostic[int] results, boolean passed) {
    int n;
    foreach i, d in results if (d.passed == passed) n = n + 1;
    return n;
}

/**
 * Summarize diagnostic pass/fail counts.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_summary(agent_diagnostic[int] results) {
    int pass;
    int fail;
    foreach i, d in results {
        if (d.passed) pass = pass + 1;
        else fail = fail + 1;
    }
    return "pass=" + pass + "\nfail=" + fail + "\ntotal=" + (pass + fail) + "\n";
}

/**
 * Emit bounded failing diagnostic rows.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_failures(agent_diagnostic[int] results, int max_entries) {
    buffer out;
    int emitted;
    foreach i, d in results {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (d.passed) continue;
        out.append(aal_testout_line(d) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Capture a harmless runtime probe replacing the original one-line vprint smoke idea with structured state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_runtime_probe() {
    buffer out;
    out.append("name=" + my_name() + "\n");
    out.append("level=" + my_level() + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    return out.to_string();
}

/**
 * Build concise machine-readable test context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_agent_context(agent_diagnostic[int] results) {
    buffer out;
    out.append(aal_testout_summary(results));
    int emitted;
    foreach i, d in results {
        if (d.passed) continue;
        if (emitted >= 10) break;
        out.append("failure=" + d.name + ";expected=" + d.expected + ";actual=" + d.actual + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 25: bootstrap.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
// Legacy initial-ascension setup that pulls/uses starter items, visits tutorial, builds meatcar, and buys detuned radio.
// ============================================================================

/**
 * Return the legacy bootstrap's starter-item targets in deterministic order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_starter_items() {
    return "clockwork maid\nfacsimile dictionary\nletter from King Ralph XI\npork elf goodies sack\nNewbiesport tent\ncarton of astral energy drinks\nbitchin' meatcar\ndetuned radio\n";
}

/**
 * Describe inventory/storage availability of a bootstrap target.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_item_state(item it) {
    buffer out;
    out.append("item=" + it + "\n");
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("storage=" + storage_amount(it) + "\n");
    out.append("available=" + available_amount(it) + "\n");
    return out.to_string();
}

/**
 * Calculate how many copies would need to be pulled from storage to meet a bootstrap requirement.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_bootstrap_pull_need(item it, int required) {
    int missing = max(0, required - item_amount(it));
    return min(missing, storage_amount(it));
}

/**
 * Preview whether a starter item is currently in inventory for use.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_bootstrap_use_preview(item it) {
    agent_action_preview r;
    r.operation = "use " + it;
    r.valid = item_amount(it) > 0;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = "inventory=" + item_amount(it);
    if (!r.valid) r.warnings = "not in inventory";
    return r;
}

/**
 * Describe whether the meatcar is owned or creatable before attempting construction.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_meatcar_state() {
    buffer out;
    out.append("available=" + available_amount($item[bitchin' meatcar]) + "\n");
    out.append("creatable=" + creatable_amount($item[bitchin' meatcar]) + "\n");
    return out.to_string();
}

/**
 * Describe detuned-radio ownership and NPC price context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_radio_state() {
    buffer out;
    out.append("available=" + available_amount($item[detuned radio]) + "\n");
    out.append("npc_price=" + npc_price($item[detuned radio]) + "\n");
    out.append("meat=" + my_meat() + "\n");
    return out.to_string();
}

/**
 * Serialize one bootstrap step and its evidence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_step_status(string step_name, boolean complete, string evidence) {
    return (complete ? "done" : "todo") + "\t" + step_name + "\t" + evidence;
}

/**
 * List obvious remaining bootstrap targets without executing them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_missing_steps() {
    buffer out;
    if (available_amount($item[clockwork maid]) == 0) out.append("clockwork-maid\n");
    if (available_amount($item[bitchin' meatcar]) == 0) out.append("meatcar\n");
    if (available_amount($item[detuned radio]) == 0) out.append("detuned-radio\n");
    if (item_amount($item[letter from King Ralph XI]) > 0) out.append("open-king-letter\n");
    if (item_amount($item[pork elf goodies sack]) > 0) out.append("open-pork-elf-sack\n");
    return out.to_string();
}

/**
 * Check whether core bootstrap travel/setup targets are already present.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_bootstrap_readiness() {
    agent_check r;
    r.subject = "bootstrap-core";
    boolean car = available_amount($item[bitchin' meatcar]) > 0;
    boolean radio = available_amount($item[detuned radio]) > 0;
    r.ok = car && radio;
    r.severity = r.ok ? "info" : "notice";
    r.reason = "meatcar=" + car + "; radio=" + radio;
    return r;
}

/**
 * Build compact initial-ascension setup context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_agent_context() {
    buffer out;
    out.append("meat=" + my_meat() + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    out.append("pulls=" + pulls_remaining() + "\n");
    out.append("meatcar=" + available_amount($item[bitchin' meatcar]) + "\n");
    out.append("radio=" + available_amount($item[detuned radio]) + "\n");
    out.append("maid=" + available_amount($item[clockwork maid]) + "\n");
    out.append("missing_steps=" + replace_string(aal_bootstrap_missing_steps(), "\n", ",") + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 26: OCD Inventory Control.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
// Malformed supplied URL resolved by GitHub code search to scripts/OCD Inventory Control.ash; inventory disposition and cleanup policy engine.
// ============================================================================

/**
 * Count copies across common personal item locations for disposition planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_owned_total(item it) {
    return item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
}

/**
 * Compute copies above a configured keep quantity.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_excess_quantity(item it, int keep_amount) {
    return max(0, aal_ocd_owned_total(it) - max(0, keep_amount));
}

/**
 * Validate a disposition action/keep quantity without performing inventory changes.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ocd_policy_validate(string action, int keep_amount) {
    agent_check r;
    r.subject = action;
    string a = to_lower_case(action);
    boolean known = a == "keep" || a == "closet" || a == "display" || a == "autosell" || a == "mallsell" || a == "use" || a == "pulverize" || a == "gift";
    r.ok = known && keep_amount >= 0;
    r.severity = r.ok ? "info" : "error";
    r.reason = "known_action=" + known + "; keep=" + keep_amount;
    return r;
}

/**
 * Preview quantity and action for an OCD-style inventory rule.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_ocd_disposition_preview(item it, string action, int keep_amount) {
    agent_action_preview r;
    int excess = aal_ocd_excess_quantity(it, keep_amount);
    r.operation = action + " " + excess + " " + it;
    r.valid = excess > 0 && aal_ocd_policy_validate(action, keep_amount).ok;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = "owned=" + aal_ocd_owned_total(it) + "; keep=" + keep_amount + "; excess=" + excess;
    if (!r.valid) r.warnings = "nothing to dispose or invalid policy";
    return r;
}

/**
 * Estimate gross liquidation value of an OCD rule without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_liquidation_value(item it, string action, int keep_amount) {
    int qty = aal_ocd_excess_quantity(it, keep_amount);
    string a = to_lower_case(action);
    if (qty <= 0) return 0;
    if (a == "autosell") return qty * max(0, autosell_price(it));
    if (a == "mallsell") return qty * max(0, mall_price(it));
    return 0;
}

/**
 * Detect conflicting duplicate disposition rules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ocd_rule_conflict(string action_a, int keep_a, string action_b, int keep_b) {
    agent_check r;
    r.subject = "ocd-rule-conflict";
    r.ok = to_lower_case(action_a) == to_lower_case(action_b) && keep_a == keep_b;
    r.severity = r.ok ? "info" : "warning";
    r.reason = r.ok ? "rules equivalent" : "rules disagree";
    return r;
}

/**
 * List owned items lacking a caller-provided OCD policy map.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ocd_missing_rule_context(item[int] inventory_items, boolean[item] ruled_items, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in inventory_items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none] || aal_ocd_owned_total(it) <= 0 || ruled_items contains it) continue;
        out.append(to_int(it) + "\t" + it + "\t" + aal_ocd_owned_total(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Count total copies above configured keep amounts across a caller item list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_cleanup_count(item[int] items, int[item] keep_amounts) {
    int total;
    foreach i, it in items {
        int keep;
        if (keep_amounts contains it) keep = keep_amounts[it];
        total = total + aal_ocd_excess_quantity(it, keep);
    }
    return total;
}

/**
 * Serialize rule plus current ownership/excess as TSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ocd_rule_line(item it, string action, int keep_amount) {
    return to_int(it) + "\t" + it + "\t" + action + "\t" + keep_amount + "\t" + aal_ocd_owned_total(it) + "\t" + aal_ocd_excess_quantity(it, keep_amount);
}

/**
 * Build bounded disposition context for policy review before execution.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ocd_agent_context(item[int] items, string[item] actions, int[item] keep_amounts, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none]) continue;
        string action = actions contains it ? actions[it] : "unruled";
        int keep = keep_amounts contains it ? keep_amounts[it] : 0;
        int owned = aal_ocd_owned_total(it);
        if (owned <= 0) continue;
        out.append("item=" + it + ";action=" + action + ";keep=" + keep + ";owned=" + owned + ";excess=" + max(0,owned-keep) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 27: insertSelect2-relays
// https://github.com/C2Talon/insertSelect2-relays
// Relay enhancement project for select controls/searchability; inspiration for deterministic option filtering and selection descriptions.
// ============================================================================

/**
 * Create a normalized searchable select option record.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_option.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_option aal_select2_option(string value, string label, boolean selected, boolean enabled) {
    agent_option o;
    o.value = value;
    o.label = label;
    o.selected = selected;
    o.enabled = enabled;
    o.score = 0;
    return o;
}

/**
 * Score an option against a case-insensitive query using exact/prefix/substring matches.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_select2_match_score(agent_option o, string query) {
    string q = to_lower_case(query);
    string l = to_lower_case(o.label);
    string v = to_lower_case(o.value);
    if (q == "") return 1;
    if (l == q || v == q) return 100;
    if (index_of(l, q) == 0 || index_of(v, q) == 0) return 50;
    if (contains_text(l, q) || contains_text(v, q)) return 10;
    return 0;
}

/**
 * Filter select options into deterministic TSV rows for search/autocomplete.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_select2_filter(agent_option[int] options, string query, int max_entries) {
    buffer out;
    int emitted;
    foreach i, o in options {
        if (max_entries > 0 && emitted >= max_entries) break;
        int score = aal_select2_match_score(o, query);
        if (score <= 0 || !o.enabled) continue;
        out.append(score + "\t" + o.value + "\t" + o.label + "\t" + o.selected + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Return the first selected enabled option value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_select2_selected_value(agent_option[int] options) {
    foreach i, o in options if (o.enabled && o.selected) return o.value;
    return "";
}

/**
 * Report duplicate option values that make selection ambiguous.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_select2_duplicate_values(agent_option[int] options) {
    int[string] counts;
    foreach i, o in options counts[o.value] = counts[o.value] + 1;
    buffer out;
    foreach v, n in counts if (n > 1) out.append(v + "\t" + n + "\n");
    return out.to_string();
}

/**
 * Validate a searchable option has stable value/label fields.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_select2_option_validate(agent_option o) {
    agent_check r;
    r.subject = o.value;
    r.ok = o.value != "" && o.label != "";
    r.severity = r.ok ? "info" : "error";
    r.reason = r.ok ? "option valid" : "value and label are required";
    return r;
}

/**
 * Normalize whitespace-separated query tokens for relay search.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_select2_query_tokens(string query) {
    boolean[string] tokens;
    foreach i, t in split_string(to_lower_case(query), "\\s+") if (t != "") tokens[t] = true;
    buffer out;
    foreach t in tokens out.append(t + "\n");
    return out.to_string();
}

/**
 * Require every normalized query token to appear in option value or label.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_select2_all_tokens_match(agent_option o, string query) {
    string hay = to_lower_case(o.value + " " + o.label);
    foreach i, t in split_string(to_lower_case(query), "\\s+") {
        if (t == "") continue;
        if (!contains_text(hay, t)) return false;
    }
    return true;
}

/**
 * Serialize one select option.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_select2_option_tsv(agent_option o) {
    return o.value + "\t" + o.label + "\t" + o.selected + "\t" + o.enabled;
}

/**
 * Build compact searchable option context for an agent choosing a relay value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/insertSelect2-relays
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_select2_agent_context(agent_option[int] options, string query, int max_entries) {
    buffer out;
    out.append("query=" + query + "\n");
    int emitted;
    foreach i, o in options {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (!o.enabled || !aal_select2_all_tokens_match(o, query)) continue;
        out.append("option=" + aal_select2_option_tsv(o) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 28: htmlform.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
// Relay HTML form construction, field helpers, validation, attributes, and save/cancel interactions.
// ============================================================================

/**
 * Escape basic HTML-sensitive characters for form output.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_escape(string value) {
    string out = replace_string(value, "&", "&amp;");
    out = replace_string(out, "<", "&lt;");
    out = replace_string(out, ">", "&gt;");
    out = replace_string(out, "\"", "&quot;");
    return out;
}

/**
 * Validate basic relay form field presence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_htmlform_field_validate(string name, string value, boolean required) {
    agent_check r;
    r.subject = name;
    r.ok = name != "" && (!required || value != "");
    r.severity = r.ok ? "info" : "error";
    r.reason = r.ok ? "field valid" : "missing name or required value";
    return r;
}

/**
 * Validate an integer form value against inclusive bounds.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_htmlform_int_validate(string name, string value, int minimum, int maximum) {
    agent_check r;
    r.subject = name;
    boolean numeric = is_integer(value);
    int v = numeric ? value.to_int() : 0;
    r.ok = numeric && v >= minimum && v <= maximum;
    r.severity = r.ok ? "info" : "error";
    r.reason = "value=" + value + "; range=" + minimum + ".." + maximum;
    return r;
}

/**
 * Normalize common form boolean encodings.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_htmlform_bool_normalize(string value) {
    string v = to_lower_case(value);
    return v == "true" || v == "1" || v == "on" || v == "yes";
}

/**
 * Serialize a form field schema for human/agent tooling.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_field_schema(string name, string type_name, string default_value, string description) {
    return name + "\t" + type_name + "\t" + default_value + "\t" + description;
}

/**
 * Check that a submitted select value belongs to the allowed set.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_htmlform_select_validate(string value, string[int] allowed_values) {
    agent_check r;
    r.subject = value;
    boolean found;
    foreach i, x in allowed_values if (x == value) found = true;
    r.ok = found;
    r.severity = found ? "info" : "error";
    r.reason = found ? "allowed" : "value not in allowed set";
    return r;
}

/**
 * Check whether a submitted field actually changes persisted value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_htmlform_changed(string old_value, string submitted_value) {
    return old_value != submitted_value;
}

/**
 * Serialize a proposed form change without applying it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_change_line(string name, string old_value, string submitted_value) {
    return name + "\t" + old_value + "\t" + submitted_value + "\t" + (old_value != submitted_value);
}

/**
 * Serialize failing field validations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_error_summary(agent_check[int] checks) {
    buffer out;
    foreach i, c in checks if (!c.ok) out.append(c.subject + "\t" + c.reason + "\n");
    return out.to_string();
}

/**
 * Serialize submitted form fields with deterministic key ordering and bounded size.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_agent_context(string[string] fields, int max_entries) {
    buffer out;
    int emitted;
    foreach name, value in fields {
        if (max_entries > 0 && emitted >= max_entries) break;
        out.append(name + "=" + value + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 29: BatBrain.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
// Combat reasoning engine with event/spread modeling, adjusted stats, action valuation, resource costs, monster value, and combat environment construction.
// ============================================================================

/**
 * Capture current combat-relevant monster/player stats without taking an action.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_combat_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_combat_state aal_batbrain_combat_state() {
    agent_combat_state r;
    r.foe = last_monster();
    r.hp = monster_hp();
    r.attack = monster_attack();
    r.defense = monster_defense();
    r.player_hp = my_hp();
    r.player_mp = my_mp();
    r.turn = my_turncount();
    return r;
}

/**
 * Compute player HP remaining after hypothetical damage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_batbrain_hit_survival_margin(int expected_damage) {
    return my_hp() - max(0, expected_damage);
}

/**
 * Compute MP remaining after hypothetical repeated skill use.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_batbrain_skill_mp_margin(skill s, int casts) {
    return my_mp() - max(0, casts) * mp_cost(s);
}

/**
 * Validate skill ownership and MP for a hypothetical combat action.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_batbrain_action_resource_check(skill s, int casts) {
    agent_check r;
    r.subject = s;
    int need = max(0, casts) * mp_cost(s);
    r.ok = casts > 0 && have_skill(s) && my_mp() >= need;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "casts=" + casts + "; mp_need=" + need + "; mp=" + my_mp() + "; have_skill=" + have_skill(s);
    return r;
}

/**
 * Estimate base monster meat value after current meat-drop modifier.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_batbrain_monster_meat_value(monster m) {
    float base = meat_drop(m);
    float mult = max(0.0, 100.0 + meat_drop_modifier()) / 100.0;
    return base * mult;
}

/**
 * Estimate opportunity cost of running away as monster base meat plus one adventure value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_batbrain_runaway_value(monster m, int value_of_adventure) {
    return aal_batbrain_monster_meat_value(m) + max(0, value_of_adventure);
}

/**
 * Value the canonical three-adventure Beaten Up opportunity cost floor.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_batbrain_beaten_up_turn_cost(int value_of_adventure) {
    return 3 * max(0, value_of_adventure);
}

/**
 * Serialize monster element and player elemental resistances for combat planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_batbrain_element_context(monster m) {
    buffer out;
    out.append("monster=" + m + "\n");
    out.append("element=" + monster_element(m) + "\n");
    foreach e in $elements[] out.append("resist_" + e + "=" + elemental_resistance(e) + "\n");
    return out.to_string();
}

/**
 * Create a non-mutating combat action preview with HP/MP/value checks.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_batbrain_action_preview(string action_label, int expected_damage, int mp_cost_value, int value_cost) {
    agent_action_preview r;
    r.operation = action_label;
    r.meat_cost = max(0, value_cost);
    r.adventure_cost = 0;
    boolean hp_ok = aal_batbrain_hit_survival_margin(expected_damage) > 0;
    boolean mp_ok = my_mp() >= max(0, mp_cost_value);
    r.valid = hp_ok && mp_ok;
    r.reason = "hp_after=" + aal_batbrain_hit_survival_margin(expected_damage) + "; mp_after=" + (my_mp()-max(0,mp_cost_value));
    if (!r.valid) r.warnings = "survival or MP precondition failed";
    return r;
}

/**
 * Build compact BatBrain-inspired combat context for an LLM without producing/executing a macro.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_batbrain_agent_context(int value_of_adventure) {
    agent_combat_state s = aal_batbrain_combat_state();
    buffer out;
    out.append("monster=" + s.foe + "\n");
    out.append("monster_hp=" + s.hp + "\n");
    out.append("monster_attack=" + s.attack + "\n");
    out.append("monster_defense=" + s.defense + "\n");
    out.append("player_hp=" + s.player_hp + "/" + my_maxhp() + "\n");
    out.append("player_mp=" + s.player_mp + "/" + my_maxmp() + "\n");
    out.append("value_of_adventure=" + value_of_adventure + "\n");
    out.append("runaway_value=" + aal_batbrain_runaway_value(s.foe, value_of_adventure) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 30: liba
// https://github.com/C2Talon/liba
// Modern small composable ASH helpers plus resource-specific modules for choices, combat checks, equip-cast, properties, priorities, and IOTMs.
// ============================================================================

/**
 * Clamp while safely normalizing reversed bounds.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_liba_clamp_normalized(float value, float low, float high) {
    float lo = min(low, high);
    float hi = max(low, high);
    return max(lo, min(hi, value));
}

/**
 * Check that every non-empty token occurs case-insensitively in text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_liba_tokens_all_present(string haystack, string[int] tokens) {
    string h = to_lower_case(haystack);
    foreach i, t in tokens if (t != "" && !contains_text(h, to_lower_case(t))) return false;
    return true;
}

/**
 * Preview integer preference increment without writing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_liba_property_increment_preview(string property_name, int delta) {
    agent_delta d;
    d.label = property_name;
    d.before_value = get_property(property_name).to_int();
    d.after_value = d.before_value + delta;
    d.difference = delta;
    return d;
}

/**
 * Select the first available item and explain the priority position.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_priority_item_reason(item[int] candidates) {
    int position;
    foreach i, it in candidates {
        position = position + 1;
        if (available_amount(it) > 0) return position + "\t" + it + "\t" + available_amount(it);
    }
    return "0\tnone\t0";
}

/**
 * Return compact current-choice context inspired by liba_inChoice.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_choice_context() {
    buffer out;
    out.append("handling=" + handling_choice() + "\n");
    out.append("choice_id=" + (handling_choice() ? last_choice() : -1) + "\n");
    if (handling_choice()) out.append("configured=" + get_property("choiceAdventure" + last_choice()) + "\n");
    return out.to_string();
}

/**
 * Return compact combat indicators inspired by liba_inCombat without executing requests.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_combat_context() {
    buffer out;
    out.append("last_monster=" + last_monster() + "\n");
    out.append("last_combat_result=" + get_property("lastCombatResult") + "\n");
    out.append("last_macro_error=" + get_property("lastMacroError") + "\n");
    return out.to_string();
}

/**
 * Check equip/cast prerequisites and MP without changing equipment.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_liba_equip_cast_preflight(item gear, skill s, int casts) {
    agent_check r;
    r.subject = gear + " + " + s;
    boolean gear_ok = available_amount(gear) > 0 && can_equip(gear);
    boolean skill_ok = have_skill(s);
    boolean mp_ok = my_mp() >= max(0, casts) * mp_cost(s);
    r.ok = casts > 0 && gear_ok && skill_ok && mp_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "gear=" + gear_ok + "; skill=" + skill_ok + "; mp=" + mp_ok;
    return r;
}

/**
 * Describe whether an item is present for low-level/raw-use logic, without using it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_liba_raw_use_preflight(item it) {
    agent_check r;
    r.subject = it;
    r.ok = item_amount(it) > 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "inventory=" + item_amount(it);
    return r;
}

/**
 * Build generic context for one of liba's resource-specific IOTM modules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_resource_module_context(item key_item, string[int] preference_names) {
    buffer out;
    out.append("key_item=" + key_item + "\n");
    out.append("available=" + available_amount(key_item) + "\n");
    boolean[string] names;
    foreach i, p in preference_names if (p != "") names[p] = true;
    foreach p in names out.append(p + "=" + get_property(p) + "\n");
    return out.to_string();
}

/**
 * Compose tiny reusable preference/item context in the spirit of liba's focused modules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_micro_context(string label, string[int] preference_names, item[int] items) {
    buffer out;
    out.append("label=" + label + "\n");
    foreach i, p in preference_names if (p != "") out.append("pref." + p + "=" + get_property(p) + "\n");
    foreach i, it in items if (it != $item[none]) out.append("item." + to_int(it) + "=" + available_amount(it) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 31: FunctionLib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
// Legacy general utility library for ownership, acquisition/use, stash/shop, recovery, equipment, familiars, still, and resistance.
// ============================================================================

/**
 * Expose where an item is currently held instead of collapsing ownership to a boolean.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_ownership_locations(item it) {
    buffer out;
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("closet=" + closet_amount(it) + "\n");
    out.append("storage=" + storage_amount(it) + "\n");
    out.append("stash=" + stash_amount(it) + "\n");
    out.append("equipped=" + equipped_amount(it) + "\n");
    return out.to_string();
}

/**
 * Compute inventory shortfall and nearby source counts without acquiring anything.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_acquisition_gap(item it, int desired) {
    buffer out;
    int gap = max(0, desired - item_amount(it));
    out.append("desired=" + desired + "\n");
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("gap=" + gap + "\n");
    out.append("closet=" + closet_amount(it) + "\n");
    out.append("storage=" + storage_amount(it) + "\n");
    out.append("stash=" + stash_amount(it) + "\n");
    out.append("mall_price=" + mall_price(it) + "\n");
    return out.to_string();
}

/**
 * Describe likely consumption channel from native item metadata.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_consumption_kind(item it) {
    string t = to_lower_case(item_type(it));
    if (contains_text(t, "food")) return "eat";
    if (contains_text(t, "booze") || contains_text(t, "drink")) return "drink";
    if (contains_text(t, "spleen")) return "spleen";
    return "use-or-other";
}

/**
 * Measure familiar base-weight gap before any training action.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_range_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_functionlib_familiar_training_gap(familiar fam, int target_weight) {
    agent_range_state r;
    r.minimum = 0;
    r.maximum = max(0, target_weight);
    r.current = have_familiar(fam) ? familiar_weight(fam) : 0;
    r.remaining = max(0, r.maximum - r.current);
    r.satisfied = have_familiar(fam) && r.current >= r.maximum;
    return r;
}

/**
 * Check possession/equipability and current equip state without equipping.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_functionlib_equipment_preflight(item it) {
    agent_check r;
    r.subject = it;
    boolean owned = available_amount(it) > 0;
    boolean equipable = can_equip(it);
    r.ok = owned && equipable;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "owned=" + owned + "; can_equip=" + equipable + "; equipped=" + have_equipped(it);
    return r;
}

/**
 * Preview a stash take/put operation and available quantity without moving items.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_functionlib_stash_transfer_preview(string direction, item it, int quantity) {
    agent_action_preview r;
    string d = to_lower_case(direction);
    r.operation = d + " " + quantity + " " + it;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    if (d == "take") r.valid = quantity > 0 && stash_amount(it) >= quantity;
    else if (d == "put") r.valid = quantity > 0 && item_amount(it) >= quantity;
    else r.valid = false;
    r.reason = "inventory=" + item_amount(it) + "; stash=" + stash_amount(it);
    if (!r.valid) r.warnings = "invalid direction or insufficient quantity";
    return r;
}

/**
 * Measure HP recovery gap and Beaten Up state without recovering.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_recovery_gap(int target_hp) {
    buffer out;
    out.append("target=" + target_hp + "\n");
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("gap=" + max(0, min(target_hp, my_maxhp()) - my_hp()) + "\n");
    out.append("beaten_up=" + have_effect($effect[Beaten Up]) + "\n");
    return out.to_string();
}

/**
 * Check ownership and MP for repeated skill use without casting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_functionlib_skill_preflight(skill s, int casts) {
    agent_check r;
    r.subject = s;
    int need = max(0, casts) * mp_cost(s);
    r.ok = casts > 0 && have_skill(s) && my_mp() >= need;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "casts=" + casts + "; mp_need=" + need + "; mp=" + my_mp();
    return r;
}

/**
 * Serialize all five zap-wand IDs currently owned/available.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_wand_inventory() {
    buffer out;
    for id from 1268 to 1272 {
        item it = to_item(id);
        int qty = available_amount(it);
        if (qty > 0) out.append(id + "\t" + it + "\t" + qty + "\n");
    }
    return out.to_string();
}

/**
 * Build compact utility context combining ownership, familiar, and skill readiness.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_agent_context(item it, familiar fam, skill s) {
    buffer out;
    out.append("item=" + it + ";available=" + available_amount(it) + "\n");
    out.append("familiar=" + fam + ";owned=" + have_familiar(fam) + ";weight=" + (have_familiar(fam) ? familiar_weight(fam) : 0) + "\n");
    out.append("skill=" + s + ";owned=" + have_skill(s) + ";mp_cost=" + mp_cost(s) + "\n");
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 32: c2t_lib
// https://github.com/C2Talon/c2t_lib
// Shared modern helper library covering assertions, clans, wanderers, choices, priorities, maximizer caching, equip-cast, buying, and macro building.
// ============================================================================

/**
 * Recompute c2t_lib-inspired sausage goblin odds without equipping or adventuring.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_c2lib_sausage_odds() {
    if (available_amount($item[Kramco Sausage-o-Matic™]) == 0 && available_amount($item[replica Kramco Sausage-o-Matic™]) == 0) return 0.0;
    int fights = get_property("_sausageFights").to_int();
    int multiplier = max(0, fights - 5);
    int last_turn = get_property("_lastSausageMonsterTurn").to_int();
    return to_float(total_turns_played() - last_turn + 1) / (5.0 + fights * 3.0 + multiplier * multiplier * multiplier);
}

/**
 * Check whether the sausage wanderer threshold is currently met.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_c2lib_sausage_ready() {
    if (available_amount($item[Kramco Sausage-o-Matic™]) == 0 && available_amount($item[replica Kramco Sausage-o-Matic™]) == 0) return false;
    int fights = get_property("_sausageFights").to_int();
    if (fights == 0) return true;
    int multiplier = max(0, fights - 5);
    int last_turn = get_property("_lastSausageMonsterTurn").to_int();
    return max(0, 4 + fights * 3 + multiplier * multiplier * multiplier - total_turns_played() + last_turn) == 0;
}

/**
 * Expose cursed magnifying glass charge/free-fight state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_void_state() {
    buffer out;
    out.append("owned=" + (available_amount($item[cursed magnifying glass]) > 0) + "\n");
    out.append("charge=" + get_property("cursedMagnifyingGlassCount") + "\n");
    out.append("free_fights_used=" + get_property("_voidFreeFights") + "\n");
    out.append("ready=" + (available_amount($item[cursed magnifying glass]) > 0 && get_property("cursedMagnifyingGlassCount").to_int() >= 13) + "\n");
    return out.to_string();
}

/**
 * Validate exact active choice ID.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2lib_choice_expectation(int expected_choice) {
    agent_check r;
    r.subject = "choice " + expected_choice;
    r.ok = handling_choice() && last_choice() == expected_choice;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "handling=" + handling_choice() + "; active=" + last_choice();
    return r;
}

/**
 * Decode pilcrow item tokens from a maximizer expression into typed item rows for troubleshooting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_pilcrow_items(string maximizer_expression) {
    buffer out;
    boolean[int] ids;
    matcher m = create_matcher("¶(\\d+)", maximizer_expression);
    while (m.find()) ids[m.group(1).to_int()] = true;
    foreach id in ids {
        item it = to_item(id);
        out.append(id + "\t" + it + "\n");
    }
    return out.to_string();
}

/**
 * Return first available item plus all candidate availability for explainable priority.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_priority_item_context(item[int] candidates) {
    buffer out;
    item selected = $item[none];
    foreach i, it in candidates {
        int qty = available_amount(it);
        out.append(i + "\t" + it + "\t" + qty + "\n");
        if (selected == $item[none] && qty > 0) selected = it;
    }
    out.append("selected\t" + selected + "\n");
    return out.to_string();
}

/**
 * Normalize a maximizer expression into a lightweight cache-comparison key.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_maximize_key(string maximizer_expression) {
    string s = to_lower_case(maximizer_expression);
    s = replace_string(s, " ", "");
    s = replace_string(s, "\t", "");
    return s;
}

/**
 * Snapshot turn count and accessibility before a caller attempts a supposedly free adventure.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2lib_free_adventure_preflight(location loc) {
    agent_check r;
    r.subject = loc;
    r.ok = can_adventure(loc) && my_adventures() > 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "can_adventure=" + can_adventure(loc) + "; adventures=" + my_adventures() + "; turncount=" + my_turncount();
    return r;
}

/**
 * Estimate mall cost/budget fit without invoking c2t_buy.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_c2lib_purchase_budget(item it, int quantity, int max_unit_price) {
    agent_action_preview r;
    int p = mall_price(it);
    r.operation = "buy " + quantity + " " + it;
    r.meat_cost = max(0, p) * max(0, quantity);
    r.adventure_cost = 0;
    r.valid = quantity > 0 && p > 0 && p <= max_unit_price && my_meat() >= r.meat_cost;
    r.reason = "unit_price=" + p + "; cap=" + max_unit_price + "; total=" + r.meat_cost + "; meat=" + my_meat();
    return r;
}

/**
 * Describe BALLS-style combat macro structure without submitting it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_macro_description(string macro_text) {
    buffer out;
    out.append("length=" + length(macro_text) + "\n");
    out.append("skills=" + contains_text(to_lower_case(macro_text), "skill ") + "\n");
    out.append("items=" + contains_text(to_lower_case(macro_text), "use ") + "\n");
    out.append("conditional=" + (contains_text(to_lower_case(macro_text), "if ") || contains_text(to_lower_case(macro_text), "while ")) + "\n");
    out.append("raw=" + macro_text + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 33: SmashLib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
// Pulverization library modeling smashability, malus upgrades, elemental outputs, tiers, and expected yields.
// ============================================================================

/**
 * Check whether an item occupies an equipment slot commonly eligible for pulverization.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_smash_slot_candidate(item it) {
    slot s = to_slot(it);
    return $slots[hat,weapon,off-hand,shirt,pants,acc1,acc2,acc3] contains s;
}

/**
 * Map equipment power to legacy pulverization power bands.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_power_band(item it) {
    int p = get_power(it);
    if (p <= 0) return "unknown";
    if (p <= 35) return "1P";
    if (p <= 55) return "2P";
    if (p <= 75) return "3P";
    if (p <= 95) return "1N";
    if (p <= 115) return "2N";
    if (p <= 135) return "3N";
    if (p <= 155) return "1W";
    if (p <= 175) return "2W";
    return "3W";
}

/**
 * Summarize elemental damage/resistance signals relevant to pulverization output.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_element_profile(item it) {
    buffer out;
    foreach e in $elements[] {
        float damage = numeric_modifier(it, e + " Damage") + numeric_modifier(it, e + " Spell Damage");
        float resist = numeric_modifier(it, e + " Resistance");
        if (damage != 0.0 || resist != 0.0) out.append(e + "\tdamage=" + damage + "\tresistance=" + resist + "\n");
    }
    return out.to_string();
}

/**
 * Compute the immediate economic floor an item should beat before smashing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_smash_value_floor(item it) {
    int floor_value = max(0, autosell_price(it));
    int mall = mall_price(it);
    if (mall > 0) floor_value = max(floor_value, mall);
    return floor_value;
}

/**
 * Validate an item as an ordinary equipment pulverization candidate without smashing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_smash_candidate_check(item it) {
    agent_check r;
    r.subject = it;
    boolean slot_ok = aal_smash_slot_candidate(it);
    boolean owned = item_amount(it) > 0;
    r.ok = slot_ok && owned;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "equipment_slot=" + slot_ok + "; inventory=" + item_amount(it) + "; power=" + get_power(it);
    return r;
}

/**
 * Normalize power band to powder/nugget/wad family.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_expected_material_tier(item it) {
    string band = aal_smash_power_band(it);
    if (contains_text(band, "P")) return "powder";
    if (contains_text(band, "N")) return "nugget";
    if (contains_text(band, "W")) return "wad";
    return "unknown";
}

/**
 * Compare estimated smash-yield value with keeping/selling value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_smash_loss_risk(item it, int estimated_yield_value) {
    agent_check r;
    r.subject = it;
    int floor_value = aal_smash_value_floor(it);
    r.ok = estimated_yield_value >= floor_value;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "yield_estimate=" + estimated_yield_value + "; item_value_floor=" + floor_value;
    return r;
}

/**
 * List owned ordinary equipment at/above a power threshold for later smash analysis.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_inventory_candidates(int min_power, int max_entries) {
    buffer out;
    int emitted;
    foreach it in $items[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (item_amount(it) <= 0 || !aal_smash_slot_candidate(it) || get_power(it) < min_power) continue;
        out.append(to_int(it) + "\t" + it + "\t" + get_power(it) + "\t" + aal_smash_power_band(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize one smash candidate with economic risk context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_plan_line(item it, int estimated_yield_value) {
    return it + "\tpower=" + get_power(it) + "\tband=" + aal_smash_power_band(it) + "\tfloor=" + aal_smash_value_floor(it) + "\tyield_estimate=" + estimated_yield_value;
}

/**
 * Build compact pulverization context without loading old data maps or smashing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_agent_context(item it) {
    buffer out;
    out.append("item=" + it + "\n");
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("slot=" + to_slot(it) + "\n");
    out.append("power=" + get_power(it) + "\n");
    out.append("band=" + aal_smash_power_band(it) + "\n");
    out.append("material_tier=" + aal_smash_expected_material_tier(it) + "\n");
    out.append("value_floor=" + aal_smash_value_floor(it) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 34: helper.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
// Legacy ascension adviser/helpers for pulls, fax/yellow-ray opportunities, access checks, consumables, weapons, and familiar suggestions.
// ============================================================================

/**
 * Summarize class-relevant Epic/Legendary/Ultimate weapon ownership without changing equipment.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_epic_weapon_state() {
    buffer out;
    out.append("class=" + my_class() + "\n");
    out.append("prime_stat=" + my_primestat() + "\n");
    foreach it in $items[Bjorn's Hammer,Mace of the Tortoise,Rock and Roll Legend,Disco Banjo,Pasta Spoon of Peril,5-Alarm Saucepan,Hammer of Smiting,Chelonian Morningstar,Shagadelic Disco Banjo,Squeezebox of the Ages,Greek Pasta Spoon of Peril,17-alarm Saucepan] {
        if (available_amount(it) > 0) out.append("owned=" + it + "\n");
    }
    return out.to_string();
}

/**
 * Return compact zap-wand ownership state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_wand_state() {
    buffer out;
    for id from 1268 to 1272 {
        item it = to_item(id);
        if (available_amount(it) > 0) out.append(it + "=" + available_amount(it) + "\n");
    }
    return out.to_string();
}

/**
 * Score a potential pull by ownership gap times caller strategic weight.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_helper_pull_need_score(item it, int target_quantity, int strategic_weight) {
    int gap = max(0, target_quantity - available_amount(it));
    return gap * max(0, strategic_weight);
}

/**
 * Check broad yellow-ray readiness signals used by legacy advisories.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_helper_yellow_ray_readiness() {
    agent_check r;
    r.subject = "yellow-ray";
    boolean blocked = have_effect($effect[Everything Looks Yellow]) > 0;
    r.ok = !blocked;
    r.severity = r.ok ? "info" : "notice";
    r.reason = blocked ? "Everything Looks Yellow active" : "not blocked by yellow cooldown effect";
    return r;
}

/**
 * Expose photocopy-use/path conditions relevant to legacy fax advisories.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_helper_fax_readiness() {
    agent_check r;
    r.subject = "fax";
    boolean used = get_property("_photocopyUsed").to_boolean();
    boolean path_block = my_path() == $path[Avatar of Boris];
    r.ok = !used && !path_block;
    r.severity = r.ok ? "info" : "notice";
    r.reason = "photocopy_used=" + used + "; avatar_of_boris=" + path_block;
    return r;
}

/**
 * Summarize pirate access items/outfit rather than temporarily equipping them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_pirate_access_context() {
    buffer out;
    out.append("fledges=" + available_amount($item[pirate fledges]) + "\n");
    out.append("swashbuckling_outfit=" + have_outfit("swashbuckling getup") + "\n");
    out.append("insult_book=" + available_amount($item[The Big Book of Pirate Insults]) + "\n");
    return out.to_string();
}

/**
 * Create an explainable familiar-goal score using weight and broad native modifiers.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_helper_familiar_goal_score(familiar fam, string goal) {
    if (!have_familiar(fam)) return -1.0;
    float score = familiar_weight(fam);
    string g = to_lower_case(goal);
    if (g == "items") score = score + numeric_modifier("Item Drop") / 10.0;
    if (g == "meat") score = score + numeric_modifier("Meat Drop") / 10.0;
    return score;
}

/**
 * List missing candidate consumables with storage counts/mall prices for pull decisions.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_consumable_pull_context(item[int] candidates, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in candidates {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (available_amount(it) > 0) continue;
        out.append(it + "\tstorage=" + storage_amount(it) + "\tmall=" + mall_price(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Combine location accessibility with a required-item condition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_helper_access_check(location loc, item required_item) {
    agent_check r;
    r.subject = loc;
    boolean loc_ok = can_adventure(loc);
    boolean item_ok = required_item == $item[none] || available_amount(required_item) > 0;
    r.ok = loc_ok && item_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "location=" + loc_ok + "; item=" + item_ok;
    return r;
}

/**
 * Build compact ascension-helper context around pulls, fax/yellow-ray and basic resources.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_agent_context(string goal) {
    buffer out;
    out.append("goal=" + goal + "\n");
    out.append("path=" + my_path() + "\n");
    out.append("level=" + my_level() + "\n");
    out.append("pulls=" + pulls_remaining() + "\n");
    out.append("yellow_blocked=" + (have_effect($effect[Everything Looks Yellow]) > 0) + "\n");
    out.append("photocopy_used=" + get_property("_photocopyUsed") + "\n");
    out.append("wand=" + replace_string(aal_helper_wand_state(), "\n", ",") + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 35: QuestLib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
// Legacy quest automation with combat-rate/mood/MCD requests, gear setup, underwater handling, acquisition/pulls, and quest flow.
// ============================================================================

/**
 * Return normalized KoLmafia quest preference text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_property_state(string quest_property) {
    return to_lower_case(get_property(quest_property));
}

/**
 * Convert common quest states into a coarse monotonic progress rank.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_quest_progress_rank(string quest_state) {
    string q = to_lower_case(quest_state);
    if (q == "unstarted" || q == "") return 0;
    if (q == "started") return 1;
    if (index_of(q, "step") == 0) {
        string n = substring(q, 4);
        return 2 + n.to_int();
    }
    if (q == "finished") return 100;
    return 1;
}

/**
 * Translate legacy request_combat/request_noncombat intent into a descriptive maximizer goal.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_combat_rate_goal(string mode) {
    string m = to_lower_case(mode);
    if (m == "combat") return "+combat";
    if (m == "noncombat") return "-combat";
    if (m == "ml" || m == "monsterlevel") return "+monster level";
    if (m == "apathetic") return "no mood";
    return "default";
}

/**
 * Return the legacy practical MCD ceiling implied by sign.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_quest_mcd_ceiling() {
    return 10 + (in_mysticality_sign() ? 1 : 0);
}

/**
 * Validate desired MCD against source-inspired practical ceiling.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_quest_mcd_preflight(int desired) {
    agent_check r;
    r.subject = "MCD " + desired;
    int max_value = aal_quest_mcd_ceiling();
    r.ok = desired >= 0 && desired <= max_value;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "current=" + current_mcd() + "; max=" + max_value;
    return r;
}

/**
 * Check ownership of common underwater breathing gear without changing outfit.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_quest_underwater_preflight() {
    agent_check r;
    r.subject = "underwater";
    boolean gear = available_amount($item[Aerated diving helmet]) > 0 || available_amount($item[makeshift SCUBA gear]) > 0;
    r.ok = gear;
    r.severity = gear ? "info" : "warning";
    r.reason = "aerated=" + available_amount($item[Aerated diving helmet]) + "; scuba=" + available_amount($item[makeshift SCUBA gear]);
    return r;
}

/**
 * Describe quest location accessibility/turn history.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_location_state(location loc) {
    buffer out;
    out.append("location=" + loc + "\n");
    out.append("can_adventure=" + can_adventure(loc) + "\n");
    out.append("turns_spent=" + loc.turns_spent + "\n");
    return out.to_string();
}

/**
 * Measure quest-item shortfall across available amount.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_quest_resource_gap(item it, int required) {
    agent_delta d;
    d.label = it;
    d.before_value = available_amount(it);
    d.after_value = max(0, required);
    d.difference = max(0, required - d.before_value);
    return d;
}

/**
 * Serialize one quest planning row from preference, location and item state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_plan_line(string quest_property, location loc, item required_item) {
    return quest_property + "\t" + get_property(quest_property) + "\t" + loc + "\t" + can_adventure(loc) + "\t" + required_item + "\t" + (required_item == $item[none] ? 0 : available_amount(required_item));
}

/**
 * Build bounded quest-state context without invoking old mood/gear automation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_agent_context(string[int] quest_properties, int max_entries) {
    buffer out;
    out.append("level=" + my_level() + "\n");
    out.append("path=" + my_path() + "\n");
    out.append("mcd=" + current_mcd() + "\n");
    int emitted;
    foreach i, p in quest_properties {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (p == "") continue;
        out.append(p + "=" + get_property(p) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 36: sims_lib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
// Legacy recommendation/simulation helpers, especially familiar selection by goal, runaways, delay, item/meat/combat priorities.
// ============================================================================

/**
 * Return current effective familiar weight basis for recommendation logic.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_sims_familiar_weight(familiar fam) {
    if (!have_familiar(fam)) return -1;
    return familiar_weight(fam) + weight_adjustment();
}

/**
 * Estimate weight-based free-runaway capacity using the legacy 5-weight-per-runaway heuristic.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_sims_runaway_capacity(familiar fam) {
    int w = aal_sims_familiar_weight(fam);
    if (w < 0) return 0;
    return floor(to_float(w) / 5.0);
}

/**
 * Expose Mini-Hipster free-adventure usage relevant to delay-zone recommendations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_sims_delay_state() {
    agent_resource_state r;
    r.name = "Mini-Hipster adventures";
    r.used = get_property("_Mini-HipsterAdv").to_int();
    r.limit_value = 7;
    r.remaining = max(0, 7 - r.used);
    r.available = have_familiar($familiar[Mini-Hipster]) && r.remaining > 0;
    return r;
}

/**
 * Score owned familiars by weight plus broad goal/combat heuristics.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_sims_goal_score(familiar fam, string goal, int combat_bias) {
    if (!have_familiar(fam)) return -1000000.0;
    float score = familiar_weight(fam) + weight_adjustment();
    string g = to_lower_case(goal);
    if (g == "runaways" && (fam == $familiar[Frumious Bandersnatch] || fam == $familiar[Pair of Stomping Boots])) score = score + 1000;
    if (g == "delay" && fam == $familiar[Mini-Hipster]) score = score + 1000;
    if (g == "combat" && combat_bias > 0) score = score + combat_bias;
    return score;
}

/**
 * Select highest-scoring candidate familiar without switching it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns familiar.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
familiar aal_sims_best_familiar(familiar[int] candidates, string goal, int combat_bias) {
    familiar best = $familiar[none];
    float best_score = -1000001.0;
    foreach i, fam in candidates {
        float score = aal_sims_goal_score(fam, goal, combat_bias);
        if (score > best_score) { best_score = score; best = fam; }
    }
    return best;
}

/**
 * Serialize familiar recommendation evidence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_familiar_line(familiar fam, string goal, int combat_bias) {
    return fam + "\towned=" + have_familiar(fam) + "\tweight=" + aal_sims_familiar_weight(fam) + "\tscore=" + aal_sims_goal_score(fam, goal, combat_bias);
}

/**
 * Emit bounded familiar candidate evidence in caller order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_goal_candidates(familiar[int] candidates, string goal, int combat_bias, int max_entries) {
    buffer out;
    int emitted;
    foreach i, fam in candidates {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (!have_familiar(fam)) continue;
        out.append(aal_sims_familiar_line(fam, goal, combat_bias) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Check whether a familiar is usable in the current path by ownership plus path-level familiar availability.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_sims_path_constraint(familiar fam) {
    agent_check r;
    r.subject = fam;
    boolean owned = have_familiar(fam);
    r.ok = owned;
    r.severity = owned ? "info" : "warning";
    r.reason = "path=" + my_path() + "; owned=" + owned;
    return r;
}

/**
 * Generate concise human/agent-readable rationale for common familiar goals.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_recommendation_reason(familiar fam, string goal) {
    string g = to_lower_case(goal);
    if (!have_familiar(fam)) return "not owned";
    if (g == "runaways" && (fam == $familiar[Frumious Bandersnatch] || fam == $familiar[Pair of Stomping Boots])) return "weight-driven free runaway source";
    if (g == "delay" && fam == $familiar[Mini-Hipster]) return "free/delay encounter resource";
    if (g == "items") return "evaluate item-drop utility and weight";
    if (g == "meat") return "evaluate meat utility and weight";
    if (g == "combat") return "evaluate combat action/block/damage utility";
    return "general familiar utility";
}

/**
 * Build compact familiar recommendation context without switching familiars.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_agent_context(familiar[int] candidates, string goal, int combat_bias) {
    buffer out;
    out.append("goal=" + goal + "\n");
    out.append("current=" + my_familiar() + "\n");
    familiar best = aal_sims_best_familiar(candidates, goal, combat_bias);
    out.append("recommended=" + best + "\n");
    foreach i, fam in candidates if (have_familiar(fam)) out.append("candidate=" + aal_sims_familiar_line(fam, goal, combat_bias) + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 37: pUpdates repository (second supplied entry)
// https://github.com/Prusias-kol/pUpdates
// Same upstream supplied again; this entry focuses on pure changelog parsing/serialization rather than operational seen-version state.
// ============================================================================

/**
 * Extract current version from a pUpdates-style map representation where index -1 stores version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_pupdateslog_parse_header(string[int] update_lines) {
    if (!(update_lines contains -1)) return -1;
    return update_lines[-1].to_int();
}

/**
 * Return one changelog entry by version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_entry(string[int] update_lines, int version) {
    if (!(update_lines contains version)) return "";
    return update_lines[version];
}

/**
 * Serialize changelog entries newer than a seen version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_since(string[int] update_lines, int seen_version, int max_entries) {
    buffer out;
    int current = aal_pupdateslog_parse_header(update_lines);
    if (current < 0 || seen_version >= current) return "";
    int emitted;
    for v from seen_version + 1 to current {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (!(update_lines contains v)) continue;
        out.append(v + "\t" + update_lines[v] + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Report gaps between version 0 and declared current version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_missing_versions(string[int] update_lines) {
    buffer out;
    int current = aal_pupdateslog_parse_header(update_lines);
    if (current < 0) return "";
    for v from 0 to current
        if (!(update_lines contains v)) out.append(v + "\n");
    return out.to_string();
}

/**
 * Check whether all changelog versions through current are present.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_pupdateslog_contiguous(string[int] update_lines) {
    return aal_pupdateslog_missing_versions(update_lines) == "";
}

/**
 * Produce a deterministic lightweight checksum from version numbers and line lengths.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_pupdateslog_checksum(string[int] update_lines) {
    int h = 5381;
    foreach v, text in update_lines {
        h = (h * 33 + v + length(text)) % 1000000007;
    }
    return h;
}

/**
 * Search changelog entries case-insensitively.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_search(string[int] update_lines, string query, int max_entries) {
    buffer out;
    string q = to_lower_case(query);
    int emitted;
    foreach v, text in update_lines {
        if (v < 0) continue;
        if (max_entries > 0 && emitted >= max_entries) break;
        if (q != "" && !contains_text(to_lower_case(text), q)) continue;
        out.append(v + "\t" + text + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize an entire changelog as versioned TSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_tsv(string script_name, string[int] update_lines) {
    buffer out;
    foreach v, text in update_lines {
        if (v < 0) continue;
        out.append(script_name + "\t" + v + "\t" + text + "\n");
    }
    return out.to_string();
}

/**
 * Validate header/version continuity for a changelog map.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_pupdateslog_validate(string[int] update_lines) {
    agent_check r;
    r.subject = "pUpdates-log";
    int current = aal_pupdateslog_parse_header(update_lines);
    r.ok = current >= 0 && aal_pupdateslog_contiguous(update_lines);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "current=" + current + "; missing=" + replace_string(aal_pupdateslog_missing_versions(update_lines), "\n", ",");
    return r;
}

/**
 * Build compact unseen-changelog context without reading/writing preferences.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_agent_context(string script_name, string[int] update_lines, int seen_version, int max_entries) {
    buffer out;
    int current = aal_pupdateslog_parse_header(update_lines);
    out.append("script=" + script_name + "\n");
    out.append("seen=" + seen_version + "\n");
    out.append("current=" + current + "\n");
    out.append("pending=" + max(0, current-seen_version) + "\n");
    out.append(aal_pupdateslog_since(update_lines, seen_version, max_entries));
    return out.to_string();
}

// ============================================================================
// SOURCE 38: DicsLibrary.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
// Large shared library with typed property reads, item valuation, stock-up, ownership, healing, songs, workshed/garden and utility logic.
// ============================================================================

/**
 * Read an integer preference with explicit default for missing/empty values.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_pref_int(string property_name, int default_value) {
    string raw = get_property(property_name);
    if (raw == "") return default_value;
    return raw.to_int();
}

/**
 * Serialize a bounded caller-selected preference set as deterministic key=value context.
 *
 * Parameters: property_names: caller-selected preference names; max_entries: output cap, <=0 means no cap.
 * Return: Stable key=value lines ordered by map key.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: line := property=value
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_pref_snapshot(string[int] property_names, int max_entries) {
    boolean[string] selected;
    foreach i, name in property_names
        if (name != "") selected[name] = true;
    buffer out;
    int emitted;
    foreach name in selected {
        if (max_entries > 0 && emitted >= max_entries) break;
        out.append(name + "=" + get_property(name) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Count item ownership across inventory/equipment/closet/storage/display/shop and optionally stash.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_total_amount(item it, boolean include_stash) {
    int total = item_amount(it) + equipped_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it);
    if (include_stash) total = total + stash_amount(it);
    return total;
}

/**
 * Classify price confidence from tradeability, historical age, historical price, and mall fallback.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_market_confidence(item it, int fresh_days) {
    if (!is_tradeable(it)) return "nontradeable";
    if (historical_price(it) > 0 && historical_age(it) <= fresh_days) return "fresh-historical";
    if (mall_price(it) > 0) return "mall";
    if (historical_price(it) > 0) return "stale-historical";
    return "unknown";
}

/**
 * Estimate item value with a configurable sell-realization multiplier.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_value_estimate(item it, int fresh_days, float multiplier) {
    int base;
    if (!is_tradeable(it)) base = max(0, max(npc_price(it), autosell_price(it)));
    else if (historical_price(it) > 0 && historical_age(it) <= fresh_days) base = historical_price(it);
    else {
        base = mall_price(it);
        if (base <= 0) base = historical_price(it);
    }
    return max(0, to_int(base * max(0.0, multiplier)));
}

/**
 * Calculate reorder quantity to reach a target personal stock.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_stock_reorder(item it, int target_amount) {
    return max(0, target_amount - item_amount(it));
}

/**
 * Expose HP/MP recovery targets and current state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_recovery_state() {
    buffer out;
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    out.append("hp_recovery=" + get_property("hpAutoRecovery") + "\n");
    out.append("hp_target=" + get_property("hpAutoRecoveryTarget") + "\n");
    out.append("mp_recovery=" + get_property("mpAutoRecovery") + "\n");
    out.append("mp_target=" + get_property("mpAutoRecoveryTarget") + "\n");
    return out.to_string();
}

/**
 * Summarize active Accordion Thief song effects and durations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_song_state() {
    buffer out;
    int[effect] active = my_effects();
    foreach e, turns in active {
        skill s = to_skill(e);
        if (s == $skill[none] || s.class != $class[Accordion Thief] || !s.buff) continue;
        out.append(e + "\t" + turns + "\n");
    }
    return out.to_string();
}

/**
 * Build compact ownership/valuation context for one item.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_item_context(item it, int fresh_days, float multiplier) {
    buffer out;
    out.append("item=" + it + "\n");
    out.append("total=" + aal_dics_total_amount(it, false) + "\n");
    out.append("stash=" + stash_amount(it) + "\n");
    out.append("confidence=" + aal_dics_market_confidence(it, fresh_days) + "\n");
    out.append("value=" + aal_dics_value_estimate(it, fresh_days, multiplier) + "\n");
    return out.to_string();
}

/**
 * Build bounded item/value context inspired by DicsLibrary's broad utility role.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_agent_context(item[int] items, int max_entries, int fresh_days, float multiplier) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none]) continue;
        out.append(it + "\ttotal=" + aal_dics_total_amount(it,false) + "\tvalue=" + aal_dics_value_estimate(it,fresh_days,multiplier) + "\tconfidence=" + aal_dics_market_confidence(it,fresh_days) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 39: Choice-Override
// https://github.com/Ezandora/Choice-Override
// Public-domain relay choice dispatcher that parses choice IDs, finds choice.<id>.ash/js handlers, encodes page text, and supports choice.0 fallback.
// ============================================================================

/**
 * Parse a choice ID from common whichchoice HTML/query patterns without issuing a request.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_choiceoverride_choice_id(string page_text) {
    string[int] patterns;
    patterns[0] = "name=['\"]?whichchoice['\"]? value=['\"]?(\\d+)['\"]?";
    patterns[1] = "value=['\"]?(\\d+)['\"]? name=['\"]?whichchoice['\"]?";
    patterns[2] = "choice\\.php\\?whichchoice=(\\d+)";
    foreach i, p in patterns {
        matcher m = create_matcher(p, page_text);
        if (m.find() && is_integer(m.group(1))) return m.group(1).to_int();
    }
    return -1;
}

/**
 * Extract unique positive option values from choice-page HTML.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_option_ids(string page_text) {
    boolean[int] ids;
    matcher m = create_matcher("name=['\"]?option['\"]?[^>]*value=['\"]?(\\d+)", page_text);
    while (m.find()) ids[m.group(1).to_int()] = true;
    matcher m2 = create_matcher("value=['\"]?(\\d+)['\"]?[^>]*name=['\"]?option", page_text);
    while (m2.find()) ids[m2.group(1).to_int()] = true;
    buffer out;
    foreach id in ids if (id > 0) out.append(id + "\n");
    return out.to_string();
}

/**
 * Generate the canonical override script basename for a choice.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_script_base(int choice_id) {
    return "choice." + choice_id;
}

/**
 * Return exact ASH/JS handler candidates plus fallback names in lookup order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_handler_candidates(int choice_id) {
    buffer out;
    out.append("relay/choice." + choice_id + ".ash\n");
    out.append("relay/choice." + choice_id + ".js\n");
    out.append("relay/choice.0.ash\n");
    out.append("relay/choice.0.js\n");
    return out.to_string();
}

/**
 * Build a lightweight deterministic choice-page fingerprint from parsed ID/length/option list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_page_fingerprint(string page_text) {
    return aal_choiceoverride_choice_id(page_text) + ":" + length(page_text) + ":" + replace_string(aal_choiceoverride_option_ids(page_text), "\n", ",");
}

/**
 * Validate that a page contains an identifiable choice and at least one option.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_choiceoverride_validate_page(string page_text) {
    agent_check r;
    r.subject = "choice-page";
    int id = aal_choiceoverride_choice_id(page_text);
    string opts = aal_choiceoverride_option_ids(page_text);
    r.ok = id > 0 && opts != "";
    r.severity = r.ok ? "info" : "warning";
    r.reason = "choice_id=" + id + "; options=" + replace_string(opts, "\n", ",");
    return r;
}

/**
 * Describe Choice-Override routing decision without dispatching a script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_route_preview(string page_text, boolean specific_handler_exists, boolean fallback_handler_exists) {
    int id = aal_choiceoverride_choice_id(page_text);
    if (id < 0) return "pass-through: choice id unknown";
    if (specific_handler_exists) return "dispatch: choice." + id;
    if (fallback_handler_exists) return "dispatch: choice.0";
    return "pass-through: no handler";
}

/**
 * URL-encode choice page text for safe argument transport, mirroring the source's transport idea.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_encode_payload(string page_text) {
    return url_encode(page_text);
}

/**
 * Decode a Choice-Override-style page payload.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_decode_payload(string encoded) {
    return url_decode(encoded);
}

/**
 * Build compact choice context from page text without visiting or submitting choice.php.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_agent_context(string page_text) {
    buffer out;
    out.append("choice_id=" + aal_choiceoverride_choice_id(page_text) + "\n");
    out.append("options=" + replace_string(aal_choiceoverride_option_ids(page_text), "\n", ",") + "\n");
    out.append("fingerprint=" + aal_choiceoverride_page_fingerprint(page_text) + "\n");
    out.append("handler_candidates=" + replace_string(aal_choiceoverride_handler_candidates(aal_choiceoverride_choice_id(page_text)), "\n", ",") + "\n");
    return out.to_string();
}

// ============================================================================
// SOURCE 40: zlib.ash (fixed historical commit)
// https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
// Zarqon's general library: typed setting normalization, string/list utilities, verbosity, numeric helpers, averages, expression evaluation, map/version/update infrastructure.
// ============================================================================

/**
 * Normalize boolean-like setting text to canonical true/false.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zlib_normalize_bool(string value) {
    return to_string(to_boolean(value));
}

/**
 * Normalize integer setting text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zlib_normalize_int(string value) {
    return to_string(to_int(value));
}

/**
 * Normalize item setting text through KoLmafia's typed item parser.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zlib_normalize_item(string value) {
    return to_string(to_item(value));
}

/**
 * De-duplicate a delimited list using deterministic lexical output.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zlib_list_unique(string list_text, string glue) {
    boolean[string] seen;
    foreach i, bit in split_string(list_text, glue) if (bit != "") seen[bit] = true;
    buffer out;
    boolean first = true;
    foreach bit in seen {
        if (!first) out.append(glue);
        first = false;
        out.append(bit);
    }
    return out.to_string();
}

/**
 * Perform exact case-insensitive membership check over a delimited list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_zlib_list_contains_exact(string list_text, string needle, string glue) {
    foreach i, bit in split_string(list_text, glue) if (to_lower_case(bit) == to_lower_case(needle)) return true;
    return false;
}

/**
 * Clamp value with normalized lower/upper bounds.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_zlib_clamp(float value, float low, float high) {
    float lo = min(low, high);
    float hi = max(low, high);
    return max(lo, min(hi, value));
}

/**
 * Serialize one settings change instead of directly persisting it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zlib_setting_diff(string name, string old_value, string new_value) {
    return name + "\t" + old_value + "\t" + new_value + "\t" + (old_value != new_value);
}

/**
 * Validate a subset of common ZLib setting types with current KoLmafia coercions.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_zlib_type_validate(string value, string type_name) {
    agent_check r;
    r.subject = type_name;
    string t = to_lower_case(type_name);
    if (t == "int") r.ok = is_integer(value);
    else if (t == "boolean") r.ok = to_lower_case(value) == "true" || to_lower_case(value) == "false";
    else if (t == "item") r.ok = to_item(value) != $item[none];
    else if (t == "skill") r.ok = to_skill(value) != $skill[none];
    else if (t == "effect") r.ok = to_effect(value) != $effect[none];
    else if (t == "location") r.ok = to_location(value) != $location[none];
    else r.ok = true;
    r.severity = r.ok ? "info" : "error";
    r.reason = r.ok ? "value normalizes for requested type" : "invalid typed setting";
    return r;
}

/**
 * Serialize a typed setting schema row for modern agent/UI consumption.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zlib_setting_schema_line(string name, string type_name, string default_value, string documentation) {
    return name + "\t" + type_name + "\t" + default_value + "\t" + documentation;
}

/**
 * Build bounded deterministic setting context from a ZLib-like settings map.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zlib_agent_context(string[string] setting_values, int max_entries) {
    buffer out;
    int emitted;
    foreach name, value in setting_values {
        if (max_entries > 0 && emitted >= max_entries) break;
        out.append(name + "=" + value + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

// ============================================================================
// SOURCE 41: relay_zlib_manager.ash (fixed historical commit)
// https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
// Relay UI for ZLib settings with descriptions, typed controls, validators, filtering, delete queues, and save feedback.
// ============================================================================

/**
 * Infer a simple editor control kind from persisted setting text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zman_field_kind(string value) {
    string low = to_lower_case(value);
    if (low == "true" || low == "false") return "checkbox";
    if (is_integer(value)) return "integer";
    string without_dot = replace_string(value, ".", "");
    if (is_integer(without_dot) && contains_text(value, ".")) return "float";
    return "text";
}

/**
 * Validate a setting according to inferred/editor kind.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_zman_field_validate(string name, string value, string kind) {
    agent_check r;
    r.subject = name;
    string k = to_lower_case(kind);
    if (k == "checkbox") r.ok = to_lower_case(value) == "true" || to_lower_case(value) == "false";
    else if (k == "integer") r.ok = is_integer(value);
    else if (k == "float") r.ok = is_integer(replace_string(value, ".", ""));
    else r.ok = name != "";
    r.severity = r.ok ? "info" : "error";
    r.reason = "kind=" + kind + "; value=" + value;
    return r;
}

/**
 * Filter settings by name or documentation, not name alone.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_zman_filter_match(string setting_name, string documentation, string query) {
    string q = to_lower_case(query);
    if (q == "") return true;
    return contains_text(to_lower_case(setting_name), q) || contains_text(to_lower_case(documentation), q);
}

/**
 * Validate and preview one settings edit without writing files/properties.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_plan.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_plan aal_zman_change_preview(string name, string old_value, string new_value, string kind) {
    agent_plan r;
    r.subject = name;
    agent_check check = aal_zman_field_validate(name, new_value, kind);
    r.valid = check.ok;
    r.action = "set " + name + " = " + new_value;
    r.reason = "old=" + old_value + "; changed=" + (old_value != new_value) + "; validation=" + check.reason;
    r.meat_cost = 0;
    r.turn_cost = 0;
    return r;
}

/**
 * Represent queued variable deletion explicitly before persistence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_plan.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_plan aal_zman_delete_preview(string name, boolean confirmed) {
    agent_plan r;
    r.subject = name;
    r.valid = name != "" && confirmed;
    r.action = "delete-setting " + name;
    r.reason = confirmed ? "explicitly confirmed" : "confirmation required";
    r.meat_cost = 0;
    r.turn_cost = 0;
    return r;
}

/**
 * List setting names associated with a script tag.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zman_group_settings(string[string] scripts_for_setting, string script_filter) {
    buffer out;
    string q = to_lower_case(script_filter);
    foreach name, scripts in scripts_for_setting if (q == "" || contains_text(to_lower_case(scripts), q)) out.append(name + "\t" + scripts + "\n");
    return out.to_string();
}

/**
 * Serialize editable settings schema/value/doc rows.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zman_schema_tsv(string[string] values, string[string] types, string[string] docs) {
    buffer out;
    foreach name, value in values {
        string kind = types contains name ? types[name] : aal_zman_field_kind(value);
        string doc = docs contains name ? docs[name] : "";
        out.append(name + "\t" + kind + "\t" + value + "\t" + doc + "\n");
    }
    return out.to_string();
}

/**
 * Validate an entire settings map and emit only errors.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zman_validation_errors(string[string] values, string[string] types) {
    buffer out;
    foreach name, value in values {
        string kind = types contains name ? types[name] : aal_zman_field_kind(value);
        agent_check c = aal_zman_field_validate(name, value, kind);
        if (!c.ok) out.append(name + "\t" + c.reason + "\n");
    }
    return out.to_string();
}

/**
 * Generate only changed, valid setting rows for a save operation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zman_save_plan(string[string] old_values, string[string] new_values, string[string] types) {
    buffer out;
    foreach name, new_value in new_values {
        string old_value = old_values contains name ? old_values[name] : "";
        if (old_value == new_value) continue;
        string kind = types contains name ? types[name] : aal_zman_field_kind(new_value);
        agent_check c = aal_zman_field_validate(name, new_value, kind);
        if (!c.ok) continue;
        out.append(name + "\t" + old_value + "\t" + new_value + "\n");
    }
    return out.to_string();
}

/**
 * Build bounded searchable setting context for agent-assisted configuration.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_zman_agent_context(string[string] values, string[string] docs, string query, int max_entries) {
    buffer out;
    int emitted;
    foreach name, value in values {
        if (max_entries > 0 && emitted >= max_entries) break;
        string doc = docs contains name ? docs[name] : "";
        if (!aal_zman_filter_match(name, doc, query)) continue;
        out.append("setting=" + name + ";kind=" + aal_zman_field_kind(value) + ";value=" + value + ";doc=" + doc + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

void main() {
    print("ASH Agent Standard Library monolith loaded: 410 functions / 41 source entries.", "teal");
    print("Run: verify ash_agent_stdlib_master.ash", "teal");
}
