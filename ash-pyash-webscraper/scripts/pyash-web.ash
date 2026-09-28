import <ashscrape.ash>;

// PyASH v0.1.0
// A small Python-like interpreter implemented entirely in KoLmafia ASH.
//
// Supported statements:
//   assignment: x = expr
//   augmented assignment: += -= *= /= %=
//   print(expr [, expr ...])
//   if expr: / else:
//   while expr:
//   pass
//
// Supported expressions:
//   numbers, strings, True, False, None, variables
//   + - * / %
//   == != < <= > >=
//   and or not
//   parentheses
//   builtins: str(), int(), float(), bool(), len(), abs(), min(), max()
//
// Deliberately unsupported in v0.1:
//   imports, classes, def/lambda, exceptions, list/dict literals, indexing,
//   attribute access, arbitrary ASH/CLI dispatch.

record py_value {
    string kind;
    float number_value;
    string string_value;
    boolean bool_value;
};

record py_token {
    string kind;
    string text;
    float number_value;
};

py_value [string] PY_GLOBALS;
py_token [int] PY_TOKENS;
int PY_POS;
string PY_ERROR;
int PY_MAX_LOOP_ITERATIONS = 10000;

py_value py_none() {
    py_value v;
    v.kind = "none";
    return v;
}

py_value py_number(float n) {
    py_value v;
    v.kind = "number";
    v.number_value = n;
    return v;
}

py_value py_string(string s) {
    py_value v;
    v.kind = "string";
    v.string_value = s;
    return v;
}

py_value py_bool(boolean b) {
    py_value v;
    v.kind = "bool";
    v.bool_value = b;
    return v;
}

void py_fail(string message) {
    if (PY_ERROR == "") PY_ERROR = message;
}

boolean py_is_error() {
    return PY_ERROR != "";
}

string py_num_string(float n) {
    int i = to_int(n);
    if (n == to_float(i)) return to_string(i);
    return to_string(n);
}

string py_repr(py_value v) {
    if (v.kind == "none") return "None";
    if (v.kind == "bool") {
        if (v.bool_value) return "True";
        return "False";
    }
    if (v.kind == "number") return py_num_string(v.number_value);
    if (v.kind == "string") return v.string_value;
    return "<invalid>";
}

boolean py_truthy(py_value v) {
    if (v.kind == "none") return false;
    if (v.kind == "bool") return v.bool_value;
    if (v.kind == "number") return v.number_value != 0.0;
    if (v.kind == "string") return length(v.string_value) > 0;
    return false;
}

boolean py_same_kind_numeric(py_value a, py_value b) {
    return (a.kind == "number" || a.kind == "bool") && (b.kind == "number" || b.kind == "bool");
}

float py_as_number(py_value v) {
    if (v.kind == "number") return v.number_value;
    if (v.kind == "bool") {
        if (v.bool_value) return 1.0;
        return 0.0;
    }
    py_fail("expected numeric value, got " + v.kind);
    return 0.0;
}

string py_trim_left(string s) {
    int i = 0;
    while (i < length(s)) {
        string c = char_at(s, i);
        if (c != " " && c != "\t") break;
        i += 1;
    }
    return substring(s, i);
}

string py_trim_right(string s) {
    int i = length(s);
    while (i > 0) {
        string c = char_at(s, i - 1);
        if (c != " " && c != "\t" && c != "\r") break;
        i -= 1;
    }
    return substring(s, 0, i);
}

string py_trim(string s) {
    return py_trim_right(py_trim_left(s));
}

boolean py_is_digit(string c) {
    return c >= "0" && c <= "9";
}

boolean py_is_alpha(string c) {
    return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_";
}

boolean py_is_alnum(string c) {
    return py_is_alpha(c) || py_is_digit(c);
}

boolean py_identifier(string s) {
    if (length(s) == 0 || !py_is_alpha(char_at(s, 0))) return false;
    int i = 1;
    while (i < length(s)) {
        if (!py_is_alnum(char_at(s, i))) return false;
        i += 1;
    }
    return true;
}

