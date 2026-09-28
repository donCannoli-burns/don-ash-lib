script "aal_s27_select2.ash";

import <ash_agent_types.ash>;

// SOURCE 27: insertSelect2-relays
// https://github.com/C2Talon/insertSelect2-relays
// Purpose: Relay enhancement project for select controls/searchability; inspiration for deterministic option filtering and selection descriptions.

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
