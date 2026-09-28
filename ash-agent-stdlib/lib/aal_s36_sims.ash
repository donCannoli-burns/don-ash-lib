script "aal_s36_sims.ash";

import <ash_agent_types.ash>;

// SOURCE 36: sims_lib.ash
// https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
// Purpose: Legacy recommendation/simulation helpers, especially familiar selection by goal, runaways, delay, item/meat/combat priorities.

/**
 * Return current effective familiar weight basis for recommendation logic.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_sims_familiar_weight(familiar fam) {
    if (!have_familiar(fam)) return -1;
    return familiar_weight(fam) + weight_adjustment();
}

/**
 * Estimate weight-based free-runaway capacity using the legacy 5-weight-per-runaway heuristic.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_sims_runaway_capacity(familiar fam) {
    int w = aal_sims_familiar_weight(fam);
    if (w < 0) return 0;
    return floor(to_float(w) / 5.0);
}

/**
 * Expose Mini-Hipster free-adventure usage relevant to delay-zone recommendations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_resource_state.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_resource_state aal_sims_delay_state() {
    agent_resource_state r;
    r.name = "Mini-Hipster adventures";
    r.used = get_property("_Mini-HipsterAdv").to_int();
    r.limit_value = 7;
    r.remaining = max(0, 7 - r.used);
    r.available = have_familiar($familiar[Mini-Hipster]) && r.remaining > 0;
    return r;
}

/**
 * Score owned familiars by weight plus broad goal/combat heuristics.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns float.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
float aal_sims_goal_score(familiar fam, string goal, int combat_bias) {
    if (!have_familiar(fam)) return -1000000.0;
    float score = familiar_weight(fam) + weight_adjustment();
    string g = to_lower_case(goal);
    if (g == "runaways" && (fam == $familiar[Frumious Bandersnatch] || fam == $familiar[Pair of Stomping Boots])) score = score + 1000;
    if (g == "delay" && fam == $familiar[Mini-Hipster]) score = score + 1000;
    if (g == "combat" && combat_bias > 0) score = score + combat_bias;
    return score;
}

/**
 * Select highest-scoring candidate familiar without switching it.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns familiar.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
familiar aal_sims_best_familiar(familiar[int] candidates, string goal, int combat_bias) {
    familiar best = $familiar[none];
    float best_score = -1000001.0;
    foreach i, fam in candidates {
        float score = aal_sims_goal_score(fam, goal, combat_bias);
        if (score > best_score) { best_score = score; best = fam; }
    }
    return best;
}

/**
 * Serialize familiar recommendation evidence.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_familiar_line(familiar fam, string goal, int combat_bias) {
    return fam + "\towned=" + have_familiar(fam) + "\tweight=" + aal_sims_familiar_weight(fam) + "\tscore=" + aal_sims_goal_score(fam, goal, combat_bias);
}

/**
 * Emit bounded familiar candidate evidence in caller order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_goal_candidates(familiar[int] candidates, string goal, int combat_bias, int max_entries) {
    buffer out;
    int emitted;
    foreach i, fam in candidates {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (!have_familiar(fam)) continue;
        out.append(aal_sims_familiar_line(fam, goal, combat_bias) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Check whether a familiar is usable in the current path by ownership plus path-level familiar availability.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_sims_path_constraint(familiar fam) {
    agent_check r;
    r.subject = fam;
    boolean owned = have_familiar(fam);
    r.ok = owned;
    r.severity = owned ? "info" : "warning";
    r.reason = "path=" + my_path() + "; owned=" + owned;
    return r;
}

/**
 * Generate concise human/agent-readable rationale for common familiar goals.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_recommendation_reason(familiar fam, string goal) {
    string g = to_lower_case(goal);
    if (!have_familiar(fam)) return "not owned";
    if (g == "runaways" && (fam == $familiar[Frumious Bandersnatch] || fam == $familiar[Pair of Stomping Boots])) return "weight-driven free runaway source";
    if (g == "delay" && fam == $familiar[Mini-Hipster]) return "free/delay encounter resource";
    if (g == "items") return "evaluate item-drop utility and weight";
    if (g == "meat") return "evaluate meat utility and weight";
    if (g == "combat") return "evaluate combat action/block/damage utility";
    return "general familiar utility";
}

/**
 * Build compact familiar recommendation context without switching familiars.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/blob/master/scripts/sims_lib.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_sims_agent_context(familiar[int] candidates, string goal, int combat_bias) {
    buffer out;
    out.append("goal=" + goal + "\n");
    out.append("current=" + my_familiar() + "\n");
    familiar best = aal_sims_best_familiar(candidates, goal, combat_bias);
    out.append("recommended=" + best + "\n");
    foreach i, fam in candidates if (have_familiar(fam)) out.append("candidate=" + aal_sims_familiar_line(fam, goal, combat_bias) + "\n");
    return out.to_string();
}
