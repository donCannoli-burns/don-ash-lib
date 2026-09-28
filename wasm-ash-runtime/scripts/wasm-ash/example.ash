import <wasm-ash/runtime.ash>;

void main() {
    if (!wasm_load_hex_file("wasm-ash/examples/add.hex")) {
        abort("Could not load Wasm: " + wasm_error());
    }

    wasm_print_module_info();

    int answer = wasm_invoke2("add", 7, 35);
    if (wasm_error() != "") {
        abort("Wasm trap: " + wasm_error());
    }
    if (answer == 42) print("add(7, 35) = " + answer, "green");
    else print("add(7, 35) = " + answer, "red");

    int doubled = wasm_invoke1("double", 21);
    if (wasm_error() != "") {
        abort("Wasm trap: " + wasm_error());
    }
    if (doubled == 42) print("double(21) = " + doubled, "green");
    else print("double(21) = " + doubled, "red");
}
