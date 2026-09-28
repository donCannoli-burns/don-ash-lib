import <wasm-ash/runtime.ash>;

void wasm_cli_usage() {
    print("wasm-ash — tiny WebAssembly interpreter in ASH", "blue");
    print("Usage:");
    print("  call wasm-ash/wasm-ash.ash selftest");
    print("  call wasm-ash/wasm-ash.ash info <hex-file>");
    print("  call wasm-ash/wasm-ash.ash run <hex-file> <export> [i32 args...]");
    print("");
    print("Example:");
    print("  call wasm-ash/wasm-ash.ash run wasm-ash/examples/add.hex add 7 35");
}

boolean wasm_cli_load(string path) {
    if (!wasm_load_hex_file(path)) {
        print("wasm-ash load failed: " + wasm_error(), "red");
        return false;
    }
    return true;
}

boolean wasm_selftest_case(string label, int actual, int expected) {
    if (wasm_error() != "") {
        print("FAIL " + label + ": " + wasm_error(), "red");
        return false;
    }
    if (actual != expected) {
        print("FAIL " + label + ": expected " + expected + ", got " + actual, "red");
        return false;
    }
    print("PASS " + label + " = " + actual, "green");
    return true;
}

boolean wasm_run_selftest() {
    // Actual Wasm v1 binary containing:
    //   (func (export "add") (param i32 i32) (result i32)
    //     local.get 0 local.get 1 i32.add)
    //   (func (export "double") (param i32) (result i32)
    //     local.get 0 local.get 0 call 0)
    string module_hex =
        "0061736d01000000" +
        "010c0260027f7f017f60017f017f" +
        "0303020001" +
        "07100203616464000006646f75626c650001" +
        "0a12020700200020016a0b08002000200010000b";

    if (!wasm_load_hex(module_hex)) {
        print("FAIL load: " + wasm_error(), "red");
        return false;
    }

    boolean ok = true;
    ok = wasm_selftest_case("add(7,35)", wasm_invoke2("add", 7, 35), 42) && ok;
    ok = wasm_selftest_case("add(-5,2)", wasm_invoke2("add", -5, 2), -3) && ok;
    ok = wasm_selftest_case("double(21)", wasm_invoke1("double", 21), 42) && ok;

    if (ok) print("wasm-ash selftest PASS", "green");
    else print("wasm-ash selftest FAIL", "red");
    return ok;
}

void main(string command) {
    string [int] argv = split_string(command, "\\s+");
    if (count(argv) == 0 || argv[0] == "" || argv[0] == "help" || argv[0] == "--help") {
        wasm_cli_usage();
        return;
    }

    if (argv[0] == "selftest") {
        wasm_run_selftest();
        return;
    }

    if (argv[0] == "info") {
        if (count(argv) < 2) {
            wasm_cli_usage();
            return;
        }
        if (wasm_cli_load(argv[1])) wasm_print_module_info();
        return;
    }

    if (argv[0] == "run") {
        if (count(argv) < 3) {
            wasm_cli_usage();
            return;
        }
        if (!wasm_cli_load(argv[1])) return;

        int [int] args;
        if (count(argv) > 3) {
            for i from 3 to count(argv) - 1 {
                args[i - 3] = to_int(argv[i]);
            }
        }

        int result = wasm_invoke(argv[2], args);
        if (wasm_error() != "") {
            print("wasm-ash trap: " + wasm_error(), "red");
            return;
        }
        if (wasm_last_had_result) print("Returned: " + result, "green");
        else print("Returned: void", "green");
        return;
    }

    wasm_cli_usage();
}