void py_add_token(string kind, string text) {
    int n = count(PY_TOKENS);
    py_token t;
    t.kind = kind;
    t.text = text;
    PY_TOKENS[n] = t;
}

void py_add_number_token(string text, float n) {
    int idx = count(PY_TOKENS);
    py_token t;
    t.kind = "number";
    t.text = text;
    t.number_value = n;
    PY_TOKENS[idx] = t;
}

boolean py_tokenize(string source) {
    clear(PY_TOKENS);
    PY_POS = 0;
    int i = 0;

    while (i < length(source)) {
        string c = char_at(source, i);

        if (c == " " || c == "\t" || c == "\r") {
            i += 1;
            continue;
        }

        if (c == "#") break;

        if (py_is_digit(c) || (c == "." && i + 1 < length(source) && py_is_digit(char_at(source, i + 1)))) {
            int start = i;
            boolean dot = false;
            while (i < length(source)) {
                string d = char_at(source, i);
                if (py_is_digit(d)) {
                    i += 1;
                    continue;
                }
                if (d == "." && !dot) {
                    dot = true;
                    i += 1;
                    continue;
                }
                break;
            }
            string text = substring(source, start, i);
            py_add_number_token(text, to_float(text));
            continue;
        }

        if (py_is_alpha(c)) {
            int start = i;
            i += 1;
            while (i < length(source) && py_is_alnum(char_at(source, i))) i += 1;
            string word = substring(source, start, i);
            if (word == "and" || word == "or" || word == "not") py_add_token("op", word);
            else py_add_token("ident", word);
            continue;
        }

        if (c == "\"" || c == "'") {
            string quote = c;
            i += 1;
            string out = "";
            boolean closed = false;
            while (i < length(source)) {
                string d = char_at(source, i);
                if (d == quote) {
                    closed = true;
                    i += 1;
                    break;
                }
                if (d == "\\" && i + 1 < length(source)) {
                    string e = char_at(source, i + 1);
                    if (e == "n") out += "\n";
                    else if (e == "t") out += "\t";
                    else if (e == "r") out += "\r";
                    else if (e == "\\") out += "\\";
                    else if (e == "\"") out += "\"";
                    else if (e == "'") out += "'";
                    else out += e;
                    i += 2;
                    continue;
                }
                out += d;
                i += 1;
            }
            if (!closed) {
                py_fail("unterminated string literal");
                return false;
            }
            py_add_token("string", out);
            continue;
        }

        if (i + 1 < length(source)) {
            string two = substring(source, i, i + 2);
            if (two == "==" || two == "!=" || two == "<=" || two == ">=" ||
                two == "+=" || two == "-=" || two == "*=" || two == "/=" || two == "%=") {
                py_add_token("op", two);
                i += 2;
                continue;
            }
        }

        if (c == "+" || c == "-" || c == "*" || c == "/" || c == "%" ||
            c == "<" || c == ">" || c == "=" || c == "(" || c == ")" || c == ",") {
            py_add_token("op", c);
            i += 1;
            continue;
        }

        py_fail("unexpected character: " + c);
        return false;
    }

    py_add_token("eof", "");
    return true;
}

py_token py_peek() {
    return PY_TOKENS[PY_POS];
}

py_token py_advance() {
    py_token t = PY_TOKENS[PY_POS];
    PY_POS += 1;
    return t;
}

boolean py_match(string text) {
    if (py_peek().text == text) {
        PY_POS += 1;
        return true;
    }
    return false;
}

boolean py_expect(string text) {
    if (py_match(text)) return true;
    py_fail("expected '" + text + "', got '" + py_peek().text + "'");
    return false;
}

