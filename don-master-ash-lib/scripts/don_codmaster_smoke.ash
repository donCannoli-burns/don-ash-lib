script "don_codmaster_smoke.ash";
import <don_codmaster_lib.ash>;

// Read-only structural tests; no save writes or equipment changes.
void main() {
    if (!don_cod_valid_name("spell")) abort("spell preset rejected");
    if (don_cod_save_path("spell") != "cod_master/saves/spell.txt")
        abort("legacy spell.txt path changed");
    if (don_cod_valid_name("../spell") || don_cod_valid_name("a/b") ||
        don_cod_valid_name("a.b") || don_cod_valid_name(""))
        abort("unsafe save name accepted");
    string [string] valid;
    for (int i = 1; i <= 5; i = i + 1)
        valid[don_cod_slot_key(i)] = to_string(to_int($item[unblemished pearl]));
    if (!don_cod_valid_config(valid)) abort("valid legacy map rejected");
    valid["cod_master_Slot_3"] = "not-a-number";
    if (don_cod_valid_config(valid)) abort("invalid numeric value accepted");
    print("don_codmaster_lib read-only smoke PASS.", "green");
}
