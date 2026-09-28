script "aal_s10_pupdates.ash";

import <ash_agent_types.ash>;

// SOURCE 10: pUpdates repository
// https://github.com/Prusias-kol/pUpdates
// Purpose: Small file-backed update/changelog library with per-script versions and local seen-version tracking.

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
