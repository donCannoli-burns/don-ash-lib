script "aal_s12_pwrapper.ash";

import <ash_agent_types.ash>;

// SOURCE 12: pwrapper
// https://github.com/Prusias-kol/pwrapper
// Purpose: Retry wrapper for a loop script with error logging, choice/combat safe-state recovery, refresh, and completion detection.

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
