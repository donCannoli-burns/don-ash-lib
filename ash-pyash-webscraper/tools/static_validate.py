from pathlib import Path
import re, sys
root = Path(__file__).parents[1]
errors=[]

ash = (root/'scripts'/'ashscrape.ash').read_text()
pyash = (root/'scripts'/'pyash-web.ash').read_text()

# Basic structural checks.
required = [
    'visit_url(url, false, false)',
    'print_html(',
    'buffer_to_file(',
    'map_to_file(',
    'SCRAPER_DEFAULT_LINES = 50',
    'SCRAPER_HARD_MAX_LINES = 100',
    'string sc_render_pdf(',
    'string sc_render_html(',
    'string sc_render_markdown(',
    'string scrape(string url, int max_lines)',
]
for token in required:
    if token not in ash:
        errors.append(f'missing required token: {token}')

for forbidden in ['cli_execute(', 'adventure(', 'buy(', 'sell(', 'use(', 'eat(', 'drink(', 'chat_']:
    # Ignore mentions in comments by scanning comment-stripped source.
    cleaned='\n'.join(line.split('//',1)[0] for line in ash.splitlines())
    if forbidden in cleaned:
        errors.append(f'forbidden mutation/escape surface: {forbidden}')

if 'import <ashscrape.ash>;' not in pyash:
    errors.append('pyash-web.ash does not import ashscrape.ash')
for token in ['name == "scrape"', 'name == "scrape_print"', 'name == "scrape_save"']:
    if token not in pyash:
        errors.append(f'missing PyASH builtin: {token}')

# Conservative call-order check for sc_* helpers in native file.
defpat = re.compile(r'^\s*(?:void|boolean|int|float|string|scrape_page|scrape_options)\s+(sc_[A-Za-z0-9_]+)\s*\(', re.M)
defs = {m.group(1): ash[:m.start()].count('\n')+1 for m in defpat.finditer(ash)}
lines=ash.splitlines()
current=None
for no,line in enumerate(lines,1):
    code=line.split('//',1)[0]
    dm=re.match(r'^\s*(?:void|boolean|int|float|string|scrape_page|scrape_options)\s+(sc_[A-Za-z0-9_]+)\s*\(', code)
    if dm: current=dm.group(1)
    for name in re.findall(r'\b(sc_[A-Za-z0-9_]+)\s*\(', code):
        if dm and name == dm.group(1):
            continue
        if name not in defs:
            errors.append(f'line {no}: undefined helper {name}')
        elif defs[name] > no and name != current:
            errors.append(f'line {no}: {name} called before definition at {defs[name]}')

if errors:
    print('ASH_SCRAPER_STATIC_VALIDATE=FAIL')
    print('\n'.join(errors))
    sys.exit(1)
print('ASH_SCRAPER_STATIC_VALIDATE=PASS')
print(f'ash_lines={len(ash.splitlines())}')
print(f'pyash_web_lines={len(pyash.splitlines())}')
print(f'sc_helpers={len(defs)}')
