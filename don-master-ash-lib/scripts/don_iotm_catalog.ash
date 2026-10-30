script "don_iotm_catalog.ash";

/*
 * DON Item-of-the-Month capability catalog (read-only)
 *
 * This is an authored, namespaced capability index informed by the public
 * C2Talon/liba and C2Talon/c2t_kol_scripts interfaces. No upstream
 * implementations are embedded or automatically executed.
 *
 * Importing or calling these functions does not visit URLs, submit choices,
 * change preferences, purchase anything, equip items, or spend adventures.
 *
 * The catalog describes candidates, NOT grants of authority to execute.
 * Future executors must use explicit typed routing, preflight, readback, and
 * user-controlled policy, not eval/CLI injection by arbitrary key.
 */

record don_iotm_capability {
    string key;
    string resource;
    string action;
    string upstream;
    int choice_id;
    int option;
    int familiar_experience_cost;
    string usage_property;
    string mode_property;
};

don_iotm_capability[int] don_iotm_catalog() {
    don_iotm_capability[int] out;

    out[0] = new don_iotm_capability(
        "cooler-yeti-adventures", "cooler yeti", "cool next drink / double adventures",
        "C2Talon/liba:liba_coolerYeti", 1560, 2, 400,
        "_coolerYetiAdventures", "coolerYetiMode"
    );
    out[1] = new don_iotm_capability(
        "cooler-yeti-effect", "cooler yeti", "Looking Cool effect for next drink",
        "C2Talon/liba:liba_coolerYeti", 1560, 3, 225,
        "", "coolerYetiMode"
    );
    out[2] = new don_iotm_capability(
        "cooler-yeti-ingredients", "cooler yeti", "ingredients from next drink",
        "C2Talon/liba:liba_coolerYeti", 1560, 4, 100,
        "", "coolerYetiMode"
    );
    out[3] = new don_iotm_capability(
        "cooler-yeti-stats", "cooler yeti", "stats from next drink",
        "C2Talon/liba:liba_coolerYeti", 1560, 5, 25,
        "", "coolerYetiMode"
    );
    out[4] = new don_iotm_capability(
        "mayam-calendar", "Mayam Calendar", "inspect used symbols / resonance candidates",
        "C2Talon/c2t_kol_scripts:c2t_mayam", 0, 0, 0,
        "_mayamSymbolsUsed", ""
    );
    out[5] = new don_iotm_capability(
        "model-train-set", "model train set", "validate 8-part configuration before change",
        "C2Talon/c2t_kol_scripts:c2t_trainSet", 1485, 1, 0,
        "", ""
    );
    out[6] = new don_iotm_capability(
        "chest-mimic", "chest mimic", "read egg/max-donation tracking candidates",
        "C2Talon/c2t_megg:c2t_megg", 0, 0, 0,
        "", ""
    );
    out[7] = new don_iotm_capability(
        "peridot-of-peril", "Peridot of Peril", "target monster and location selection",
        "C2Talon/liba:liba_peridot", 1557, 0, 0,
        "", ""
    );
    out[8] = new don_iotm_capability(
        "eternity-codpiece", "the eternity codpiece", "read/plan 5 gem slots",
        "C2Talon/liba:liba_eternityCodpiece", 0, 0, 0,
        "", ""
    );
    out[9] = new don_iotm_capability(
        "heartstone", "heartstone", "skill and effect planning",
        "C2Talon/liba:liba_heartstone", 0, 0, 0,
        "", ""
    );

    return out;
}

don_iotm_capability don_iotm_find(string key) {
    don_iotm_capability[int] entries = don_iotm_catalog();
    foreach i, entry in entries {
        if (entry.key == key) return entry;
    }
    don_iotm_capability unknown;
    return unknown;
}

// Returns only observational hints, not a permission or guaranteed readiness.
string don_iotm_status(string key) {
    don_iotm_capability entry = don_iotm_find(key);
    if (entry.key == "") return "unknown capability";

    if (key.starts_with("cooler-yeti-")) {
        familiar yeti = $familiar[cooler yeti];
        if (!have_familiar(yeti)) return "cooler yeti not owned";
        return "owned; experience=" + yeti.experience +
            "; usedAdventures=" + get_property("_coolerYetiAdventures") +
            "; mode=" + get_property("coolerYetiMode");
    }

    if (key == "mayam-calendar") {
        return "available_amount=" + available_amount($item[Mayam Calendar]) +
            "; usedSymbols=" + get_property("_mayamSymbolsUsed");
    }
    if (key == "model-train-set") {
        return "workshed=" + get_workshed() +
            "; installed=" + (get_workshed() == $item[model train set]);
    }
    if (key == "chest-mimic") {
        return "owned=" + have_familiar($familiar[chest mimic]);
    }
    if (key == "peridot-of-peril") {
        return "direct available_amount=" + available_amount($item[Peridot of Peril]) +
            "; NOTE: gems mounted in codpiece require a separate check";
    }
    if (key == "eternity-codpiece") {
        return "available_amount=" + available_amount($item[the eternity codpiece]);
    }
    if (key == "heartstone") {
        return "direct available_amount=" + available_amount($item[heartstone]) +
            "; NOTE: gems mounted in codpiece require a separate check";
    }

    return "cataloged; no observation adapter";
}
