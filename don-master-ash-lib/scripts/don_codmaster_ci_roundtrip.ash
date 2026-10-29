script "don_codmaster_ci_roundtrip.ash";
import <don_codmaster_lib.ash>;

// ONLY run in disposable CI profile. Creates a namespaced test save.
// Never use this as routine player smoke or overwrite spell.txt.
void main() {
    string name = "__don_cod_ci_roundtrip";
    string [string] config;
    for (int i = 1; i <= 5; i = i + 1)
        config[don_cod_slot_key(i)] = to_string(to_int($item[unblemished pearl]));
    if (!don_cod_write(name, config, false)) abort("roundtrip write failed");
    string [string] result;
    if (!don_cod_read(name, result)) abort("roundtrip read failed");
    for (int i = 1; i <= 5; i = i + 1)
        if (result[don_cod_slot_key(i)] != config[don_cod_slot_key(i)])
            abort("roundtrip changed slot " + i);
    if (don_cod_write(name, config, false)) abort("existing preset overwritten without approval");
    print("don_codmaster_lib CI disk roundtrip PASS.", "green");
}
