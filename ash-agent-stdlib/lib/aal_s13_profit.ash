script "aal_s13_profit.ash";

import <ash_agent_types.ash>;

// SOURCE 13: ProfitTracking.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
// Purpose: Inventory/meat/net-worth checkpoint logging, accountval parsing, item delta valuation, and profit-per-adventure comparison.

/**
 * Return liquid meat across inventory, closet, and storage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_profit_liquid_meat() {
    return my_meat() + my_closet_meat() + my_storage_meat();
}

/**
 * Capture an item's quantities across major account locations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_item_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_item_state aal_profit_item_state(item it) {
    agent_item_state r;
    r.thing = it;
    r.inventory = item_amount(it);
    r.closet = closet_amount(it);
    r.storage = storage_amount(it);
    r.display = display_amount(it);
    r.shop = shop_amount(it);
    r.equipped = equipped_amount(it);
    r.total = r.inventory + r.closet + r.storage + r.display + r.shop + r.equipped;
    return r;
}

/**
 * Estimate an item value with fresh historical price fallback to mall/autosell.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_profit_price_estimate(item it, int max_historical_age) {
    if (it == $item[none]) return 0;
    if (!is_tradeable(it)) return max(0, autosell_price(it));
    int hist = historical_price(it);
    if (hist > 0 && historical_age(it) <= max_historical_age) return hist;
    int mall = mall_price(it);
    if (mall > 0) return mall;
    return max(0, autosell_price(it));
}

/**
 * Estimate total value of currently held inventory/closet/storage/display/shop/equipped items.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_profit_inventory_value(int max_historical_age) {
    int total;
    foreach it in $items[] {
        int qty = item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
        if (qty <= 0) continue;
        total = total + qty * aal_profit_price_estimate(it, max_historical_age);
    }
    return total;
}

/**
 * Capture liquid meat, item value, total value, turns and caller timestamp.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_value_snapshot.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_value_snapshot aal_profit_snapshot(int stamp, int max_historical_age) {
    agent_value_snapshot r;
    r.liquid_meat = aal_profit_liquid_meat();
    r.item_value = aal_profit_inventory_value(max_historical_age);
    r.total_value = r.liquid_meat + r.item_value;
    r.turns = total_turns_played();
    r.stamp = stamp;
    return r;
}

/**
 * Serialize value/turn/time changes between two profit snapshots.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_profit_snapshot_delta(agent_value_snapshot before, agent_value_snapshot after) {
    buffer out;
    out.append("liquid_meat_delta=" + (after.liquid_meat - before.liquid_meat) + "\n");
    out.append("item_value_delta=" + (after.item_value - before.item_value) + "\n");
    out.append("total_value_delta=" + (after.total_value - before.total_value) + "\n");
    out.append("turn_delta=" + (after.turns - before.turns) + "\n");
    out.append("time_delta=" + (after.stamp - before.stamp) + "\n");
    return out.to_string();
}

/**
 * Compute total-value delta per turn.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_profit_value_per_turn(agent_value_snapshot before, agent_value_snapshot after) {
    int turns = after.turns - before.turns;
    if (turns <= 0) return 0.0;
    return to_float(after.total_value - before.total_value) / turns;
}

/**
 * Compare current cross-location item total against an earlier captured total.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_delta.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_delta aal_profit_item_delta(item it, int before_total) {
    agent_delta d;
    d.label = it;
    d.before_value = before_total;
    agent_item_state s = aal_profit_item_state(it);
    d.after_value = s.total;
    d.difference = d.after_value - d.before_value;
    return d;
}

/**
 * Emit bounded valuable-item context without logging to disk.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_profit_top_inventory_context(int min_unit_value, int max_entries, int max_historical_age) {
    buffer out;
    int emitted;
    foreach it in $items[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        int qty = item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
        if (qty <= 0) continue;
        int unit = aal_profit_price_estimate(it, max_historical_age);
        if (unit < min_unit_value) continue;
        out.append(to_int(it) + "\t" + it + "\t" + qty + "\t" + unit + "\t" + (qty * unit) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize a profit snapshot as compact key=value state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/ProfitTracking.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_profit_agent_context(agent_value_snapshot snap) {
    buffer out;
    out.append("liquid_meat=" + snap.liquid_meat + "\n");
    out.append("item_value=" + snap.item_value + "\n");
    out.append("total_value=" + snap.total_value + "\n");
    out.append("turns=" + snap.turns + "\n");
    out.append("stamp=" + snap.stamp + "\n");
    return out.to_string();
}
