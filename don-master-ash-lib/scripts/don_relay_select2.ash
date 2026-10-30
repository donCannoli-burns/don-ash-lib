script "don_relay_select2.ash";

/*
 * Read-only relay HTML transformer. Does not make network requests or load JS.
 * Inspired by C2Talon/insertSelect2 (MIT):
 *   https://github.com/C2Talon/insertSelect2
 *   https://github.com/donCannoli-burns/don_insertSelect2
 *
 * This helper intentionally DOES NOT install choice.*.ash or fight.ash
 * overrides. The owning relay handler can call it before emitting its HTML.
 *
 * A frontend must load/initialize a searchable-select implementation for
 * the class to be interactive. No third-party CDN is loaded by default.
 */

string don_relay_tag_searchable_selects(string page) {
    if (!contains_text(page, "<select")) return page;

    // A second application to an already-tagged page is a no-op.
    if (contains_text(page, "don-searchable-select")) return page;

    matcher withClass = create_matcher(
        `<select([^>]*class=["'])([^"']*)(["'][^>]*)>`, page
    );
    page = replace_all(withClass, "<select$1$2 don-searchable-select$3>");

    matcher withoutClass = create_matcher(
        '<select(((?!class=)[^>])*)>', page
    );
    page = replace_all(withoutClass, '<select class="don-searchable-select"$1>');

    return page;
}
