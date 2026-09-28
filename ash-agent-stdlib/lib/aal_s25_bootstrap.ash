script "aal_s25_bootstrap.ash";

import <ash_agent_types.ash>;

// SOURCE 25: bootstrap.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
// Purpose: Legacy initial-ascension setup that pulls/uses starter items, visits tutorial, builds meatcar, and buys detuned radio.

/**
 * Return the legacy bootstrap's starter-item targets in deterministic order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_starter_items() {
    return "clockwork maid\nfacsimile dictionary\nletter from King Ralph XI\npork elf goodies sack\nNewbiesport tent\ncarton of astral energy drinks\nbitchin' meatcar\ndetuned radio\n";
}

/**
 * Describe inventory/storage availability of a bootstrap target.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_item_state(item it) {
    buffer out;
    out.append("item=" + it + "\n");
    out.append("inventory=" + item_amount(it) + "\n");
    out.append("storage=" + storage_amount(it) + "\n");
    out.append("available=" + available_amount(it) + "\n");
    return out.to_string();
}

/**
 * Calculate how many copies would need to be pulled from storage to meet a bootstrap requirement.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_bootstrap_pull_need(item it, int required) {
    int missing = max(0, required - item_amount(it));
    return min(missing, storage_amount(it));
}

/**
 * Preview whether a starter item is currently in inventory for use.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_bootstrap_use_preview(item it) {
    agent_action_preview r;
    r.operation = "use " + it;
    r.valid = item_amount(it) > 0;
    r.meat_cost = 0;
    r.adventure_cost = 0;
    r.reason = "inventory=" + item_amount(it);
    if (!r.valid) r.warnings = "not in inventory";
    return r;
}

/**
 * Describe whether the meatcar is owned or creatable before attempting construction.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_meatcar_state() {
    buffer out;
    out.append("available=" + available_amount($item[bitchin' meatcar]) + "\n");
    out.append("creatable=" + creatable_amount($item[bitchin' meatcar]) + "\n");
    return out.to_string();
}

/**
 * Describe detuned-radio ownership and NPC price context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_radio_state() {
    buffer out;
    out.append("available=" + available_amount($item[detuned radio]) + "\n");
    out.append("npc_price=" + npc_price($item[detuned radio]) + "\n");
    out.append("meat=" + my_meat() + "\n");
    return out.to_string();
}

/**
 * Serialize one bootstrap step and its evidence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_step_status(string step_name, boolean complete, string evidence) {
    return (complete ? "done" : "todo") + "\t" + step_name + "\t" + evidence;
}

/**
 * List obvious remaining bootstrap targets without executing them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_missing_steps() {
    buffer out;
    if (available_amount($item[clockwork maid]) == 0) out.append("clockwork-maid\n");
    if (available_amount($item[bitchin' meatcar]) == 0) out.append("meatcar\n");
    if (available_amount($item[detuned radio]) == 0) out.append("detuned-radio\n");
    if (item_amount($item[letter from King Ralph XI]) > 0) out.append("open-king-letter\n");
    if (item_amount($item[pork elf goodies sack]) > 0) out.append("open-pork-elf-sack\n");
    return out.to_string();
}

/**
 * Check whether core bootstrap travel/setup targets are already present.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_bootstrap_readiness() {
    agent_check r;
    r.subject = "bootstrap-core";
    boolean car = available_amount($item[bitchin' meatcar]) > 0;
    boolean radio = available_amount($item[detuned radio]) > 0;
    r.ok = car && radio;
    r.severity = r.ok ? "info" : "notice";
    r.reason = "meatcar=" + car + "; radio=" + radio;
    return r;
}

/**
 * Build compact initial-ascension setup context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/bootstrap.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_bootstrap_agent_context() {
    buffer out;
    out.append("meat=" + my_meat() + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    out.append("pulls=" + pulls_remaining() + "\n");
    out.append("meatcar=" + available_amount($item[bitchin' meatcar]) + "\n");
    out.append("radio=" + available_amount($item[detuned radio]) + "\n");
    out.append("maid=" + available_amount($item[clockwork maid]) + "\n");
    out.append("missing_steps=" + replace_string(aal_bootstrap_missing_steps(), "\n", ",") + "\n");
    return out.to_string();
}
