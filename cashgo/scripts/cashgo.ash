script "cashgo";

// CashGo v0.1.0
// Cargo-inspired dependency/project manager implemented in KoLmafia ASH.
// Manifest + lock state live under KoLmafia's data/ directory.
// Installs are delegated only to KoLmafia's native git CLI surface.

record cg_package {
    string name;
    string version;
    string entry;
};

record cg_dependency {
    string alias;
    string source_kind;
    string source;
    string ref_name;
    boolean optional;
};

record cg_manifest {
    cg_package package;
    cg_dependency [string] dependencies;
};

record cg_options {
    string command;
    string manifest_path;
    string arg1;
    string arg2;
    string arg3;
    boolean dry_run;
    boolean quiet;
};

string CG_VERSION = "0.1.0";
string CG_DEFAULT_MANIFEST = "cashgo/cashgo.toml";
string CG_DEFAULT_LOCK = "cashgo/cashgo.lock";
string CG_STATE_FILE = "cashgo/state.tsv";

string cg_trim(string s) {
    matcher edges = create_matcher("^\\s+|\\s+$", s);
    return replace_all(edges, "");
}

boolean cg_starts(string text, string prefix) {
    return starts_with(text, prefix);
}

boolean cg_ends(string text, string suffix) {
    return ends_with(text, suffix);
}

string cg_unquote(string s) {
    string t = cg_trim(s);
    if (length(t) >= 2) {
        string first = char_at(t, 0);
        string last = char_at(t, length(t) - 1);
        if ((first == "\"" && last == "\"") || (first == "'" && last == "'")) {
            return substring(t, 1, length(t) - 1);
        }
    }
    return t;
}

string cg_quote(string s) {
    string x = replace_string(s, "\\", "\\\\");
    x = replace_string(x, "\"", "\\\"");
    return "\"" + x + "\"";
}

string cg_before(string s, string needle) {
    int p = index_of(s, needle);
    if (p < 0) return s;
    return substring(s, 0, p);
}

string cg_after(string s, string needle) {
    int p = index_of(s, needle);
    if (p < 0) return "";
    return substring(s, p + length(needle));
}

string cg_strip_comment(string line) {
    boolean in_double = false;
    boolean in_single = false;
    int i = 0;
    while (i < length(line)) {
        string c = char_at(line, i);
        if (c == "\"" && !in_single) in_double = !in_double;
        else if (c == "'" && !in_double) in_single = !in_single;
        else if (c == "#" && !in_double && !in_single) return substring(line, 0, i);
        i = i + 1;
    }
    return line;
}

boolean cg_safe_token(string s) {
    if (s == "") return false;
    matcher m = create_matcher("^[A-Za-z0-9._/@:+-]+$", s);
    return m.find();
}

boolean cg_safe_alias(string s) {
    if (s == "") return false;
    matcher m = create_matcher("^[A-Za-z0-9._-]+$", s);
    return m.find();
}

boolean cg_safe_project_name(string s) {
    return cg_safe_alias(s);
}

boolean cg_safe_git_source(string s) {
    if (s == "") return false;
    // Accept GitHub short form owner/repo or explicit HTTPS git URL.
    matcher short_form = create_matcher("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(?:\\.git)?$", s);
    if (short_form.find()) return true;
    matcher https_form = create_matcher("^https://[A-Za-z0-9._~:/?#@!$&'()*+,;=%-]+$", s);
    return https_form.find();
}

string cg_normalize_source(string raw) {
    string s = cg_trim(raw);
    if (cg_starts(s, "github:")) return substring(s, 7);
    if (cg_starts(s, "git:")) return substring(s, 4);
    return s;
}

cg_dependency cg_parse_dependency(string alias, string raw) {
    cg_dependency d;
    d.alias = alias;
    d.optional = false;
    d.source_kind = "git";

    string value = cg_unquote(raw);
    if (cg_starts(value, "optional:")) {
        d.optional = true;
        value = substring(value, 9);
    }

    string source = value;
    string ref_name = "";
    int at = last_index_of(value, "@");
    if (at > 7) {
        source = substring(value, 0, at);
        ref_name = substring(value, at + 1);
    }

    source = cg_normalize_source(source);
    d.source = source;
    d.ref_name = ref_name;
    return d;
}

string cg_dependency_spec(cg_dependency d) {
    string prefix = "";
    if (d.optional) prefix = "optional:";
    string body = "github:" + d.source;
    if (cg_starts(d.source, "https://")) body = "git:" + d.source;
    if (d.ref_name != "") body = body + "@" + d.ref_name;
    return prefix + body;
}

