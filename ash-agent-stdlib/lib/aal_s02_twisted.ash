script "aal_s02_twisted.ash";

import <ash_agent_types.ash>;

// SOURCE 02: twistedmage assorted scripts
// https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
// Purpose: Large legacy ASH script collection with questing, utilities, helpers, combat, crafting, and relay-era patterns.

/**
 * Extract imported ASH filenames from legacy script text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_imports(string source_text) {
    buffer out;
    string[int] lines = split_string(source_text, "\n");
    boolean[string] imports;
    foreach i, line in lines {
        string low = to_lower_case(line);
        if (!contains_text(low, "import")) continue;
        int l = index_of(line, "<");
        int r = index_of(line, ">");
        if (l >= 0 && r > l) imports[substring(line, l + 1, r)] = true;
    }
    foreach name in imports out.append(name + "\n");
    return out.to_string();
}

/**
 * Describe potentially mutating primitives present in a legacy ASH script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_mutation_surface(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "cli_execute(")) out.append("cli_execute\n");
    if (contains_text(low, "visit_url(")) out.append("visit_url\n");
    if (contains_text(low, "adventure(")) out.append("adventure\n");
    if (contains_text(low, "use(")) out.append("use\n");
    if (contains_text(low, "eat(")) out.append("eat\n");
    if (contains_text(low, "drink(")) out.append("drink\n");
    if (contains_text(low, "buy(")) out.append("buy\n");
    if (contains_text(low, "set_property(")) out.append("set_property\n");
    if (contains_text(low, "take_stash(") || contains_text(low, "put_stash(")) out.append("stash\n");
    return out.to_string();
}

/**
 * Compute a coarse modernization risk score from legacy execution and page-scraping patterns.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Integer risk signal; higher means more review pressure, not a safety verdict.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_twisted_legacy_risk_score(string source_text) {
    string low = to_lower_case(source_text);
    int score;
    if (contains_text(low, "visit_url(")) score = score + 2;
    if (contains_text(low, "cli_execute(")) score = score + 2;
    if (contains_text(low, "contains_text(visit_url")) score = score + 2;
    if (contains_text(low, "svn_")) score = score + 2;
    if (contains_text(low, "kolmafia.us")) score = score + 1;
    if (contains_text(low, "pwd")) score = score + 1;
    if (contains_text(low, "abort(")) score = score + 1;
    return score;
}

/**
 * Extract get_property/set_property preference names from straightforward quoted calls.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_preference_refs(string source_text) {
    buffer out;
    boolean[string] prefs;
    matcher m = create_matcher("(?:get_property|set_property)\\(\"([^\"]+)\"", source_text);
    while (m.find()) prefs[m.group(1)] = true;
    foreach p in prefs out.append(p + "\n");
    return out.to_string();
}

/**
 * Extract quoted .php endpoints referenced by a legacy script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_url_endpoints(string source_text) {
    buffer out;
    boolean[string] endpoints;
    matcher m = create_matcher("\"([A-Za-z0-9_./-]+\\.php[^\" ]*)\"", source_text);
    while (m.find()) endpoints[m.group(1)] = true;
    foreach e in endpoints out.append(e + "\n");
    return out.to_string();
}

/**
 * Count likely main-function entrypoints in source text.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_twisted_entrypoint_count(string source_text) {
    matcher m = create_matcher("\\bvoid\\s+main\\s*\\(", source_text);
    int n;
    while (m.find()) n = n + 1;
    return n;
}

/**
 * Flag scripts whose decisions appear coupled to raw HTML text matching.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_twisted_raw_html_dependency(string source_text) {
    agent_check r;
    r.subject = "raw-html-coupling";
    string low = to_lower_case(source_text);
    int visit_count;
    matcher m = create_matcher("visit_url\\s*\\(", low);
    while (m.find()) visit_count = visit_count + 1;
    boolean coupled = contains_text(low, "contains_text") && visit_count > 0;
    r.ok = !coupled;
    r.severity = coupled ? "warning" : "info";
    r.reason = coupled ? "script combines page fetches with text matching" : "no obvious fetch/text-match coupling";
    return r;
}

/**
 * Estimate dependency pressure from import count and nested executor usage.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_twisted_import_depth_hint(string source_text) {
    int imports;
    matcher m = create_matcher("\\bimport\\b", to_lower_case(source_text));
    while (m.find()) imports = imports + 1;
    int pressure = imports;
    if (contains_text(to_lower_case(source_text), "cli_execute(")) pressure = pressure + 2;
    if (contains_text(to_lower_case(source_text), "call ")) pressure = pressure + 1;
    return pressure;
}

/**
 * Create a deterministic modernization checklist based on patterns actually present.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_modernization_todo(string source_text) {
    buffer out;
    string low = to_lower_case(source_text);
    if (contains_text(low, "visit_url(")) out.append("review-page-scraping\n");
    if (contains_text(low, "cli_execute(")) out.append("replace-string-command-where-typed-api-exists\n");
    if (contains_text(low, "svn_")) out.append("replace-svn-era-update-path\n");
    if (contains_text(low, "set_property(")) out.append("separate-read-plan-write\n");
    if (contains_text(low, "abort(")) out.append("document-failure-contract\n");
    if (contains_text(low, "import <zlib.ash>")) out.append("audit-zlib-dependency\n");
    return out.to_string();
}

/**
 * Build a compact static-analysis context for an agent modernizing a twistedmage-era script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/twistedmage/assorted-kol-scripts/tree/master/scripts
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_twisted_source_context(string source_name, string source_text) {
    buffer out;
    out.append("source=" + source_name + "\n");
    out.append("bytes=" + length(source_text) + "\n");
    string low = to_lower_case(source_text);
    out.append("has_cli_execute=" + to_string(contains_text(low, "cli_execute(")) + "\n");
    out.append("has_visit_url=" + to_string(contains_text(low, "visit_url(")) + "\n");
    out.append("has_properties=" + to_string(contains_text(low, "get_property(") || contains_text(low, "set_property(")) + "\n");
    out.append("has_main=" + to_string(contains_text(low, "void main")) + "\n");
    return out.to_string();
}
