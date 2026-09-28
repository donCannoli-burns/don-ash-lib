// wasm-ash/runtime.ash
// Tiny, read-only WebAssembly interpreter written in KoLmafia ASH.
//
// v0.1 execution profile:
//   * actual Wasm binary format supplied as hexadecimal text
//   * Wasm MVP version 1
//   * i32 values only
//   * type/function/export/code sections
//   * locals, direct calls, constants, comparisons, integer arithmetic/bitwise
//   * no imports, memory, tables, globals, host functions, blocks/loops/branches
//
// The lack of host imports is deliberate: guest bytecode cannot invoke KoLmafia
// runtime functions or mutate game state through this interpreter.

record WasmImmediate {
    boolean ok;
    int value;
    int next;
};

// Raw module bytes.
int [int] wasm_bytes;
int wasm_byte_count = 0;
int wasm_parse_pos = 0;

// Type section.
int [int] wasm_type_param_count;
int [int] wasm_type_result_count;
int [int, int] wasm_type_params;
int [int, int] wasm_type_results;
int wasm_type_count = 0;

// Function + code sections. Imported functions are intentionally unsupported,
// so Wasm function indices are identical to these defined-function indices.
int [int] wasm_func_type;
int [int] wasm_func_local_count;
int [int, int] wasm_func_local_type;
int [int] wasm_func_code_len;
int [int, int] wasm_func_code;
int wasm_function_count = 0;

// Export section.
int [string] wasm_export_kind;
int [string] wasm_export_index;

boolean wasm_module_loaded = false;
string wasm_last_error = "";
boolean wasm_last_had_result = false;

// Runtime guards.
int wasm_default_fuel = 100000;
int wasm_fuel_remaining = 0;
int wasm_max_call_depth = 64;
int wasm_max_module_bytes = 1048576;

boolean wasm_fail(string message) {
    wasm_last_error = message;
    return false;
}

string wasm_error() {
    return wasm_last_error;
}

void wasm_clear_module() {
    clear(wasm_bytes);
    clear(wasm_type_param_count);
    clear(wasm_type_result_count);
    clear(wasm_type_params);
    clear(wasm_type_results);
    clear(wasm_func_type);
    clear(wasm_func_local_count);
    clear(wasm_func_local_type);
    clear(wasm_func_code_len);
    clear(wasm_func_code);
    clear(wasm_export_kind);
    clear(wasm_export_index);

    wasm_byte_count = 0;
    wasm_parse_pos = 0;
    wasm_type_count = 0;
    wasm_function_count = 0;
    wasm_module_loaded = false;
    wasm_last_error = "";
    wasm_last_had_result = false;
}

int wasm_i32(int value) {
    // ASH ints are signed 64-bit. WebAssembly i32 arithmetic wraps modulo 2^32.
    int masked = value & 4294967295;
    if (masked >= 2147483648) {
        return masked - 4294967296;
    }
    return masked;
}

int wasm_u32(int value) {
    int normalized = wasm_i32(value);
    if (normalized < 0) {
        return normalized + 4294967296;
    }
    return normalized;
}

int wasm_hex_nibble(string ch) {
    string digits = "0123456789abcdef";
    int p = index_of(digits, to_lower_case(ch));
    return p;
}

boolean wasm_is_ignored_hex_char(string ch) {
    return ch == " " || ch == "\t" || ch == "\r" || ch == "\n" || ch == "," || ch == ":";
}

boolean wasm_decode_hex(string text) {
    clear(wasm_bytes);
    wasm_byte_count = 0;

    if (length(text) == 0) {
        return wasm_fail("Wasm input is empty");
    }

    int high = -1;
    for i from 0 to length(text) - 1 {
        string ch = char_at(text, i);
        if (wasm_is_ignored_hex_char(ch)) {
            continue;
        }

        int nibble = wasm_hex_nibble(ch);
        if (nibble < 0) {
            return wasm_fail("Invalid character in Wasm hex input at character " + i + ": '" + ch + "'");
        }

        if (high < 0) {
            high = nibble;
        } else {
            if (wasm_byte_count >= wasm_max_module_bytes) {
                return wasm_fail("Wasm module exceeds byte limit " + wasm_max_module_bytes);
            }
            wasm_bytes[wasm_byte_count] = high * 16 + nibble;
            wasm_byte_count += 1;
            high = -1;
        }
    }

    if (high >= 0) {
        return wasm_fail("Odd number of hexadecimal digits in Wasm input");
    }
    if (wasm_byte_count == 0) {
        return wasm_fail("Wasm input is empty");
    }
    return true;
}

