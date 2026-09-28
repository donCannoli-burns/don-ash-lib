// ASH/PyASH Web Scraper v0.1.0
// Bounded, GET-only web scraper for KoLmafia.
//
// Examples:
//   call ashscrape.ash scrape --url=https://example.com --max-lines=50 --format=all --dest=data
//   call ashscrape.ash scrape --url=https://example.com --max-lines=100 --format=md --dest=both --name=example
//
// Output data files live under ~/.kolmafia/data/scraper/.
// gCLI output is always HTML via print_html().

record scrape_page {
    string url;
    string title;
    string raw_html;
    string [int] lines;
    int line_count;
    boolean truncated;
};

record scrape_options {
    string url;
    string format;
    string dest;
    string name;
    int max_lines;
    int max_source_chars;
};

record scrape_index_entry {
    string url;
    string title;
    int lines;
    string formats;
};

int SCRAPER_DEFAULT_LINES = 50;
int SCRAPER_HARD_MAX_LINES = 100;
int SCRAPER_DEFAULT_SOURCE_CHARS = 250000;
int SCRAPER_HARD_MAX_SOURCE_CHARS = 1000000;

string sc_trim_left(string s) {
    int i = 0;
    while (i < length(s)) {
        string c = char_at(s, i);
        if (c != " " && c != "\t" && c != "\r" && c != "\n") break;
        i += 1;
    }
    return substring(s, i);
}

string sc_trim_right(string s) {
    int i = length(s);
    while (i > 0) {
        string c = char_at(s, i - 1);
        if (c != " " && c != "\t" && c != "\r" && c != "\n") break;
        i -= 1;
    }
    return substring(s, 0, i);
}

string sc_trim(string s) {
    return sc_trim_right(sc_trim_left(s));
}

string sc_regex_replace(string source, string pattern, string replacement) {
    matcher m = create_matcher(pattern, source);
    return replace_all(m, replacement);
}

string sc_collapse_ws(string s) {
    string out = sc_regex_replace(s, "[\\t\\x0B\\f\\r ]+", " ");
    return sc_trim(out);
}

string sc_ascii(string s) {
    // Keep PDF byte offsets deterministic: the PDF renderer uses ASCII only.
    return sc_regex_replace(s, "[^\\x20-\\x7E]", "?");
}

string sc_safe_name(string name) {
    name = sc_trim(name);
    if (name == "") name = "scrape";
    name = sc_regex_replace(name, "[^A-Za-z0-9._-]+", "-");
    name = sc_regex_replace(name, "^-+|-+$", "");
    if (name == "") name = "scrape";
    if (length(name) > 80) name = substring(name, 0, 80);
    return name;
}

string sc_name_from_url(string url) {
    string s = url;
    s = sc_regex_replace(s, "^[A-Za-z]+://", "");
    s = sc_regex_replace(s, "[?#].*$", "");
    s = sc_regex_replace(s, "[/\\\\]+", "-");
    return sc_safe_name(s);
}

boolean sc_allowed_url(string url) {
    string u = to_lower_case(sc_trim(url));
    return starts_with(u, "http://") || starts_with(u, "https://");
}

int sc_bound_lines(int requested) {
    if (requested <= 0) return SCRAPER_DEFAULT_LINES;
    if (requested > SCRAPER_HARD_MAX_LINES) return SCRAPER_HARD_MAX_LINES;
    return requested;
}

int sc_bound_source_chars(int requested) {
    if (requested <= 0) return SCRAPER_DEFAULT_SOURCE_CHARS;
    if (requested > SCRAPER_HARD_MAX_SOURCE_CHARS) return SCRAPER_HARD_MAX_SOURCE_CHARS;
    return requested;
}

string sc_extract_title(string html) {
    matcher m = create_matcher("(?is)<title\\b[^>]*>(.*?)</title>", html);
    if (find(m)) {
        string t = group(m, 1);
        t = sc_regex_replace(t, "(?is)<[^>]+>", "");
        t = entity_decode(t);
        t = sc_collapse_ws(t);
        if (t != "") return t;
    }
    return "Untitled scrape";
}

