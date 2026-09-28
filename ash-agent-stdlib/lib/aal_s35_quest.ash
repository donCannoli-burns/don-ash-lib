script "aal_s35_quest.ash";

import <ash_agent_types.ash>;

// SOURCE 35: QuestLib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
// Purpose: Legacy quest automation with combat-rate/mood/MCD requests, gear setup, underwater handling, acquisition/pulls, and quest flow.

/**
 * Return normalized KoLmafia quest preference text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_property_state(string quest_property) {
    return to_lower_case(get_property(quest_property));
}

/**
 * Convert common quest states into a coarse monotonic progress rank.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_quest_progress_rank(string quest_state) {
    string q = to_lower_case(quest_state);
    if (q == "unstarted" || q == "") return 0;
    if (q == "started") return 1;
    if (index_of(q, "step") == 0) {
        string n = substring(q, 4);
        return 2 + n.to_int();
    }
    if (q == "finished") return 100;
    return 1;
}

/**
 * Translate legacy request_combat/request_noncombat intent into a descriptive maximizer goal.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_combat_rate_goal(string mode) {
    string m = to_lower_case(mode);
    if (m == "combat") return "+combat";
    if (m == "noncombat") return "-combat";
    if (m == "ml" || m == "monsterlevel") return "+monster level";
    if (m == "apathetic") return "no mood";
    return "default";
}

/**
 * Return the legacy practical MCD ceiling implied by sign.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_quest_mcd_ceiling() {
    return 10 + (in_mysticality_sign() ? 1 : 0);
}

/**
 * Validate desired MCD against source-inspired practical ceiling.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_quest_mcd_preflight(int desired) {
    agent_check r;
    r.subject = "MCD " + desired;
    int max_value = aal_quest_mcd_ceiling();
    r.ok = desired >= 0 && desired <= max_value;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "current=" + current_mcd() + "; max=" + max_value;
    return r;
}

/**
 * Check ownership of common underwater breathing gear without changing outfit.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_quest_underwater_preflight() {
    agent_check r;
    r.subject = "underwater";
    boolean gear = available_amount($item[Aerated diving helmet]) > 0 || available_amount($item[makeshift SCUBA gear]) > 0;
    r.ok = gear;
    r.severity = gear ? "info" : "warning";
    r.reason = "aerated=" + available_amount($item[Aerated diving helmet]) + "; scuba=" + available_amount($item[makeshift SCUBA gear]);
    return r;
}

/**
 * Describe quest location accessibility/turn history.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_location_state(location loc) {
    buffer out;
    out.append("location=" + loc + "\n");
    out.append("can_adventure=" + can_adventure(loc) + "\n");
    out.append("turns_spent=" + loc.turns_spent + "\n");
    return out.to_string();
}

/**
 * Measure quest-item shortfall across available amount.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_quest_resource_gap(item it, int required) {
    agent_delta d;
    d.label = it;
    d.before_value = available_amount(it);
    d.after_value = max(0, required);
    d.difference = max(0, required - d.before_value);
    return d;
}

/**
 * Serialize one quest planning row from preference, location and item state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_plan_line(string quest_property, location loc, item required_item) {
    return quest_property + "\t" + get_property(quest_property) + "\t" + loc + "\t" + can_adventure(loc) + "\t" + required_item + "\t" + (required_item == $item[none] ? 0 : available_amount(required_item));
}

/**
 * Build bounded quest-state context without invoking old mood/gear automation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/QuestLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_quest_agent_context(string[int] quest_properties, int max_entries) {
    buffer out;
    out.append("level=" + my_level() + "\n");
    out.append("path=" + my_path() + "\n");
    out.append("mcd=" + current_mcd() + "\n");
    int emitted;
    foreach i, p in quest_properties {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (p == "") continue;
        out.append(p + "=" + get_property(p) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
