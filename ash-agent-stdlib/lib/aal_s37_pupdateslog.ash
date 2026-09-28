script "aal_s37_pupdateslog.ash";

import <ash_agent_types.ash>;

// SOURCE 37: pUpdates repository (second supplied entry)
// https://github.com/Prusias-kol/pUpdates
// Purpose: Same upstream supplied again; this entry focuses on pure changelog parsing/serialization rather than operational seen-version state.

/**
 * Extract current version from a pUpdates-style map representation where index -1 stores version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_pupdateslog_parse_header(string[int] update_lines) {
    if (!(update_lines contains -1)) return -1;
    return update_lines[-1].to_int();
}

/**
 * Return one changelog entry by version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_entry(string[int] update_lines, int version) {
    if (!(update_lines contains version)) return "";
    return update_lines[version];
}

/**
 * Serialize changelog entries newer than a seen version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_since(string[int] update_lines, int seen_version, int max_entries) {
    buffer out;
    int current = aal_pupdateslog_parse_header(update_lines);
    if (current < 0 || seen_version >= current) return "";
    int emitted;
    for v from seen_version + 1 to current {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (!(update_lines contains v)) continue;
        out.append(v + "\t" + update_lines[v] + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Report gaps between version 0 and declared current version.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_missing_versions(string[int] update_lines) {
    buffer out;
    int current = aal_pupdateslog_parse_header(update_lines);
    if (current < 0) return "";
    for v from 0 to current
        if (!(update_lines contains v)) out.append(v + "\n");
    return out.to_string();
}

/**
 * Check whether all changelog versions through current are present.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns boolean.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
boolean aal_pupdateslog_contiguous(string[int] update_lines) {
    return aal_pupdateslog_missing_versions(update_lines) == "";
}

/**
 * Produce a deterministic lightweight checksum from version numbers and line lengths.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_pupdateslog_checksum(string[int] update_lines) {
    int h = 5381;
    foreach v, text in update_lines {
        h = (h * 33 + v + length(text)) % 1000000007;
    }
    return h;
}

/**
 * Search changelog entries case-insensitively.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_search(string[int] update_lines, string query, int max_entries) {
    buffer out;
    string q = to_lower_case(query);
    int emitted;
    foreach v, text in update_lines {
        if (v < 0) continue;
        if (max_entries > 0 && emitted >= max_entries) break;
        if (q != "" && !contains_text(to_lower_case(text), q)) continue;
        out.append(v + "\t" + text + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Serialize an entire changelog as versioned TSV.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_tsv(string script_name, string[int] update_lines) {
    buffer out;
    foreach v, text in update_lines {
        if (v < 0) continue;
        out.append(script_name + "\t" + v + "\t" + text + "\n");
    }
    return out.to_string();
}

/**
 * Validate header/version continuity for a changelog map.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_pupdateslog_validate(string[int] update_lines) {
    agent_check r;
    r.subject = "pUpdates-log";
    int current = aal_pupdateslog_parse_header(update_lines);
    r.ok = current >= 0 && aal_pupdateslog_contiguous(update_lines);
    r.severity = r.ok ? "info" : "warning";
    r.reason = "current=" + current + "; missing=" + replace_string(aal_pupdateslog_missing_versions(update_lines), "\n", ",");
    return r;
}

/**
 * Build compact unseen-changelog context without reading/writing preferences.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/Prusias-kol/pUpdates
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_pupdateslog_agent_context(string script_name, string[int] update_lines, int seen_version, int max_entries) {
    buffer out;
    int current = aal_pupdateslog_parse_header(update_lines);
    out.append("script=" + script_name + "\n");
    out.append("seen=" + seen_version + "\n");
    out.append("current=" + current + "\n");
    out.append("pending=" + max(0, current-seen_version) + "\n");
    out.append(aal_pupdateslog_since(update_lines, seen_version, max_entries));
    return out.to_string();
}
