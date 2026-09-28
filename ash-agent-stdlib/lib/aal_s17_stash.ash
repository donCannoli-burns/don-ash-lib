script "aal_s17_stash.ash";

import <ash_agent_types.ash>;

// SOURCE 17: pStash
// https://github.com/Prusias-kol/pStash
// Purpose: Clan stash baseline, expected-vs-actual verification, personal-overlap protection, return workflows, and activity logging.

/**
 * Capture expected versus current stash quantity with personal-overlap marker.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_stash_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_stash_state aal_stash_state(item it, int expected, boolean personal_overlap) {
    agent_stash_state r;
    r.thing = it;
    r.expected = max(0, expected);
    r.actual = stash_amount(it);
    r.difference = r.actual - r.expected;
    r.personal_overlap = personal_overlap;
    return r;
}

/**
 * Return number missing from stash relative to a baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_stash_deficit(item it, int expected) {
    return max(0, expected - stash_amount(it));
}

/**
 * Return surplus above a recorded stash baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_stash_surplus(item it, int expected) {
    return max(0, stash_amount(it) - expected);
}

/**
 * Validate a single stash baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_stash_verify(item it, int expected) {
    agent_check r;
    r.subject = it;
    int actual = stash_amount(it);
    r.ok = actual >= expected;
    r.severity = r.ok ? (actual == expected ? "info" : "notice") : "warning";
    r.reason = "actual=" + actual + "; expected=" + expected;
    return r;
}

/**
 * Preview how many inventory copies could be returned without crossing a personal-ownership protection floor.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_stash_return_preview(item it, int expected, int personal_owned) {
    agent_action_preview r;
    r.operation = "stash return " + it;
    int deficit = max(0, expected - stash_amount(it));
    int spare = max(0, item_amount(it) - personal_owned);
    int qty = min(deficit, spare);
    r.valid = qty > 0;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = "deficit=" + deficit + "; inventory_spare=" + spare + "; returnable=" + qty;
    if (!r.valid) r.warnings = "no safe return quantity";
    return r;
}

/**
 * Serialize expected/actual/delta for a tracked stash map.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_stash_map_summary(int[item] expected) {
    buffer out;
    foreach it, qty in expected {
        int actual = stash_amount(it);
        out.append(to_int(it) + "\t" + it + "\t" + qty + "\t" + actual + "\t" + (actual - qty) + "\n");
    }
    return out.to_string();
}

/**
 * Count tracked stash entries below baseline.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_stash_missing_count(int[item] expected) {
    int n;
    foreach it, qty in expected if (stash_amount(it) < qty) n = n + 1;
    return n;
}

/**
 * Check whether current personal ownership is at/below a recorded personal floor.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_stash_personal_overlap(item it, int personal_baseline) {
    agent_check r;
    r.subject = it;
    int personal_now = item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
    r.ok = personal_now >= personal_baseline;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "personal_now=" + personal_now + "; baseline=" + personal_baseline;
    return r;
}

/**
 * Build bounded reconciliation recommendations without moving stash items.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_stash_reconcile_plan(int[item] expected, int[item] personal_baseline, int max_entries) {
    buffer out;
    int emitted;
    foreach it, qty in expected {
        if (max_entries > 0 && emitted >= max_entries) break;
        int deficit = max(0, qty - stash_amount(it));
        if (deficit <= 0) continue;
        int personal = 0;
        if (personal_baseline contains it) personal = personal_baseline[it];
        int spare = max(0, item_amount(it) - personal);
        out.append(it + "\tdeficit=" + deficit + "\tinventory_spare=" + spare + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Build compact stash health context centered on deficits/surpluses.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pStash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_stash_agent_context(int[item] expected, int max_entries) {
    buffer out;
    int emitted;
    foreach it, qty in expected {
        if (max_entries > 0 && emitted >= max_entries) break;
        int actual = stash_amount(it);
        if (actual == qty) continue;
        out.append("item=" + it + ";expected=" + qty + ";actual=" + actual + ";delta=" + (actual-qty) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
