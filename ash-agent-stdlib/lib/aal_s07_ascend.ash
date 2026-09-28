script "aal_s07_ascend.ash";

import <ash_agent_types.ash>;

// SOURCE 07: c2t_ascend
// https://github.com/C2Talon/c2t_ascend
// Purpose: Valhalla/ascension automation with relay-configured path/class/sign/astral/perm choices and validation.

/**
 * Return stable names for a minimal Valhalla/ascension plan schema.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_config_fields() {
    return "path\nclass\nsign\nastral_item\nastral_consumable\nperms\npost_ascension_script\n";
}

/**
 * Safely read an indexed value from a comma-delimited ascension configuration.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_config_value(string csv, int index) {
    if (index < 0) return "";
    string[int] bits = split_string(csv, ",");
    if (index >= count(bits)) return "";
    return bits[index];
}

/**
 * Compare banked karma with planned perm expenditure.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_range_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_ascend_karma_budget(int planned_perm_cost) {
    agent_range_state r;
    r.minimum = max(0, planned_perm_cost);
    r.maximum = get_property("bankedKarma").to_int();
    r.current = r.maximum;
    r.remaining = r.current - r.minimum;
    r.satisfied = r.remaining >= 0;
    return r;
}

/**
 * Expose current aftercore/interaction/king state relevant to entering Valhalla.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_prerequisite_state() {
    buffer out;
    out.append("can_interact=" + can_interact() + "\n");
    out.append("king_liberated=" + get_property("kingLiberated") + "\n");
    out.append("ascensions=" + my_ascensions() + "\n");
    out.append("path=" + my_path() + "\n");
    return out.to_string();
}

/**
 * Validate that configured path/class/sign strings resolve to current KoLmafia typed values.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ascend_plan_validate(string path_name, string class_name, string sign_name) {
    agent_check r;
    r.subject = "ascension-plan";
    path p = to_path(path_name);
    class c = to_class(class_name);
    r.ok = p != $path[none] && c != $class[none] && sign_name != "";
    r.severity = r.ok ? "info" : "warning";
    r.reason = "path=" + p + "; class=" + c + "; sign=" + sign_name;
    return r;
}

/**
 * Filter caller-supplied perm candidates to skills actually known by the character.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_perm_candidates(skill[int] skills, int max_entries) {
    buffer out;
    int emitted;
    foreach i, s in skills {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (!have_skill(s)) continue;
        out.append(to_int(s) + "\t" + s + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize compact pre-ascension currencies/resources useful for planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_resource_snapshot() {
    buffer out;
    out.append("meat=" + my_meat() + "\n");
    out.append("karma=" + get_property("bankedKarma") + "\n");
    out.append("pulls_remaining=" + pulls_remaining() + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    return out.to_string();
}

/**
 * Describe the configured post-ascension command without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_ascend_post_script_preview(string command_text) {
    agent_action_preview r;
    r.operation = command_text;
    r.valid = command_text != "";
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = r.valid ? "configured command preserved verbatim" : "no post-ascension command configured";
    if (contains_text(to_lower_case(command_text), "send ") || contains_text(to_lower_case(command_text), "kmail")) r.warnings = "contains communication-like command text; review manually";
    return r;
}

/**
 * Produce a stable lightweight fingerprint for detecting ascension-config drift.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ascend_config_fingerprint(string config_csv) {
    int h = length(config_csv) * 97;
    int commas;
    int spaces;
    if (length(config_csv) > 0) {
        for i from 0 to length(config_csv) - 1 {
            string ch = substring(config_csv, i, i + 1);
            if (ch == ",") commas = commas + 1;
            if (ch == " ") spaces = spaces + 1;
        }
    }
    return (h + commas * 31 + spaces * 17) % 1000003;
}

/**
 * Build compact current-state plus configured-plan context for an ascension agent.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_ascend
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ascend_agent_context(string config_csv, string post_script) {
    buffer out;
    out.append("config=" + config_csv + "\n");
    out.append("post_script=" + post_script + "\n");
    out.append("current_path=" + my_path() + "\n");
    out.append("current_class=" + my_class() + "\n");
    out.append("karma=" + get_property("bankedKarma") + "\n");
    out.append("can_interact=" + can_interact() + "\n");
    return out.to_string();
}
