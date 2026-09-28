script "aal_s08_ploop.ash";

import <ash_agent_types.ash>;

// SOURCE 08: pLooper
// https://github.com/Prusias-kol/pLooper
// Purpose: Re-entrant full-day loop orchestration around breakfast, farming, prep, ascension, post-run work, nightcap, and checkpoints.

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
