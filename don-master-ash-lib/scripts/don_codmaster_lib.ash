script "don_codmaster_lib.ash";

// Absorbed codMaster shared helpers. Importing this file changes NO state.
// Existing KoLmafia map_to_file format, savefile and preferences are preserved.
string DON_COD_SAVE_DIR = "data/cod_master/saves/";

boolean don_cod_valid_name(string name) {
    if (length(name) < 1 || length(name) > 64) return false;
    string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-";
    for (int i = 0; i < length(name); i = i + 1) {
        if (!contains_text(alphabet, substring(name, i, i + 1))) return false;
    }
    return true;
}

string don_cod_save_path(string name) {
    if (!don_cod_valid_name(name)) return "";
    return DON_COD_SAVE_DIR + name + ".txt";
}

// Legacy saved files are KoLmafia string maps keyed cod_master_Slot_1 ... _5.
string don_cod_slot_key(int i) {
    return "cod_master_Slot_" + i;
}

boolean don_cod_valid_item_id(string value) {
    int id = to_int(value);
    if (id < 0 || to_string(id) != value) return false;
    if (id == 0) return true; // empty gem slot
    return to_item(id) != $item[none];
}

boolean don_cod_valid_config(string [string] config) {
    for (int i = 1; i <= 5; i = i + 1) {
        string value = config[don_cod_slot_key(i)];
        if (!don_cod_valid_item_id(value)) return false;
    }
    // Reject unexpected keys rather than letting a save set arbitrary preferences.
    foreach key, value in config {
        boolean known = false;
        for (int i = 1; i <= 5; i = i + 1)
            if (key == don_cod_slot_key(i)) known = true;
        if (!known) return false;
    }
    return true;
}

boolean don_cod_read(string name, string [string] config) {
    string savefile = don_cod_save_path(name);
    if (savefile == "") return false;
    if (!file_to_map(savefile, config)) return false;
    return don_cod_valid_config(config);
}

// Save exactly five keys and verify persisted bytes through file_to_map.
// Existing saves are never overwritten unless overwrite is explicitly true.
boolean don_cod_write(string name, string [string] config, boolean overwrite) {
    string savefile = don_cod_save_path(name);
    if (savefile == "" || !don_cod_valid_config(config)) return false;
    string [string] old;
    if (!overwrite && file_to_map(savefile, old)) return false;
    if (!map_to_file(config, savefile)) return false;
    string [string] persisted;
    if (!file_to_map(savefile, persisted) || !don_cod_valid_config(persisted)) return false;
    for (int i = 1; i <= 5; i = i + 1)
        if (persisted[don_cod_slot_key(i)] != config[don_cod_slot_key(i)]) return false;
    string registry = get_property("cod_master_validSaves");
    boolean known = false;
    string [int] entries = split_string(registry, ",");
    foreach k, entry in entries {
        if (entry == name) known = true;
    }
    if (!known)
        set_property("cod_master_validSaves", registry == "" ? name : registry + "," + name);
    return true;
}

boolean don_cod_current_preferences(string [string] config) {
    for (int i = 1; i <= 5; i = i + 1)
        config[don_cod_slot_key(i)] = get_property(don_cod_slot_key(i));
    return don_cod_valid_config(config);
}

boolean don_cod_save_preferences(string name, boolean overwrite) {
    string [string] config;
    if (!don_cod_current_preferences(config)) return false;
    return don_cod_write(name, config, overwrite);
}

boolean don_cod_load_preferences(string name) {
    string [string] config;
    if (!don_cod_read(name, config)) return false;
    for (int i = 1; i <= 5; i = i + 1)
        set_property(don_cod_slot_key(i), config[don_cod_slot_key(i)]);
    return true;
}

// Capture actual codpiece auxiliary equipment slots, not get_property(slot).
boolean don_cod_capture(string [string] config) {
    for (int i = 1; i <= 5; i = i + 1) {
        slot target = to_slot("codpiece" + i);
        if (target == $slot[none]) return false;
        config[don_cod_slot_key(i)] = to_string(to_int(equipped_item(target)));
    }
    return don_cod_valid_config(config);
}

boolean don_cod_save_equipped(string name, boolean overwrite) {
    string [string] config;
    if (!don_cod_capture(config)) return false;
    return don_cod_write(name, config, overwrite);
}

// Preflight required inventory before any slot change. Failed individual
// equip stops immediately; it is NOT an atomic five-slot transaction.
boolean don_cod_equip_config(string [string] config) {
    if (!don_cod_valid_config(config)) return false;
    if (available_amount($item[The Eternity Codpiece]) <= 0) return false;
    int [item] needed;
    for (int i = 1; i <= 5; i = i + 1) {
        slot target = to_slot("codpiece" + i);
        if (target == $slot[none]) return false;
        item wanted = to_item(to_int(config[don_cod_slot_key(i)]));
        if (wanted != $item[none] && equipped_item(target) != wanted)
            needed[wanted] = needed[wanted] + 1;
    }
    foreach target, qty in needed {
        if (item_amount(target) < qty) {
            print("codMaster: missing " + target + " x" + (qty - item_amount(target)) + " in inventory.", "red");
            return false;
        }
    }
    for (int i = 1; i <= 5; i = i + 1) {
        slot target = to_slot("codpiece" + i);
        item wanted = to_item(to_int(config[don_cod_slot_key(i)]));
        if (equipped_item(target) == wanted) continue;
        if (!equip(target, wanted)) {
            print("codMaster: equip failed at slot " + i + "; later slots not changed.", "red");
            return false;
        }
        if (equipped_item(target) != wanted) {
            print("codMaster: slot " + i + " did not confirm expected gem.", "red");
            return false;
        }
    }
    for (int i = 1; i <= 5; i = i + 1)
        set_property(don_cod_slot_key(i), config[don_cod_slot_key(i)]);
    return true;
}

boolean don_cod_equip_saved(string name) {
    string [string] config;
    if (!don_cod_read(name, config)) return false;
    return don_cod_equip_config(config);
}

boolean don_cod_clear() {
    for (int i = 1; i <= 5; i = i + 1) {
        slot target = to_slot("codpiece" + i);
        if (target == $slot[none]) return false;
        if (equipped_item(target) != $item[none] && !equip(target, $item[none]))
            return false;
    }
    return true;
}

void don_cod_print_saved(string name) {
    string [string] config;
    if (!don_cod_read(name, config)) {
        print("codMaster: no valid save named '" + name + "' at " + don_cod_save_path(name), "orange");
        return;
    }
    print("codMaster preset " + name + " (" + don_cod_save_path(name) + "):", "blue");
    for (int i = 1; i <= 5; i = i + 1) {
        int id = to_int(config[don_cod_slot_key(i)]);
        print("  slot " + i + ": " + to_item(id) + " (#" + id + ")");
    }
}