string sc_html_to_text(string html) {
    string s = html;

    // Remove content that is almost never useful in a text scrape.
    s = sc_regex_replace(s, "(?is)<!--.*?-->", " ");
    s = sc_regex_replace(s, "(?is)<script\\b[^>]*>.*?</script>", " ");
    s = sc_regex_replace(s, "(?is)<style\\b[^>]*>.*?</style>", " ");
    s = sc_regex_replace(s, "(?is)<noscript\\b[^>]*>.*?</noscript>", " ");
    s = sc_regex_replace(s, "(?is)<svg\\b[^>]*>.*?</svg>", " ");

    // Preserve visual block boundaries before removing markup.
    s = sc_regex_replace(s, "(?is)<br\\s*/?>", "\n");
    s = sc_regex_replace(s, "(?is)</(p|div|section|article|header|footer|main|aside|nav|li|ul|ol|table|tr|h[1-6]|pre|blockquote)\\s*>", "\n");
    s = sc_regex_replace(s, "(?is)<li\\b[^>]*>", "- ");
    s = sc_regex_replace(s, "(?is)<[^>]+>", " ");

    s = entity_decode(s);
    s = replace_string(s, "\r\n", "\n").to_string();
    s = replace_string(s, "\r", "\n").to_string();
    return s;
}

scrape_page sc_fetch(string url, int max_lines, int max_source_chars) {
    scrape_page page;
    page.url = url;

    if (!sc_allowed_url(url)) {
        page.title = "ERROR: only http:// and https:// URLs are accepted";
        return page;
    }

    max_lines = sc_bound_lines(max_lines);
    max_source_chars = sc_bound_source_chars(max_source_chars);

    // Explicit GET. No scraper request ever uses POST.
    string html = visit_url(url, false, false);
    if (html == "") {
        page.title = "ERROR: empty response or request timeout";
        return page;
    }

    page.raw_html = html;
    page.title = sc_extract_title(html);

    string working = html;
    if (length(working) > max_source_chars) {
        working = substring(working, 0, max_source_chars);
        page.truncated = true;
    }

    string text = sc_html_to_text(working);
    string [int] raw_lines = split_string(text, "\n");
    string previous = "";

    foreach _, raw in raw_lines {
        string line = sc_collapse_ws(raw);
        if (line == "") continue;
        if (line == previous) continue;
        if (count(page.lines) >= max_lines) {
            page.truncated = true;
            break;
        }
        page.lines[count(page.lines)] = line;
        previous = line;
    }

    page.line_count = count(page.lines);
    return page;
}

string sc_render_markdown(scrape_page page) {
    buffer out;
    out.append("# " + page.title + "\n\n");
    out.append("Source: " + page.url + "\n\n");
    out.append("Lines: " + page.line_count);
    if (page.truncated) out.append(" (bounded/truncated)");
    out.append("\n\n---\n\n");

    foreach _, line in page.lines {
        out.append(line + "\n\n");
    }
    return out.to_string();
}

