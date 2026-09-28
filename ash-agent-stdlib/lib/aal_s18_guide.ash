script "aal_s18_guide.ash";

import <ash_agent_types.ash>;

// SOURCE 18: Guide
// https://github.com/Ezandora/Guide
// Purpose: Large modular relay adviser that generates tasks/resources/future tasks from quest, item, IOTM, path, and availability state.

/**
 * Serialize a Guide-inspired task entry for machine consumption.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_task_line(string title, string status, string url, int priority) {
    return priority + "\t" + status + "\t" + title + "\t" + url;
}

/**
 * Serialize a Guide-inspired daily-resource entry.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_resource_line(string title, int remaining, string url) {
    return title + "\t" + remaining + "\t" + url;
}

/**
 * Expose one KoLmafia quest preference in normalized lowercase form.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_quest_property(string quest_property) {
    return to_lower_case(get_property(quest_property));
}

/**
 * Compare a quest preference with an expected state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_guide_quest_status_check(string quest_property, string expected_state) {
    agent_check r;
    r.subject = quest_property;
    string actual = to_lower_case(get_property(quest_property));
    r.ok = actual == to_lower_case(expected_state);
    r.severity = r.ok ? "info" : "notice";
    r.reason = "actual=" + actual + "; expected=" + to_lower_case(expected_state);
    return r;
}

/**
 * Convert a Guide-like daily counter into a structured remaining-resource record.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_guide_resource_from_property(string label, string used_property, int limit_value) {
    agent_resource_state r;
    r.name = label;
    r.used = get_property(used_property).to_int();
    r.limit_value = max(0, limit_value);
    r.remaining = max(0, r.limit_value - r.used);
    r.available = r.remaining > 0;
    return r;
}

/**
 * Describe whether a location-based task is currently actionable.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_plan.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_plan aal_guide_location_task(location loc, string title) {
    agent_plan r;
    r.subject = title;
    r.valid = can_adventure(loc);
    r.action = "adventure at " + loc;
    r.reason = r.valid ? "location currently adventureable" : "location not currently adventureable";
    r.meat_cost = 0;
    r.turn_cost = r.valid ? 1 : 0;
    return r;
}

/**
 * Filter/bound task text for a user or LLM query.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_task_filter(string[int] tasks, string query, int max_entries) {
    buffer out;
    string q = to_lower_case(query);
    int emitted;
    foreach i, task in tasks {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (q != "" && !contains_text(to_lower_case(task), q)) continue;
        out.append(task + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Represent future/optional task state without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_guide_future_task(string title, boolean unlocked, boolean completed, string prerequisite) {
    agent_check r;
    r.subject = title;
    r.ok = unlocked && !completed;
    r.severity = r.ok ? "notice" : "info";
    if (completed) r.reason = "completed";
    else if (!unlocked) r.reason = "waiting for " + prerequisite;
    else r.reason = "available";
    return r;
}

/**
 * Merge Guide-like task lanes into bounded labeled context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_advisory_merge(string[int] mandatory, string[int] optional, string[int] future, int max_each) {
    buffer out;
    int n;
    foreach i, x in mandatory { if (max_each > 0 && n >= max_each) break; if (x != "") { out.append("TASK\t" + x + "\n"); n = n + 1; } }
    n = 0;
    foreach i, x in optional { if (max_each > 0 && n >= max_each) break; if (x != "") { out.append("OPTIONAL\t" + x + "\n"); n = n + 1; } }
    n = 0;
    foreach i, x in future { if (max_each > 0 && n >= max_each) break; if (x != "") { out.append("FUTURE\t" + x + "\n"); n = n + 1; } }
    return out.to_string();
}

/**
 * Build compact quest-preference context using Guide's advisory orientation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Guide
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_guide_agent_context(string[int] quest_properties, int max_entries) {
    buffer out;
    int emitted;
    foreach i, p in quest_properties {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (p == "") continue;
        out.append(p + "=" + get_property(p) + "\n");
        emitted = emitted + 1;
    }
    out.append("adventures=" + my_adventures() + "\n");
    out.append("level=" + my_level() + "\n");
    return out.to_string();
}
