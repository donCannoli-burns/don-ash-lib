script "aal_s32_c2lib.ash";

import <ash_agent_types.ash>;

// SOURCE 32: c2t_lib
// https://github.com/C2Talon/c2t_lib
// Purpose: Shared modern helper library covering assertions, clans, wanderers, choices, priorities, maximizer caching, equip-cast, buying, and macro building.

/**
 * Recompute c2t_lib-inspired sausage goblin odds without equipping or adventuring.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_c2lib_sausage_odds() {
    if (available_amount($item[Kramco Sausage-o-Matic™]) == 0 && available_amount($item[replica Kramco Sausage-o-Matic™]) == 0) return 0.0;
    int fights = get_property("_sausageFights").to_int();
    int multiplier = max(0, fights - 5);
    int last_turn = get_property("_lastSausageMonsterTurn").to_int();
    return to_float(total_turns_played() - last_turn + 1) / (5.0 + fights * 3.0 + multiplier * multiplier * multiplier);
}

/**
 * Check whether the sausage wanderer threshold is currently met.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_c2lib_sausage_ready() {
    if (available_amount($item[Kramco Sausage-o-Matic™]) == 0 && available_amount($item[replica Kramco Sausage-o-Matic™]) == 0) return false;
    int fights = get_property("_sausageFights").to_int();
    if (fights == 0) return true;
    int multiplier = max(0, fights - 5);
    int last_turn = get_property("_lastSausageMonsterTurn").to_int();
    return max(0, 4 + fights * 3 + multiplier * multiplier * multiplier - total_turns_played() + last_turn) == 0;
}

/**
 * Expose cursed magnifying glass charge/free-fight state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_void_state() {
    buffer out;
    out.append("owned=" + (available_amount($item[cursed magnifying glass]) > 0) + "\n");
    out.append("charge=" + get_property("cursedMagnifyingGlassCount") + "\n");
    out.append("free_fights_used=" + get_property("_voidFreeFights") + "\n");
    out.append("ready=" + (available_amount($item[cursed magnifying glass]) > 0 && get_property("cursedMagnifyingGlassCount").to_int() >= 13) + "\n");
    return out.to_string();
}

/**
 * Validate exact active choice ID.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2lib_choice_expectation(int expected_choice) {
    agent_check r;
    r.subject = "choice " + expected_choice;
    r.ok = handling_choice() && last_choice() == expected_choice;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "handling=" + handling_choice() + "; active=" + last_choice();
    return r;
}

/**
 * Decode pilcrow item tokens from a maximizer expression into typed item rows for troubleshooting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_pilcrow_items(string maximizer_expression) {
    buffer out;
    boolean[int] ids;
    matcher m = create_matcher("¶(\\d+)", maximizer_expression);
    while (m.find()) ids[m.group(1).to_int()] = true;
    foreach id in ids {
        item it = to_item(id);
        out.append(id + "\t" + it + "\n");
    }
    return out.to_string();
}

/**
 * Return first available item plus all candidate availability for explainable priority.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_priority_item_context(item[int] candidates) {
    buffer out;
    item selected = $item[none];
    foreach i, it in candidates {
        int qty = available_amount(it);
        out.append(i + "\t" + it + "\t" + qty + "\n");
        if (selected == $item[none] && qty > 0) selected = it;
    }
    out.append("selected\t" + selected + "\n");
    return out.to_string();
}

/**
 * Normalize a maximizer expression into a lightweight cache-comparison key.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_maximize_key(string maximizer_expression) {
    string s = to_lower_case(maximizer_expression);
    s = replace_string(s, " ", "");
    s = replace_string(s, "\t", "");
    return s;
}

/**
 * Snapshot turn count and accessibility before a caller attempts a supposedly free adventure.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2lib_free_adventure_preflight(location loc) {
    agent_check r;
    r.subject = loc;
    r.ok = can_adventure(loc) && my_adventures() > 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "can_adventure=" + can_adventure(loc) + "; adventures=" + my_adventures() + "; turncount=" + my_turncount();
    return r;
}

/**
 * Estimate mall cost/budget fit without invoking c2t_buy.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_c2lib_purchase_budget(item it, int quantity, int max_unit_price) {
    agent_action_preview r;
    int p = mall_price(it);
    r.operation = "buy " + quantity + " " + it;
    r.meat_cost = max(0, p) * max(0, quantity);
    r.adventure_cost = 0;
    r.valid = quantity > 0 && p > 0 && p <= max_unit_price && my_meat() >= r.meat_cost;
    r.reason = "unit_price=" + p + "; cap=" + max_unit_price + "; total=" + r.meat_cost + "; meat=" + my_meat();
    return r;
}

/**
 * Describe BALLS-style combat macro structure without submitting it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon/c2t_lib
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2lib_macro_description(string macro_text) {
    buffer out;
    out.append("length=" + length(macro_text) + "\n");
    out.append("skills=" + contains_text(to_lower_case(macro_text), "skill ") + "\n");
    out.append("items=" + contains_text(to_lower_case(macro_text), "use ") + "\n");
    out.append("conditional=" + (contains_text(to_lower_case(macro_text), "if ") || contains_text(to_lower_case(macro_text), "while ")) + "\n");
    out.append("raw=" + macro_text + "\n");
    return out.to_string();
}