string sc_render_html(scrape_page page) {
    buffer out;
    string safe_title = entity_encode(page.title);
    string safe_url = entity_encode(page.url);

    out.append("<!doctype html>\n<html><head><meta charset=\"utf-8\">");
    out.append("<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">");
    out.append("<title>" + safe_title + "</title>");
    out.append("<style>body{font:16px/1.55 system-ui,sans-serif;max-width:960px;margin:2rem auto;padding:0 1rem;background:#f6f3e8;color:#1b1b1b}main{background:#fff;border:1px solid #bbb;padding:1.25rem;box-shadow:4px 4px 0 #222}h1{line-height:1.1}.meta{font-family:monospace;font-size:.9rem;border-bottom:1px solid #bbb;padding-bottom:1rem;margin-bottom:1rem}.line{display:grid;grid-template-columns:3.5rem 1fr;gap:.75rem;border-bottom:1px dotted #ccc;padding:.32rem 0}.n{color:#666;text-align:right;font-family:monospace}.bounded{background:#fff0b3;padding:.5rem;border:1px solid #8a6d00}</style></head><body><main>");
    out.append("<h1>" + safe_title + "</h1>");
    out.append("<div class=\"meta\"><a href=\"" + safe_url + "\">" + safe_url + "</a><br>lines: " + page.line_count + "</div>");
    if (page.truncated) out.append("<p class=\"bounded\">Output was bounded by the configured source/line limit.</p>");

    foreach i, line in page.lines {
        out.append("<div class=\"line\"><span class=\"n\">" + (i + 1) + "</span><span>" + entity_encode(line) + "</span></div>");
    }
    out.append("</main></body></html>\n");
    return out.to_string();
}

string sc_pdf_escape(string s) {
    s = sc_ascii(s);
    s = replace_string(s, "\\", "\\\\").to_string();
    s = replace_string(s, "(", "\\(").to_string();
    s = replace_string(s, ")", "\\)").to_string();
    return s;
}

string sc_pdf_crop(string s, int width) {
    s = sc_ascii(s);
    if (length(s) <= width) return s;
    if (width <= 3) return substring(s, 0, width);
    return substring(s, 0, width - 3) + "...";
}

string sc_pad10(int n) {
    string s = to_string(n);
    while (length(s) < 10) s = "0" + s;
    return s;
}

string sc_render_pdf(scrape_page page) {
    // Minimal ASCII PDF 1.4 generator. Up to 100 scraped lines, split across
    // 50-line pages. Helvetica keeps the file dependency-free.
    int lines_per_page = 50;
    int page_count = 1;
    if (page.line_count > lines_per_page) page_count = 2;

    int [int] offsets;
    string [int] objects;

    string kids = "";
    int p = 0;
    while (p < page_count) {
        int page_obj = 4 + (p * 2);
        if (kids != "") kids += " ";
        kids += page_obj + " 0 R";
        p += 1;
    }

    objects[1] = "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n";
    objects[2] = "2 0 obj\n<< /Type /Pages /Kids [" + kids + "] /Count " + page_count + " >>\nendobj\n";
    objects[3] = "3 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n";

    p = 0;
    while (p < page_count) {
        int page_obj = 4 + (p * 2);
        int content_obj = page_obj + 1;
        objects[page_obj] = page_obj + " 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 3 0 R >> >> /Contents " + content_obj + " 0 R >>\nendobj\n";

        buffer stream;
        stream.append("BT\n/F1 9 Tf\n46 754 Td\n12 TL\n");
        if (p == 0) {
            stream.append("(" + sc_pdf_escape(sc_pdf_crop(page.title, 92)) + ") Tj\nT*\n");
            stream.append("(" + sc_pdf_escape(sc_pdf_crop("Source: " + page.url, 92)) + ") Tj\nT*\n");
            stream.append("( ) Tj\nT*\n");
        } else {
            stream.append("(" + sc_pdf_escape(sc_pdf_crop(page.title + " (continued)", 92)) + ") Tj\nT*\n");
            stream.append("( ) Tj\nT*\n");
        }

        int start_line = p * lines_per_page;
        int end_line = start_line + lines_per_page;
        if (end_line > page.line_count) end_line = page.line_count;
        int i = start_line;
        while (i < end_line) {
            string label = to_string(i + 1) + ". " + page.lines[i];
            stream.append("(" + sc_pdf_escape(sc_pdf_crop(label, 96)) + ") Tj\nT*\n");
            i += 1;
        }
        if (page.truncated && p == page_count - 1) {
            stream.append("( ) Tj\nT*\n");
            stream.append("([bounded/truncated]) Tj\nT*\n");
        }
        stream.append("ET\n");
        string stream_text = stream.to_string();
        objects[content_obj] = content_obj + " 0 obj\n<< /Length " + length(stream_text) + " >>\nstream\n" + stream_text + "endstream\nendobj\n";
        p += 1;
    }

    int object_count = 3 + (page_count * 2);
    buffer pdf;
    pdf.append("%PDF-1.4\n%ASH-PyASH-Scraper\n");

    int obj = 1;
    while (obj <= object_count) {
        offsets[obj] = length(pdf.to_string());
        pdf.append(objects[obj]);
        obj += 1;
    }

    int xref_offset = length(pdf.to_string());
    pdf.append("xref\n0 " + (object_count + 1) + "\n");
    pdf.append("0000000000 65535 f \n");
    obj = 1;
    while (obj <= object_count) {
        pdf.append(sc_pad10(offsets[obj]) + " 00000 n \n");
        obj += 1;
    }
    pdf.append("trailer\n<< /Size " + (object_count + 1) + " /Root 1 0 R >>\n");
    pdf.append("startxref\n" + xref_offset + "\n%%EOF\n");
    return pdf.to_string();
}

boolean sc_write_text_file(string contents, string relative_path) {
    buffer b;
    b.append(contents);
    return buffer_to_file(b, relative_path);
}

void sc_update_index(scrape_page page, string name, string formats) {
    scrape_index_entry [string] index;
    file_to_map("scraper/index.tsv", index);
    scrape_index_entry entry;
    entry.url = page.url;
    entry.title = page.title;
    entry.lines = page.line_count;
    entry.formats = formats;
    index[name] = entry;
    map_to_file(index, "scraper/index.tsv");
}

boolean sc_write_outputs(scrape_page page, string name, string format) {
    boolean ok = true;
    name = sc_safe_name(name);
    format = to_lower_case(format);

    if (format == "html" || format == "all") {
        if (!sc_write_text_file(sc_render_html(page), "scraper/" + name + ".html")) ok = false;
    }
    if (format == "md" || format == "markdown" || format == "all") {
        if (!sc_write_text_file(sc_render_markdown(page), "scraper/" + name + ".md")) ok = false;
    }
    if (format == "pdf" || format == "all") {
        if (!sc_write_text_file(sc_render_pdf(page), "scraper/" + name + ".pdf")) ok = false;
    }

    sc_update_index(page, name, format);
    return ok;
}

void sc_print_gcli(scrape_page page) {
    buffer out;
    out.append("<div style='font-family:system-ui,sans-serif;border:1px solid #777;padding:8px;background:#f8f8f8'>");
    out.append("<b>ASH/PyASH scrape:</b> " + entity_encode(page.title));
    out.append(" <span style='color:#666'>(" + page.line_count + " lines)</span><br>");
    out.append("<span style='font-family:monospace;font-size:smaller'>" + entity_encode(page.url) + "</span>");
    if (page.truncated) out.append("<div style='color:#8a5a00'><b>bounded/truncated</b></div>");
    out.append("<ol style='margin-top:6px'>");
    foreach _, line in page.lines out.append("<li>" + entity_encode(line) + "</li>");
    out.append("</ol></div>");
    print_html(out.to_string());
}

scrape_options sc_default_options() {
    scrape_options o;
    o.format = "all";
    o.dest = "data";
    o.max_lines = SCRAPER_DEFAULT_LINES;
    o.max_source_chars = SCRAPER_DEFAULT_SOURCE_CHARS;
    return o;
}

scrape_options sc_parse_options(string command) {
    scrape_options o = sc_default_options();
    string [int] parts = split_string(sc_trim(command), " ");

    foreach _, part in parts {
        if (part == "" || part == "scrape") continue;
        if (starts_with(part, "--url=")) o.url = substring(part, 6);
        else if (starts_with(part, "--format=")) o.format = substring(part, 9);
        else if (starts_with(part, "--dest=")) o.dest = substring(part, 7);
        else if (starts_with(part, "--name=")) o.name = substring(part, 7);
        else if (starts_with(part, "--max-lines=")) o.max_lines = to_int(substring(part, 12));
        else if (starts_with(part, "--max-source-chars=")) o.max_source_chars = to_int(substring(part, 19));
        else if (starts_with(part, "http://") || starts_with(part, "https://")) o.url = part;
    }

    o.max_lines = sc_bound_lines(o.max_lines);
    o.max_source_chars = sc_bound_source_chars(o.max_source_chars);
    o.format = to_lower_case(o.format);
    o.dest = to_lower_case(o.dest);
    if (o.name == "" && o.url != "") o.name = sc_name_from_url(o.url);
    o.name = sc_safe_name(o.name);
    return o;
}

boolean sc_valid_format(string format) {
    return format == "html" || format == "md" || format == "markdown" || format == "pdf" || format == "all";
}

boolean sc_valid_dest(string dest) {
    return dest == "data" || dest == "gcli" || dest == "both";
}

// Public library API ---------------------------------------------------------
// These functions make the scraper usable from other ASH scripts with import.

string scrape(string url, int max_lines) {
    scrape_page page = sc_fetch(url, max_lines, SCRAPER_DEFAULT_SOURCE_CHARS);
    if (starts_with(page.title, "ERROR:")) return "";
    buffer out;
    foreach _, line in page.lines {
        if (length(out.to_string()) > 0) out.append("\n");
        out.append(line);
    }
    return out.to_string();
}

string scrape(string url) {
    return scrape(url, SCRAPER_DEFAULT_LINES);
}

boolean scrape_save(string url, string format, int max_lines, string name) {
    format = to_lower_case(format);
    if (!sc_valid_format(format)) return false;
    scrape_page page = sc_fetch(url, max_lines, SCRAPER_DEFAULT_SOURCE_CHARS);
    if (starts_with(page.title, "ERROR:")) return false;
    return sc_write_outputs(page, sc_safe_name(name), format);
}

void scrape_print(string url, int max_lines) {
    scrape_page page = sc_fetch(url, max_lines, SCRAPER_DEFAULT_SOURCE_CHARS);
    if (starts_with(page.title, "ERROR:")) {
        print("scraper: " + page.title, "red");
        return;
    }
    sc_print_gcli(page);
}

void scrape_print(string url) {
    scrape_print(url, SCRAPER_DEFAULT_LINES);
}

void sc_help() {
    print("ASH/PyASH Web Scraper v0.1.0", "blue");
    print("GET-only, bounded text scraper. Data output: ~/.kolmafia/data/scraper/.");
    print("Usage:");
    print("  call ashscrape.ash scrape --url=https://example.com --max-lines=50 --format=all --dest=data");
    print("  call ashscrape.ash scrape --url=https://example.com --max-lines=100 --format=md --dest=both --name=example");
    print("Options:");
    print("  --url=URL                 required; http:// or https:// only");
    print("  --max-lines=N             default 50; hard maximum 100");
    print("  --max-source-chars=N      default 250000; hard maximum 1000000");
    print("  --format=html|md|pdf|all  data-file formats; default all");
    print("  --dest=data|gcli|both     gCLI mode always uses HTML; default data");
    print("  --name=NAME               sanitized base filename under data/scraper/");
}

void sc_run(scrape_options o) {
    if (o.url == "") {
        print("scraper: --url is required", "red");
        return;
    }
    if (!sc_allowed_url(o.url)) {
        print("scraper: only http:// and https:// URLs are accepted", "red");
        return;
    }
    if (!sc_valid_format(o.format)) {
        print("scraper: invalid --format; use html, md, pdf, or all", "red");
        return;
    }
    if (!sc_valid_dest(o.dest)) {
        print("scraper: invalid --dest; use data, gcli, or both", "red");
        return;
    }

    print("scraper: GET " + o.url + " (max-lines=" + o.max_lines + ")", "blue");
    scrape_page page = sc_fetch(o.url, o.max_lines, o.max_source_chars);
    if (starts_with(page.title, "ERROR:")) {
        print("scraper: " + page.title, "red");
        return;
    }

    if (o.dest == "data" || o.dest == "both") {
        boolean ok = sc_write_outputs(page, o.name, o.format);
        if (ok) print("scraper: wrote data/scraper/" + o.name + " [" + o.format + "]", "green");
        else print("scraper: one or more file writes failed", "red");
    }
    if (o.dest == "gcli" || o.dest == "both") sc_print_gcli(page);
}

void main(string command) {
    command = sc_trim(command);
    if (command == "" || command == "help" || command == "--help") {
        sc_help();
        return;
    }
    scrape_options o = sc_parse_options(command);
    sc_run(o);
}
