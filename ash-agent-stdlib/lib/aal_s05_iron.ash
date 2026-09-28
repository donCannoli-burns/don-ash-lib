script "aal_s05_iron.ash";

import <ash_agent_types.ash>;

// SOURCE 05: IronTetsubo KoLmafia-ash scripts
// https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
// Purpose: Historical ASH collection including BatBrain, net worth, rollover, bootstrap, OCD inventory, recovery, and automation scripts.

/**
 * List mutation-oriented primitives in an IronTetsubo-era script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_side_effect_scan(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "visit_url(")) out.append("visit_url\n");
    if (contains_text(low, "cli_execute(")) out.append("cli_execute\n");
    if (contains_text(low, "adventure(")) out.append("adventure\n");
    if (contains_text(low, "use(")) out.append("use\n");
    if (contains_text(low, "buy(")) out.append("buy\n");
    if (contains_text(low, "autosell(")) out.append("autosell\n");
    if (contains_text(low, "take_storage(")) out.append("take_storage\n");
    if (contains_text(low, "set_property(")) out.append("set_property\n");
    return out.to_string();
}

/**
 * Detect external HTTP-era dependencies separately from in-game page access.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_iron_scripts_network_scan(string source_text) {
    agent_check r;
    r.subject = "external-network";
    string low = to_lower_case(source_text);
    boolean external = contains_text(low, "http://") || contains_text(low, "https://");
    r.ok = !external;
    r.severity = external ? "warning" : "info";
    r.reason = external ? "external URL text present; inspect modernization path" : "no obvious external URL";
    return r;
}

/**
 * Score reliance on substring/excise/matcher parsing around page requests.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_iron_scripts_html_parse_score(string source_text) {
    string low = to_lower_case(source_text);
    int score;
    if (contains_text(low, "visit_url(")) score = score + 1;
    if (contains_text(low, "contains_text(")) score = score + 1;
    if (contains_text(low, "substring(")) score = score + 1;
    if (contains_text(low, "index_of(")) score = score + 1;
    if (contains_text(low, "create_matcher(")) score = score + 1;
    if (contains_text(low, "excise(")) score = score + 1;
    return score;
}

/**
 * Extract legacy imports for migration dependency auditing.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_import_manifest(string source_text) {
    buffer out;
    boolean[string] imports;
    matcher m = create_matcher("import\\s*<([^>]+)>", source_text);
    while (m.find()) imports[m.group(1)] = true;
    foreach x in imports out.append(x + "\n");
    return out.to_string();
}

/**
 * Extract quoted properties referenced by get_property/set_property.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_property_manifest(string source_text) {
    buffer out;
    boolean[string] prefs;
    matcher m = create_matcher("(?:get_property|set_property)\\(\"([^\"]+)\"", source_text);
    while (m.find()) prefs[m.group(1)] = true;
    foreach x in prefs out.append(x + "\n");
    return out.to_string();
}

/**
 * Extract straightforward quoted cli_execute command literals for review.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_cli_command_literals(string source_text) {
    buffer out;
    boolean[string] cmds;
    matcher m = create_matcher("cli_execute\\(\"([^\"]+)\"\\)", source_text);
    while (m.find()) cmds[m.group(1)] = true;
    foreach c in cmds out.append(c + "\n");
    return out.to_string();
}

/**
 * Combine parsing, command, network, and direct-page indicators into one modernization pressure metric.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_iron_scripts_modernization_pressure(string source_text) {
    string low = to_lower_case(source_text);
    int score;
    if (contains_text(low, "visit_url(")) score = score + 3;
    if (contains_text(low, "cli_execute(")) score = score + 2;
    if (contains_text(low, "http://")) score = score + 3;
    if (contains_text(low, "svn_")) score = score + 2;
    if (contains_text(low, "pwd")) score = score + 1;
    if (contains_text(low, "index_of(") && contains_text(low, ".php")) score = score + 2;
    return score;
}

/**
 * Flag likely top-level side effects by comparing early executable tokens with function declarations.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_iron_scripts_import_safe_hint(string source_text) {
    agent_check r;
    r.subject = "import-safety";
    string low = to_lower_case(source_text);
    int first_mut = length(low);
    int p = index_of(low, "visit_url(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "cli_execute(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "set_property(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "use(");
    if (p >= 0 && p < first_mut) first_mut = p;
    p = index_of(low, "buy(");
    if (p >= 0 && p < first_mut) first_mut = p;
    int first_function = index_of(low, "void ");
    if (first_function < 0) first_function = index_of(low, "boolean ");
    r.ok = first_mut >= first_function && first_function >= 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = r.ok ? "no obvious mutation before first function" : "possible top-level side effect";
    return r;
}

/**
 * Suggest explicit read/plan/execute split points based on legacy primitives found.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_read_plan_split(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "visit_url(")) out.append("READ: replace/encapsulate page observation\n");
    if (contains_text(low, "contains_text(") || contains_text(low, "create_matcher(")) out.append("NORMALIZE: parse observed state\n");
    if (contains_text(low, "maximize") || contains_text(low, "mall_price")) out.append("PLAN: compute candidate/cost\n");
    if (contains_text(low, "cli_execute(") || contains_text(low, "use(") || contains_text(low, "buy(")) out.append("EXECUTE: isolate mutation\n");
    return out.to_string();
}

/**
 * Build a compact migration context for an agent reviewing historical IronTetsubo scripts.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_iron_scripts_agent_context(string source_name, string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    out.append("source=" + source_name + "\n");
    out.append("length=" + length(source_text) + "\n");
    out.append("visit_url=" + contains_text(low, "visit_url(") + "\n");
    out.append("cli_execute=" + contains_text(low, "cli_execute(") + "\n");
    out.append("external_http=" + (contains_text(low, "http://") || contains_text(low, "https://")) + "\n");
    out.append("zlib=" + contains_text(low, "zlib.ash") + "\n");
    return out.to_string();
}
