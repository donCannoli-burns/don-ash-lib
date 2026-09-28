script "aal_s29_batbrain.ash";

import <ash_agent_types.ash>;

// SOURCE 29: BatBrain.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
// Purpose: Combat reasoning engine with event/spread modeling, adjusted stats, action valuation, resource costs, monster value, and combat environment construction.

/**
 * Capture current combat-relevant monster/player stats without taking an action.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_combat_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_combat_state aal_batbrain_combat_state() {
    agent_combat_state r;
    r.foe = last_monster();
    r.hp = monster_hp();
    r.attack = monster_attack();
    r.defense = monster_defense();
    r.player_hp = my_hp();
    r.player_mp = my_mp();
    r.turn = my_turncount();
    return r;
}

/**
 * Compute player HP remaining after hypothetical damage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_batbrain_hit_survival_margin(int expected_damage) {
    return my_hp() - max(0, expected_damage);
}

/**
 * Compute MP remaining after hypothetical repeated skill use.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_batbrain_skill_mp_margin(skill s, int casts) {
    return my_mp() - max(0, casts) * mp_cost(s);
}

/**
 * Validate skill ownership and MP for a hypothetical combat action.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_batbrain_action_resource_check(skill s, int casts) {
    agent_check r;
    r.subject = s;
    int need = max(0, casts) * mp_cost(s);
    r.ok = casts > 0 && have_skill(s) && my_mp() >= need;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "casts=" + casts + "; mp_need=" + need + "; mp=" + my_mp() + "; have_skill=" + have_skill(s);
    return r;
}

/**
 * Estimate base monster meat value after current meat-drop modifier.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_batbrain_monster_meat_value(monster m) {
    float base = meat_drop(m);
    float mult = max(0.0, 100.0 + meat_drop_modifier()) / 100.0;
    return base * mult;
}

/**
 * Estimate opportunity cost of running away as monster base meat plus one adventure value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_batbrain_runaway_value(monster m, int value_of_adventure) {
    return aal_batbrain_monster_meat_value(m) + max(0, value_of_adventure);
}

/**
 * Value the canonical three-adventure Beaten Up opportunity cost floor.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_batbrain_beaten_up_turn_cost(int value_of_adventure) {
    return 3 * max(0, value_of_adventure);
}

/**
 * Serialize monster element and player elemental resistances for combat planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_batbrain_element_context(monster m) {
    buffer out;
    out.append("monster=" + m + "\n");
    out.append("element=" + monster_element(m) + "\n");
    foreach e in $elements[] out.append("resist_" + e + "=" + elemental_resistance(e) + "\n");
    return out.to_string();
}

/**
 * Create a non-mutating combat action preview with HP/MP/value checks.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_batbrain_action_preview(string action_label, int expected_damage, int mp_cost_value, int value_cost) {
    agent_action_preview r;
    r.operation = action_label;
    r.meat_cost = max(0, value_cost);
    r.adventure_cost = 0;
    boolean hp_ok = aal_batbrain_hit_survival_margin(expected_damage) > 0;
    boolean mp_ok = my_mp() >= max(0, mp_cost_value);
    r.valid = hp_ok && mp_ok;
    r.reason = "hp_after=" + aal_batbrain_hit_survival_margin(expected_damage) + "; mp_after=" + (my_mp()-max(0,mp_cost_value));
    if (!r.valid) r.warnings = "survival or MP precondition failed";
    return r;
}

/**
 * Build compact BatBrain-inspired combat context for an LLM without producing/executing a macro.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/BatBrain.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_batbrain_agent_context(int value_of_adventure) {
    agent_combat_state s = aal_batbrain_combat_state();
    buffer out;
    out.append("monster=" + s.foe + "\n");
    out.append("monster_hp=" + s.hp + "\n");
    out.append("monster_attack=" + s.attack + "\n");
    out.append("monster_defense=" + s.defense + "\n");
    out.append("player_hp=" + s.player_hp + "/" + my_maxhp() + "\n");
    out.append("player_mp=" + s.player_mp + "/" + my_maxmp() + "\n");
    out.append("value_of_adventure=" + value_of_adventure + "\n");
    out.append("runaway_value=" + aal_batbrain_runaway_value(s.foe, value_of_adventure) + "\n");
    return out.to_string();
}
