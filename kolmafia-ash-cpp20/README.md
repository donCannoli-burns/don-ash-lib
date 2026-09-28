# kolmafia-ash-cpp

A small C++20 binding for the **KoLmafia ASH runtime**.

The binding uses KoLmafia's local Browser JSON API instead of embedding the JVM or scraping the gCLI. C++ sends structured ASH-runtime calls to the already-running KoLmafia process and receives JSON results.

## What this binds

```text
C++ application
      |
      | HTTP POST, loopback
      v
/KoLmafia/jsonApi
      |
      v
KoLmafia ASH runtime functions
```

It supports:

- dynamic calls to built-in ASH runtime functions;
- batching multiple calls in one request;
- KoLmafia properties;
- ASH enumerated types such as Item, Monster, Skill, Effect, Familiar and Location;
- a few read-only convenience methods;
- generation of additional typed wrappers from a small local spec.

This is intentionally **not** an arbitrary native-code loader for ASH. KoLmafia remains the running authority and C++ is a client of its supported local API.

## Build

Requirements:

- CMake 3.20+
- C++20 compiler
- libcurl development package
- Boost headers containing Boost.JSON

```bash
cmake -S . -B build
cmake --build build -j
ctest --test-dir build --output-on-failure
```

## Basic use

```cpp
#include <kolmafia_ash/client.hpp>

using namespace kolmafia::ash;

Client mafia(ClientOptions{
    .base_url = "http://127.0.0.1:60080",
    .pwd_provider = [] { return obtain_pwd_from_your_existing_runtime(); },
});

std::cout << mafia.my_name() << "\n";
std::cout << mafia.my_meat() << "\n";
std::cout << mafia.available_amount(Item("seal-clubbing club")) << "\n";

// Dynamic access to the complete Browser JSON API function surface:
auto result = mafia.call("numericModifier", args("Item Drop"));
```

Browser-API function names use KoLmafia's JavaScript-style camelCase naming: `my_meat()` -> `myMeat`, `available_amount()` -> `availableAmount`, etc.

## Enumerated ASH values

```cpp
auto item = Item("filthy lucre");
auto skill = Skill(123);
auto monster = Monster("Knob Goblin Embezzler");

auto full = mafia.identity(item);
```

The encoder emits KoLmafia's supported placeholder representation:

```json
{
  "objectType": "Item",
  "identifierString": "filthy lucre"
}
```

## Session hash / `pwd`

KoLmafia's Browser JSON API requires the current session hash. This library deliberately does **not** discover, cache, print, log, or persist it. `ClientOptions::pwd_provider` is called at request time so an existing launcher/control plane can provide the current value.

Do not commit the hash. Do not put it in generated headers. Avoid putting it in shell history. The environment variable in `examples/read_only.cpp` is only a minimal standalone demonstration.

## Mutation policy

This library is a transport binding, not a policy engine. `Client::call()` can address any function accepted by KoLmafia's JSON API, including functions that may mutate game state.

For agent-facing use, put your existing command/function policy **above** this binding and expose only approved wrappers. A good pattern is:

```text
agent/tool request
    -> policy classification
    -> confirmation / approval gate
    -> typed C++ wrapper
    -> kolmafia-ash-cpp
    -> KoLmafia
```

The bundled convenience methods are read-only, but the generic dynamic method is intentionally explicit.

## Generate typed wrappers

Use `ashref` on the actual KoLmafia build to decide which functions/signatures you want to expose, then place the approved subset into a spec such as:

```text
string my_name myName
int64 my_meat myMeat
int64 available_amount availableAmount enum item
bool have_skill haveSkill enum skill
```

Generate a header:

```bash
python3 tools/generate_wrapper.py tools/example.api include/generated_api.hpp
```

This is deliberately allowlist-shaped: generation starts from functions you explicitly choose rather than blindly exporting every mutating runtime function.

## Custom user `.ash` libraries

KoLmafia can import ASH scripts from its JavaScript runtime, but the Browser JSON API itself is aimed at the built-in runtime function surface. For a custom ASH library, use one of these two follow-on adapters:

1. **Generated relay adapter (recommended):** generate a tiny relay-side ASH dispatcher with a fixed allowlist of exported functions and matching C++ wrappers.
2. **JS/ASH module adapter:** use KoLmafia's JS -> ASH interoperability to require a specific ASH module, again behind a fixed exported surface.

Do not implement custom-library support by allowing C++ to submit arbitrary ASH/JS source strings. That turns a typed binding into a remote-code-execution interface and defeats the main benefit of having a constrained bridge.

## Scope of v0.1

Implemented:

- local HTTP transport;
- URL-encoded request body;
- API and HTTP errors;
- batching;
- properties;
- common enumerated references;
- convenience wrappers;
- typed-wrapper generator;
- compile-time smoke test.

Not yet implemented:

- automatic `ashref` parser;
- generated custom-library relay adapters;
- async client;
- Windows-specific credential/provider helpers;
- packaged install/export targets.

## Why It Exists

It exposes structured ASH runtime calls to native C++ programs without embedding the JVM or scraping gCLI output.

## Files

- `CMakeLists.txt` — packaged source/support material.
- `LICENSE` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `examples/` — packaged source/support material.
- `include/` — packaged source/support material.
- `src/` — packaged source/support material.
- `tests/` — packaged source/support material.
- `tools/` — packaged source/support material.

## Status

Prototype.

## Compatibility

CMake 3.20+, a C++20 compiler, libcurl, and a running KoLmafia relay for live calls.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-ash-cpp20-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- CMake configure/build
- ctest smoke

No live KoLmafia call was used.
