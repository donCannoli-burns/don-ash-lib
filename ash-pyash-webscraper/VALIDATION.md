# Validation - ASH / PyASH Web Scraper v0.1.0

## Completed

- Static scraper structure audit: **PASS**
- GET-only transport check (`visit_url(url, false, false)`): **PASS**
- Mutation/escape scan (`cli_execute`, adventuring, buy/sell/use/eat/drink): **PASS**
- Default line cap present: **50**
- Hard line cap present: **100**
- HTML renderer present: **PASS**
- Markdown renderer present: **PASS**
- Native PDF renderer present: **PASS**
- Data-file writer present: **PASS**
- `map_to_file()` index present: **PASS**
- `print_html()` gCLI renderer present: **PASS**
- PyASH import and explicit scraper built-ins present: **PASS**

Static validator result:

```text
ASH_SCRAPER_STATIC_VALIDATE=PASS
ash_lines=521
pyash_web_lines=869
sc_helpers=30
```

## PDF verification

A local fixture was normalized and passed through an equivalent byte-for-byte PDF layout algorithm.

Small fixture:

```text
pages: 1
render: PASS
```

Boundary fixture:

```text
scraped lines: 100
pages: 2
line 51 begins page 2: PASS
line 100 visible on page 2: PASS
render: PASS
```

The checked example is `examples/sample-output.pdf`.

## Not claimed

This environment does not have a runnable KoLmafia JAR installed, so the package has **not** been through KoLmafia's own `verify` command here and no live `visit_url()` request was executed from ASH.

Recommended local verification:

```text
verify ashscrape.ash
verify pyash-web.ash
call ashscrape.ash scrape --url=https://example.com --max-lines=50 --dest=gcli
```

No live KoL character actions were performed during package validation.