string wasm_strip_hex_comment(string line) {
    int p = index_of(line, "#");
    if (p >= 0) {
        line = substring(line, 0, p);
    }
    p = index_of(line, "//");
    if (p >= 0) {
        line = substring(line, 0, p);
    }
    return line;
}

int wasm_read_u8() {
    if (wasm_parse_pos < 0 || wasm_parse_pos >= wasm_byte_count) {
        wasm_fail("Unexpected end of Wasm module at byte " + wasm_parse_pos);
        return 0;
    }
    int value = wasm_bytes[wasm_parse_pos];
    wasm_parse_pos += 1;
    return value;
}

int wasm_read_u32_leb() {
    int result = 0;
    int shift = 0;
    for i from 0 to 4 {
        int b = wasm_read_u8();
        if (wasm_last_error != "") {
            return 0;
        }
        result = result | ((b & 127) << shift);
        if ((b & 128) == 0) {
            return result;
        }
        shift += 7;
    }
    wasm_fail("Invalid or oversized u32 LEB128 at byte " + wasm_parse_pos);
    return 0;
}

int wasm_read_i32_leb() {
    int result = 0;
    int shift = 0;
    int b = 0;

    for i from 0 to 4 {
        b = wasm_read_u8();
        if (wasm_last_error != "") {
            return 0;
        }
        result = result | ((b & 127) << shift);
        shift += 7;
        if ((b & 128) == 0) {
            if (shift < 32 && (b & 64) != 0) {
                result = result | (-1 << shift);
            }
            return wasm_i32(result);
        }
    }

    wasm_fail("Invalid or oversized i32 LEB128 at byte " + wasm_parse_pos);
    return 0;
}

string wasm_ascii_byte(int b) {
    if (b >= 48 && b <= 57) {
        return substring("0123456789", b - 48, b - 47);
    }
    if (b >= 65 && b <= 90) {
        return substring("ABCDEFGHIJKLMNOPQRSTUVWXYZ", b - 65, b - 64);
    }
    if (b >= 97 && b <= 122) {
        return substring("abcdefghijklmnopqrstuvwxyz", b - 97, b - 96);
    }
    if (b == 95) return "_";
    if (b == 45) return "-";
    if (b == 46) return ".";
    if (b == 36) return "$";
    return "";
}

string wasm_read_name() {
    int n = wasm_read_u32_leb();
    if (wasm_last_error != "") {
        return "";
    }

    buffer out;
    if (n > 0) {
        for i from 0 to n - 1 {
            int b = wasm_read_u8();
            if (wasm_last_error != "") {
                return "";
            }
            string ch = wasm_ascii_byte(b);
            if (ch == "") {
                wasm_fail("v0.1 supports ASCII export names [A-Za-z0-9_.$-] only; got byte " + b);
                return "";
            }
            append(out, ch);
        }
    }
    return to_string(out);
}

boolean wasm_expect_section_end(int section_end, string section_name) {
    if (wasm_last_error != "") {
        return false;
    }
    if (wasm_parse_pos != section_end) {
        return wasm_fail(section_name + " section length mismatch: parser ended at " + wasm_parse_pos + ", expected " + section_end);
    }
    return true;
}

