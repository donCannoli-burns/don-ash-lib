script "aal_s28_htmlform.ash";

import <ash_agent_types.ash>;

// SOURCE 28: htmlform.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
// Purpose: Relay HTML form construction, field helpers, validation, attributes, and save/cancel interactions.

/**
 * Escape basic HTML-sensitive characters for form output.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_escape(string value) {
    string out = replace_string(value, "&", "&amp;");
    out = replace_string(out, "<", "&lt;");
    out = replace_string(out, ">", "&gt;");
    out = replace_string(out, "\"", "&quot;");
    return out;
}

/**
 * Validate basic relay form field presence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_htmlform_field_validate(string name, string value, boolean required) {
    agent_check r;
    r.subject = name;
    r.ok = name != "" && (!required || value != "");
    r.severity = r.ok ? "info" : "error";
    r.reason = r.ok ? "field valid" : "missing name or required value";
    return r;
}

/**
 * Validate an integer form value against inclusive bounds.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_htmlform_int_validate(string name, string value, int minimum, int maximum) {
    agent_check r;
    r.subject = name;
    boolean numeric = is_integer(value);
    int v = numeric ? value.to_int() : 0;
    r.ok = numeric && v >= minimum && v <= maximum;
    r.severity = r.ok ? "info" : "error";
    r.reason = "value=" + value + "; range=" + minimum + ".." + maximum;
    return r;
}

/**
 * Normalize common form boolean encodings.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_htmlform_bool_normalize(string value) {
    string v = to_lower_case(value);
    return v == "true" || v == "1" || v == "on" || v == "yes";
}

/**
 * Serialize a form field schema for human/agent tooling.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_field_schema(string name, string type_name, string default_value, string description) {
    return name + "\t" + type_name + "\t" + default_value + "\t" + description;
}

/**
 * Check that a submitted select value belongs to the allowed set.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_htmlform_select_validate(string value, string[int] allowed_values) {
    agent_check r;
    r.subject = value;
    boolean found;
    foreach i, x in allowed_values if (x == value) found = true;
    r.ok = found;
    r.severity = found ? "info" : "error";
    r.reason = found ? "allowed" : "value not in allowed set";
    return r;
}

/**
 * Check whether a submitted field actually changes persisted value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_htmlform_changed(string old_value, string submitted_value) {
    return old_value != submitted_value;
}

/**
 * Serialize a proposed form change without applying it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_change_line(string name, string old_value, string submitted_value) {
    return name + "\t" + old_value + "\t" + submitted_value + "\t" + (old_value != submitted_value);
}

/**
 * Serialize failing field validations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_error_summary(agent_check[int] checks) {
    buffer out;
    foreach i, c in checks if (!c.ok) out.append(c.subject + "\t" + c.reason + "\n");
    return out.to_string();
}

/**
 * Serialize submitted form fields with deterministic key ordering and bounded size.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/htmlform.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_htmlform_agent_context(string[string] fields, int max_entries) {
    buffer out;
    int emitted;
    foreach name, value in fields {
        if (max_entries > 0 && emitted >= max_entries) break;
        out.append(name + "=" + value + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
