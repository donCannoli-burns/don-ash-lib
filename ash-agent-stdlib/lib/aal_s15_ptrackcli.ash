script "aal_s15_ptrackcli.ash";

import <ash_agent_types.ash>;

// SOURCE 15: ptrack.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ptrack.ash
// Purpose: User-facing breakpoint orchestration over profit and time trackers, daily reset, comparison, and breakpoint lists.

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