boolean wasm_parse_type_section(int section_end) {
    int count_types = wasm_read_u32_leb();
    if (wasm_last_error != "") return false;
    wasm_type_count = count_types;

    if (count_types > 0) {
        for t from 0 to count_types - 1 {
            int form = wasm_read_u8();
            if (form != 96) {
                return wasm_fail("Unsupported function type form 0x" + form + "; expected 0x60");
            }

            int pc = wasm_read_u32_leb();
            wasm_type_param_count[t] = pc;
            if (pc > 0) {
                for p from 0 to pc - 1 {
                    int value_type = wasm_read_u8();
                    if (value_type != 127) {
                        return wasm_fail("v0.1 supports i32 parameters only (type " + t + ", parameter " + p + ")");
                    }
                    wasm_type_params[t, p] = value_type;
                }
            }

            int rc = wasm_read_u32_leb();
            if (rc > 1) {
                return wasm_fail("v0.1 supports at most one function result (type " + t + ")");
            }
            wasm_type_result_count[t] = rc;
            if (rc > 0) {
                for r from 0 to rc - 1 {
                    int value_type = wasm_read_u8();
                    if (value_type != 127) {
                        return wasm_fail("v0.1 supports i32 results only (type " + t + ")");
                    }
                    wasm_type_results[t, r] = value_type;
                }
            }
        }
    }
    return wasm_expect_section_end(section_end, "type");
}

boolean wasm_parse_function_section(int section_end) {
    int n = wasm_read_u32_leb();
    if (wasm_last_error != "") return false;
    wasm_function_count = n;

    if (n > 0) {
        for f from 0 to n - 1 {
            int type_index = wasm_read_u32_leb();
            if (type_index < 0 || type_index >= wasm_type_count) {
                return wasm_fail("Function " + f + " references missing type " + type_index);
            }
            wasm_func_type[f] = type_index;
        }
    }
    return wasm_expect_section_end(section_end, "function");
}

boolean wasm_parse_export_section(int section_end) {
    int n = wasm_read_u32_leb();
    if (wasm_last_error != "") return false;

    if (n > 0) {
        for e from 0 to n - 1 {
            string name = wasm_read_name();
            if (wasm_last_error != "") return false;
            if (wasm_export_kind contains name) {
                return wasm_fail("Duplicate Wasm export name: " + name);
            }
            int kind = wasm_read_u8();
            int index = wasm_read_u32_leb();
            if (kind != 0) {
                return wasm_fail("v0.1 supports function exports only; export '" + name + "' has kind " + kind);
            }
            wasm_export_kind[name] = kind;
            wasm_export_index[name] = index;
        }
    }
    return wasm_expect_section_end(section_end, "export");
}

boolean wasm_parse_code_section(int section_end) {
    int n = wasm_read_u32_leb();
    if (wasm_last_error != "") return false;
    if (n != wasm_function_count) {
        return wasm_fail("Code/function count mismatch: code=" + n + ", functions=" + wasm_function_count);
    }

    if (n > 0) {
        for f from 0 to n - 1 {
        int body_size = wasm_read_u32_leb();
        int body_end = wasm_parse_pos + body_size;
        if (body_end > section_end || body_end > wasm_byte_count) {
            return wasm_fail("Function " + f + " body exceeds code section");
        }

        int local_groups = wasm_read_u32_leb();
        int expanded = 0;
        if (local_groups > 0) {
            for g from 0 to local_groups - 1 {
                int local_count = wasm_read_u32_leb();
                int local_type = wasm_read_u8();
                if (local_type != 127) {
                    return wasm_fail("v0.1 supports i32 locals only (function " + f + ")");
                }
                if (local_count < 0 || expanded + local_count > 10000) {
                    return wasm_fail("Unreasonable local count in function " + f);
                }
                if (local_count > 0) {
                    for j from 0 to local_count - 1 {
                        wasm_func_local_type[f, expanded] = local_type;
                        expanded += 1;
                    }
                }
            }
        }
        wasm_func_local_count[f] = expanded;

        int code_len = body_end - wasm_parse_pos;
        if (code_len <= 0) {
            return wasm_fail("Function " + f + " has an empty instruction stream");
        }
        wasm_func_code_len[f] = code_len;
        for pc from 0 to code_len - 1 {
            wasm_func_code[f, pc] = wasm_read_u8();
        }
        if (wasm_func_code[f, code_len - 1] != 11) {
            return wasm_fail("Function " + f + " does not terminate with end (0x0b)");
        }
        if (wasm_parse_pos != body_end) {
            return wasm_fail("Function " + f + " body length mismatch");
        }
        }
    }
    return wasm_expect_section_end(section_end, "code");
}