py_value py_apply_builtin(string name, py_value[int] args) {
    int n = count(args);

    if (name == "str") {
        if (n != 1) { py_fail("str() expects 1 argument"); return py_none(); }
        return py_string(py_repr(args[0]));
    }
    if (name == "bool") {
        if (n != 1) { py_fail("bool() expects 1 argument"); return py_none(); }
        return py_bool(py_truthy(args[0]));
    }
    if (name == "int") {
        if (n != 1) { py_fail("int() expects 1 argument"); return py_none(); }
        if (args[0].kind == "number" || args[0].kind == "bool") return py_number(to_float(to_int(py_as_number(args[0]))));
        if (args[0].kind == "string") return py_number(to_float(to_int(args[0].string_value)));
        py_fail("int() cannot convert " + args[0].kind);
        return py_none();
    }
    if (name == "float") {
        if (n != 1) { py_fail("float() expects 1 argument"); return py_none(); }
        if (args[0].kind == "number" || args[0].kind == "bool") return py_number(py_as_number(args[0]));
        if (args[0].kind == "string") return py_number(to_float(args[0].string_value));
        py_fail("float() cannot convert " + args[0].kind);
        return py_none();
    }
    if (name == "len") {
        if (n != 1 || args[0].kind != "string") { py_fail("len() currently expects 1 string"); return py_none(); }
        return py_number(to_float(length(args[0].string_value)));
    }
    if (name == "abs") {
        if (n != 1) { py_fail("abs() expects 1 argument"); return py_none(); }
        float x = py_as_number(args[0]);
        if (py_is_error()) return py_none();
        if (x < 0.0) return py_number(-x);
        return py_number(x);
    }
    if (name == "min" || name == "max") {
        if (n < 1) { py_fail(name + "() expects at least 1 argument"); return py_none(); }
        float best = py_as_number(args[0]);
        if (py_is_error()) return py_none();
        int i = 1;
        while (i < n) {
            float x = py_as_number(args[i]);
            if (py_is_error()) return py_none();
            if ((name == "min" && x < best) || (name == "max" && x > best)) best = x;
            i += 1;
        }
        return py_number(best);
    }

    // Explicit web capability built-ins. These are bounded, GET-only, and
    // implemented by the imported ashscrape.ash engine.
    if (name == "scrape") {
        if (n < 1 || n > 2 || args[0].kind != "string") {
            py_fail("scrape(url [, max_lines]) expects a URL string and optional line count");
            return py_none();
        }
        int max_lines = SCRAPER_DEFAULT_LINES;
        if (n == 2) {
            max_lines = to_int(py_as_number(args[1]));
            if (py_is_error()) return py_none();
        }
        scrape_page page = sc_fetch(args[0].string_value, max_lines, SCRAPER_DEFAULT_SOURCE_CHARS);
        if (starts_with(page.title, "ERROR:")) { py_fail(page.title); return py_none(); }
        buffer text;
        foreach _, line in page.lines {
            if (length(text.to_string()) > 0) text.append("\n");
            text.append(line);
        }
        return py_string(text.to_string());
    }

    if (name == "scrape_print") {
        if (n < 1 || n > 2 || args[0].kind != "string") {
            py_fail("scrape_print(url [, max_lines]) expects a URL string and optional line count");
            return py_none();
        }
        int max_lines = SCRAPER_DEFAULT_LINES;
        if (n == 2) {
            max_lines = to_int(py_as_number(args[1]));
            if (py_is_error()) return py_none();
        }
        scrape_page page = sc_fetch(args[0].string_value, max_lines, SCRAPER_DEFAULT_SOURCE_CHARS);
        if (starts_with(page.title, "ERROR:")) { py_fail(page.title); return py_none(); }
        sc_print_gcli(page);
        return py_number(to_float(page.line_count));
    }

    if (name == "scrape_save") {
        if (n != 4 || args[0].kind != "string" || args[1].kind != "string" || args[3].kind != "string") {
            py_fail("scrape_save(url, format, max_lines, name) expects string, string, number, string");
            return py_none();
        }
        int max_lines = to_int(py_as_number(args[2]));
        if (py_is_error()) return py_none();
        string format = to_lower_case(args[1].string_value);
        if (!sc_valid_format(format)) { py_fail("invalid scrape format"); return py_none(); }
        string out_name = sc_safe_name(args[3].string_value);
        scrape_page page = sc_fetch(args[0].string_value, max_lines, SCRAPER_DEFAULT_SOURCE_CHARS);
        if (starts_with(page.title, "ERROR:")) { py_fail(page.title); return py_none(); }
        if (!sc_write_outputs(page, out_name, format)) { py_fail("one or more scraper file writes failed"); return py_none(); }
        return py_string("scraper/" + out_name + " [" + format + "]");
    }

    py_fail("unknown builtin: " + name);
    return py_none();
}

