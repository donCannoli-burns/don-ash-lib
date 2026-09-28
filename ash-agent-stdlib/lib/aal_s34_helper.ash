script "aal_s34_helper.ash";

import <ash_agent_types.ash>;

// SOURCE 34: helper.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
// Purpose: Legacy ascension adviser/helpers for pulls, fax/yellow-ray opportunities, access checks, consumables, weapons, and familiar suggestions.

/**
 * Summarize class-relevant Epic/Legendary/Ultimate weapon ownership without changing equipment.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_epic_weapon_state() {
    buffer out;
    out.append("class=" + my_class() + "\n");
    out.append("prime_stat=" + my_primestat() + "\n");
    foreach it in $items[Bjorn's Hammer,Mace of the Tortoise,Rock and Roll Legend,Disco Banjo,Pasta Spoon of Peril,5-Alarm Saucepan,Hammer of Smiting,Chelonian Morningstar,Shagadelic Disco Banjo,Squeezebox of the Ages,Greek Pasta Spoon of Peril,17-alarm Saucepan] {
        if (available_amount(it) > 0) out.append("owned=" + it + "\n");
    }
    return out.to_string();
}

/**
 * Return compact zap-wand ownership state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_wand_state() {
    buffer out;
    for id from 1268 to 1272 {
        item it = to_item(id);
        if (available_amount(it) > 0) out.append(it + "=" + available_amount(it) + "\n");
    }
    return out.to_string();
}

/**
 * Score a potential pull by ownership gap times caller strategic weight.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_helper_pull_need_score(item it, int target_quantity, int strategic_weight) {
    int gap = max(0, target_quantity - available_amount(it));
    return gap * max(0, strategic_weight);
}

/**
 * Check broad yellow-ray readiness signals used by legacy advisories.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_helper_yellow_ray_readiness() {
    agent_check r;
    r.subject = "yellow-ray";
    boolean blocked = have_effect($effect[Everything Looks Yellow]) > 0;
    r.ok = !blocked;
    r.severity = r.ok ? "info" : "notice";
    r.reason = blocked ? "Everything Looks Yellow active" : "not blocked by yellow cooldown effect";
    return r;
}

/**
 * Expose photocopy-use/path conditions relevant to legacy fax advisories.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_helper_fax_readiness() {
    agent_check r;
    r.subject = "fax";
    boolean used = get_property("_photocopyUsed").to_boolean();
    boolean path_block = my_path() == $path[Avatar of Boris];
    r.ok = !used && !path_block;
    r.severity = r.ok ? "info" : "notice";
    r.reason = "photocopy_used=" + used + "; avatar_of_boris=" + path_block;
    return r;
}

/**
 * Summarize pirate access items/outfit rather than temporarily equipping them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_pirate_access_context() {
    buffer out;
    out.append("fledges=" + available_amount($item[pirate fledges]) + "\n");
    out.append("swashbuckling_outfit=" + have_outfit("swashbuckling getup") + "\n");
    out.append("insult_book=" + available_amount($item[The Big Book of Pirate Insults]) + "\n");
    return out.to_string();
}

/**
 * Create an explainable familiar-goal score using weight and broad native modifiers.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_helper_familiar_goal_score(familiar fam, string goal) {
    if (!have_familiar(fam)) return -1.0;
    float score = familiar_weight(fam);
    string g = to_lower_case(goal);
    if (g == "items") score = score + numeric_modifier("Item Drop") / 10.0;
    if (g == "meat") score = score + numeric_modifier("Meat Drop") / 10.0;
    return score;
}

/**
 * List missing candidate consumables with storage counts/mall prices for pull decisions.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_consumable_pull_context(item[int] candidates, int max_entries) {
    buffer out;
    int emitted;
    foreach i, it in candidates {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (available_amount(it) > 0) continue;
        out.append(it + "\tstorage=" + storage_amount(it) + "\tmall=" + mall_price(it) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Combine location accessibility with a required-item condition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_helper_access_check(location loc, item required_item) {
    agent_check r;
    r.subject = loc;
    boolean loc_ok = can_adventure(loc);
    boolean item_ok = required_item == $item[none] || available_amount(required_item) > 0;
    r.ok = loc_ok && item_ok;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "location=" + loc_ok + "; item=" + item_ok;
    return r;
}

/**
 * Build compact ascension-helper context around pulls, fax/yellow-ray and basic resources.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/helper.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_helper_agent_context(string goal) {
    buffer out;
    out.append("goal=" + goal + "\n");
    out.append("path=" + my_path() + "\n");
    out.append("level=" + my_level() + "\n");
    out.append("pulls=" + pulls_remaining() + "\n");
    out.append("yellow_blocked=" + (have_effect($effect[Everything Looks Yellow]) > 0) + "\n");
    out.append("photocopy_used=" + get_property("_photocopyUsed") + "\n");
    out.append("wand=" + replace_string(aal_helper_wand_state(), "\n", ",") + "\n");
    return out.to_string();
}