boolean wasm_parse_module() {
    wasm_parse_pos = 0;
    wasm_last_error = "";

    if (wasm_byte_count < 8) {
        return wasm_fail("Wasm module is shorter than the 8-byte header");
    }

    int [int] expected = { 0, 97, 115, 109, 1, 0, 0, 0 };
    for i from 0 to 7 {
        int got = wasm_read_u8();
        if (got != expected[i]) {
            return wasm_fail("Invalid Wasm magic/version at byte " + i + ": got " + got + ", expected " + expected[i]);
        }
    }

    boolean saw_type = false;
    boolean saw_function = false;
    boolean saw_code = false;
    int last_standard_section = 0;

    while (wasm_parse_pos < wasm_byte_count) {
        int section_id = wasm_read_u8();
        int section_size = wasm_read_u32_leb();
        if (wasm_last_error != "") return false;
        int section_end = wasm_parse_pos + section_size;
        if (section_end < wasm_parse_pos || section_end > wasm_byte_count) {
            return wasm_fail("Section " + section_id + " exceeds module bounds");
        }
        if (section_id != 0) {
            if (section_id <= last_standard_section) {
                return wasm_fail("Duplicate or out-of-order standard section " + section_id);
            }
            last_standard_section = section_id;
        }

        if (section_id == 0) {
            // Custom sections are metadata; skip them.
            wasm_parse_pos = section_end;
        } else if (section_id == 1) {
            if (saw_type) return wasm_fail("Duplicate type section");
            saw_type = true;
            if (!wasm_parse_type_section(section_end)) return false;
        } else if (section_id == 2) {
            return wasm_fail("Imports are deliberately disabled in wasm-ash v0.1");
        } else if (section_id == 3) {
            if (!saw_type) return wasm_fail("Function section encountered before type section");
            if (saw_function) return wasm_fail("Duplicate function section");
            saw_function = true;
            if (!wasm_parse_function_section(section_end)) return false;
        } else if (section_id == 7) {
            if (!wasm_parse_export_section(section_end)) return false;
        } else if (section_id == 10) {
            if (!saw_function) return wasm_fail("Code section encountered before function section");
            if (saw_code) return wasm_fail("Duplicate code section");
            saw_code = true;
            if (!wasm_parse_code_section(section_end)) return false;
        } else {
            return wasm_fail("Unsupported Wasm section " + section_id + " in wasm-ash v0.1");
        }
    }

    if (!saw_type || !saw_function || !saw_code) {
        return wasm_fail("Module must contain type, function, and code sections");
    }

    foreach name in wasm_export_kind {
        if (wasm_export_kind[name] == 0) {
            int f = wasm_export_index[name];
            if (f < 0 || f >= wasm_function_count) {
                return wasm_fail("Function export '" + name + "' references missing function " + f);
            }
        }
    }

    wasm_module_loaded = true;
    return true;
}

boolean wasm_load_hex(string text) {
    wasm_clear_module();
    if (!wasm_decode_hex(text)) return false;
    if (!wasm_parse_module()) return false;
    return true;
}

boolean wasm_load_hex_file(string path) {
    wasm_clear_module();
    string [int] lines = file_to_array(path);
    if (count(lines) == 0) {
        return wasm_fail("Could not read Wasm hex file or file is empty: " + path);
    }

    buffer joined;
    foreach i in lines {
        append(joined, wasm_strip_hex_comment(lines[i]));
        append(joined, "\n");
    }
    return wasm_load_hex(to_string(joined));
}

WasmImmediate wasm_code_u32(int function_index, int pc) {
    WasmImmediate r;
    r.ok = false;
    r.next = pc;

    int result = 0;
    int shift = 0;
    for i from 0 to 4 {
        if (pc >= wasm_func_code_len[function_index]) {
            wasm_fail("Unexpected end of function " + function_index + " while decoding u32 LEB128");
            return r;
        }
        int b = wasm_func_code[function_index, pc];
        pc += 1;
        result = result | ((b & 127) << shift);
        if ((b & 128) == 0) {
            r.ok = true;
            r.value = result;
            r.next = pc;
            return r;
        }
        shift += 7;
    }
    wasm_fail("Invalid u32 LEB128 in function " + function_index);
    return r;
}

