script "aal_s30_liba.ash";

import <ash_agent_types.ash>;

// SOURCE 30: liba
// https://github.com/C2Talon/liba
// Purpose: Modern small composable ASH helpers plus resource-specific modules for choices, combat checks, equip-cast, properties, priorities, and IOTMs.

/**
 * Clamp while safely normalizing reversed bounds.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_liba_clamp_normalized(float value, float low, float high) {
    float lo = min(low, high);
    float hi = max(low, high);
    return max(lo, min(hi, value));
}

/**
 * Check that every non-empty token occurs case-insensitively in text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_liba_tokens_all_present(string haystack, string[int] tokens) {
    string h = to_lower_case(haystack);
    foreach i, t in tokens if (t != "" && !contains_text(h, to_lower_case(t))) return false;
    return true;
}

/**
 * Preview integer preference increment without writing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_liba_property_increment_preview(string property_name, int delta) {
    agent_delta d;
    d.label = property_name;
    d.before_value = get_property(property_name).to_int();
    d.after_value = d.before_value + delta;
    d.difference = delta;
    return d;
}

/**
 * Select the first available item and explain the priority position.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_priority_item_reason(item[int] candidates) {
    int position;
    foreach i, it in candidates {
        position = position + 1;
        if (available_amount(it) > 0) return position + "\t" + it + "\t" + available_amount(it);
    }
    return "0\tnone\t0";
}

/**
 * Return compact current-choice context inspired by liba_inChoice.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_choice_context() {
    buffer out;
    out.append("handling=" + handling_choice() + "\n");
    out.append("choice_id=" + (handling_choice() ? last_choice() : -1) + "\n");
    if (handling_choice()) out.append("configured=" + get_property("choiceAdventure" + last_choice()) + "\n");
    return out.to_string();
}

/**
 * Return compact combat indicators inspired by liba_inCombat without executing requests.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_combat_context() {
    buffer out;
    out.append("last_monster=" + last_monster() + "\n");
    out.append("last_combat_result=" + get_property("lastCombatResult") + "\n");
    out.append("last_macro_error=" + get_property("lastMacroError") + "\n");
    return out.to_string();
}

/**
 * Check equip/cast prerequisites and MP without changing equipment.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_liba_equip_cast_preflight(item gear, skill s, int casts) {
    agent_check r;
    r.subject = gear + " + " + s;
    boolean gear_ok = available_amount(gear) > 0 && can_equip(gear);
    boolean skill_ok = have_skill(s);
    boolean mp_ok = my_mp() >= max(0, casts) * mp_cost(s);
    r.ok = casts > 0 && gear_ok && skill_ok && mp_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "gear=" + gear_ok + "; skill=" + skill_ok + "; mp=" + mp_ok;
    return r;
}

/**
 * Describe whether an item is present for low-level/raw-use logic, without using it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_liba_raw_use_preflight(item it) {
    agent_check r;
    r.subject = it;
    r.ok = item_amount(it) > 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "inventory=" + item_amount(it);
    return r;
}

/**
 * Build generic context for one of liba's resource-specific IOTM modules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_resource_module_context(item key_item, string[int] preference_names) {
    buffer out;
    out.append("key_item=" + key_item + "\n");
    out.append("available=" + available_amount(key_item) + "\n");
    boolean[string] names;
    foreach i, p in preference_names if (p != "") names[p] = true;
    foreach p in names out.append(p + "=" + get_property(p) + "\n");
    return out.to_string();
}

/**
 * Compose tiny reusable preference/item context in the spirit of liba's focused modules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/liba
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_liba_micro_context(string label, string[int] preference_names, item[int] items) {
    buffer out;
    out.append("label=" + label + "\n");
    foreach i, p in preference_names if (p != "") out.append("pref." + p + "=" + get_property(p) + "\n");
    foreach i, it in items if (it != $item[none]) out.append("item." + to_int(it) + "=" + available_amount(it) + "\n");
    return out.to_string();
}