boolean cg_manifest_valid(cg_manifest m, boolean print_errors) {
    boolean ok = true;
    if (!cg_safe_project_name(m.package.name)) {
        if (print_errors) print("cashgo: invalid or missing package.name", "red");
        ok = false;
    }
    if (m.package.version == "") {
        if (print_errors) print("cashgo: missing package.version", "red");
        ok = false;
    }
    foreach alias, d in m.dependencies {
        if (!cg_safe_alias(alias)) {
            if (print_errors) print("cashgo: unsafe dependency alias: " + alias, "red");
            ok = false;
        }
        if (!cg_safe_git_source(d.source)) {
            if (print_errors) print("cashgo: unsafe dependency source for " + alias + ": " + d.source, "red");
            ok = false;
        }
        if (d.ref_name != "" && !cg_safe_token(d.ref_name)) {
            if (print_errors) print("cashgo: unsafe dependency ref for " + alias + ": " + d.ref_name, "red");
            ok = false;
        }
    }
    return ok;
}

cg_manifest cg_read_manifest(string path) {
    cg_manifest result;
    buffer raw = file_to_buffer(path);
    string text = raw.to_string();
    if (text == "") return result;

    string [int] lines = split_string(text, "\\r?\\n");
    string section = "";
    foreach i, original in lines {
        string line = cg_trim(cg_strip_comment(original));
        if (line == "") continue;
        if (cg_starts(line, "[") && cg_ends(line, "]")) {
            section = to_lower_case(cg_trim(substring(line, 1, length(line) - 1)));
            continue;
        }
        int equals = index_of(line, "=");
        if (equals < 1) continue;
        string key = cg_trim(substring(line, 0, equals));
        string value = cg_trim(substring(line, equals + 1));

        if (section == "package") {
            if (key == "name") result.package.name = cg_unquote(value);
            else if (key == "version") result.package.version = cg_unquote(value);
            else if (key == "entry") result.package.entry = cg_unquote(value);
        } else if (section == "dependencies") {
            cg_dependency d = cg_parse_dependency(key, value);
            result.dependencies[key] = d;
        }
    }
    return result;
}

string cg_render_manifest(cg_manifest m) {
    buffer out;
    out.append("# CashGo manifest v1\n\n");
    out.append("[package]\n");
    out.append("name = " + cg_quote(m.package.name) + "\n");
    out.append("version = " + cg_quote(m.package.version) + "\n");
    if (m.package.entry != "") out.append("entry = " + cg_quote(m.package.entry) + "\n");
    out.append("\n[dependencies]\n");
    foreach alias, d in m.dependencies {
        out.append(alias + " = " + cg_quote(cg_dependency_spec(d)) + "\n");
    }
    return out.to_string();
}

boolean cg_write_manifest(string path, cg_manifest m) {
    buffer out;
    out.append(cg_render_manifest(m));
    return buffer_to_file(out, path);
}

string cg_lock_path(string manifest_path) {
    int slash = last_index_of(manifest_path, "/");
    if (slash < 0) return "cashgo.lock";
    return substring(manifest_path, 0, slash + 1) + "cashgo.lock";
}

string cg_render_lock(cg_manifest m) {
    buffer out;
    out.append("# CashGo lockfile v1\n");
    out.append("# exact manifest dependency specs; source revisions are managed by KoLmafia git\n");
    out.append("package\t" + m.package.name + "\t" + m.package.version + "\n");
    foreach alias, d in m.dependencies {
        out.append("dep\t" + alias + "\t" + d.source + "\t" + d.ref_name + "\t" + d.optional + "\n");
    }
    return out.to_string();
}

boolean cg_write_lock(string manifest_path, cg_manifest m) {
    buffer out;
    out.append(cg_render_lock(m));
    return buffer_to_file(out, cg_lock_path(manifest_path));
}

string cg_checkout_command(cg_dependency d) {
    string cmd = "git checkout " + d.source;
    if (d.ref_name != "") cmd = cmd + " " + d.ref_name;
    return cmd;
}

boolean cg_run_generated_command(string cmd, boolean dry_run, boolean quiet) {
    string prefix = "";
    if (dry_run) prefix = "[dry-run] ";
    if (!quiet) print(prefix + cmd, "blue");
    if (dry_run) return true;
    return cli_execute(cmd);
}

boolean cg_install_dep(cg_dependency d, boolean dry_run, boolean quiet) {
    if (!cg_safe_git_source(d.source)) {
        print("cashgo: refusing unsafe source: " + d.source, "red");
        return false;
    }
    if (d.ref_name != "" && !cg_safe_token(d.ref_name)) {
        print("cashgo: refusing unsafe ref: " + d.ref_name, "red");
        return false;
    }
    return cg_run_generated_command(cg_checkout_command(d), dry_run, quiet);
}