WasmImmediate wasm_code_i32(int function_index, int pc) {
    WasmImmediate r;
    r.ok = false;
    r.next = pc;

    int result = 0;
    int shift = 0;
    int b = 0;
    for i from 0 to 4 {
        if (pc >= wasm_func_code_len[function_index]) {
            wasm_fail("Unexpected end of function " + function_index + " while decoding i32 LEB128");
            return r;
        }
        b = wasm_func_code[function_index, pc];
        pc += 1;
        result = result | ((b & 127) << shift);
        shift += 7;
        if ((b & 128) == 0) {
            if (shift < 32 && (b & 64) != 0) {
                result = result | (-1 << shift);
            }
            r.ok = true;
            r.value = wasm_i32(result);
            r.next = pc;
            return r;
        }
    }
    wasm_fail("Invalid i32 LEB128 in function " + function_index);
    return r;
}

int wasm_pop_binary_rhs(int [int] stack, int sp) {
    return stack[sp - 1];
}

int wasm_pop_binary_lhs(int [int] stack, int sp) {
    return stack[sp - 2];
}

int wasm_exec_function(int function_index, int [int] args, int depth) {
    wasm_last_had_result = false;

    if (wasm_last_error != "") return 0;
    if (depth >= wasm_max_call_depth) {
        wasm_fail("Wasm call-depth limit exceeded (" + wasm_max_call_depth + ")");
        return 0;
    }
    if (function_index < 0 || function_index >= wasm_function_count) {
        wasm_fail("Call to missing function " + function_index);
        return 0;
    }

    int type_index = wasm_func_type[function_index];
    int param_count = wasm_type_param_count[type_index];
    int result_count = wasm_type_result_count[type_index];

    if (count(args) != param_count) {
        wasm_fail("Function " + function_index + " expects " + param_count + " arguments, got " + count(args));
        return 0;
    }

    int [int] locals;
    if (param_count > 0) {
        for i from 0 to param_count - 1 {
            if (!(args contains i)) {
                wasm_fail("Argument vector is sparse at index " + i);
                return 0;
            }
            locals[i] = wasm_i32(args[i]);
        }
    }
    int declared_locals = wasm_func_local_count[function_index];
    if (declared_locals > 0) {
        for i from 0 to declared_locals - 1 {
            locals[param_count + i] = 0;
        }
    }
    int total_locals = param_count + declared_locals;

    int [int] stack;
    int sp = 0;
    int pc = 0;

    while (pc < wasm_func_code_len[function_index]) {
        if (wasm_fuel_remaining <= 0) {
            wasm_fail("Wasm fuel exhausted");
            return 0;
        }
        wasm_fuel_remaining -= 1;

        int opcode = wasm_func_code[function_index, pc];
        pc += 1;

        if (opcode == 0) {
            wasm_fail("unreachable executed in function " + function_index);
            return 0;
        } else if (opcode == 1) {
            // nop
        } else if (opcode == 11 || opcode == 15) {
            if (result_count == 0) {
                if (sp != 0) {
                    wasm_fail("Void function " + function_index + " ended with " + sp + " value(s) on stack");
                    return 0;
                }
                wasm_last_had_result = false;
                return 0;
            }
            if (sp != 1) {
                wasm_fail("Function " + function_index + " expected exactly one result on stack, found " + sp);
                return 0;
            }
            wasm_last_had_result = true;
            return wasm_i32(stack[0]);
        } else if (opcode == 16) {
            WasmImmediate imm = wasm_code_u32(function_index, pc);
            if (!imm.ok) return 0;
            pc = imm.next;
            int callee = imm.value;
            if (callee < 0 || callee >= wasm_function_count) {
                wasm_fail("call references missing function " + callee);
                return 0;
            }
            int callee_type = wasm_func_type[callee];
            int n_args = wasm_type_param_count[callee_type];
            if (sp < n_args) {
                wasm_fail("Stack underflow preparing call to function " + callee);
                return 0;
            }
            int [int] call_args;
            if (n_args > 0) {
                for i from n_args - 1 downto 0 {
                    sp -= 1;
                    call_args[i] = stack[sp];
                    remove stack[sp];
                }
            }
            int call_result = wasm_exec_function(callee, call_args, depth + 1);
            if (wasm_last_error != "") return 0;
            if (wasm_type_result_count[callee_type] == 1) {
                stack[sp] = wasm_i32(call_result);
                sp += 1;
            }
        } else if (opcode == 26) {
            if (sp < 1) {
                wasm_fail("drop stack underflow");
                return 0;
            }
            sp -= 1;
            remove stack[sp];
        } else if (opcode == 27) {
            if (sp < 3) {
                wasm_fail("select stack underflow");
                return 0;
            }
            int condition = stack[sp - 1];
            int b = stack[sp - 2];
            int a = stack[sp - 3];
            sp -= 3;
            remove stack[sp];
            remove stack[sp + 1];
            remove stack[sp + 2];
            if (condition != 0) {
                stack[sp] = a;
            } else {
                stack[sp] = b;
            }
            sp += 1;
        } else if (opcode == 32 || opcode == 33 || opcode == 34) {
            WasmImmediate imm = wasm_code_u32(function_index, pc);
            if (!imm.ok) return 0;
            pc = imm.next;
            int local_index = imm.value;
            if (local_index < 0 || local_index >= total_locals) {
                wasm_fail("Local index out of range in function " + function_index + ": " + local_index);
                return 0;
            }
            if (opcode == 32) {
                stack[sp] = locals[local_index];
                sp += 1;
            } else if (opcode == 33) {
                if (sp < 1) {
                    wasm_fail("local.set stack underflow");
                    return 0;
                }
                sp -= 1;
                locals[local_index] = stack[sp];
                remove stack[sp];
            } else {
                if (sp < 1) {
                    wasm_fail("local.tee stack underflow");
                    return 0;
                }
                locals[local_index] = stack[sp - 1];
            }
        } else if (opcode == 65) {
            WasmImmediate imm = wasm_code_i32(function_index, pc);
            if (!imm.ok) return 0;
            pc = imm.next;
            stack[sp] = imm.value;
            sp += 1;
        } else if (opcode >= 69 && opcode <= 79) {
            if (opcode == 69) {
                if (sp < 1) {
                    wasm_fail("i32.eqz stack underflow");
                    return 0;
                }
                if (stack[sp - 1] == 0) {
                    stack[sp - 1] = 1;
                } else {
                    stack[sp - 1] = 0;
                }
            } else {
                if (sp < 2) {
                    wasm_fail("i32 comparison stack underflow");
                    return 0;
                }
                int b = wasm_i32(wasm_pop_binary_rhs(stack, sp));
                int a = wasm_i32(wasm_pop_binary_lhs(stack, sp));
                int truth = 0;
                if (opcode == 70) { if (a == b) truth = 1; }       // eq
                else if (opcode == 71) { if (a != b) truth = 1; }  // ne
                else if (opcode == 72) { if (a < b) truth = 1; }   // lt_s
                else if (opcode == 73) { if (wasm_u32(a) < wasm_u32(b)) truth = 1; } // lt_u
                else if (opcode == 74) { if (a > b) truth = 1; }   // gt_s
                else if (opcode == 75) { if (wasm_u32(a) > wasm_u32(b)) truth = 1; } // gt_u
                else if (opcode == 76) { if (a <= b) truth = 1; }  // le_s
                else if (opcode == 77) { if (wasm_u32(a) <= wasm_u32(b)) truth = 1; } // le_u
                else if (opcode == 78) { if (a >= b) truth = 1; }  // ge_s
                else if (opcode == 79) { if (wasm_u32(a) >= wasm_u32(b)) truth = 1; } // ge_u
                sp -= 2;
                remove stack[sp];
                remove stack[sp + 1];
                stack[sp] = truth;
                sp += 1;
            }
        } else if (opcode >= 106 && opcode <= 118) {
            if (sp < 2) {
                wasm_fail("i32 binary operator stack underflow (opcode " + opcode + ")");
                return 0;
            }
            int b = wasm_i32(wasm_pop_binary_rhs(stack, sp));
            int a = wasm_i32(wasm_pop_binary_lhs(stack, sp));
            int value = 0;

            if (opcode == 106) value = wasm_i32(a + b);          // add
            else if (opcode == 107) value = wasm_i32(a - b);     // sub
            else if (opcode == 108) value = wasm_i32(a * b);     // mul
            else if (opcode == 109) {                            // div_s
                if (b == 0) {
                    wasm_fail("i32.div_s division by zero");
                    return 0;
                }
                if (a == -2147483648 && b == -1) {
                    wasm_fail("i32.div_s signed overflow");
                    return 0;
                }
                value = wasm_i32(a / b);
            } else if (opcode == 111) {                           // rem_s
                if (b == 0) {
                    wasm_fail("i32.rem_s division by zero");
                    return 0;
                }
                value = wasm_i32(a % b);
            } else if (opcode == 113) value = wasm_i32(a & b);    // and
            else if (opcode == 114) value = wasm_i32(a | b);      // or
            else if (opcode == 115) value = wasm_i32(a ^ b);      // xor
            else if (opcode == 116) value = wasm_i32(a << (b & 31)); // shl
            else if (opcode == 117) value = wasm_i32(a >> (b & 31)); // shr_s
            else if (opcode == 118) {                             // shr_u
                int shift = b & 31;
                int divisor = 1 << shift;
                value = wasm_i32(wasm_u32(a) / divisor);
            } else {
                wasm_fail("Unsupported i32 opcode 0x" + opcode + " in function " + function_index);
                return 0;
            }

            sp -= 2;
            remove stack[sp];
            remove stack[sp + 1];
            stack[sp] = value;
            sp += 1;
        } else {
            wasm_fail("Unsupported opcode " + opcode + " (0x" + opcode + ") in function " + function_index + " at pc " + (pc - 1));
            return 0;
        }
    }

    wasm_fail("Function " + function_index + " ran off the end without end/return");
    return 0;
}

