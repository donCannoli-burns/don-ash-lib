script "aal_s26_ocd.ash";

import <ash_agent_types.ash>;

// SOURCE 26: OCD Inventory Control.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
// Purpose: Malformed supplied URL resolved by GitHub code search to scripts/OCD Inventory Control.ash; inventory disposition and cleanup policy engine.

/**
 * Count copies across common personal item locations for disposition planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_owned_total(item it) {
    return item_amount(it) + closet_amount(it) + storage_amount(it) + display_amount(it) + shop_amount(it) + equipped_amount(it);
}

/**
 * Compute copies above a configured keep quantity.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_excess_quantity(item it, int keep_amount) {
    return max(0, aal_ocd_owned_total(it) - max(0, keep_amount));
}

/**
 * Validate a disposition action/keep quantity without performing inventory changes.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ocd_policy_validate(string action, int keep_amount) {
    agent_check r;
    r.subject = action;
    string a = to_lower_case(action);
    boolean known = a == "keep" || a == "closet" || a == "display" || a == "autosell" || a == "mallsell" || a == "use" || a == "pulverize" || a == "gift";
    r.ok = known && keep_amount >= 0;
    r.severity = r.ok ? "info" : "error";
    r.reason = "known_action=" + known + "; keep=" + keep_amount;
    return r;
}

/**
 * Preview quantity and action for an OCD-style inventory rule.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_ocd_disposition_preview(item it, string action, int keep_amount) {
    agent_action_preview r;
    int excess = aal_ocd_excess_quantity(it, keep_amount);
    r.operation = action + " " + excess + " " + it;
    r.valid = excess > 0 && aal_ocd_policy_validate(action, keep_amount).ok;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = "owned=" + aal_ocd_owned_total(it) + "; keep=" + keep_amount + "; excess=" + excess;
    if (!r.valid) r.warnings = "nothing to dispose or invalid policy";
    return r;
}

/**
 * Estimate gross liquidation value of an OCD rule without executing it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_liquidation_value(item it, string action, int keep_amount) {
    int qty = aal_ocd_excess_quantity(it, keep_amount);
    string a = to_lower_case(action);
    if (qty <= 0) return 0;
    if (a == "autosell") return qty * max(0, autosell_price(it));
    if (a == "mallsell") return qty * max(0, mall_price(it));
    return 0;
}

/**
 * Detect conflicting duplicate disposition rules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_ocd_rule_conflict(string action_a, int keep_a, string action_b, int keep_b) {
    agent_check r;
    r.subject = "ocd-rule-conflict";
    r.ok = to_lower_case(action_a) == to_lower_case(action_b) && keep_a == keep_b;
    r.severity = r.ok ? "info" : "warning";
    r.reason = r.ok ? "rules equivalent" : "rules disagree";
    return r;
}

/**
 * List owned items lacking a caller-provided OCD policy map.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ocd_missing_rule_context(item[int] inventory_items, boolean[item] ruled_items, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in inventory_items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none] || aal_ocd_owned_total(it) <= 0 || ruled_items contains it) continue;
        out.append(to_int(it) + "\t" + it + "\t" + aal_ocd_owned_total(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Count total copies above configured keep amounts across a caller item list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_ocd_cleanup_count(item[int] items, int[item] keep_amounts) {
    int total;
    foreach i, it in items {
        int keep;
        if (keep_amounts contains it) keep = keep_amounts[it];
        total = total + aal_ocd_excess_quantity(it, keep);
    }
    return total;
}

/**
 * Serialize rule plus current ownership/excess as TSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ocd_rule_line(item it, string action, int keep_amount) {
    return to_int(it) + "\t" + it + "\t" + action + "\t" + keep_amount + "\t" + aal_ocd_owned_total(it) + "\t" + aal_ocd_excess_quantity(it, keep_amount);
}

/**
 * Build bounded disposition context for policy review before execution.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/OCD%20Inventory%
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_ocd_agent_context(item[int] items, string[item] actions, int[item] keep_amounts, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in items {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (it == $item[none]) continue;
        string action = actions contains it ? actions[it] : "unruled";
        int keep = keep_amounts contains it ? keep_amounts[it] : 0;
        int owned = aal_ocd_owned_total(it);
        if (owned <= 0) continue;
        out.append("item=" + it + ";action=" + action + ";keep=" + keep + ";owned=" + owned + ";excess=" + max(0,owned-keep) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