boolean cg_fetch_all(cg_manifest m, boolean dry_run, boolean quiet) {
    boolean ok = true;
    foreach alias, d in m.dependencies {
        if (d.optional) {
            if (!quiet) print("cashgo: skip optional dependency " + alias + " (use explicit install to enable)", "gray");
            continue;
        }
        if (!cg_install_dep(d, dry_run, quiet)) ok = false;
    }
    if (!cg_run_generated_command("git sync", dry_run, quiet)) ok = false;
    return ok;
}

boolean cg_update_all(cg_manifest m, boolean dry_run, boolean quiet) {
    // KoLmafia exposes a native Git updater. In v0.1 CashGo intentionally
    // delegates update semantics to it rather than guessing project IDs.
    // This may update other installed KoLmafia Git projects too.
    boolean ok = cg_run_generated_command("git update", dry_run, quiet);
    if (!cg_run_generated_command("git sync", dry_run, quiet)) ok = false;
    return ok;
}

void cg_print_tree(cg_manifest m) {
    print(m.package.name + " v" + m.package.version, "green");
    foreach alias, d in m.dependencies {
        string marker = "+";
        if (d.optional) marker = "?";
        string ref = d.ref_name;
        if (ref == "") ref = "default";
        string suffix = "";
        if (d.optional) suffix = " [optional]";
        print(marker + "- " + alias + " => " + d.source + " @ " + ref + suffix);
    }
}

void cg_print_metadata(cg_manifest m, string manifest_path) {
    print("CashGo " + CG_VERSION, "blue");
    print("manifest: " + manifest_path);
    print("lock:     " + cg_lock_path(manifest_path));
    print("package:  " + m.package.name + " v" + m.package.version);
    string shown_entry = m.package.entry;
    if (shown_entry == "") shown_entry = "(none)";
    print("entry:    " + shown_entry);
    print("deps:     " + count(m.dependencies));
}

boolean cg_init(string manifest_path, string name) {
    if (!cg_safe_project_name(name)) {
        print("cashgo: project name must match [A-Za-z0-9._-]+", "red");
        return false;
    }
    if (file_to_buffer(manifest_path).to_string() != "") {
        print("cashgo: manifest already exists: " + manifest_path, "red");
        return false;
    }
    cg_manifest m;
    m.package.name = name;
    m.package.version = "0.1.0";
    m.package.entry = name + ".ash";
    if (!cg_write_manifest(manifest_path, m)) {
        print("cashgo: failed to write " + manifest_path, "red");
        return false;
    }
    cg_write_lock(manifest_path, m);
    print("cashgo: initialized " + manifest_path, "green");
    return true;
}

boolean cg_add(string manifest_path, string alias, string spec) {
    cg_manifest m = cg_read_manifest(manifest_path);
    if (!cg_manifest_valid(m, true)) return false;
    if (!cg_safe_alias(alias)) {
        print("cashgo: unsafe dependency alias", "red");
        return false;
    }
    cg_dependency d = cg_parse_dependency(alias, spec);
    if (!cg_safe_git_source(d.source) || (d.ref_name != "" && !cg_safe_token(d.ref_name))) {
        print("cashgo: invalid dependency spec", "red");
        return false;
    }
    m.dependencies[alias] = d;
    if (!cg_write_manifest(manifest_path, m)) return false;
    cg_write_lock(manifest_path, m);
    print("cashgo: added " + alias + " => " + cg_dependency_spec(d), "green");
    return true;
}

boolean cg_remove(string manifest_path, string alias) {
    cg_manifest m = cg_read_manifest(manifest_path);
    if (!cg_manifest_valid(m, true)) return false;
    if (!(m.dependencies contains alias)) {
        print("cashgo: dependency not found: " + alias, "red");
        return false;
    }
    remove m.dependencies[alias];
    if (!cg_write_manifest(manifest_path, m)) return false;
    cg_write_lock(manifest_path, m);
    print("cashgo: removed " + alias, "green");
    return true;
}

boolean cg_install_one(cg_manifest m, string alias, boolean dry_run, boolean quiet) {
    if (!(m.dependencies contains alias)) {
        print("cashgo: dependency not found: " + alias, "red");
        return false;
    }
    return cg_install_dep(m.dependencies[alias], dry_run, quiet);
}

boolean cg_run_entry(cg_manifest m, string extra, boolean dry_run, boolean quiet) {
    if (m.package.entry == "") {
        print("cashgo: package.entry is not set", "red");
        return false;
    }
    if (!cg_safe_token(m.package.entry)) {
        print("cashgo: refusing unsafe package.entry", "red");
        return false;
    }
    string cmd = "call " + m.package.entry;
    if (extra != "") cmd = cmd + " " + extra;
    return cg_run_generated_command(cmd, dry_run, quiet);
}

