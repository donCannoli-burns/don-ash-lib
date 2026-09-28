script "aal_s14_time.ash";

import <ash_agent_types.ash>;

// SOURCE 14: TimeTracking.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/TimeTracking.ash
// Purpose: Named timestamp checkpoints, elapsed-time comparison, event-list tracking, and combined profit/time breakpoints.

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
