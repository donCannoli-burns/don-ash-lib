# PyASH v0.1.0 validation

Validation performed for this package:

- ASH-specific function ordering audit: PASS
- no C-style forward declarations: PASS
- no reserved ASH datatype names used as simple local/parameter identifiers: PASS
- no dependency on ternary syntax: PASS
- no plural-string aggregate literal dependency: PASS
- source examples present under `data/pyash/`: PASS
- interpreter contains no `cli_execute`, `visit_url`, `adventure`, item-use, chat, or other game mutation bridge: PASS

Static audit result:

```text
PYASH_STATIC_VALIDATE=PASS
functions=42
lines=805
```

## Important limitation

This environment does not contain a runnable KoLmafia installation, so this build was not passed through KoLmafia's live `verify` command. The implementation was written against current ASH documentation for records/maps, string handling, file loading, operators, and function-definition visibility, then checked with the included ASH-oriented static validator.

Recommended first local check:

```text
verify pyash.ash
call pyash.ash eval 2 + 3 * 4
call pyash.ash run pyash/smoke.py
```

Expected smoke output:

```text
14
PASS
```
