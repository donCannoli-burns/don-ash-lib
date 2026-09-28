from pathlib import Path
import re, sys

path = Path(__file__).parents[1] / 'scripts' / 'pyash.ash'
src = path.read_text()
lines = src.splitlines()

# Strip line comments for a conservative call-order scan.
clean=[]
for line in lines:
    clean.append(line.split('//',1)[0])

# Locate py_* definitions and their brace ranges.
def_pat=re.compile(r'^\s*(?:void|boolean|int|float|string|py_value|py_token)\s+(py_[A-Za-z0-9_]+)\s*\(')
defs={}
for i,line in enumerate(clean,1):
    m=def_pat.match(line)
    if m: defs[m.group(1)] = i

errors=[]
call_pat=re.compile(r'\b(py_[A-Za-z0-9_]+)\s*\(')
current=None
for i,line in enumerate(clean,1):
    m=def_pat.match(line)
    if m: current=m.group(1)
    for name in call_pat.findall(line):
        if m and name == m.group(1):
            continue
        if name not in defs:
            errors.append(f'line {i}: call to undefined {name}')
        elif defs[name] > i and name != current:
            errors.append(f'line {i}: {name} called before definition at line {defs[name]}')

# Datatype names are reserved identifiers in ASH; reject them as parameters/locals.
reserved = {
    'boolean','int','float','string','buffer','matcher','item','location','class','stat',
    'skill','effect','familiar','slot','monster','path','element','phylum','thrall','servant',
    'coinmaster','record','void','aggregate'
}
# This is intentionally narrow: inspect declarations of the form TYPE identifier.
decl_pat=re.compile(r'\b(?:boolean|int|float|string|buffer|matcher|py_value|py_token)\s+([A-Za-z_][A-Za-z0-9_]*)')
for i,line in enumerate(clean,1):
    for name in decl_pat.findall(line):
        if name.lower() in reserved:
            errors.append(f'line {i}: reserved datatype used as identifier: {name}')

# Known accidental portability hazards from the first draft.
for bad, label in [
    ('py_value py_parse_expression();', 'C-style forward declaration'),
    ('$strings[', 'plural string aggregate literal dependency'),
]:
    if bad in src:
        errors.append(f'contains {label}: {bad}')

if '?' in '\n'.join(x.split('//',1)[0] for x in lines):
    errors.append('contains ?: / question-mark syntax; avoid relying on reserved ternary precedence')

if errors:
    print('PYASH_STATIC_VALIDATE=FAIL')
    print('\n'.join(errors))
    sys.exit(1)

print('PYASH_STATIC_VALIDATE=PASS')
print(f'functions={len(defs)}')
print(f'lines={len(lines)}')
