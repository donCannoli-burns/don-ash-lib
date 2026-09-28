# Adding Tools

PyASH Seed MCP uses a deliberately tiny tool ABI so the registry, MCP schema, and PyASH execution environment stay aligned.

## 1. Add one registry row

Edit:

```text
data/pyash-mcp/tools.tsv
```

Each non-comment line has exactly five tab-separated columns:

```text
name    title    description    script    args
```

Example:

```text
square	Square	Square a number.	pyash-mcp/tools/square.py	x:number:required
```

Tool names must use only MCP-safe ASCII letters, digits, `_`, `-`, and `.`.

The script path must remain under:

```text
pyash-mcp/tools/
```

and end in `.py`.

## 2. Declare scalar arguments

The final registry column is either `-` for no arguments or a comma-separated list.

```text
name:type:required
name:type:optional
name:type:optional:default
```

Supported types:

- `string`
- `number`
- `integer`
- `boolean`

Examples:

```text
message:string:required
x:number:required,y:number:required
enabled:boolean:optional:true
count:integer:optional:3
```

The MCP adapter derives a JSON Schema from this declaration and rejects undeclared arguments before KoLmafia sees them.

## 3. Write the PyASH tool

A tool receives its arguments as pre-populated PyASH globals.

It must assign one final global:

```python
result = ...
```

Example:

```python
result = x * x
```

Control flow works within the PyASH v0.1 language:

```python
if enabled:
    result = "yes"
else:
    result = "no"
```

## 4. Result types

The dispatcher currently accepts these PyASH result kinds:

- string
- number
- bool
- None

For current MCP `2026-07-28`, the adapter returns the scalar both as text content and as scalar `structuredContent`.

For legacy MCP, it returns text content only for compatibility.

## 5. Validate

Run:

```bash
make check
```

Then reinstall the KoLmafia-side files and run:

```text
verify pyash.ash
verify relay/relay_pyash_mcp.ash
```

## Future capability extension

If PyASH gains lists/dicts later, extend the ABI deliberately:

1. add a new declared argument/result kind;
2. add schema handling to the adapter;
3. add exact conversion logic to the ASH dispatcher;
4. add tests;
5. only then expose it in the registry.

Do not silently convert arbitrary JSON into executable ASH expressions.
