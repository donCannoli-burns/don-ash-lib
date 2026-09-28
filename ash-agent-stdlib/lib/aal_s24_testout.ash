script "aal_s24_testout.ash";

import <ash_agent_types.ash>;

// SOURCE 24: testout.ash
// https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
// Purpose: Minimal vprint test script; useful as inspiration for standardized diagnostics and smoke probes.

/**
 * Create a structured boolean smoke-test result.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_bool(string name, boolean actual, boolean expected) {
    agent_diagnostic r;
    r.name = name;
    r.passed = actual == expected;
    r.expected = to_string(expected);
    r.actual = to_string(actual);
    r.note = "";
    return r;
}

/**
 * Create a structured collection-cardinality diagnostic with explicit bounds.
 *
 * Parameters: name: diagnostic label; actual_count: observed collection size; minimum_count/maximum_count: accepted bounds.
 * Return: Structured bounded-cardinality diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: agent_diagnostic
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_cardinality(string name, int actual_count, int minimum_count, int maximum_count) {
    agent_diagnostic d;
    d.name = name;
    d.actual = actual_count;
    d.expected = minimum_count + ".." + maximum_count;
    d.passed = actual_count >= minimum_count && actual_count <= maximum_count;
    d.detail = d.passed ? "cardinality within bounds" : "cardinality outside bounds";
    return d;
}

/**
 * Validate that a string map contains every required schema key and report missing keys.
 *
 * Parameters: name: diagnostic label; fields: observed schema map; required_keys: required field names.
 * Return: Structured schema-presence diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: agent_diagnostic
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_required_keys(string name, string[string] fields, string[int] required_keys) {
    agent_diagnostic d;
    d.name = name;
    buffer missing;
    foreach i, key in required_keys {
        if (!(fields contains key)) missing.append((length(missing) > 0 ? "," : "") + key);
    }
    d.actual = "keys=" + count(fields);
    d.expected = "required=" + count(required_keys);
    d.passed = length(missing) == 0;
    d.detail = d.passed ? "all required keys present" : "missing=" + missing.to_string();
    return d;
}

/**
 * Create a diagnostic for an inclusive numeric range.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns agent_diagnostic.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
agent_diagnostic aal_testout_range(string name, float actual, float minimum, float maximum) {
    agent_diagnostic r;
    r.name = name;
    r.passed = actual >= minimum && actual <= maximum;
    r.expected = to_string(minimum) + ".." + to_string(maximum);
    r.actual = to_string(actual);
    r.note = "";
    return r;
}

/**
 * Serialize a diagnostic in compact TSV form.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_line(agent_diagnostic d) {
    return (d.passed ? "PASS" : "FAIL") + "\t" + d.name + "\t" + d.expected + "\t" + d.actual + "\t" + d.note;
}

/**
 * Count passing or failing diagnostics.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns int.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
int aal_testout_assertion_count(agent_diagnostic[int] results, boolean passed) {
    int n;
    foreach i, d in results if (d.passed == passed) n = n + 1;
    return n;
}

/**
 * Summarize diagnostic pass/fail counts.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_summary(agent_diagnostic[int] results) {
    int pass;
    int fail;
    foreach i, d in results {
        if (d.passed) pass = pass + 1;
        else fail = fail + 1;
    }
    return "pass=" + pass + "\nfail=" + fail + "\ntotal=" + (pass + fail) + "\n";
}

/**
 * Emit bounded failing diagnostic rows.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_failures(agent_diagnostic[int] results, int max_entries) {
    buffer out;
    int emitted;
    foreach i, d in results {
        if (max_entries > 0 && emitted >= max_entries) break;
        if (d.passed) continue;
        out.append(aal_testout_line(d) + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}

/**
 * Capture a harmless runtime probe replacing the original one-line vprint smoke idea with structured state.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: READ_ONLY
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_runtime_probe() {
    buffer out;
    out.append("name=" + my_name() + "\n");
    out.append("level=" + my_level() + "\n");
    out.append("adventures=" + my_adventures() + "\n");
    out.append("hp=" + my_hp() + "/" + my_maxhp() + "\n");
    out.append("mp=" + my_mp() + "/" + my_maxmp() + "\n");
    return out.to_string();
}

/**
 * Build concise machine-readable test context.
 *
 * Parameters: See signature; parameters are read-only inputs unless noted.
 * Return: Returns string.
 * Side effects: PURE
 * Failure behavior: Returns an empty/default value when the requested state cannot be derived.
 * Source inspiration: https://github.com/IronTetsubo/KoLmafia-ash/blob/master/scripts/testout.ash
 * New implementation: This function was designed for this library and is not a renamed upstream function.
 * Agent schema: Native ASH return type; strings use documented key/value or TSV form where applicable.
 * Determinism: Deterministic for identical inputs/current KoLmafia state.
 */
string aal_testout_agent_context(agent_diagnostic[int] results) {
    buffer out;
    out.append(aal_testout_summary(results));
    int emitted;
    foreach i, d in results {
        if (d.passed) continue;
        if (emitted >= 10) break;
        out.append("failure=" + d.name + ";expected=" + d.expected + ";actual=" + d.actual + "\n");
        emitted = emitted + 1;
    }
    return out.to_string();
}
