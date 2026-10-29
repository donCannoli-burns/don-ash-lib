script "don_bone_smoke.ash";
import <don_bone_lib.ash>;

// Read-only. No gameplay, user prompts, or preference writes.
void main() {
    int total = don_bone_daily_drops();
    int rests = don_bone_rest_drops();
    if (total < 0 || rests < 0) abort("Bone counters must be nonnegative.");
    if (don_bone_adventure_drops() != max(0, total - rests))
        abort("Adventure bone counter is inconsistent.");
    if (don_bone_remaining(100) != max(0, 100 - total))
        abort("Remaining-bone calculation is inconsistent.");
    if (don_bone_owned_amount($item[knucklebone]) < 0)
        abort("Owned amount must be nonnegative.");
    print("don_bone_lib read-only smoke PASS: " + total + " total, " +
        rests + " from rests, " + don_bone_remaining(100) + " remaining.");
}
