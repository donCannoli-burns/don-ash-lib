script "aal_s11_lowerstats.ash";

import <ash_agent_types.ash>;

// SOURCE 11: pLooper lowerstats.ash
// https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
// Purpose: Stat-lowering helper that identifies buffed stats over a target, applies negative effects/items, shrugs positive stat effects, and aborts on failure.

/**
 * Measure how far a buffed stat exceeds a desired cap.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_range_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_range_state aal_lowerstats_pressure(stat s, int cap) {
    agent_range_state r;
    r.minimum = 0;
    r.maximum = max(0, cap);
    r.current = my_buffedstat(s);
    r.remaining = max(0, r.current - r.maximum);
    r.satisfied = r.current <= r.maximum;
    return r;
}

/**
 * Serialize over-cap pressure for all three stats.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: stat<TAB>buffed<TAB>excess
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_all_pressure(int cap) {
    buffer out;
    foreach s in $stats[] {
        int current = my_buffedstat(s);
        int excess = max(0, current - cap);
        out.append(s + "\t" + current + "\t" + excess + "\n");
    }
    return out.to_string();
}

/**
 * List active effects that positively modify the requested stat, bounded for agent context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_positive_effects(stat s, int max_entries) {
    buffer out;
    int emitted;
    int[effect] active = my_effects();
    foreach e, turns in active {
        if (max_entries > 0 && emitted >= max_entries) break;
        float v = numeric_modifier(e, s.to_string());
        if (v <= 0) continue;
        out.append(e + "\t" + turns + "\t" + v + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Explain whether an active positive-stat effect also carries protected economic/familiar/smithsness modifiers.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_lowerstats_effect_safety(effect e) {
    agent_check r;
    r.subject = e;
    boolean economic = numeric_modifier(e, "Meat Drop") > 0;
    boolean familiar = numeric_modifier(e, "Familiar Weight") != 0;
    boolean smith = numeric_modifier(e, "Smithsness") != 0;
    r.ok = !(economic || familiar || smith);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "meat=" + economic + "; familiar=" + familiar + "; smithsness=" + smith;
    return r;
}

/**
 * List active positive-stat effects that are plausible shrug candidates under the source's protection rules.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_shrug_candidates(stat s, int cap, int max_entries) {
    if (my_buffedstat(s) <= cap) return "";
    buffer out;
    int emitted;
    int[effect] active = my_effects();
    foreach e, turns in active {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (numeric_modifier(e, s.to_string()) <= 0) continue;
        if (numeric_modifier(e, "Meat Drop") > 0) continue;
        if (numeric_modifier(e, "Familiar Weight") != 0) continue;
        if (numeric_modifier(e, "Smithsness") != 0) continue;
        out.append(e + "\t" + turns + "\t" + numeric_modifier(e, s.to_string()) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Describe source-inspired low-stat consumable/item options without acquiring or using them.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_item_option(stat s) {
    if (s == $stat[muscle]) return "decorative fountain -> Sleepy";
    if (s == $stat[moxie]) return "patchouli incense stick -> Far Out";
    return "Fun-Guy spore -> Mush-Mouth; Mr. Mediocrebar -> Apathy";
}

/**
 * Compare a stat-lowering item's mall price with a caller budget without buying it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_action_preview.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_action_preview aal_lowerstats_budget_preview(item it, int max_price) {
    agent_action_preview r;
    r.operation = "acquire " + it;
    int p = mall_price(it);
    r.meat_cost = max(0, p);
    r.adventure_cost = 0;
    r.valid = it != $item[none] && (available_amount(it) > 0 || (p > 0 && p <= max_price));
    r.reason = "available=" + available_amount(it) + "; mall_price=" + p + "; max_price=" + max_price;
    if (!r.valid) r.warnings = "item unavailable or above budget";
    return r;
}

/**
 * Build a compact read-only stat-lowering plan for one stat.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_plan(stat s, int cap) {
    buffer out;
    out.append("stat=" + s + "\n");
    out.append("current=" + my_buffedstat(s) + "\n");
    out.append("cap=" + cap + "\n");
    out.append("excess=" + max(0, my_buffedstat(s) - cap) + "\n");
    if (my_buffedstat(s) > cap) out.append("suggestion=" + aal_lowerstats_item_option(s) + "\n");
    else out.append("suggestion=none\n");
    return out.to_string();
}

/**
 * Check the postcondition the original helper ultimately wanted: buffed stat at or below cap.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_lowerstats_postcondition(stat s, int cap) {
    agent_check r;
    r.subject = s;
    r.ok = my_buffedstat(s) <= cap;
    r.severity = r.ok ? "info" : "error";
    r.reason = "buffed=" + my_buffedstat(s) + "; cap=" + cap;
    return r;
}

/**
 * Build compact all-stat state plus relevant source-inspired negative effects for an agent.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pLooper/blob/main/kolmafia/scripts/ploophelpers/lowerstats.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_lowerstats_agent_context(int cap) {
    buffer out;
    out.append("cap=" + cap + "\n");
    foreach s in $stats[] out.append(s + "=" + my_buffedstat(s) + ";excess=" + max(0, my_buffedstat(s)-cap) + "\n");
    out.append("mush_mouth=" + have_effect($effect[Mush-Mouth]) + "\n");
    out.append("sleepy=" + have_effect($effect[Sleepy]) + "\n");
    out.append("far_out=" + have_effect($effect[Far Out]) + "\n");
    out.append("apathy=" + have_effect($effect[Apathy]) + "\n");
    return out.to_string();
}
