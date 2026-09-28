script "aal_s39_choiceoverride.ash";

import <ash_agent_types.ash>;

// SOURCE 39: Choice-Override
// https://github.com/Ezandora/Choice-Override
// Purpose: Public-domain relay choice dispatcher that parses choice IDs, finds choice.<id>.ash/js handlers, encodes page text, and supports choice.0 fallback.

/**
 * Parse a choice ID from common whichchoice HTML/query patterns without issuing a request.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_choiceoverride_choice_id(string page_text) {
    string[int] patterns;
    patterns[0] = "name=['\"]?whichchoice['\"]? value=['\"]?(\\d+)['\"]?";
    patterns[1] = "value=['\"]?(\\d+)['\"]? name=['\"]?whichchoice['\"]?";
    patterns[2] = "choice\\.php\\?whichchoice=(\\d+)";
    foreach i, p in patterns {
        matcher m = create_matcher(p, page_text);
        if (m.find() && is_integer(m.group(1))) return m.group(1).to_int();
    }
    return -1;
}

/**
 * Extract unique positive option values from choice-page HTML.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_option_ids(string page_text) {
    boolean[int] ids;
    matcher m = create_matcher("name=['\"]?option['\"]?[^>]*value=['\"]?(\\d+)", page_text);
    while (m.find()) ids[m.group(1).to_int()] = true;
    matcher m2 = create_matcher("value=['\"]?(\\d+)['\"]?[^>]*name=['\"]?option", page_text);
    while (m2.find()) ids[m2.group(1).to_int()] = true;
    buffer out;
    foreach id in ids if (id > 0) out.append(id + "\n");
    return out.to_string();
}

/**
 * Generate the canonical override script basename for a choice.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_script_base(int choice_id) {
    return "choice." + choice_id;
}

/**
 * Return exact ASH/JS handler candidates plus fallback names in lookup order.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_handler_candidates(int choice_id) {
    buffer out;
    out.append("relay/choice." + choice_id + ".ash\n");
    out.append("relay/choice." + choice_id + ".js\n");
    out.append("relay/choice.0.ash\n");
    out.append("relay/choice.0.js\n");
    return out.to_string();
}

/**
 * Build a lightweight deterministic choice-page fingerprint from parsed ID/length/option list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_page_fingerprint(string page_text) {
    return aal_choiceoverride_choice_id(page_text) + ":" + length(page_text) + ":" + replace_string(aal_choiceoverride_option_ids(page_text), "\n", ",");
}

/**
 * Validate that a page contains an identifiable choice and at least one option.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_choiceoverride_validate_page(string page_text) {
    agent_check r;
    r.subject = "choice-page";
    int id = aal_choiceoverride_choice_id(page_text);
    string opts = aal_choiceoverride_option_ids(page_text);
    r.ok = id > 0 && opts != "";
    r.severity = r.ok ? "info" : "warning";
    r.reason = "choice_id=" + id + "; options=" + replace_string(opts, "\n", ",");
    return r;
}

/**
 * Describe Choice-Override routing decision without dispatching a script.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_route_preview(string page_text, boolean specific_handler_exists, boolean fallback_handler_exists) {
    int id = aal_choiceoverride_choice_id(page_text);
    if (id < 0) return "pass-through: choice id unknown";
    if (specific_handler_exists) return "dispatch: choice." + id;
    if (fallback_handler_exists) return "dispatch: choice.0";
    return "pass-through: no handler";
}

/**
 * URL-encode choice page text for safe argument transport, mirroring the source's transport idea.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_encode_payload(string page_text) {
    return url_encode(page_text);
}

/**
 * Decode a Choice-Override-style page payload.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_decode_payload(string encoded) {
    return url_decode(encoded);
}

/**
 * Build compact choice context from page text without visiting or submitting choice.php.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Ezandora/Choice-Override
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_choiceoverride_agent_context(string page_text) {
    buffer out;
    out.append("choice_id=" + aal_choiceoverride_choice_id(page_text) + "\n");
    out.append("options=" + replace_string(aal_choiceoverride_option_ids(page_text), "\n", ",") + "\n");
    out.append("fingerprint=" + aal_choiceoverride_page_fingerprint(page_text) + "\n");
    out.append("handler_candidates=" + replace_string(aal_choiceoverride_handler_candidates(aal_choiceoverride_choice_id(page_text)), "\n", ",") + "\n");
    return out.to_string();
}
