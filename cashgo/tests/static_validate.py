from pathlib import Path

root = Path(__file__).resolve().parents[1]
src = (root / "scripts" / "cashgo.ash").read_text()

assert 'script "cashgo";' in src
assert 'cli_execute(cmd)' in src
assert src.count('cli_execute(') == 1, "cli_execute should be centralized"
for forbidden in ['visit_url(', 'adventure(', 'buy(', 'send_kmail(', 'chat_private(']:
    assert forbidden not in src, forbidden
for required in ['git checkout ', 'git sync', 'git update', '--dry-run', 'cashgo.lock', 'cashgo.toml']:
    assert required in src, required
assert '?' not in _strip_comments_strings(src) if False else True

def strip_strings_comments(text: str) -> str:
    out=[]; i=0; in_str=False; esc=False
    while i < len(text):
        c=text[i]
        if in_str:
            if esc: esc=False
            elif c=='\\': esc=True
            elif c=='"': in_str=False
            out.append(' '); i+=1; continue
        if c=='"':
            in_str=True; out.append(' '); i+=1; continue
        if c=='/' and i+1<len(text) and text[i+1]=='/':
            while i<len(text) and text[i] != '\n':
                out.append(' '); i+=1
            continue
        out.append(c); i+=1
    return ''.join(out)

plain=strip_strings_comments(src)
assert plain.count('{') == plain.count('}')
assert plain.count('(') == plain.count(')')
assert '?' not in plain, "ternary/question-mark syntax should not appear in executable ASH"
assert 'sort ' not in plain, "v0.1 should rely on ordered ASH map iteration"

# `cli_execute` must be centralized behind a helper; direct hard-coded calls are forbidden.
lines=[ln.strip() for ln in src.splitlines() if 'cli_execute(' in ln]
assert lines == ['return cli_execute(cmd);'], lines

# Basic manifest fixture sanity.
manifest=(root/'examples'/'cashgo.toml').read_text()
assert '[package]' in manifest and '[dependencies]' in manifest
assert 'github:Veracity0/vprops@main' in manifest

print('CASHGO_STATIC_VALIDATE=PASS')
print('ash_lines=', len(src.splitlines()))
print('cli_execute_sites=', src.count('cli_execute('))
