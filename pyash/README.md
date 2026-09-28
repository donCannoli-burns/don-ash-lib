# PyASH

**PyASH** is a small Python-like interpreter implemented entirely in KoLmafia ASH.

It is not CPython and does not attempt Python bytecode or C-extension compatibility. Its purpose is to provide a deliberately small, understandable Python-flavored language that can run *inside* KoLmafia's ASH environment.

## v0.1 language

Supported:

- numbers (stored internally as ASH `float`)
- strings
- `True`, `False`, `None`
- variables and assignment
- `+=`, `-=`, `*=`, `/=`, `%=`
- arithmetic: `+ - * / %`
- comparisons: `== != < <= > >=`
- boolean operators: `and`, `or`, `not`
- parentheses
- `if ...:` / `else:`
- `while ...:` with a 10,000-iteration safety ceiling
- `pass`
- `print(...)`
- built-ins: `str`, `int`, `float`, `bool`, `len`, `abs`, `min`, `max`
- comments beginning with `#`
- single- and double-quoted strings with basic escapes

Not yet supported:

- `def`, `return`, lambdas or closures
- lists, tuples, dictionaries or sets
- indexing/slicing
- `for` / iterators
- imports
- classes
- exceptions
- comprehensions
- Python modules/C extensions
- arbitrary ASH, CLI, URL, or game-mutating calls

The last limitation is intentional. v0.1 is a language core rather than an execution bypass. A future host API can expose selected KoLmafia/ASH functions through an explicit allowlist.

## Install

Copy:

```text
scripts/pyash.ash
```

to KoLmafia's `scripts/` directory.

Put Python-like programs under KoLmafia's `data/` or `scripts/` tree. `py_run_file()` uses KoLmafia's `file_to_buffer()`, and KoLmafia file-loading APIs resolve files from those script/data locations.

## CLI

Evaluate one expression:

```text
call pyash.ash eval 2 + 3 * 4
```

Run a file:

```text
call pyash.ash run pyash/hello.py
```

## Example

```python
name = "KoLmafia"
count = 3

print("Hello from", name)

while count > 0:
    print("count", count)
    count -= 1

if count == 0:
    print("done")
else:
    print("unexpected")
```

Expected output:

```text
Hello from KoLmafia
count 3
count 2
count 1
done
```

## Embedding from another ASH script

Import the script and use:

```ash
import <pyash.ash>;

boolean ok = py_run("x = 6\nprint(x * 7)");
if (!ok) print(PY_ERROR, "red");
```

You can also evaluate an expression and inspect the returned `py_value`:

```ash
py_reset();
py_value answer = py_eval("6 * 7");
print(py_repr(answer));
```

## Architecture

```text
Python-like source
      |
      v
line/block executor
      |
      +-- tokenizer
      |
      +-- recursive-descent expression parser
      |
      +-- dynamic py_value record
      |
      v
ASH maps / records / strings / floats
      |
      v
KoLmafia
```

The interpreter uses ASH records for dynamic values and maps for the Python global namespace. String handling relies on standard ASH functions such as `char_at`, `substring`, `length`, and `split_string`.

## Deliberate semantic differences from Python

PyASH is Python-flavored, not Python-compliant:

- all numeric values currently use ASH `float`
- `%` is implemented numerically and does not yet reproduce every Python negative-modulo edge case
- `and`/`or` currently return booleans rather than one of their operands
- chained comparisons are evaluated left-to-right rather than with CPython's special chaining semantics
- no lexical local scopes yet
- `int(string)` and `float(string)` inherit ASH conversion behavior

## Next useful milestones

1. lists and dictionaries
2. indexing and slicing
3. `for ... in range(...)`
4. user functions (`def` / `return`)
5. explicit `kol.*` capability object exposing allowlisted ASH functions
6. test runner with golden output fixtures
7. optional tokenizer/parser split into importable ASH libraries

## Safety boundary

PyASH v0.1 does **not** translate arbitrary Python identifiers into ASH calls and does not invoke `cli_execute()` or `visit_url()`. If KoLmafia integration is added later, expose capabilities explicitly rather than treating every ASH function as automatically callable.

## Why It Exists

It explores a narrow Python-flavored language core inside ASH without exposing arbitrary CLI, URL, or mutation authority.

## Files

- `LICENSE` — packaged source/support material.
- `MANIFEST.md` — packaged source/support material.
- `VALIDATION.md` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `data/` — packaged source/support material.
- `examples/` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `tests/` — packaged source/support material.
- `tools/` — packaged source/support material.

## Status

Prototype.

## Compatibility

KoLmafia ASH; Python 3 is used only for portable validation/examples.

## Provenance

Extracted and packaged as a standalone repository from `pyash-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- portable PyASH static validator

KoLmafia verify/runtime smoke not run.
