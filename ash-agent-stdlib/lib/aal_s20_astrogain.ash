script "aal_s20_astrogain.ash";

import <ash_agent_types.ash>;

// SOURCE 20: Astro3207 Gain
// https://github.com/Astro3207/Gain
// Purpose: Gain fork with effect-modifier indexing, source discovery, percentage handling, mutual exclusion, limits, and simulation machinery.

/**
 * Parse an effect's Modifiers string into normalized modifier names.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_modifier_names(effect e) {
    string raw = string_modifier(e, "Modifiers");
    buffer out;
    boolean[string] names;
    foreach i, entry in split_string(raw, ", ") {
        string name = entry;
        int p = index_of(name, ": ");
        if (p >= 0) name = substring(name, 0, p);
        if (name != "") names[to_lower_case(name)] = true;
    }
    foreach name in names out.append(name + "\n");
    return out.to_string();
}

/**
 * Combine flat and percent stat modifiers against current base stat for planning.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_astrogain_percentage_stat_value(effect e, stat s) {
    float flat = numeric_modifier(e, s.to_string());
    float pct = numeric_modifier(e, to_string(s) + " Percent");
    return flat + pct / 100.0 * my_basestat(s);
}

/**
 * Flag effect modifier text that contains bracket/quoted expressions and should not be blindly cached.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_astrogain_dynamic_modifier_hint(effect e) {
    agent_check r;
    r.subject = e;
    string raw = string_modifier(e, "Modifiers");
    boolean dynamic = contains_text(raw, "[") || contains_text(raw, "\"");
    r.ok = !dynamic;
    r.severity = dynamic ? "notice" : "info";
    r.reason = dynamic ? "modifier expression appears dynamic" : "modifier text appears constant";
    return r;
}

/**
 * Find bounded item sources whose Effect modifier matches the requested effect.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_effect_source_items(effect e, int max_entries) {
    buffer out;
    int emitted;
    foreach it in $items[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (effect_modifier(it, "Effect") != e) continue;
        out.append(to_int(it) + "\t" + it + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Find bounded skill sources that map to the requested effect.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_effect_source_skills(effect e, int max_entries) {
    buffer out;
    int emitted;
    foreach s in $skills[] {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (to_effect(s) != e) continue;
        out.append(to_int(s) + "\t" + s + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Approximate Gain-style combat-rate soft-cap conversion for simulation.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_astrogain_combat_rate_softcap(float current, float raw_delta) {
    if (raw_delta == 0.0) return 0.0;
    float direction = raw_delta < 0.0 ? -1.0 : 1.0;
    float magnitude = raw_delta < 0.0 ? -raw_delta : raw_delta;
    float linear_room;
    if (direction > 0.0) linear_room = max(0.0, 25.0 - current);
    else linear_room = max(0.0, current + 25.0);
    float linear = min(magnitude, linear_room);
    float remaining = max(0.0, magnitude - linear);
    float soft = min(10.0, remaining / 5.0);
    return direction * (linear + soft);
}

/**
 * Score a buff source with combined item/meat and MP opportunity costs.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_astrogain_source_efficiency(float modifier_value, int turns, int meat_cost, int mp_cost_value, int meat_per_mp) {
    int total_cost = max(0, meat_cost) + max(0, mp_cost_value) * max(0, meat_per_mp);
    float benefit = (modifier_value < 0.0 ? -modifier_value : modifier_value) * max(0, turns);
    if (benefit <= 0.0) return 1000000000.0;
    return to_float(total_cost) / benefit;
}

/**
 * List active effects in one caller-defined mutually exclusive set.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_mutual_exclusion_state(effect[int] set_members) {
    buffer out;
    int active_count;
    foreach i, e in set_members {
        int turns = have_effect(e);
        if (turns <= 0) continue;
        active_count = active_count + 1;
        out.append(e + "\t" + turns + "\n");
    }
    out.append("active_count\t" + active_count + "\n");
    return out.to_string();
}

/**
 * Serialize a modifier-source ranking row for external sorting/LLM consumption.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_source_rank_line(string source_name, float efficiency, float modifier_value, int turns) {
    return source_name + "\t" + efficiency + "\t" + modifier_value + "\t" + turns;
}

/**
 * Build effect/source/modifier context suitable for an agent planning buff acquisition.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Astro3207/Gain
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_astrogain_agent_context(effect e, string modifier_name) {
    buffer out;
    out.append("effect=" + e + "\n");
    out.append("modifier=" + modifier_name + "\n");
    out.append("effect_value=" + numeric_modifier(e, modifier_name) + "\n");
    out.append("current_total=" + numeric_modifier(modifier_name) + "\n");
    out.append("active_turns=" + have_effect(e) + "\n");
    out.append("modifier_text=" + string_modifier(e, "Modifiers") + "\n");
    return out.to_string();
}
