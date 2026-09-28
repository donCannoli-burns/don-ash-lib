script "aal_s33_smash.ash";

import <ash_agent_types.ash>;

// SOURCE 33: SmashLib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
// Purpose: Pulverization library modeling smashability, malus upgrades, elemental outputs, tiers, and expected yields.

/**
 * Check whether an item occupies an equipment slot commonly eligible for pulverization.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_smash_slot_candidate(item it) {
    slot s = to_slot(it);
    return $slots[hat,weapon,off-hand,shirt,pants,acc1,acc2,acc3] contains s;
}

/**
 * Map equipment power to legacy pulverization power bands.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_power_band(item it) {
    int p = get_power(it);
    if (p <= 0) return "unknown";
    if (p <= 35) return "1P";
    if (p <= 55) return "2P";
    if (p <= 75) return "3P";
    if (p <= 95) return "1N";
    if (p <= 115) return "2N";
    if (p <= 135) return "3N";
    if (p <= 155) return "1W";
    if (p <= 175) return "2W";
    return "3W";
}

/**
 * Summarize elemental damage/resistance signals relevant to pulverization output.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_element_profile(item it) {
    buffer out;
    foreach e in $elements[] {
        float damage = numeric_modifier(it, e + " Damage") + numeric_modifier(it, e + " Spell Damage");
        float resist = numeric_modifier(it, e + " Resistance");
        if (damage != 0.0 || resist != 0.0) out.append(e + "\tdamage=" + damage + "\tresistance=" + resist + "\n");
    }
    return out.to_string();
}

/**
 * Compute the immediate economic floor an item should beat before smashing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_smash_value_floor(item it) {
    int floor_value = max(0, autosell_price(it));
    int mall = mall_price(it);
    if (mall > 0) floor_value = max(floor_value, mall);
    return floor_value;
}

/**
 * Validate an item as an ordinary equipment pulverization candidate without smashing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_smash_candidate_check(item it) {
    agent_check r;
    r.subject = it;
    boolean slot_ok = aal_smash_slot_candidate(it);
    boolean owned = item_amount(it) > 0;
    r.ok = slot_ok && owned;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "equipment_slot=" + slot_ok + "; inventory=" + item_amount(it) + "; power=" + get_power(it);
    return r;
}

/**
 * Normalize power band to powder/nugget/wad family.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_expected_material_tier(item it) {
    string band = aal_smash_power_band(it);
    if (contains_text(band, "P")) return "powder";
    if (contains_text(band, "N")) return "nugget";
    if (contains_text(band, "W")) return "wad";
    return "unknown";
}

/**
 * Compare estimated smash-yield value with keeping/selling value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_smash_loss_risk(item it, int estimated_yield_value) {
    agent_check r;
    r.subject = it;
    int floor_value = aal_smash_value_floor(it);
    r.ok = estimated_yield_value >= floor_value;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "yield_estimate=" + estimated_yield_value + "; item_value_floor=" + floor_value;
    return r;
}

/**
 * List owned ordinary equipment at/above a power threshold for later smash analysis.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_inventory_candidates(int min_power, int max_entries) {
    buffer out;
    int emitted;
    foreach it in $items[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (item_amount(it) <= 0 || !aal_smash_slot_candidate(it) || get_power(it) < min_power) continue;
        out.append(to_int(it) + "\t" + it + "\t" + get_power(it) + "\t" + aal_smash_power_band(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize one smash candidate with economic risk context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_plan_line(item it, int estimated_yield_value) {
    return it + "\tpower=" + get_power(it) + "\tband=" + aal_smash_power_band(it) + "\tfloor=" + aal_smash_value_floor(it) + "\tyield_estimate=" + estimated_yield_value;
}

/**
 * Build compact pulverization context without loading old data maps or smashing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/SmashLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_smash_agent_context(item it) {
    buffer out;
    out.append("item=" + it + "\n");
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("slot=" + to_slot(it) + "\n");
    out.append("power=" + get_power(it) + "\n");
    out.append("band=" + aal_smash_power_band(it) + "\n");
    out.append("material_tier=" + aal_smash_expected_material_tier(it) + "\n");
    out.append("value_floor=" + aal_smash_value_floor(it) + "\n");
    return out.to_string();
}
