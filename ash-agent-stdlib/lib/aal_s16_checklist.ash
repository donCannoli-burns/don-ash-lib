script "aal_s16_checklist.ash";

import <ash_agent_types.ash>;

// SOURCE 16: pChecklist
// https://github.com/Prusias-kol/pChecklist
// Purpose: File-backed item checklists supporting ranges/custom ID lists and ownership checks across multiple item locations.

/**
 * Count an item across inventory, closet, display, equipment, shop, and storage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_checklist_total_owned(item it) {
    return item_amount(it) + closet_amount(it) + display_amount(it) + equipped_amount(it) + shop_amount(it) + storage_amount(it);
}

/**
 * Capture checklist ownership state across storage locations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_item_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_item_state aal_checklist_item_state(item it) {
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
 * Check whether cross-location ownership satisfies a required checklist quantity.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_checklist_item_check(item it, int required) {
    agent_check r;
    r.subject = it;
    int have = aal_checklist_total_owned(it);
    r.ok = have >= max(0, required);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "have=" + have + "; required=" + required;
    return r;
}

/**
 * List missing valid items from an inclusive item-ID range.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_range_missing(int first_id, int last_id, int max_entries) {
    buffer out;
    int emitted;
    for id from first_id to last_id {
        if (max_entries > 0 && emitted >= max_entries) break;
        item it = to_item(id);
        if (it == $item[none]) continue;
        if (aal_checklist_total_owned(it) > 0) continue;
        out.append(id + "\t" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * List missing items from a caller-defined checklist.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_custom_missing(item[int] items, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none] || aal_checklist_total_owned(it) > 0) continue;
        out.append(to_int(it) + "\t" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Calculate fraction of valid checklist items owned at least once.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_checklist_completion_ratio(item[int] items) {
    int total;
    int have;
    foreach i, it in items {
        if (it == $item[none]) continue;
        total = total + 1;
        if (aal_checklist_total_owned(it) > 0) have = have + 1;
    }
    if (total == 0) return 1.0;
    return to_float(have) / total;
}

/**
 * Report duplicate item IDs in a custom checklist definition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_duplicate_ids(int[int] ids) {
    int[int] counts;
    foreach i, id in ids counts[id] = counts[id] + 1;
    buffer out;
    foreach id, n in counts if (n > 1) out.append(id + "\t" + n + "\n");
    return out.to_string();
}

/**
 * Serialize checklist item status in deterministic input order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_status_tsv(item[int] items, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none]) continue;
        out.append(to_int(it) + "\t" + it + "\t" + aal_checklist_total_owned(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Estimate mall acquisition value of currently missing tradeable checklist items without buying them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_checklist_missing_value(item[int] items) {
    int total;
    foreach i, it in items {
        if (it == $item[none] || aal_checklist_total_owned(it) > 0 || !is_tradeable(it)) continue;
        int p = mall_price(it);
        if (p > 0) total = total + p;
    }
    return total;
}

/**
 * Build compact checklist completion/missing context for an agent.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pChecklist
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_checklist_agent_context(string checklist_name, item[int] items, int max_entries) {
    buffer out;
    out.append("checklist=" + checklist_name + "\n");
    out.append("completion_ratio=" + aal_checklist_completion_ratio(items) + "\n");
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none] || aal_checklist_total_owned(it) > 0) continue;
        out.append("missing=" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
