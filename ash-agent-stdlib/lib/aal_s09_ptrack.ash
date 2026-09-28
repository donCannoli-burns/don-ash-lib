script "aal_s09_ptrack.ash";

import <ash_agent_types.ash>;

// SOURCE 09: pTrack repository
// https://github.com/Prusias-kol/pTrack
// Purpose: Profit/time/breakpoint tracking suite combining inventory, meat, time, account value, and named checkpoints.

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
