script "aal_s22_networth.ash";

import <ash_agent_types.ash>;

// SOURCE 22: networth.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
// Purpose: Legacy account valuation using historical/mall/autosell pricing and item-location totals.

/**
 * Modernize networth.ash pricing: autosell for untradeable, fresh historical price when sane, otherwise mall.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_unit_price(item it, int max_historical_age, int historical_cap) {
    if (it == $item[none]) return 0;
    if (!is_tradeable(it)) return max(0, autosell_price(it));
    int hist = historical_price(it);
    if (hist > 0 && historical_age(it) <= max_historical_age && (historical_cap <= 0 || hist <= historical_cap)) return hist;
    int mall = mall_price(it);
    if (mall > 0) return mall;
    return max(0, autosell_price(it));
}

/**
 * Count relevant item copies for a net-worth calculation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_quantity(item it, boolean include_storage) {
    int qty = available_amount(it) + shop_amount(it) + display_amount(it);
    if (include_storage) qty = qty + storage_amount(it);
    return qty;
}

/**
 * Value one item's included quantity with the normalized unit-price heuristic.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_item_value(item it, boolean include_storage, int max_historical_age, int historical_cap) {
    return aal_networth_quantity(it, include_storage) * aal_networth_unit_price(it, max_historical_age, historical_cap);
}

/**
 * Value one item in one named account location for explainable net-worth decomposition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_location_value(item it, string location_name, int max_historical_age, int historical_cap) {
    string loc = to_lower_case(location_name);
    int qty;
    if (loc == "inventory") qty = item_amount(it);
    else if (loc == "closet") qty = closet_amount(it);
    else if (loc == "storage") qty = storage_amount(it);
    else if (loc == "display") qty = display_amount(it);
    else if (loc == "shop") qty = shop_amount(it);
    else if (loc == "equipped") qty = equipped_amount(it);
    else return 0;
    return qty * aal_networth_unit_price(it, max_historical_age, historical_cap);
}

/**
 * Estimate total item value across the source-inspired account locations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_inventory_value(boolean include_storage, int max_historical_age, int historical_cap) {
    int total;
    foreach it in $items[] {
        int qty = aal_networth_quantity(it, include_storage);
        if (qty <= 0) continue;
        total = total + qty * aal_networth_unit_price(it, max_historical_age, historical_cap);
    }
    return total;
}

/**
 * Estimate liquid meat plus item value.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_total(boolean include_storage, int max_historical_age, int historical_cap) {
    return my_meat() + my_closet_meat() + my_storage_meat() + aal_networth_inventory_value(include_storage, max_historical_age, historical_cap);
}

/**
 * Serialize one item's net-worth contribution.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_networth_item_line(item it, boolean include_storage, int max_historical_age, int historical_cap) {
    int qty = aal_networth_quantity(it, include_storage);
    int unit = aal_networth_unit_price(it, max_historical_age, historical_cap);
    return to_int(it) + "\t" + it + "\t" + qty + "\t" + unit + "\t" + (qty * unit);
}

/**
 * Return a conservative non-negative value floor from autosell/NPC pricing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_networth_value_floor(item it) {
    return max(max(0, autosell_price(it)), max(0, npc_price(it)));
}

/**
 * Capture a net-worth snapshot suitable for later delta comparison.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_value_snapshot.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_value_snapshot aal_networth_snapshot(boolean include_storage, int max_historical_age, int historical_cap, int stamp) {
    agent_value_snapshot r;
    r.liquid_meat = my_meat() + my_closet_meat() + my_storage_meat();
    r.item_value = aal_networth_inventory_value(include_storage, max_historical_age, historical_cap);
    r.total_value = r.liquid_meat + r.item_value;
    r.turns = total_turns_played();
    r.stamp = stamp;
    return r;
}

/**
 * Build compact valuation policy/current-total context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/networth.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_networth_agent_context(boolean include_storage, int max_historical_age, int historical_cap) {
    buffer out;
    out.append("include_storage=" + include_storage + "\n");
    out.append("max_historical_age=" + max_historical_age + "\n");
    out.append("historical_cap=" + historical_cap + "\n");
    out.append("liquid_meat=" + (my_meat() + my_closet_meat() + my_storage_meat()) + "\n");
    out.append("item_value=" + aal_networth_inventory_value(include_storage, max_historical_age, historical_cap) + "\n");
    out.append("total=" + aal_networth_total(include_storage, max_historical_age, historical_cap) + "\n");
    return out.to_string();
}
