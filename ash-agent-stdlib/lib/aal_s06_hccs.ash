script "aal_s06_hccs.ash";

import <ash_agent_types.ash>;

// SOURCE 06: c2t_hccs
// https://github.com/C2Talon/c2t_hccs
// Purpose: Community Service automation with test thresholds, resources, recovery, combat, pre-adventure hooks, and relay configuration.

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
