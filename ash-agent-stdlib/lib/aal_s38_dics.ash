script "aal_s38_dics.ash";

import <ash_agent_types.ash>;

// SOURCE 38: DicsLibrary.ash
// https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
// Purpose: Large shared library with typed property reads, item valuation, stock-up, ownership, healing, songs, workshed/garden and utility logic.

/**
 * Read an integer preference with explicit default for missing/empty values.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_pref_int(string property_name, int default_value) {
    string raw = get_property(property_name);
    if (raw == "") return default_value;
    return raw.to_int();
}

/**
 * Serialize a bounded caller-selected preference set as deterministic key=value context.
 *
 * Parameters: property_names: caller-selected preference names; max_entries: output cap, <=0 means no cap.
 * Return: Stable key=value lines ordered by map key.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: line := property=value
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_pref_snapshot(string[int] property_names, int max_entries) {
    boolean[string] selected;
    foreach i, name in property_names
        if (name != "") selected[name] = true;
    buffer out;
    int emitted;
    foreach name in selected {
        if (max_entries > 0 && emitted >= max_entries) break;
        out.append(name + "=" + get_property(name) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Count item ownership across inventory/equipment/closet/storage/display/shop and optionally stash.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_total_amount(item it, boolean include_stash) {
    int total = item_amount(it) + equipped_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it);
    if (include_stash) total = total + stash_amount(it);
    return total;
}

/**
 * Classify price confidence from tradeability, historical age, historical price, and mall fallback.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_market_confidence(item it, int fresh_days) {
    if (!is_tradeable(it)) return "nontradeable";
    if (historical_price(it) > 0 && historical_age(it) <= fresh_days) return "fresh-historical";
    if (mall_price(it) > 0) return "mall";
    if (historical_price(it) > 0) return "stale-historical";
    return "unknown";
}

/**
 * Estimate item value with a configurable sell-realization multiplier.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_value_estimate(item it, int fresh_days, float multiplier) {
    int base;
    if (!is_tradeable(it)) base = max(0, max(npc_price(it), autosell_price(it)));
    else if (historical_price(it) > 0 && historical_age(it) <= fresh_days) base = historical_price(it);
    else {
        base = mall_price(it);
        if (base <= 0) base = historical_price(it);
    }
    return max(0, to_int(base * max(0.0, multiplier)));
}

/**
 * Calculate reorder quantity to reach a target personal stock.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_dics_stock_reorder(item it, int target_amount) {
    return max(0, target_amount - item_amount(it));
}

/**
 * Expose HP/MP recovery targets and current state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_recovery_state() {
    buffer out;
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    out.append("hp_recovery=" + get_property("hpAutoRecovery") + "\n");
    out.append("hp_target=" + get_property("hpAutoRecoveryTarget") + "\n");
    out.append("mp_recovery=" + get_property("mpAutoRecovery") + "\n");
    out.append("mp_target=" + get_property("mpAutoRecoveryTarget") + "\n");
    return out.to_string();
}

/**
 * Summarize active Accordion Thief song effects and durations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_song_state() {
    buffer out;
    int[effect] active = my_effects();
    foreach e, turns in active {
        skill s = to_skill(e);
        if (s == $skill[none] || s.class != $class[Accordion Thief] || !s.buff) continue;
        out.append(e + "\t" + turns + "\n");
    }
    return out.to_string();
}

/**
 * Build compact ownership/valuation context for one item.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_item_context(item it, int fresh_days, float multiplier) {
    buffer out;
    out.append("item=" + it + "\n");
    out.append("total=" + aal_dics_total_amount(it, false) + "\n");
    out.append("stash=" + stash_amount(it) + "\n");
    out.append("confidence=" + aal_dics_market_confidence(it, fresh_days) + "\n");
    out.append("value=" + aal_dics_value_estimate(it, fresh_days, multiplier) + "\n");
    return out.to_string();
}

/**
 * Build bounded item/value context inspired by DicsLibrary's broad utility role.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pTrack/blob/main/kolmafia/scripts/ptrackSuite/DicsLibrary.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_dics_agent_context(item[int] items, int max_entries, int fresh_days, float multiplier) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none]) continue;
        out.append(it + "\ttotal=" + aal_dics_total_amount(it,false) + "\tvalue=" + aal_dics_value_estimate(it,fresh_days,multiplier) + "\tconfidence=" + aal_dics_market_confidence(it,fresh_days) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
