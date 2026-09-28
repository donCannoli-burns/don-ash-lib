script "aal_s23_rollover.ash";

import <ash_agent_types.ash>;

// SOURCE 23: rollover.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
// Purpose: Rollover optimizer/reminder checking rollover gear, unused daily resources, organ capacity, wand state, VIP actions, and MP waste.

/**
 * Serialize unused organ capacity before rollover.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_rollover_organ_gaps() {
    buffer out;
    out.append("fullness_gap=" + max(0, fullness_limit() - my_fullness()) + "\n");
    out.append("inebriety_gap=" + max(0, inebriety_limit() - my_inebriety()) + "\n");
    out.append("spleen_gap=" + max(0, spleen_limit() - my_spleen_use()) + "\n");
    return out.to_string();
}

/**
 * Estimate rollover MP that would exceed current maximum MP.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_rollover_mp_waste(int expected_rollover_mp) {
    return max(0, my_mp() + max(0, expected_rollover_mp) - my_maxmp());
}

/**
 * Expose remaining still uses as a rollover resource.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_rollover_still_state() {
    agent_resource_state r;
    r.name = "stills";
    r.used = 0;
    r.limit_value = stills_available();
    r.remaining = stills_available();
    r.available = stills_available() > 0;
    return r;
}

/**
 * Expose remaining pulls as rollover context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_rollover_pull_state() {
    agent_resource_state r;
    r.name = "pulls";
    r.used = 0;
    r.limit_value = max(0, pulls_remaining());
    r.remaining = max(0, pulls_remaining());
    r.available = pulls_remaining() > 0;
    return r;
}

/**
 * Return the first known wand item currently available.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns item.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
item aal_rollover_wand_candidate() {
    for id from 1268 to 1272 {
        item it = to_item(id);
        if (available_amount(it) > 0) return it;
    }
    return $item[none];
}

/**
 * Normalize a rollover-relevant daily preference into remaining-use state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_rollover_daily_resource(string label, string used_property, int limit_value) {
    agent_resource_state r;
    r.name = label;
    r.used = get_property(used_property).to_int();
    r.limit_value = max(0, limit_value);
    r.remaining = max(0, r.limit_value - r.used);
    r.available = r.remaining > 0;
    return r;
}

/**
 * Compute a simple reminder pressure score from organ gaps, MP waste, stills, and pulls.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_rollover_readiness_score(int expected_rollover_mp) {
    int score;
    if (my_fullness() < fullness_limit()) score = score + 1;
    if (my_inebriety() < inebriety_limit()) score = score + 1;
    if (my_spleen_use() < spleen_limit()) score = score + 1;
    if (aal_rollover_mp_waste(expected_rollover_mp) > 0) score = score + 1;
    if (stills_available() > 0) score = score + 1;
    if (pulls_remaining() > 0) score = score + 1;
    return score;
}

/**
 * Build deterministic rollover warnings without changing equipment/resources.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_rollover_warning_lines(int expected_rollover_mp) {
    buffer out;
    if (my_fullness() < fullness_limit()) out.append("unused-fullness\n");
    if (my_inebriety() < inebriety_limit()) out.append("unused-liver\n");
    if (my_spleen_use() < spleen_limit()) out.append("unused-spleen\n");
    if (aal_rollover_mp_waste(expected_rollover_mp) > 0) out.append("rollover-mp-waste=" + aal_rollover_mp_waste(expected_rollover_mp) + "\n");
    if (stills_available() > 0) out.append("stills-remaining=" + stills_available() + "\n");
    if (pulls_remaining() > 0) out.append("pulls-remaining=" + pulls_remaining() + "\n");
    return out.to_string();
}

/**
 * Return ready only when the source-inspired warning set is empty.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_rollover_ready_check(int expected_rollover_mp) {
    agent_check r;
    r.subject = "rollover";
    string warnings = aal_rollover_warning_lines(expected_rollover_mp);
    r.ok = warnings == "";
    r.severity = r.ok ? "info" : "notice";
    r.reason = r.ok ? "no modeled rollover warnings" : warnings;
    return r;
}

/**
 * Build compact rollover state for an agent/user reminder surface.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/rollover.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_rollover_agent_context(int expected_rollover_mp) {
    buffer out;
    out.append("adventures=" + my_adventures() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    out.append(aal_rollover_organ_gaps());
    out.append("expected_rollover_mp=" + expected_rollover_mp + "\n");
    out.append("mp_waste=" + aal_rollover_mp_waste(expected_rollover_mp) + "\n");
    out.append("stills=" + stills_available() + "\n");
    out.append("pulls=" + pulls_remaining() + "\n");
    return out.to_string();
}