int wasm_invoke_index(int function_index, int [int] args) {
    if (!wasm_module_loaded) {
        wasm_fail("No Wasm module loaded");
        return 0;
    }
    wasm_last_error = "";
    wasm_last_had_result = false;
    wasm_fuel_remaining = wasm_default_fuel;
    return wasm_exec_function(function_index, args, 0);
}

int wasm_invoke(string export_name, int [int] args) {
    if (!wasm_module_loaded) {
        wasm_fail("No Wasm module loaded");
        return 0;
    }
    if (!(wasm_export_kind contains export_name)) {
        wasm_fail("No such Wasm export: " + export_name);
        return 0;
    }
    if (wasm_export_kind[export_name] != 0) {
        wasm_fail("Export '" + export_name + "' is not a function");
        return 0;
    }
    return wasm_invoke_index(wasm_export_index[export_name], args);
}

int wasm_invoke0(string export_name) {
    int [int] args;
    return wasm_invoke(export_name, args);
}

int wasm_invoke1(string export_name, int a) {
    int [int] args = { a };
    return wasm_invoke(export_name, args);
}

int wasm_invoke2(string export_name, int a, int b) {
    int [int] args = { a, b };
    return wasm_invoke(export_name, args);
}

int wasm_invoke3(string export_name, int a, int b, int c) {
    int [int] args = { a, b, c };
    return wasm_invoke(export_name, args);
}

