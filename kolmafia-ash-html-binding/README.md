# KoLmafia ASH ↔ HTML / HTML5 binding

A small two-way UI binding for KoLmafia:

```text
HTML or HTML5/JavaScript
        ↓ relay request / form POST
relay_ash_html*.ash
        ↓ named dispatcher
scripts/html5_bind.ash
        ↓
KoLmafia ASH runtime
```

## What is included

- `scripts/html5_bind.ash` — reusable binding helpers and an allowlisted dispatcher.
- `relay/relay_ash_html.ash` — plain HTML/form interface; JavaScript is not required.
- `relay/relay_ash_html5.ash` — HTML5 interface with `fetch()` calls into the same ASH dispatcher.

This is intentionally **not** an arbitrary ASH-eval or raw-CLI bridge. Browser code can invoke only operations explicitly added to `hb_dispatch()`.

## Install

Copy the files into the matching KoLmafia directories:

```text
<KoLmafia root>/
├── scripts/
│   └── html5_bind.ash
└── relay/
    ├── relay_ash_html.ash
    └── relay_ash_html5.ash
```

In gCLI, verify the files:

```text
verify html5_bind.ash
verify relay_ash_html.ash
verify relay_ash_html5.ash
```

Then refresh the relay-browser script menu and launch either:

```text
relay_ash_html.ash
relay_ash_html5.ash
```

## Binding contract

The HTML5 frontend POSTs form fields back to the relay script:

```text
api=1
op=state
value=
```

The ASH side returns JSON text:

```json
{
  "ok": true,
  "player": "example",
  "level": 13,
  "adventures": 42,
  "meat": 12345,
  "hp": 100,
  "maxhp": 100,
  "mp": 80,
  "maxmp": 80,
  "theme": "system"
}
```

Current operations:

| Operation | Mutation | Purpose |
|---|---:|---|
| `ping` | No | Connectivity smoke test |
| `state` | No | Read a small player-state snapshot |
| `get_theme` | No | Read this binding's namespaced UI preference |
| `set_theme` | Local preference only | Set `_ashHtml5_theme` to `system`, `light`, or `dark` |

## Adding a new binding

Add a named branch to `hb_dispatch()` instead of exposing generic `cli_execute()` or arbitrary ASH evaluation.

Example shape:

```ash
if (op == "my_safe_operation") {
    // validate `value`
    // perform one bounded operation
    // return JSON text
}
```

Then call it from HTML5:

```js
const result = await ash("my_safe_operation", "argument");
```

For game-mutating functions, use a dedicated operation, strict argument validation, and an explicit confirmation/CSRF strategy. Avoid a browser-callable "run any CLI command" endpoint.

## Notes

KoLmafia user-interface relay scripts conventionally live in the top-level `relay/` directory and use the `relay_*.ash` naming form. `form_field()` / `form_fields()` receive submitted request values, `write()` emits the relay response, and `entity_encode()` is useful when inserting arbitrary text into HTML.

This starter keeps the browser/API surface intentionally narrow so it can grow into a safer typed binding.

## Why It Exists

It provides a tiny reusable ASH-to-HTML bridge for relay tools instead of repeating ad-hoc rendering glue.

## Files

- `binding-manifest.json` — packaged source/support material.
- `relay/` — packaged source/support material.
- `scripts/` — packaged source/support material.

## Status

Prototype.

## Compatibility

KoLmafia relay/ASH environment.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-ash-html-binding-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT License. See `LICENSE`.

## Packaging Verification

**PASS**

- binding-manifest JSON parse
- relay source/static HTML checks

KoLmafia relay/ASH verify has not been run; runtime verification remains separate from publication readiness.
