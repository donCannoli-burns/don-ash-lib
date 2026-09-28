script "aal_s03_c2scripts.ash";

import <ash_agent_types.ash>;

// SOURCE 03: c2t_kol_scripts
// https://github.com/C2Talon/c2t_kol_scripts
// Purpose: Focused modern ASH scripts for resource use, trackers, choices, cartography, casting, and item-of-the-month workflows.

/**
 * Describe whether KoLmafia is currently handling a requested choice and its configured choiceAdventure preference.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_choice_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_choice_state aal_c2scripts_choice_state(int choice_id) {
    agent_choice_state r;
    r.choice_id = choice_id;
    r.handling = handling_choice() && last_choice() == choice_id;
    r.preference_name = "choiceAdventure" + choice_id;
    r.configured_option = get_property(r.preference_name).to_int();
    r.note = r.handling ? "active" : "not-active";
    return r;
}

/**
 * Validate an intended choice against current choice state without submitting it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2scripts_choice_preflight(int choice_id, int intended_option) {
    agent_check r;
    r.subject = "choice " + choice_id + " option " + intended_option;
    r.ok = handling_choice() && last_choice() == choice_id && intended_option > 0;
    r.severity = r.ok ? "info" : "warning";
    if (!handling_choice()) r.reason = "not handling a choice";
    else if (last_choice() != choice_id) r.reason = "active choice is " + last_choice();
    else if (intended_option <= 0) r.reason = "option must be positive";
    else r.reason = "preconditions satisfied";
    return r;
}

/**
 * Summarize Cold Medicine Cabinet consultation state from tracked preferences.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_cold_medicine_state() {
    buffer out;
    out.append("consults_used=" + get_property("_coldMedicineConsults") + "\n");
    out.append("last_consult=" + get_property("_nextColdMedicineConsult") + "\n");
    out.append("last_environment=" + get_property("lastCombatEnvironments") + "\n");
    return out.to_string();
}

/**
 * Expose the Daylight Shavings Helmet tracking preferences as compact machine context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_shavings_state() {
    buffer out;
    out.append("last_buff=" + get_property("_shavingHelmetBuff") + "\n");
    out.append("previous_buff=" + get_property("shavingHelmetBuff") + "\n");
    return out.to_string();
}

/**
 * Check non-mutating prerequisites for using Map the Monsters at a requested location.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2scripts_map_monster_preflight(location where, monster target) {
    agent_check r;
    r.subject = "map " + target + " at " + where;
    boolean skill_ok = have_skill($skill[Map the Monsters]);
    boolean loc_ok = can_adventure(where);
    boolean target_ok = target != $monster[none];
    r.ok = skill_ok && loc_ok && target_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "skill=" + skill_ok + "; location=" + loc_ok + "; monster=" + target_ok;
    return r;
}

/**
 * Preview MP and skill-availability requirements for repeated casting without casting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_c2scripts_cast_resource_preview(skill s, int casts) {
    agent_action_preview r;
    r.operation = "cast " + casts + " " + s;
    r.adventure_cost = 0;
    r.meat_cost = 0;
    int cost = mp_cost(s) * max(0, casts);
    r.valid = casts > 0 && have_skill(s) && my_mp() >= cost;
    r.reason = "mp_required=" + cost + "; mp_current=" + my_mp() + "; have_skill=" + have_skill(s);
    if (!r.valid) r.warnings = "insufficient skill, casts, or MP";
    return r;
}

/**
 * Combine item and skill availability into one reusable resource readiness check.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2scripts_resource_readiness(item required_item, skill required_skill) {
    agent_check r;
    r.subject = required_item + " + " + required_skill;
    boolean item_ok = required_item == $item[none] || available_amount(required_item) > 0;
    boolean skill_ok = required_skill == $skill[none] || have_skill(required_skill);
    r.ok = item_ok && skill_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "item=" + item_ok + "; skill=" + skill_ok;
    return r;
}

/**
 * Serialize a caller-selected tracker preference set in stable lexical order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_tracker_fingerprint(string[int] preference_names) {
    boolean[string] names;
    foreach i, p in preference_names if (p != "") names[p] = true;
    buffer out;
    foreach p in names out.append(p + "=" + get_property(p) + "\n");
    return out.to_string();
}

/**
 * Compare a numeric tracked preference to an earlier captured value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_c2scripts_resource_delta(string property_name, int before_value) {
    agent_delta d;
    d.label = property_name;
    d.before_value = before_value;
    d.after_value = get_property(property_name).to_int();
    d.difference = d.after_value - d.before_value;
    return d;
}

/**
 * Build compact choice/cartography/resource context inspired by c2t_kol_scripts.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_kol_scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2scripts_agent_context(location where, monster target, int choice_id) {
    buffer out;
    out.append("location=" + where + "\n");
    out.append("can_adventure=" + can_adventure(where) + "\n");
    out.append("target_monster=" + target + "\n");
    out.append("map_skill=" + have_skill($skill[Map the Monsters]) + "\n");
    out.append("handling_choice=" + handling_choice() + "\n");
    out.append("last_choice=" + last_choice() + "\n");
    out.append("requested_choice=" + choice_id + "\n");
    return out.to_string();
}
