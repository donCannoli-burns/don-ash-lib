script "aal_s40_zlib.ash";

import <ash_agent_types.ash>;

// SOURCE 40: zlib.ash (fixed historical commit)
// https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/scripts/zlib.ash#L4
// Purpose: Zarqon's general library: typed setting normalization, string/list utilities, verbosity, numeric helpers, averages, expression evaluation, map/version/update infrastructure.

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
