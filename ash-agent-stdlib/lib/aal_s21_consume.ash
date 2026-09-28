script "aal_s21_consume.ash";

import <ash_agent_types.ash>;

// SOURCE 21: Consume
// https://github.com/Ezandora/Consume
// Purpose: Consumption optimizer for food/booze/spleen planning with value-of-adventure and resource-aware selection.

/**
 * Capture current fullness, inebriety, and spleen usage/limits.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_organ_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_organ_state aal_consume_organ_state() {
    agent_organ_state r;
    r.fullness = my_fullness();
    r.fullness_limit_value = fullness_limit();
    r.inebriety = my_inebriety();
    r.inebriety_limit_value = inebriety_limit();
    r.spleen = my_spleen_use();
    r.spleen_limit_value = spleen_limit();
    return r;
}

/**
 * Return remaining capacity for fullness, liver, or spleen by normalized organ name.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_consume_organ_remaining(string organ_name) {
    string n = to_lower_case(organ_name);
    if (n == "fullness" || n == "stomach") return max(0, fullness_limit() - my_fullness());
    if (n == "inebriety" || n == "liver") return max(0, inebriety_limit() - my_inebriety());
    if (n == "spleen") return max(0, spleen_limit() - my_spleen_use());
    return -1;
}

/**
 * Create a normalized consumable candidate with density/value fields.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_consumption_candidate.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_consumption_candidate aal_consume_candidate(item it, int size, float expected_adventures, int price) {
    agent_consumption_candidate r;
    r.thing = it;
    r.size = max(0, size);
    r.adventures = expected_adventures;
    r.price = max(0, price);
    r.adventures_per_size = r.size > 0 ? r.adventures / r.size : 0.0;
    r.value = 0.0;
    r.fits = false;
    return r;
}

/**
 * Check whether a candidate fits the requested organ's remaining capacity.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_consume_candidate_fits(agent_consumption_candidate c, string organ_name) {
    int remaining = aal_consume_organ_remaining(organ_name);
    return remaining >= 0 && c.size > 0 && c.size <= remaining;
}

/**
 * Estimate net adventure value after purchase cost.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_consume_candidate_value(agent_consumption_candidate c, int value_of_adventure) {
    return c.adventures * max(0, value_of_adventure) - c.price;
}

/**
 * Estimate net value per organ point.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_consume_candidate_density(agent_consumption_candidate c, int value_of_adventure) {
    if (c.size <= 0) return 0.0;
    return aal_consume_candidate_value(c, value_of_adventure) / c.size;
}

/**
 * Check candidate price against a caller budget.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_consume_budget_check(agent_consumption_candidate c, int meat_budget) {
    agent_check r;
    r.subject = c.thing;
    r.ok = c.price <= max(0, meat_budget);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "price=" + c.price + "; budget=" + meat_budget;
    return r;
}

/**
 * Describe whether consuming a drink of the given size would exceed the normal liver limit.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_consume_overdrink_risk(int drink_size) {
    agent_check r;
    r.subject = "overdrink-risk";
    int after = my_inebriety() + max(0, drink_size);
    r.ok = after <= inebriety_limit();
    r.severity = r.ok ? "info" : "warning";
    r.reason = "current=" + my_inebriety() + "; size=" + drink_size + "; limit=" + inebriety_limit();
    return r;
}

/**
 * Serialize a candidate's fit and economic density for planner/agent sorting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_consume_plan_line(agent_consumption_candidate c, string organ_name, int value_of_adventure) {
    boolean fits = aal_consume_candidate_fits(c, organ_name);
    float density = aal_consume_candidate_density(c, value_of_adventure);
    return c.thing + "\t" + c.size + "\t" + c.adventures + "\t" + c.price + "\t" + fits + "\t" + density;
}

/**
 * Build compact organ/value context for a consumption planner.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Consume
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_consume_agent_context(int value_of_adventure) {
    buffer out;
    out.append("value_of_adventure=" + value_of_adventure + "\n");
    out.append("fullness=" + my_fullness() + "/" + fullness_limit() + "\n");
    out.append("inebriety=" + my_inebriety() + "/" + inebriety_limit() + "\n");
    out.append("spleen=" + my_spleen_use() + "/" + spleen_limit() + "\n");
    out.append("meat=" + my_meat() + "\n");
    return out.to_string();
}
