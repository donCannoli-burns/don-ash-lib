script "don_train_plan.ash";

/*
 * Pure Model Train Set configuration validator.
 * Inspired by C2Talon/c2t_kol_scripts/c2t_trainSet.ash (MIT).
 *
 * No URL submissions, choices, preference writes, or workshed mutations.
 * Train configuration choice 1485 must be performed by an explicitly
 * authorized caller after an independent readiness check.
 */

// Returns "" for a valid, canonical eight-station string; otherwise reason.
string don_train_layout_error(string configuration) {
    string[int] stations = split_string(configuration, ",");
    if (count(stations) != 8) return "Expected exactly eight stations.";

    boolean[int] seen;
    foreach index, token in stations {
        if (token == "" || token != to_string(to_int(token)))
            return "Station " + (index + 1) + " is not a canonical integer.";

        int id = to_int(token);
        if (id < 1 || id > 20 || id == 10)
            return "Station " + (index + 1) + " has an invalid train piece " + token + ".";

        if (seen[id])
            return "Train piece " + id + " is duplicated.";

        seen[id] = true;
    }
    return "";
}

boolean don_train_layout_valid(string configuration) {
    return don_train_layout_error(configuration) == "";
}
