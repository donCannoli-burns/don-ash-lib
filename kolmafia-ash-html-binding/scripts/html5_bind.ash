// html5_bind.ash
// Small, deliberately bounded ASH <-> HTML/HTML5 helper library for KoLmafia.
// This library exposes helpers; the relay scripts decide which operations are callable.

string hb_json_escape(string s) {
    s = replace_string(s, "\\", "\\\\");
    s = replace_string(s, "\"", "\\\"");
    s = replace_string(s, "\r", "\\r");
    s = replace_string(s, "\n", "\\n");
    s = replace_string(s, "\t", "\\t");
    return s;
}

string hb_json_string(string s) {
    return "\"" + hb_json_escape(s) + "\"";
}

string hb_json_bool(boolean b) {
    if (b) return "true";
    return "false";
}

string hb_html(string s) {
    return entity_encode(s);
}

string hb_theme() {
    string theme = get_property("_ashHtml5_theme");
    if (theme == "") return "system";
    if (theme == "light" || theme == "dark" || theme == "system") return theme;
    return "system";
}

boolean hb_set_theme(string theme) {
    if (theme != "light" && theme != "dark" && theme != "system") return false;
    set_property("_ashHtml5_theme", theme);
    return true;
}

string hb_state_json() {
    string out = "{";
    out += "\"ok\":true,";
    out += "\"player\":" + hb_json_string(my_name()) + ",";
    out += "\"level\":" + my_level() + ",";
    out += "\"adventures\":" + my_adventures() + ",";
    out += "\"meat\":" + my_meat() + ",";
    out += "\"hp\":" + my_hp() + ",";
    out += "\"maxhp\":" + my_maxhp() + ",";
    out += "\"mp\":" + my_mp() + ",";
    out += "\"maxmp\":" + my_maxmp() + ",";
    out += "\"theme\":" + hb_json_string(hb_theme());
    out += "}";
    return out;
}

string hb_dispatch(string op, string value) {
    if (op == "ping") {
        return "{\"ok\":true,\"result\":\"pong\"}";
    }

    if (op == "state") {
        return hb_state_json();
    }

    if (op == "get_theme") {
        return "{\"ok\":true,\"theme\":" + hb_json_string(hb_theme()) + "}";
    }

    if (op == "set_theme") {
        if (!hb_set_theme(value)) {
            return "{\"ok\":false,\"error\":\"invalid_theme\"}";
        }
        return "{\"ok\":true,\"theme\":" + hb_json_string(hb_theme()) + "}";
    }

    return "{\"ok\":false,\"error\":\"unknown_operation\"}";
}
