// PyASH Seed MCP relay dispatcher v0.1.0
//
// This is intentionally a narrow execution adapter. It loads only tools
// declared in data/pyash-mcp/tools.tsv and executes their PyASH source through
// the supplied PyASH v0.1 interpreter. It does not expose arbitrary ASH names.

import <pyash.ash>;

record mcp_tool_record {
    string title;
    string description;
    string script;
    string args;
};

mcp_tool_record [string] MCP_TOOL_REGISTRY;
string MCP_ERROR;

string mcp_trim(string s) {
    int left = 0;
    int right = length(s);
    while (left < right) {
        string c = char_at(s, left);
        if (c != " " && c != "\t" && c != "\r" && c != "\n") break;
        left += 1;
    }
    while (right > left) {
        string c = char_at(s, right - 1);
        if (c != " " && c != "\t" && c != "\r" && c != "\n") break;
        right -= 1;
    }
    return substring(s, left, right);
}

string mcp_json_escape(string s) {
    string out = "";
    int i = 0;
    while (i < length(s)) {
        string c = char_at(s, i);
        if (c == "\\") out += "\\\\";
        else if (c == "\"") out += "\\\"";
        else if (c == "\n") out += "\\n";
        else if (c == "\r") out += "\\r";
        else if (c == "\t") out += "\\t";
        else out += c;
        i += 1;
    }
    return out;
}

boolean mcp_safe_script_path(string path) {
    if (!starts_with(path, "pyash-mcp/tools/")) return false;
    if (!ends_with(path, ".py")) return false;
    if (index_of(path, "..") >= 0) return false;
    if (index_of(path, "\\") >= 0) return false;
    return true;
}

boolean mcp_seed_value(string name, string arg_kind, string raw_value) {
    if (!py_identifier(name)) {
        MCP_ERROR = "invalid PyASH argument name: " + name;
        return false;
    }

    if (arg_kind == "string") {
        PY_GLOBALS[name] = py_string(raw_value);
        return true;
    }
    if (arg_kind == "number" || arg_kind == "integer") {
        PY_GLOBALS[name] = py_number(to_float(raw_value));
        return true;
    }
    if (arg_kind == "boolean") {
        string b = to_lower_case(raw_value);
        if (b == "true" || b == "1") {
            PY_GLOBALS[name] = py_bool(true);
            return true;
        }
        if (b == "false" || b == "0") {
            PY_GLOBALS[name] = py_bool(false);
            return true;
        }
        MCP_ERROR = "invalid boolean for " + name;
        return false;
    }

    MCP_ERROR = "unsupported argument type for " + name + ": " + arg_kind;
    return false;
}

boolean mcp_seed_arguments(string spec, string [string] fields) {
    if (spec == "" || spec == "-") return true;

    string [int] entries = split_string(spec, ",");
    foreach _, entry in entries {
        string [int] parts = split_string(entry, ":");
        if (count(parts) < 3) {
            MCP_ERROR = "invalid registry argument spec: " + entry;
            return false;
        }

        string name = mcp_trim(parts[0]);
        string arg_kind = mcp_trim(parts[1]);
        string mode = mcp_trim(parts[2]);
        string field_name = "arg_" + name;
        string raw_value = "";

        if (fields contains field_name) {
            raw_value = fields[field_name];
        } else if (mode == "optional") {
            if (count(parts) >= 4) raw_value = parts[3];
        } else {
            MCP_ERROR = "missing required argument: " + name;
            return false;
        }

        if (!mcp_seed_value(name, arg_kind, raw_value)) return false;
    }
    return true;
}

py_value mcp_execute_tool(string tool_name, string [string] fields) {
    MCP_ERROR = "";
    py_reset();

    if (!(MCP_TOOL_REGISTRY contains tool_name)) {
        MCP_ERROR = "unknown tool: " + tool_name;
        return py_none();
    }

    mcp_tool_record tool = MCP_TOOL_REGISTRY[tool_name];
    if (!mcp_safe_script_path(tool.script)) {
        MCP_ERROR = "registry contains unsafe script path";
        return py_none();
    }

    if (!mcp_seed_arguments(tool.args, fields)) return py_none();

    buffer source_buffer = file_to_buffer(tool.script);
    string source = to_string(source_buffer);
    if (source == "") {
        MCP_ERROR = "tool source is empty or missing: " + tool.script;
        return py_none();
    }

    string [int] lines = split_string(source);
    if (!py_exec_range(lines, 0, count(lines), 0)) {
        MCP_ERROR = PY_ERROR;
        return py_none();
    }

    if (!(PY_GLOBALS contains "result")) {
        MCP_ERROR = "PyASH tool did not assign global 'result'";
        return py_none();
    }

    return PY_GLOBALS["result"];
}

string mcp_value_json(py_value value) {
    if (value.kind == "none") return "{\"ok\":true,\"kind\":\"none\",\"value\":null}";
    if (value.kind == "bool") {
        string b = "false";
        if (value.bool_value) b = "true";
        return "{\"ok\":true,\"kind\":\"bool\",\"value\":" + b + "}";
    }
    if (value.kind == "number") {
        return "{\"ok\":true,\"kind\":\"number\",\"value\":" + py_num_string(value.number_value) + "}";
    }
    if (value.kind == "string") {
        return "{\"ok\":true,\"kind\":\"string\",\"value\":\"" + mcp_json_escape(value.string_value) + "\"}";
    }
    return "{\"ok\":false,\"error\":\"invalid PyASH result kind\"}";
}

string mcp_error_json(string message) {
    return "{\"ok\":false,\"error\":\"" + mcp_json_escape(message) + "\"}";
}

void main() {
    if (!file_to_map("pyash-mcp/tools.tsv", MCP_TOOL_REGISTRY)) {
        writeln(mcp_error_json("could not load tool registry"));
        return;
    }

    string [string] fields = form_fields();
    if (!(fields contains "tool")) {
        writeln(mcp_error_json("missing tool field"));
        return;
    }

    string tool_name = fields["tool"];
    py_value result = mcp_execute_tool(tool_name, fields);
    if (MCP_ERROR != "") {
        writeln(mcp_error_json(MCP_ERROR));
        return;
    }

    writeln(mcp_value_json(result));
}