py_value py_compare_values(py_value a, string op, py_value b) {
    if (op == "==" || op == "!=") {
        boolean equal = false;
        if (a.kind == b.kind) {
            if (a.kind == "none") equal = true;
            else if (a.kind == "bool") equal = a.bool_value == b.bool_value;
            else if (a.kind == "number") equal = a.number_value == b.number_value;
            else if (a.kind == "string") equal = a.string_value == b.string_value;
        } else if (py_same_kind_numeric(a, b)) {
            equal = py_as_number(a) == py_as_number(b);
        }
        if (op == "==") return py_bool(equal);
        return py_bool(!equal);
    }

    if (a.kind == "string" && b.kind == "string") {
        if (op == "<") return py_bool(a.string_value < b.string_value);
        if (op == "<=") return py_bool(a.string_value <= b.string_value);
        if (op == ">") return py_bool(a.string_value > b.string_value);
        if (op == ">=") return py_bool(a.string_value >= b.string_value);
    }

    float av = py_as_number(a);
    float bv = py_as_number(b);
    if (py_is_error()) return py_none();
    if (op == "<") return py_bool(av < bv);
    if (op == "<=") return py_bool(av <= bv);
    if (op == ">") return py_bool(av > bv);
    if (op == ">=") return py_bool(av >= bv);

    py_fail("unknown comparison operator " + op);
    return py_none();
}