void wasm_set_fuel(int fuel) {
    if (fuel < 1) fuel = 1;
    wasm_default_fuel = fuel;
}

void wasm_set_max_call_depth(int depth) {
    if (depth < 1) depth = 1;
    wasm_max_call_depth = depth;
}

void wasm_set_max_module_bytes(int bytes) {
    if (bytes < 8) bytes = 8;
    wasm_max_module_bytes = bytes;
}

void wasm_print_module_info() {
    if (!wasm_module_loaded) {
        print("wasm-ash: no module loaded", "red");
        if (wasm_last_error != "") print("error: " + wasm_last_error, "red");
        return;
    }

    print("wasm-ash module", "blue");
    print("  bytes:     " + wasm_byte_count);
    print("  types:     " + wasm_type_count);
    print("  functions: " + wasm_function_count);
    print("  fuel:      " + wasm_default_fuel);
    print("  max depth: " + wasm_max_call_depth);
    print("  byte limit:" + wasm_max_module_bytes);
    print("  exports:");
    foreach name in wasm_export_kind {
        string kind = "func";
        if (wasm_export_kind[name] != 0) {
            kind = "kind=" + wasm_export_kind[name];
        }
        print("    " + name + " -> " + kind + " #" + wasm_export_index[name]);
    }
}
