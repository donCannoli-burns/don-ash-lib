# ASH / PyASH Web Scraper

A bounded, GET-only web scraper for KoLmafia, implemented in ASH and exposed to PyASH.

The project is intentionally small:

```text
URL
  -> visit_url(..., false)       GET only
  -> strip script/style/markup
  -> entity decode
  -> normalize text lines
  -> hard line limit (default 50, maximum 100)
  -> HTML / Markdown / PDF
       |             |
       |             +-> ~/.kolmafia/data/scraper/
       +-> print_html() in gCLI
```

It does **not** execute page JavaScript, submit forms, POST, click links, crawl a site, or expose arbitrary gCLI commands.

## Install

From the unpacked project:

```bash
./install.sh
```

By default that installs into `~/.kolmafia`. Override with:

```bash
KOLMAFIA_HOME=/path/to/.kolmafia ./install.sh
```

The installer creates:

```text
~/.kolmafia/scripts/ashscrape.ash
~/.kolmafia/scripts/pyash-web.ash
~/.kolmafia/data/pyash/web_demo.py
~/.kolmafia/data/scraper/
```

## Native ASH CLI

### Scrape 50 lines and write all formats

```text
call ashscrape.ash scrape --url=https://example.com --max-lines=50 --format=all --dest=data
```

Writes:

```text
~/.kolmafia/data/scraper/example.com.html
~/.kolmafia/data/scraper/example.com.md
~/.kolmafia/data/scraper/example.com.pdf
~/.kolmafia/data/scraper/index.tsv
```

### Scrape at most 100 lines

```text
call ashscrape.ash scrape --url=https://example.com --max-lines=100 --format=md --dest=data
```

`100` is the hard v0.1 ceiling. A request such as `--max-lines=9000` is clamped to 100.

### Print the result directly into gCLI as rendered HTML

```text
call ashscrape.ash scrape --url=https://example.com --max-lines=50 --dest=gcli
```

`gcli` output always uses `print_html()` regardless of the file-format setting.

### File + gCLI at once

```text
call ashscrape.ash scrape --url=https://example.com --max-lines=100 --format=all --dest=both --name=example-home
```

## Arguments

| Argument | Values | Default | Meaning |
|---|---|---:|---|
| `--url=` | `http://...` or `https://...` | required | Page to GET |
| `--max-lines=` | `1..100` | `50` | Maximum normalized output lines |
| `--max-source-chars=` | `1..1000000` | `250000` | Maximum source characters processed after retrieval |
| `--format=` | `html`, `md`, `pdf`, `all` | `all` | Data-file output |
| `--dest=` | `data`, `gcli`, `both` | `data` | Destination |
| `--name=` | safe filename stem | URL-derived | Filename under `data/scraper/` |

Names are sanitized to `[A-Za-z0-9._-]`; callers cannot use `../` to escape the scraper directory.

## ASH library API

Import the scraper from another ASH script:

```ash
import <ashscrape.ash>;

string text = scrape("https://example.com", 50);
print(text);
```

Save a result:

```ash
boolean ok = scrape_save(
    "https://example.com",
    "all",
    100,
    "example-home"
);
```

Or render directly in gCLI:

```ash
scrape_print("https://example.com", 50);
```

Public helpers:

```text
string  scrape(string url)
string  scrape(string url, int max_lines)
boolean scrape_save(string url, string format, int max_lines, string name)
void    scrape_print(string url)
void    scrape_print(string url, int max_lines)
```

## PyASH integration

`pyash-web.ash` is the earlier PyASH interpreter with the scraper imported as an explicit capability.

It adds only three Python-like built-ins:

```python
scrape(url, max_lines=50)
scrape_print(url, max_lines=50)
scrape_save(url, format, max_lines, name)
```

Example:

```python
text = scrape("https://example.com", 50)
print(text)

result = scrape_save(
    "https://example.com",
    "all",
    50,
    "example-com"
)
print(result)
```

Run the included example:

```text
call pyash-web.ash run pyash/web_demo.py
```

Or call the scraper CLI through the PyASH-enabled script:

```text
call pyash-web.ash scrape --url=https://example.com --max-lines=50 --format=all --dest=both
```

## What counts as a line?

The limit applies *after* normalization.

The scraper:

1. removes HTML comments, `<script>`, `<style>`, `<noscript>`, and `<svg>` blocks;
2. converts common block endings and `<br>` to newlines;
3. removes the remaining tags;
4. decodes HTML entities;
5. collapses horizontal whitespace;
6. drops empty lines;
7. drops immediately repeated duplicate lines;
8. keeps only the requested first N lines.

This is intentionally closer to a small reader/extractor than an HTML source dumper.

## Output formats

### HTML

A standalone readable HTML document with source metadata and numbered lines.

### Markdown

A title, source URL, line-count metadata, and normalized text.

### PDF

The ASH runtime generates a minimal PDF 1.4 file directly. It uses built-in Helvetica and requires no external converter.

The PDF renderer is deliberately text-oriented:

- maximum 100 scraped lines;
- 50 scraped lines per page;
- up to 2 pages in v0.1;
- long PDF lines are cropped to fit;
- non-ASCII characters are replaced with `?` in PDF output so byte offsets remain deterministic.

HTML and Markdown retain normal Unicode text.

This is a scraped-text PDF, **not** a browser screenshot or faithful webpage layout renderer.

## Index

Every data save updates:

```text
~/.kolmafia/data/scraper/index.tsv
```

using KoLmafia's `map_to_file()` support. It stores the source URL, title, retained line count, and selected format for each sanitized output name.

## Safety / bounded behavior

The runtime intentionally has these constraints:

```text
GET only
http:// and https:// only
no cli_execute()
no form submission
no POST
no link following/crawl loop
50 lines default
100 lines hard maximum
250,000 processed source chars default
1,000,000 processed source chars hard maximum
fixed data/scraper output directory
sanitized filenames
```

A single call retrieves a single URL. If you later add crawling, add an independent page-count/rate limit rather than weakening the per-page bounds.

## Verification in KoLmafia

The recommended first local checks are:

```text
verify ashscrape.ash
verify pyash-web.ash
```

Then:

```text
call ashscrape.ash scrape --url=https://example.com --max-lines=50 --dest=gcli
```

and:

```text
call ashscrape.ash scrape --url=https://example.com --max-lines=100 --format=all --dest=data --name=example
```

Inspect:

```text
~/.kolmafia/data/scraper/example.html
~/.kolmafia/data/scraper/example.md
~/.kolmafia/data/scraper/example.pdf
```

## Validation included here

The package contains a local HTML fixture and example HTML/Markdown/PDF output. The PDF generator design was tested at both the small fixture size and the full 100-line/two-page boundary; the generated PDFs render successfully.

See [`VALIDATION.md`](VALIDATION.md).

## Why It Exists

It provides a deliberately bounded web-to-text/HTML/Markdown/PDF path without turning ASH into a general crawler or arbitrary command surface.

## Files

- `LICENSE` — packaged source/support material.
- `VALIDATION.md` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `data/` — packaged source/support material.
- `examples/` — packaged source/support material.
- `install.sh` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `tests/` — packaged source/support material.
- `tools/` — packaged source/support material.

## Status

Prototype.

## Compatibility

KoLmafia ASH plus Python 3 for portable validation; live ASH verification still belongs to the installed KoLmafia runtime.

## Provenance

Extracted and packaged as a standalone repository from `ash-pyash-webscraper-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- portable static validator

KoLmafia verify/live GET not run.
