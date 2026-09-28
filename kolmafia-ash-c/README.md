# KoLmafia ASH C Binding

A small C11 binding for KoLmafia's ASH runtime through KoLmafia's native browser JSON API.

Instead of embedding ASH or scraping gCLI output, the library sends form-encoded POST requests to:

```text
/KoLmafia/jsonApi
```

That endpoint accepts property reads and ASH-runtime function calls. ASH names are automatically converted from `snake_case` to the JSON API's JavaScript-style `lowerCamelCase` names.

## Features

- C11 API.
- `libcurl` transport.
- `json-c` JSON representation/parsing.
- Loopback-only endpoints by default.
- Generic calls to any ASH runtime function exposed by KoLmafia.
- Automatic `available_amount` → `availableAmount` name conversion.
- KoL enum placeholders such as Item, Skill, Effect, Familiar, Location, Monster, Path, Class, Stat, and Slot.
- Batched property/function requests.
- Raw JSON escape hatch for newly added ASH APIs (JSON `null` is returned as a NULL `json_object *` with a successful status).
- Typed bool/int64/double/string call helpers.
- Explicit wrappers for potentially-mutating `set_property`, `cli_execute`, and `visit_url`.
- Unit tests and a fake KoLmafia HTTP integration test.

## Dependencies

Debian/Ubuntu example:

```bash
sudo apt install build-essential cmake pkg-config libcurl4-openssl-dev libjson-c-dev
```

## Build

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
```

Or:

```bash
make
```

## Test

The test suite does **not** touch a real KoL account. Its integration test runs a local fake `/KoLmafia/jsonApi` server.

```bash
make test
```

## Basic usage

```c
#include "kolmafia_ash.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    const char *pwd = getenv("KOLMAFIA_PWD");
    km_ash_client *mafia = km_ash_client_new(NULL, pwd);
    if (!mafia) return 1;

    char *name = NULL;
    int64_t level = 0;

    if (km_ash_my_name(mafia, &name) != 0 ||
        km_ash_my_level(mafia, &level) != 0) {
        fprintf(stderr, "%s\n", km_ash_last_error(mafia));
        km_ash_client_free(mafia);
        return 1;
    }

    printf("%s is level %" PRId64 "\n", name, level);
    km_ash_free(name);
    km_ash_client_free(mafia);
}
```

Run it against a local KoLmafia relay server:

```bash
export KOLMAFIA_PWD='your-current-pwd-hash'
./build/kolmafia_ash_example
```

The default base URL is:

```text
http://127.0.0.1:60080
```

## Generic ASH calls

You can call an ASH function by its normal ASH name:

```c
struct json_object *args = json_object_new_array();
json_object_array_add(args, json_object_new_string("lastAdventure"));

char *value = NULL;
if (km_ash_call_string(mafia, "get_property", args, &value) == 0) {
    printf("%s\n", value);
    km_ash_free(value);
}
json_object_put(args);
```

The binding translates:

```text
get_property      -> getProperty
available_amount  -> availableAmount
my_adventures     -> myAdventures
```

## KoL enum values

The JSON API accepts enum placeholders. The binding supplies constructors:

```c
struct json_object *item = km_ash_item("seal-clubbing club");
struct json_object *skill = km_ash_skill("Saucegeyser");
struct json_object *loc = km_ash_location("Noob Cave");
```

For example:

```c
int64_t amount = 0;
struct json_object *item = km_ash_item("seal-clubbing club");

if (km_ash_available_amount(mafia, item, &amount) == 0) {
    printf("amount = %" PRId64 "\n", amount);
}

json_object_put(item);
```

Numeric item identifiers are supported too:

```c
struct json_object *item = km_ash_item_id(1234);
```

Generic enum constructors are available when you need another KoLmafia enumerated type:

```c
struct json_object *coinmaster =
    km_ash_enum_string("Coinmaster", "The Hermit");
```

## Batching

KoLmafia's endpoint can read multiple properties and execute multiple functions in one HTTP request:

```c
struct json_object *request = km_ash_request_new();
km_ash_request_add_property(request, "kingLiberated");
km_ash_request_add_call(request, "my_name", NULL);
km_ash_request_add_call(request, "my_adventures", NULL);

struct json_object *response = NULL;
if (km_ash_request_execute(mafia, request, &response) == 0) {
    puts(json_object_to_json_string_ext(response, JSON_C_TO_STRING_PRETTY));
    json_object_put(response);
}
json_object_put(request);
```

Response ordering follows request ordering.

## Raw return values

For ASH functions without a typed wrapper, use:

```c
struct json_object *result = NULL;
if (km_ash_call_json(mafia, "some_new_function", args, &result) == 0) {
    /* inspect result with json-c */
    json_object_put(result);
}
```

This keeps the binding usable when KoLmafia adds new runtime functions.

## Potentially-mutating functions

These are deliberately explicit:

```c
bool ok = false;
km_ash_cli_execute(mafia, "refresh all", &ok);
km_ash_set_property(mafia, "someProperty", "value");

char *page = NULL;
km_ash_visit_url(mafia, "inventory.php", &page);
km_ash_free(page);
```

`visit_url` is classified here as potentially mutating because the URL supplied by the caller can target an action endpoint. If you put this library behind an agent or automation system, perform policy/confirmation checks above these calls rather than assuming every ASH function is read-only.

## Memory ownership

- `km_ash_client_new*()` → release with `km_ash_client_free()`.
- `km_ash_name_to_js()` and returned C strings → release with `km_ash_free()`.
- `struct json_object *` returned by constructors/calls → release with `json_object_put()`.
- `km_ash_request_add_call()` takes its own reference to the argument array; the caller remains responsible for its own reference.

## Why JSON API instead of invoking `ash` through gCLI?

KoLmafia already has a structured JSON-facing bridge to its scripting runtime. That means C gets typed JSON values, enum representations, batching, and explicit error responses rather than having to parse console text.

This is a binding to the **runtime-library surface**, not a C implementation of the ASH language parser/interpreter. User-defined `.ash` module function importing would require an additional shim or a different integration layer.

## Current KoLmafia references

- Browser JSON API: https://wiki.kolmafia.us/index.php?title=Browser_JSON_API
- JavaScript/ASH runtime mapping: https://wiki.kolmafia.us/index.php/JavaScript_Support
- ASH function inventory: https://wiki.kolmafia.us/index.php/Ash_Functions

For the exact runtime available in your installed KoLmafia build, `ashref` remains the authoritative local inventory.

## Why It Exists

It offers a low-level native ABI for structured ASH calls and batches without Java embedding.

## Files

- `CMakeLists.txt` — packaged source/support material.
- `LICENSE` — packaged source/support material.
- `Makefile` — packaged source/support material.
- `TEST_STATUS.md` — packaged source/support material.
- `examples/` — packaged source/support material.
- `include/` — packaged source/support material.
- `scripts/` — packaged source/support material.
- `src/` — packaged source/support material.
- `tests/` — packaged source/support material.

## Status

Prototype.

## Compatibility

C11 compiler, CMake, libcurl, json-c; live calls require a running KoLmafia relay.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-c-ash-binding.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PARTIAL**

- CMake build
- unit ctest

The fake-server integration harness did not establish its loopback test service during this packaging session, so integration PASS is not claimed.