void cg_help() {
    print_html("<b>CashGo " + CG_VERSION + "</b> - Cargo-ish project/dependency manager for ASH<br>");
    print("call cashgo.ash init <name>");
    print("call cashgo.ash check");
    print("call cashgo.ash add <alias> <github:owner/repo@branch>");
    print("call cashgo.ash remove <alias>");
    print("call cashgo.ash fetch [--dry-run]");
    print("call cashgo.ash install <alias> [--dry-run]");
    print("call cashgo.ash update [--dry-run]");
    print("call cashgo.ash lock");
    print("call cashgo.ash tree");
    print("call cashgo.ash metadata");
    print("call cashgo.ash run [args] [--dry-run]");
    print("");
    print("Options: --manifest=cashgo/path.toml --dry-run --quiet");
    print("Manifest lives in KoLmafia data/. Default: data/" + CG_DEFAULT_MANIFEST);
}

cg_options cg_parse_options(string command) {
    cg_options o;
    o.manifest_path = CG_DEFAULT_MANIFEST;
    string [int] parts = split_string(cg_trim(command), "\\s+");
    int positional = 0;
    foreach i, p in parts {
        if (p == "") continue;
        if (p == "--dry-run") {
            o.dry_run = true;
            continue;
        }
        if (p == "--quiet") {
            o.quiet = true;
            continue;
        }
        if (cg_starts(p, "--manifest=")) {
            o.manifest_path = substring(p, 11);
            continue;
        }
        if (positional == 0) o.command = p;
        else if (positional == 1) o.arg1 = p;
        else if (positional == 2) o.arg2 = p;
        else if (positional == 3) o.arg3 = p;
        positional = positional + 1;
    }
    return o;
}

void main(string command) {
    cg_options o = cg_parse_options(command);
    if (o.command == "" || o.command == "help" || o.command == "--help" || o.command == "-h") {
        cg_help();
        return;
    }
    if (o.command == "version" || o.command == "--version") {
        print("cashgo " + CG_VERSION);
        return;
    }
    if (o.command == "init" || o.command == "new") {
        if (o.arg1 == "") abort("cashgo: init requires a project name");
        if (!cg_init(o.manifest_path, o.arg1)) abort("cashgo: init failed");
        return;
    }

    cg_manifest m = cg_read_manifest(o.manifest_path);
    if (!cg_manifest_valid(m, true)) abort("cashgo: invalid manifest " + o.manifest_path);

    if (o.command == "check") {
        print("cashgo: manifest OK", "green");
        return;
    }
    if (o.command == "add") {
        if (o.arg1 == "" || o.arg2 == "") abort("cashgo: add requires <alias> <source>");
        if (!cg_add(o.manifest_path, o.arg1, o.arg2)) abort("cashgo: add failed");
        return;
    }
    if (o.command == "remove" || o.command == "rm") {
        if (o.arg1 == "") abort("cashgo: remove requires <alias>");
        if (!cg_remove(o.manifest_path, o.arg1)) abort("cashgo: remove failed");
        return;
    }
    if (o.command == "lock") {
        if (!cg_write_lock(o.manifest_path, m)) abort("cashgo: lock write failed");
        print("cashgo: wrote " + cg_lock_path(o.manifest_path), "green");
        return;
    }
    if (o.command == "tree") {
        cg_print_tree(m);
        return;
    }
    if (o.command == "metadata") {
        cg_print_metadata(m, o.manifest_path);
        return;
    }
    if (o.command == "fetch" || o.command == "build") {
        if (!cg_fetch_all(m, o.dry_run, o.quiet)) abort("cashgo: fetch failed");
        cg_write_lock(o.manifest_path, m);
        if (!o.quiet) print("cashgo: dependencies ready", "green");
        return;
    }
    if (o.command == "install") {
        if (o.arg1 == "") abort("cashgo: install requires <alias>");
        if (!cg_install_one(m, o.arg1, o.dry_run, o.quiet)) abort("cashgo: install failed");
        return;
    }
    if (o.command == "update") {
        if (!cg_update_all(m, o.dry_run, o.quiet)) abort("cashgo: update failed");
        if (!o.quiet) print("cashgo: update complete", "green");
        return;
    }
    if (o.command == "run") {
        if (!cg_run_entry(m, o.arg1, o.dry_run, o.quiet)) abort("cashgo: run failed");
        return;
    }

    abort("cashgo: unknown command '" + o.command + "'. Try: call cashgo.ash help");
}
