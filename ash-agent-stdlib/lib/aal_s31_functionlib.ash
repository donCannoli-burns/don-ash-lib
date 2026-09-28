script "aal_s31_functionlib.ash";

import <ash_agent_types.ash>;

// SOURCE 31: FunctionLib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
// Purpose: Legacy general utility library for ownership, acquisition/use, stash/shop, recovery, equipment, familiars, still, and resistance.

/**
 * Expose where an item is currently held instead of collapsing ownership to a boolean.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_ownership_locations(item it) {
    buffer out;
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("closet=" + closet_amount(it) + "\n");
    out.append("storage=" + storage_amount(it) + "\n");
    out.append("stash=" + stash_amount(it) + "\n");
    out.append("equipped=" + equipped_amount(it) + "\n");
    return out.to_string();
}

/**
 * Compute inventory shortfall and nearby source counts without acquiring anything.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_acquisition_gap(item it, int desired) {
    buffer out;
    int gap = max(0, desired - item_amount(it));
    out.append("desired=" + desired + "\n");
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("gap=" + gap + "\n");
    out.append("closet=" + closet_amount(it) + "\n");
    out.append("storage=" + storage_amount(it) + "\n");
    out.append("stash=" + stash_amount(it) + "\n");
    out.append("mall_price=" + mall_price(it) + "\n");
    return out.to_string();
}

/**
 * Describe likely consumption channel from native item metadata.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_consumption_kind(item it) {
    string t = to_lower_case(item_type(it));
    if (contains_text(t, "food")) return "eat";
    if (contains_text(t, "booze") || contains_text(t, "drink")) return "drink";
    if (contains_text(t, "spleen")) return "spleen";
    return "use-or-other";
}

/**
 * Measure familiar base-weight gap before any training action.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_range_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_functionlib_familiar_training_gap(familiar fam, int target_weight) {
    agent_range_state r;
    r.minimum = 0;
    r.maximum = max(0, target_weight);
    r.current = have_familiar(fam) ? familiar_weight(fam) : 0;
    r.remaining = max(0, r.maximum - r.current);
    r.satisfied = have_familiar(fam) && r.current >= r.maximum;
    return r;
}

/**
 * Check possession/equipability and current equip state without equipping.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_functionlib_equipment_preflight(item it) {
    agent_check r;
    r.subject = it;
    boolean owned = available_amount(it) > 0;
    boolean equipable = can_equip(it);
    r.ok = owned && equipable;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "owned=" + owned + "; can_equip=" + equipable + "; equipped=" + have_equipped(it);
    return r;
}

/**
 * Preview a stash take/put operation and available quantity without moving items.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_functionlib_stash_transfer_preview(string direction, item it, int quantity) {
    agent_action_preview r;
    string d = to_lower_case(direction);
    r.operation = d + " " + quantity + " " + it;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    if (d == "take") r.valid = quantity > 0 && stash_amount(it) >= quantity;
    else if (d == "put") r.valid = quantity > 0 && item_amount(it) >= quantity;
    else r.valid = false;
    r.reason = "inventory=" + item_amount(it) + "; stash=" + stash_amount(it);
    if (!r.valid) r.warnings = "invalid direction or insufficient quantity";
    return r;
}

/**
 * Measure HP recovery gap and Beaten Up state without recovering.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_recovery_gap(int target_hp) {
    buffer out;
    out.append("target=" + target_hp + "\n");
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("gap=" + max(0, min(target_hp, my_maxhp()) - my_hp()) + "\n");
    out.append("beaten_up=" + have_effect($effect[Beaten Up]) + "\n");
    return out.to_string();
}

/**
 * Check ownership and MP for repeated skill use without casting.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_functionlib_skill_preflight(skill s, int casts) {
    agent_check r;
    r.subject = s;
    int need = max(0, casts) * mp_cost(s);
    r.ok = casts > 0 && have_skill(s) && my_mp() >= need;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "casts=" + casts + "; mp_need=" + need + "; mp=" + my_mp();
    return r;
}

/**
 * Serialize all five zap-wand IDs currently owned/available.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_wand_inventory() {
    buffer out;
    for id from 1268 to 1272 {
        item it = to_item(id);
        int qty = available_amount(it);
        if (qty > 0) out.append(id + "\t" + it + "\t" + qty + "\n");
    }
    return out.to_string();
}

/**
 * Build compact utility context combining ownership, familiar, and skill readiness.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/FunctionLib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_functionlib_agent_context(item it, familiar fam, skill s) {
    buffer out;
    out.append("item=" + it + ";available=" + available_amount(it) + "\n");
    out.append("familiar=" + fam + ";owned=" + have_familiar(fam) + ";weight=" + (have_familiar(fam) ? familiar_weight(fam) : 0) + "\n");
    out.append("skill=" + s + ";owned=" + have_skill(s) + ";mp_cost=" + mp_cost(s) + "\n");
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    return out.to_string();
}