int py_precedence(string op) {
    if (op == "or") return 1;
    if (op == "and") return 2;
    if (op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" || op == ">=") return 3;
    if (op == "+" || op == "-") return 4;
    if (op == "*" || op == "/" || op == "%") return 5;
    return 0;
}

py_value py_apply_binary(py_value left, string op, py_value right) {
    if (op == "and") return py_bool(py_truthy(left) && py_truthy(right));
    if (op == "or") return py_bool(py_truthy(left) || py_truthy(right));

    if (op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" || op == ">=") {
        return py_compare_values(left, op, right);
    }

    if (op == "+" && left.kind == "string" && right.kind == "string") {
        return py_string(left.string_value + right.string_value);
    }

    float a = py_as_number(left);
    float b = py_as_number(right);
    if (py_is_error()) return py_none();

    if ((op == "/" || op == "%") && b == 0.0) {
        py_fail("division by zero");
        return py_none();
    }

    if (op == "+") return py_number(a + b);
    if (op == "-") return py_number(a - b);
    if (op == "*") return py_number(a * b);
    if (op == "/") return py_number(a / b);
    if (op == "%") return py_number(a - to_float(to_int(a / b)) * b);

    py_fail("unknown operator " + op);
    return py_none();
}

// Single self-recursive precedence parser. ASH requires functions to be visible
// before use, so avoiding mutually-recursive parser functions is intentional.
py_value py_parse_expr_prec(int min_precedence) {
    py_value left;

    if (py_match("not")) {
        py_value inner = py_parse_expr_prec(3);
        left = py_bool(!py_truthy(inner));
    } else if (py_match("+")) {
        py_value inner = py_parse_expr_prec(6);
        left = py_number(py_as_number(inner));
    } else if (py_match("-")) {
        py_value inner = py_parse_expr_prec(6);
        left = py_number(-py_as_number(inner));
    } else if (py_match("(")) {
        left = py_parse_expr_prec(1);
        if (!py_expect(")")) return py_none();
    } else {
        py_token t = py_peek();

        if (t.kind == "number") {
            py_advance();
            left = py_number(t.number_value);
        } else if (t.kind == "string") {
            py_advance();
            left = py_string(t.text);
        } else if (t.kind == "ident") {
            string name = t.text;
            py_advance();

            if (name == "True") left = py_bool(true);
            else if (name == "False") left = py_bool(false);
            else if (name == "None") left = py_none();
            else if (py_match("(")) {
                py_value[int] args;
                if (!py_match(")")) {
                    while (true) {
                        args[count(args)] = py_parse_expr_prec(1);
                        if (py_is_error()) return py_none();
                        if (py_match(")")) break;
                        if (!py_expect(",")) return py_none();
                    }
                }
                left = py_apply_builtin(name, args);
            } else {
                if (!(PY_GLOBALS contains name)) {
                    py_fail("name '" + name + "' is not defined");
                    return py_none();
                }
                left = PY_GLOBALS[name];
            }
        } else {
            py_fail("expected expression, got '" + t.text + "'");
            return py_none();
        }
    }

    if (py_is_error()) return py_none();

    while (true) {
        string op = py_peek().text;
        int precedence = py_precedence(op);
        if (precedence < min_precedence || precedence == 0) break;
        py_advance();
        py_value right = py_parse_expr_prec(precedence + 1);
        if (py_is_error()) return py_none();
        left = py_apply_binary(left, op, right);
        if (py_is_error()) return py_none();
    }

    return left;
}

py_value py_parse_expression() {
    return py_parse_expr_prec(1);
}

py_value py_eval(string expr) {
    PY_ERROR = "";
    if (!py_tokenize(expr)) return py_none();
    py_value v = py_parse_expression();
    if (!py_is_error() && py_peek().kind != "eof") py_fail("unexpected token '" + py_peek().text + "'");
    return v;
}

int py_indent(string line) {
    int n = 0;
    while (n < length(line)) {
        string c = char_at(line, n);
        if (c == " ") n += 1;
        else if (c == "\t") n += 4;
        else break;
    }
    return n;
}

boolean py_blank_or_comment(string line) {
    string t = py_trim(line);
    return t == "" || starts_with(t, "#");
}

int py_find_assignment(string line) {
    boolean in_string = false;
    string quote = "";
    int depth = 0;
    int i = 0;
    while (i < length(line)) {
        string c = char_at(line, i);
        if (in_string) {
            if (c == "\\") { i += 2; continue; }
            if (c == quote) in_string = false;
            i += 1;
            continue;
        }
        if (c == "\"" || c == "'") { in_string = true; quote = c; i += 1; continue; }
        if (c == "(") { depth += 1; i += 1; continue; }
        if (c == ")") { depth -= 1; i += 1; continue; }
        if (depth != 0 || c != "=") { i += 1; continue; }
        string prev = "";
        string next = "";
        if (i > 0) prev = char_at(line, i - 1);
        if (i + 1 < length(line)) next = char_at(line, i + 1);
        if (prev == "=" || prev == "!" || prev == "<" || prev == ">" ||
            prev == "+" || prev == "-" || prev == "*" || prev == "/" || prev == "%" || next == "=") {
            i += 1;
            continue;
        }
        return i;
    }
    return -1;
}

int py_find_block_end(string[int] lines, int start, int end, int parent_indent) {
    int i = start;
    while (i < end) {
        if (py_blank_or_comment(lines[i])) { i += 1; continue; }
        if (py_indent(lines[i]) <= parent_indent) return i;
        i += 1;
    }
    return end;
}

int py_next_code_line(string[int] lines, int start, int end) {
    int i = start;
    while (i < end && py_blank_or_comment(lines[i])) i += 1;
    return i;
}

boolean py_exec_simple(string line) {
    string t = py_trim(line);

    if (t == "pass") return true;

    if (starts_with(t, "print(") && ends_with(t, ")")) {
        string inner = substring(t, 6, length(t) - 1);
        PY_ERROR = "";
        if (!py_tokenize(inner)) return false;

        string output = "";
        if (py_peek().kind != "eof") {
            while (true) {
                py_value v = py_parse_expression();
                if (py_is_error()) return false;
                if (output != "") output += " ";
                output += py_repr(v);
                if (!py_match(",")) break;
            }
        }
        if (py_peek().kind != "eof") { py_fail("unexpected token in print(): " + py_peek().text); return false; }
        print(output);
        return true;
    }

    string[int] augops;
    augops[0] = "+=";
    augops[1] = "-=";
    augops[2] = "*=";
    augops[3] = "/=";
    augops[4] = "%=";
    foreach _, op in augops {
        int p = index_of(t, op);
        if (p > 0) {
            string name = py_trim(substring(t, 0, p));
            string rhs = py_trim(substring(t, p + 2));
            if (!py_identifier(name)) { py_fail("invalid assignment target: " + name); return false; }
            if (!(PY_GLOBALS contains name)) { py_fail("name '" + name + "' is not defined"); return false; }
            py_value a = PY_GLOBALS[name];
            py_value b = py_eval(rhs);
            if (py_is_error()) return false;
            if (op == "+=" && a.kind == "string" && b.kind == "string") {
                PY_GLOBALS[name] = py_string(a.string_value + b.string_value);
                return true;
            }
            float av = py_as_number(a);
            float bv = py_as_number(b);
            if (py_is_error()) return false;
            if ((op == "/=" || op == "%=") && bv == 0.0) { py_fail("division by zero"); return false; }
            if (op == "+=") PY_GLOBALS[name] = py_number(av + bv);
            else if (op == "-=") PY_GLOBALS[name] = py_number(av - bv);
            else if (op == "*=") PY_GLOBALS[name] = py_number(av * bv);
            else if (op == "/=") PY_GLOBALS[name] = py_number(av / bv);
            else PY_GLOBALS[name] = py_number(av - to_float(to_int(av / bv)) * bv);
            return true;
        }
    }

    int eq = py_find_assignment(t);
    if (eq >= 0) {
        string name = py_trim(substring(t, 0, eq));
        string rhs = py_trim(substring(t, eq + 1));
        if (!py_identifier(name)) { py_fail("invalid assignment target: " + name); return false; }
        py_value value = py_eval(rhs);
        if (py_is_error()) return false;
        PY_GLOBALS[name] = value;
        return true;
    }

    // Allow expression statements for experimentation.
    py_eval(t);
    return !py_is_error();
}

boolean py_exec_range(string[int] lines, int start, int end, int indent) {
    int i = start;

    while (i < end) {
        if (py_blank_or_comment(lines[i])) { i += 1; continue; }

        int actual = py_indent(lines[i]);
        if (actual < indent) return true;
        if (actual > indent) {
            py_fail("unexpected indentation on line " + (i + 1));
            return false;
        }

        string t = py_trim(lines[i]);

        if (starts_with(t, "if ") && ends_with(t, ":")) {
            string cond_text = py_trim(substring(t, 3, length(t) - 1));
            int body_start = py_next_code_line(lines, i + 1, end);
            if (body_start >= end || py_indent(lines[body_start]) <= indent) {
                py_fail("expected indented block after if on line " + (i + 1));
                return false;
            }
            int body_indent = py_indent(lines[body_start]);
            int body_end = py_find_block_end(lines, body_start, end, indent);

            int else_line = body_end;
            while (else_line < end && py_blank_or_comment(lines[else_line])) else_line += 1;
            boolean has_else = else_line < end && py_indent(lines[else_line]) == indent && py_trim(lines[else_line]) == "else:";
            int else_start = -1;
            int else_end = body_end;
            int after = body_end;

            if (has_else) {
                else_start = py_next_code_line(lines, else_line + 1, end);
                if (else_start >= end || py_indent(lines[else_start]) <= indent) {
                    py_fail("expected indented block after else on line " + (else_line + 1));
                    return false;
                }
                int else_indent = py_indent(lines[else_start]);
                else_end = py_find_block_end(lines, else_start, end, indent);
                after = else_end;

                py_value cond = py_eval(cond_text);
                if (py_is_error()) return false;
                if (py_truthy(cond)) {
                    if (!py_exec_range(lines, body_start, body_end, body_indent)) return false;
                } else {
                    if (!py_exec_range(lines, else_start, else_end, else_indent)) return false;
                }
            } else {
                py_value cond = py_eval(cond_text);
                if (py_is_error()) return false;
                if (py_truthy(cond)) {
                    if (!py_exec_range(lines, body_start, body_end, body_indent)) return false;
                }
            }

            i = after;
            continue;
        }

        if (starts_with(t, "while ") && ends_with(t, ":")) {
            string cond_text = py_trim(substring(t, 6, length(t) - 1));
            int body_start = py_next_code_line(lines, i + 1, end);
            if (body_start >= end || py_indent(lines[body_start]) <= indent) {
                py_fail("expected indented block after while on line " + (i + 1));
                return false;
            }
            int body_indent = py_indent(lines[body_start]);
            int body_end = py_find_block_end(lines, body_start, end, indent);
            int loops = 0;

            while (true) {
                py_value cond = py_eval(cond_text);
                if (py_is_error()) return false;
                if (!py_truthy(cond)) break;
                loops += 1;
                if (loops > PY_MAX_LOOP_ITERATIONS) {
                    py_fail("loop limit exceeded (" + PY_MAX_LOOP_ITERATIONS + ")");
                    return false;
                }
                if (!py_exec_range(lines, body_start, body_end, body_indent)) return false;
            }

            i = body_end;
            continue;
        }

        if (t == "else:") {
            py_fail("unexpected else on line " + (i + 1));
            return false;
        }

        if (!py_exec_simple(t)) {
            PY_ERROR = "line " + (i + 1) + ": " + PY_ERROR;
            return false;
        }

        i += 1;
    }

    return true;
}

void py_reset() {
    clear(PY_GLOBALS);
    clear(PY_TOKENS);
    PY_POS = 0;
    PY_ERROR = "";
}

boolean py_run(string source) {
    py_reset();
    string[int] lines = split_string(source);
    return py_exec_range(lines, 0, count(lines), 0);
}

boolean py_run_file(string filename) {
    buffer b = file_to_buffer(filename);
    return py_run(to_string(b));
}

void main(string command) {
    if (command == "" || command == "help" || command == "--help") {
        print("PyASH Web v0.1.0 - Python-like interpreter + bounded GET scraper", "blue");
        print("Usage: call pyash-web.ash run <data-relative-file>");
        print("       call pyash-web.ash eval <expression>");
        print("       call pyash-web.ash scrape --url=https://example.com --max-lines=50 --format=all --dest=data");
        print("PyASH built-ins: scrape(url [, max_lines]), scrape_print(url [, max_lines]), scrape_save(url, format, max_lines, name)");
        return;
    }

    if (command == "scrape" || starts_with(command, "scrape ")) {
        scrape_options options = sc_parse_options(command);
        sc_run(options);
        return;
    }

    if (starts_with(command, "eval ")) {
        py_reset();
        py_value v = py_eval(substring(command, 5));
        if (py_is_error()) print("PyASH error: " + PY_ERROR, "red");
        else print(py_repr(v));
        return;
    }

    if (starts_with(command, "run ")) {
        string filename = py_trim(substring(command, 4));
        if (!py_run_file(filename)) print("PyASH error: " + PY_ERROR, "red");
        return;
    }

    print("PyASH Web: unknown command. Use 'call pyash-web.ash help'.", "red");
}
