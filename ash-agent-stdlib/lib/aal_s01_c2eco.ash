script "aal_s01_c2eco.ash";

import <ash_agent_types.ash>;

// SOURCE 01: C2Talon repository ecosystem
// https://github.com/C2Talon?tab=repositories
// Purpose: Repository collection spanning reusable ASH libraries, resource modules, ascension automation, trackers, relays, and KoLmafia tooling.

/**
 * Normalize a repository-name list into stable one-name-per-line manifest text.
 *
 * Parameters: repo_names: repository names discovered from the C2Talon ecosystem.
 * Return: Lower-cased de-duplicated manifest, one repository per line.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: line := repository-name
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_repo_manifest(string[int] repo_names) {
    buffer out;
    boolean[string] seen;
    foreach i, name in repo_names {
        if (name != "") seen[to_lower_case(name)] = true;
    }
    foreach name in seen {
        out.append(name);
        out.append("\n");
    }
    return out.to_string();
}

/**
 * Classify a C2Talon-style repository by its name into a useful runtime role.
 *
 * Parameters: repo_name: repository name.
 * Return: Stable role label.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_repo_role(string repo_name) {
    string n = to_lower_case(repo_name);
    if (contains_text(n, "relay")) return "relay-ui";
    if (contains_text(n, "lib")) return "library";
    if (contains_text(n, "ascend") || contains_text(n, "hccs")) return "run-automation";
    if (contains_text(n, "track")) return "tracking";
    if (contains_text(n, "trainer")) return "training";
    if (contains_text(n, "choice")) return "choice-support";
    if (contains_text(n, "kolmafia")) return "runtime";
    return "script-or-tool";
}

/**
 * Normalize dependencies.txt-style content into deterministic dependency lines without comments/blank rows.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_dependency_lines(string dependencies_text) {
    buffer out;
    string[int] lines = split_string(dependencies_text, "\n");
    boolean[string] seen;
    foreach i, line in lines {
        string cleaned = line;
        if (index_of(cleaned, "#") >= 0) cleaned = substring(cleaned, 0, index_of(cleaned, "#"));
        if (cleaned != "") seen[cleaned] = true;
    }
    foreach line in seen {
        out.append(line);
        out.append("\n");
    }
    return out.to_string();
}

/**
 * Count unique non-comment dependency declarations in a dependencies file.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Unique dependency count.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_c2eco_dependency_count(string dependencies_text) {
    boolean[string] seen;
    string[int] lines = split_string(dependencies_text, "\n");
    foreach i, line in lines {
        string cleaned = line;
        if (index_of(cleaned, "#") >= 0) cleaned = substring(cleaned, 0, index_of(cleaned, "#"));
        if (cleaned != "") seen[cleaned] = true;
    }
    return count(seen);
}

/**
 * Produce compact capability tags inferred from ecosystem naming conventions.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_repo_capability_tags(string repo_name) {
    buffer out;
    string n = to_lower_case(repo_name);
    if (contains_text(n, "relay")) out.append("ui,");
    if (contains_text(n, "lib")) out.append("library,");
    if (contains_text(n, "ascend")) out.append("ascension,");
    if (contains_text(n, "hccs")) out.append("community-service,");
    if (contains_text(n, "choice")) out.append("choice,");
    if (contains_text(n, "track")) out.append("tracking,");
    if (contains_text(n, "train")) out.append("training,");
    if (contains_text(n, "mafia")) out.append("runtime,");
    string s = out.to_string();
    if (s == "") return "general";
    return substring(s, 0, length(s) - 1);
}

/**
 * Select ecosystem repositories whose names/roles plausibly match a task description.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_select_repos_for_task(string[int] repo_names, string task_text) {
    buffer out;
    string q = to_lower_case(task_text);
    boolean[string] chosen;
    foreach i, repo in repo_names {
        string n = to_lower_case(repo);
        boolean match = contains_text(q, n);
        if (contains_text(q, "ascend") && contains_text(n, "ascend")) match = true;
        if (contains_text(q, "community service") && contains_text(n, "hccs")) match = true;
        if (contains_text(q, "relay") && contains_text(n, "relay")) match = true;
        if (contains_text(q, "library") && contains_text(n, "lib")) match = true;
        if (contains_text(q, "choice") && contains_text(n, "choice")) match = true;
        if (match) chosen[n] = true;
    }
    foreach n in chosen {
        out.append(n);
        out.append("\n");
    }
    return out.to_string();
}

/**
 * Compare two repository manifests and report added/removed names.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: TSV: change_type<TAB>repository
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_manifest_delta(string[int] before_repos, string[int] after_repos) {
    boolean[string] before;
    boolean[string] after;
    foreach i, n in before_repos if (n != "") before[to_lower_case(n)] = true;
    foreach i, n in after_repos if (n != "") after[to_lower_case(n)] = true;
    buffer out;
    foreach n in after if (!(before contains n)) out.append("added\t" + n + "\n");
    foreach n in before if (!(after contains n)) out.append("removed\t" + n + "\n");
    return out.to_string();
}

/**
 * Extract likely reusable library repositories from a mixed account repository list.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_library_candidates(string[int] repo_names) {
    buffer out;
    boolean[string] libs;
    foreach i, repo in repo_names {
        string n = to_lower_case(repo);
        if (contains_text(n, "lib") || contains_text(n, "helper")) libs[n] = true;
    }
    foreach n in libs out.append(n + "\n");
    return out.to_string();
}

/**
 * Summarize whether a repository ecosystem exposes both reusable libraries and explicit dependency metadata.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: agent_check.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_check aal_c2eco_ecosystem_health(string[int] repo_names, string dependencies_text) {
    agent_check r;
    r.subject = "c2talon-ecosystem";
    int libraries;
    foreach i, repo in repo_names if (contains_text(to_lower_case(repo), "lib")) libraries = libraries + 1;
    int deps;
    boolean[string] dep_seen;
    foreach i, line in split_string(dependencies_text, "\n") if (line != "" && !contains_text(line, "#")) dep_seen[line] = true;
    deps = count(dep_seen);
    r.ok = libraries > 0 && deps > 0;
    r.severity = r.ok ? "info" : "warning";
    r.reason = "libraries=" + libraries + "; dependencies=" + deps;
    return r;
}

/**
 * Build a compact deterministic ecosystem context for an agent selecting reusable C2Talon components.
 *
 * Parameters: max_repos <= 0 means no cap.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/C2Talon?tab=repositories
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: key=value lines; repos emitted lexically.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_c2eco_agent_context(string[int] repo_names, string dependencies_text, int max_repos) {
    buffer out;
    out.append("ecosystem=C2Talon\n");
    int emitted;
    boolean[string] seen;
    foreach i, repo in repo_names if (repo != "") seen[to_lower_case(repo)] = true;
    foreach repo in seen {
        if (max_repos > 0 && emitted >= max_repos) break;
        out.append("repo=" + repo + "\n");
        emitted = emitted + 1;
    }
    int deps;
    foreach i, line in split_string(dependencies_text, "\n") if (line != "" && !contains_text(line, "#")) deps = deps + 1;
    out.append("dependency_lines=" + deps + "\n");
    return out.to_string();
}
