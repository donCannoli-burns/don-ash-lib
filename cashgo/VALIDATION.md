# CashGo v0.1.0 validation

Validation in this package is intentionally split into what can be proven without a live KoLmafia runtime and what should be checked locally with KoLmafia's parser.

## Static checks performed

- balanced braces/parens/quotes heuristic
- no C-style forward declarations
- helper functions defined before first internal call where practical
- manifest render/parse fixture checked by companion host-side test
- dangerous gCLI verbs absent from generated command constructors
- `cli_execute()` appears only behind the generated-command helper
- source/ref validation rejects whitespace-bearing command fragments
- package contents and example manifest present

## Runtime checks to perform in KoLmafia

```text
verify cashgo.ash
call cashgo.ash help
call cashgo.ash init test-project --manifest=cashgo/test/cashgo.toml
call cashgo.ash check --manifest=cashgo/test/cashgo.toml
call cashgo.ash add vprops github:Veracity0/vprops@main --manifest=cashgo/test/cashgo.toml
call cashgo.ash tree --manifest=cashgo/test/cashgo.toml
call cashgo.ash fetch --dry-run --manifest=cashgo/test/cashgo.toml
```

The final command should print generated Git commands without performing network/install actions.

## Live-action status

No KoL turns, item actions, chat, messages, purchases, or live character mutations are part of CashGo's implementation. Git installation is intentionally not exercised by the package's static validation.
