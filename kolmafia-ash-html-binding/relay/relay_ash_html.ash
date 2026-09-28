import <html5_bind.ash>;

void page_head(string title) {
    write("<!DOCTYPE html>");
    write("<html><head><meta charset=\"utf-8\">");
    write("<title>" + hb_html(title) + "</title>");
    write("<style>");
    write("body{font-family:sans-serif;max-width:760px;margin:2rem auto;padding:0 1rem}");
    write("fieldset{margin:1rem 0;padding:1rem}code,pre{background:#eee;padding:.15rem .3rem}");
    write("button,select{font:inherit;padding:.35rem .6rem}");
    write("</style></head><body>");
}

void main() {
    string op = form_field("op");
    string value = form_field("value");

    page_head("KoLmafia ASH ↔ HTML binding");
    write("<h1>ASH ↔ HTML binding</h1>");
    write("<p>This version uses ordinary HTML forms and works without JavaScript.</p>");

    if (op != "") {
        write("<h2>Result</h2><pre>");
        write(hb_html(hb_dispatch(op, value)));
        write("</pre>");
    }

    write("<fieldset><legend>Read state</legend>");
    write("<form method=\"post\" action=\"" + hb_html(__FILE__) + "\">");
    write("<input type=\"hidden\" name=\"op\" value=\"state\">");
    write("<button type=\"submit\">Read KoLmafia state</button>");
    write("</form></fieldset>");

    write("<fieldset><legend>Theme preference</legend>");
    write("<form method=\"post\" action=\"" + hb_html(__FILE__) + "\">");
    write("<input type=\"hidden\" name=\"op\" value=\"set_theme\">");
    write("<select name=\"value\">");
    write("<option value=\"system\">System</option>");
    write("<option value=\"light\">Light</option>");
    write("<option value=\"dark\">Dark</option>");
    write("</select> ");
    write("<button type=\"submit\">Save namespaced preference</button>");
    write("</form></fieldset>");

    write("<p><small>No raw CLI, arbitrary ASH, or arbitrary preference access is exposed.</small></p>");
    write("</body></html>");
}
