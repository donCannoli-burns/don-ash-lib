script "aal_s19_gain.ash";

import <ash_agent_types.ash>;

// SOURCE 19: Ezandora Gain
// https://github.com/Ezandora/Gain
// Purpose: Modifier optimizer that indexes effect sources, models costs/efficiency, handles conflicts/limited buffs, and supports simulation.

/**
 * Capture current modifier value and target gap.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_modifier_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_modifier_state aal_gain_modifier_state(string modifier_name, float target) {
    agent_modifier_state r;
    r.modifier_name = to_lower_case(modifier_name);
    r.current_value = numeric_modifier(modifier_name);
    r.target_value = target;
    r.gap = target - r.current_value;
    r.satisfied = r.gap <= 0;
    return r;
}

/**
 * Read one effect's contribution to a modifier.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_effect_modifier(effect e, string modifier_name) {
    return numeric_modifier(e, modifier_name);
}

/**
 * Compute simple cost per modifier-turn for an effect candidate.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_effect_efficiency(effect e, string modifier_name, int turns, int estimated_cost) {
    float value = numeric_modifier(e, modifier_name);
    if (value == 0.0 || turns <= 0) return 1000000000.0;
    return to_float(max(0, estimated_cost)) / ((value < 0.0 ? -value : value) * turns);
}

/**
 * Report active mutually-exclusive effects from a caller-supplied conflict set.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_gain_conflict_hint(effect desired, effect[int] exclusive_set) {
    buffer out;
    foreach i, e in exclusive_set {
        if (e == desired) continue;
        int turns = have_effect(e);
        if (turns > 0) out.append(e + "\t" + turns + "\n");
    }
    return out.to_string();
}

/**
 * Apply explicit limited-effect policy to a candidate.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_gain_limited_effect_check(effect e, boolean allow_limited) {
    agent_check r;
    r.subject = e;
    boolean known_limited = e == $effect[Blessing of your favorite Bird] || e == $effect[Blessing of the Bird] || e == $effect[Triple-Sized] || e == $effect[Invisible Avatar];
    r.ok = allow_limited || !known_limited;
    r.severity = r.ok ? "info" : "warning";
    r.reason = known_limited ? "limited effect" : "not in known limited set";
    return r;
}

/**
 * Estimate acquisition cost of an item source without acquiring it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_gain_item_source_cost(item it) {
    if (it == $item[none]) return 0;
    if (available_amount(it) > 0) return 0;
    int p = historical_price(it);
    if (p <= 0) p = mall_price(it);
    if (p <= 0) p = max(0, autosell_price(it));
    return p;
}

/**
 * Estimate a skill buff's MP opportunity cost.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_gain_skill_source_cost(skill s, int meat_per_mp) {
    if (s == $skill[none] || !have_skill(s)) return -1;
    return max(0, mp_cost(s) * meat_per_mp);
}

/**
 * Compute a simple non-mutating additive modifier simulation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_simulate_additive(string modifier_name, float additional_value) {
    return numeric_modifier(modifier_name) + additional_value;
}

/**
 * Score a modifier source by gain-turns per meat; higher is better.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_gain_candidate_score(float modifier_gain, int turns, int cost) {
    if (modifier_gain == 0.0 || turns <= 0) return 0.0;
    if (cost <= 0) return (modifier_gain < 0.0 ? -modifier_gain : modifier_gain) * turns * 1000000.0;
    return (modifier_gain < 0.0 ? -modifier_gain : modifier_gain) * turns / cost;
}

/**
 * Build bounded context of current modifier and active effects contributing to it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_gain_agent_context(string modifier_name, float target, int max_effects) {
    buffer out;
    out.append("modifier=" + modifier_name + "\n");
    out.append("current=" + numeric_modifier(modifier_name) + "\n");
    out.append("target=" + target + "\n");
    int emitted;
    int[effect] active = my_effects();
    foreach e, turns in active {
        if (max_effects > 0 && emitted >= max_effects) break;
        float v = numeric_modifier(e, modifier_name);
        if (v == 0.0) continue;
        out.append("effect=" + e + ";turns=" + turns + ";value=" + v + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
