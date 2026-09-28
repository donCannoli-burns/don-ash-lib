script "aal_s41_zman.ash";

import <ash_agent_types.ash>;

// SOURCE 41: relay_zlib_manager.ash (fixed historical commit)
// https://github.com/twistedmage/assorted-kol-scripts/blob/1b7f2f94eaa9e9969be6d26886664e2b9b1ea31a/relay/relay_zlib_manager.ash
// Purpose: Relay UI for ZLib settings with descriptions, typed controls, validators, filtering, delete queues, and save feedback.

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
