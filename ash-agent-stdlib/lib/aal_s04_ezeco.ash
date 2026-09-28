script "aal_s04_ezeco.ash";

import <ash_agent_types.ash>;

// SOURCE 04: Ezandora repository ecosystem
// https://github.com/Ezandora?tab=repositories
// Purpose: Large ecosystem of relay advisers, optimizers, choice overrides, consumption/buff tools, and modular KoLmafia projects.

/**
 * Serialize one Guide-like advisory entry as compact deterministic text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advisory_entry(string title, string url, string[int] details) {
    buffer out;
    out.append("title=" + title + "\n");
    out.append("url=" + url + "\n");
    foreach i, d in details out.append("detail=" + d + "\n");
    return out.to_string();
}

/**
 * Calculate a stable task-priority signal inspired by Guide task/resource/future-task separation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ezeco_task_priority(boolean mandatory, boolean available_now, int turns_until_relevant) {
    int score;
    if (mandatory) score = score + 100;
    if (available_now) score = score + 50;
    if (turns_until_relevant <= 0) score = score + 25;
    else score = score + max(0, 20 - turns_until_relevant);
    return score;
}

/**
 * Return remaining uses for a preference-backed daily resource.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_ezeco_resource_remaining(string used_property, int limit_value) {
    agent_resource_state r;
    r.name = used_property;
    r.used = get_property(used_property).to_int();
    r.limit_value = max(0, limit_value);
    r.remaining = max(0, r.limit_value - r.used);
    r.available = r.remaining > 0;
    return r;
}

/**
 * Describe future-task eligibility from explicit unlock/completion preferences.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ezeco_future_task_state(string unlock_property, string complete_property) {
    agent_check r;
    r.subject = unlock_property + " -> " + complete_property;
    boolean unlocked = get_property(unlock_property).to_boolean();
    boolean complete = get_property(complete_property).to_boolean();
    r.ok = unlocked && !complete;
    r.severity = "info";
    r.reason = "unlocked=" + unlocked + "; complete=" + complete;
    return r;
}

/**
 * Expose location accessibility and recent turn count as advisory context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_location_advice(location loc) {
    buffer out;
    out.append("location=" + loc + "\n");
    out.append("available=" + can_adventure(loc) + "\n");
    out.append("turns_spent=" + loc.turns_spent + "\n");
    return out.to_string();
}

/**
 * Describe whether a feature is present through any of its item/familiar/skill surfaces.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ezeco_iotm_presence(item key_item, familiar key_familiar, skill key_skill) {
    agent_check r;
    r.subject = "feature-presence";
    boolean item_ok = key_item != $item[none] && available_amount(key_item) > 0;
    boolean fam_ok = key_familiar != $familiar[none] && have_familiar(key_familiar);
    boolean skill_ok = key_skill != $skill[none] && have_skill(key_skill);
    r.ok = item_ok || fam_ok || skill_ok;
    r.severity = "info";
    r.reason = "item=" + item_ok + "; familiar=" + fam_ok + "; skill=" + skill_ok;
    return r;
}

/**
 * De-duplicate Guide-like advisory lines while retaining deterministic lexical order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advice_dedupe(string[int] advisory_lines) {
    boolean[string] seen;
    foreach i, line in advisory_lines if (line != "") seen[line] = true;
    buffer out;
    foreach line in seen out.append(line + "\n");
    return out.to_string();
}

/**
 * Filter advisory lines case-insensitively for an agent/user query.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advice_filter(string[int] advisory_lines, string query) {
    buffer out;
    string q = to_lower_case(query);
    foreach i, line in advisory_lines if (q == "" || contains_text(to_lower_case(line), q)) out.append(line + "\n");
    return out.to_string();
}

/**
 * Cap a potentially large advisory list for context-budget-aware agent use.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_advice_budget(string[int] advisory_lines, int max_entries) {
    buffer out;
    int emitted;
    foreach i, line in advisory_lines {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (line == "") continue;
        out.append(line + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Build a Guide-inspired compact tasks/resources section for an LLM.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ezeco_agent_context(string section_name, string[int] current_tasks, string[int] resources, int max_each) {
    buffer out;
    out.append("section=" + section_name + "\n");
    int n;
    foreach i, line in current_tasks {
        if (max_each > 0 && n >= max_each) break;
        if (line != "") { out.append("task=" + line + "\n"); n = n + 1; }
    }
    n = 0;
    foreach i, line in resources {
        if (max_each > 0 && n >= max_each) break;
        if (line != "") { out.append("resource=" + line + "\n"); n = n + 1; }
    }
    return out.to_string();
}
