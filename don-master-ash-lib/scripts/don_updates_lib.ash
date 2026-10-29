// DON updates library. MIT-derived adaptation of Prusias-kol/pUpdates.
// Historical upstream: https://github.com/Prusias-kol/pUpdates
// Original copyright (c) 2023 Prusias-kol. Preserve upstream MIT notice.
// Experimental; use at your own risk. No I/O happens merely by importing.
script "don_updates_lib";

string don_updates_path(string name) {
    return "dUpdates/prusias_pUpdates_" + name + ".txt";
}

string don_updates_legacy_path(string name) {
    return "pUpdates/prusias_pUpdates_" + name + ".txt";
}

boolean don_updates_valid_name(string name) {
    if (length(name) < 1 || length(name) > 64) return false;
    matcher name_match = create_matcher("^[A-Za-z0-9_-]+$", name);
    return find(name_match);
}

boolean don_updates_read(string name, string[int] entries) {
    if (!don_updates_valid_name(name)) return false;
    if (file_to_map(don_updates_path(name), entries) && (entries contains -1)) return true;
    clear(entries);
    return file_to_map(don_updates_legacy_path(name), entries) && (entries contains -1);
}

boolean don_updates_version_ok(string[int] entries) {
    if (!(entries contains -1)) return false;
    if (!is_integer(entries[-1])) return false;
    int latest = entries[-1].to_int();
    return latest >= 0 && latest <= 10000 && (entries contains 0);
}

boolean don_updates_init(string name) {
    if (!don_updates_valid_name(name)) {
        print("dUpdates: invalid script name (use 1-64 letters, numbers, _ or -).", "red");
        return false;
    }
    string[int] existing;
    if (don_updates_read(name, existing)) {
        print("dUpdates: data already exists; refusing to overwrite " + name + ".", "red");
        return false;
    }
    string[int] updates;
    updates[-1] = "0";
    updates[0] = "pUpdates for " + name + " are now installed";
    if (!map_to_file(updates, don_updates_path(name))) {
        print("dUpdates: unable to write initial update file.", "red");
        return false;
    }
    print("dUpdates: initialized " + name + ".", "teal");
    return true;
}

boolean don_updates_add(string name, string note) {
    if (!don_updates_valid_name(name) || length(note) < 1 || length(note) > 2048) {
        print("dUpdates: invalid name or update length (1-2048 characters).", "red");
        return false;
    }
    string[int] updates;
    if (!don_updates_read(name, updates) || !don_updates_version_ok(updates)) {
        print("dUpdates: missing or invalid update file; initialize first.", "red");
        return false;
    }
    int current = updates[-1].to_int();
    if (current >= 10000) {
        print("dUpdates: maximum number of updates reached.", "red");
        return false;
    }
    updates[current + 1] = note;
    updates[-1] = to_string(current + 1);
    if (!map_to_file(updates, don_updates_path(name))) {
        print("dUpdates: failed to save; local version not advanced.", "red");
        return false;
    }
    print("dUpdates: update recorded for " + name + ".", "teal");
    return true;
}

boolean don_updates_check(string name) {
    if (!don_updates_valid_name(name)) {
        print("dUpdates: invalid script name.", "red");
        return false;
    }
    string[int] updates;
    if (!don_updates_read(name, updates) || !don_updates_version_ok(updates)) {
        print("dUpdates: no valid update data for " + name + "; preference unchanged.", "red");
        return false;
    }
    int latest = updates[-1].to_int();
    string prop = "prusias_pUpdates_" + name + "_localVersion";
    string raw = get_property(prop);
    int last_seen = -1;
    if (is_integer(raw)) last_seen = raw.to_int();
    if (last_seen > latest) last_seen = latest;
    if (last_seen < -1) last_seen = -1;
    if (latest == last_seen) return true;
    print("---- " + name + " latest updates ----", "teal");
    for i from (last_seen + 1) to latest {
        if (updates contains i) {
            // Plain text output: never interpret community-supplied notes as HTML.
            print(to_string(i) + " - " + updates[i]);
        }
    }
    // Only mark seen after reading a verified file and printing the entries.
    set_property(prop, to_string(latest));
    return true;
}
