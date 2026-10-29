script "don_bone_lib.ash";

// Read-only, import-safe Skeleton of Crimbo Past / knucklebone helpers.
// _knuckleboneDrops ALREADY includes daily rest drops; never add rests to it.
// Live preferences are read on every call. This file never adventures or writes prefs.

int don_bone_daily_drops() {
    return max(0, get_property("_knuckleboneDrops").to_int());
}

int don_bone_rest_drops() {
    return max(0, get_property("_knuckleboneRests").to_int());
}

int don_bone_adventure_drops() {
    return max(0, don_bone_daily_drops() - don_bone_rest_drops());
}

int don_bone_remaining(int daily_cap) {
    return max(0, daily_cap - don_bone_daily_drops());
}

// Keep boneTrack's legacy ownership accounting unchanged.
// Does not auto-retrieve/withdraw items; familiar-slot details are not expanded.
int don_bone_owned_amount(item target) {
    return item_amount(target) + closet_amount(target) +
        storage_amount(target) + display_amount(target) + equipped_amount(target);
}
