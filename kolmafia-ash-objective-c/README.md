# KoLmafia Objective-C ASH Binding

A small ARC Objective-C binding for KoLmafia's ASH runtime surface through the native **Browser JSON API** (`/KoLmafia/jsonApi`).

It is intentionally not an embedded ASH interpreter. It lets Objective-C programs invoke KoLmafia runtime/ASH functions, read properties, batch calls, and pass KoL enumerated values using Foundation objects.

## Requirements

- macOS with the Foundation framework
- Clang / Xcode Command Line Tols
- ARC (the Makefile enables `-fobjc-arc`)
- a running KoLmafia relay server (default `http://127.0.0.1:60080`)
- the current KoLmafia `pwd` hash

There are no third-party runtime dependencies.

## Build

```bash
make
```

That builds:

```text
build/kmash-smoke
```

Run source checks with:

```bash
make source-check
```

## Quick start

```objc
#import <Foundation/Foundation.h>
#import "KMAsh.h"

NSError *error = nil;
KMAshClient *mafia = [[KMAshClient alloc]
    initWithPasswordHash:NSProcessInfo.processInfo.environment[@!"KOLMAFIA_PWD"]];

NSString *name = [mafia myName:&error];
NSNumber *level = [mafia myLevel:&error];
NSNumber *meat = [mafia myMeat:&error];

NSLog(@"%@ — level %@ — %@ Meat", name, level, meat);
```

The default endpoint is loopback-only:

```text
http://127.0.0.1:60080/KoLmafia/jsonApi
```

A non-loopback `baseURL` is rejected unless `allowsRemoteEndpoint:YES` is explicitly supplied to the designated initializer.

## ASH-style function names

KoLmafia's Browser JSON API expects JavaScript/camelCase function names. The binding lets Objective-C callers use familiar ASH snake_case names:

```objc
id result = [mafia call:@"available_amount"
              arguments:@[KMAshItem(@"seal-clubbing club")]
                  error:&error];
```

Internally:

```text
available_amount -> availableAmount
my_adventures    -> myAdventures
get_property     -> getProperty
```

Already-camelCase names are left alone.

## KoL datatypes

The Browser JSON API accepts enumerated values as typed placeholders. Helpers are included for common ASH types:

```objc
NSDictionary *item     = KMAshItem(@"seal-clubbing club");
NSDictionary *skill    = KMAshSkill(@"Saucegeyser");
NSDictionary *effect   = KMAshEffect(@"Leash of Linguini");
NSDictionary *familiar = KMAshFamiliar(@"Mosquito");
NSDictionary *location = KMAshLocation(@"Noob Cave");
NSDictionary *monster  = KMAshMonster(@"spooky vampire");
NSDictionary *path     = KMAshPath(@"Standard");
NSDictionary *klass    = KMAshClass(@"Seal Clubber");
NSDictionary *stat     = KMAshStat(@"Muscle");
NSDictionary *slot     = KMAshSlot(@"hat");
```

Numeric identifiers are also supported:

```objc
NSDictionary *item = KMAshItemID(1234);
```

For less-common enum types:

```objc
NSDictionary *value = KMAshEnum(@"Thrall", @"Penne Dreadful");
```

Returned KoL enum objects are left as `NSDictionary` values so new proxy fields do not require a new version of this binding.

Use `identity:` to expand a placeholder:

```objc
NSDictionary *details = [mafia identity:KMAshItem(@"seal-clubbing club")
                                      error:&error];
```

## Typed convenience calls

```objc
NSString *name       = [mafia myName:&error];
NSNumber *level      = [mafia myLevel:&error];
NSNumber *adventures = [mafia myAdventures:&error];
NSNumber *meat       = [mafia myMeat:&error];

NSNumber *amount = [mafia availableAmountOf:KMAshItem(@"seal-clubbing club")
                                       error:&error];

NSString *lastAdventure = [mafia getProperty:@"lastAdventure" error:&error];
```

The generic call API is the forward-compatible escape hatch:

```objc
id result = [mafia call:@"some_future_ash_function"
              arguments:@[/* Foundation JSON values */]
                  error:&error];
```

## Properties

The native JSON API can read KoLmafia properties without routing through `get_property()`:

```objc
id value = [mafia property:@"kingLiberated" error:&error];
```

For string semantics matching ASH `get_property()`:

```objc
NSString *value = [mafia getProperty:@"kingLiberated" error:&error];
```

## Batching

Multiple properties and functions can be evaluated in one round trip:

```objc
KMAshBatch *batch = [[KMAshBatch alloc] init];
[batch addProperty:@"kingLiberated"];
[batch addProperty:@"lastAdventure"];
[batch addCall:@"my_name" arguments:nil];
[batch addCall:@"available_amount"
     arguments:@[KMAshItem(@"seal-clubbing club")]];

NSDictionary *response = [mafia executeBatch:batch error:&error];
```

The result arrays retain request ordering.

## Explicit effectful surfaces

Potentially mutating operations are intentionally visible in the API:

```objc
[mafia setProperty:@"examplePreference" value:@"value" error:&error];
[mafia cliExecute:@"some command" error:&error];
NSString *page = [mafia visitURL:@"inventory.php" error:&error];
```

`cli_execute`, `visit_url`, and preference writes should not be treated as read-only merely because they travel through the same JSON endpoint. If this client is placed behind an agent, put policy/confirmation checks above these methods (and above generic `call:` for untrusted function names).

## Error handling

Transport, HTTP, malformed response, KoLmafia API errors, and simple typed-wrapper mismatches are returned through `NSError` in `KMAshErrorDomain`.

```objc
NSError *error = nil;
id value = [mafia call:@"my_name" arguments:nil error:&error];
if (!value) {
    NSLog(@"%@", error);
}
```

Note that a successful ASH `void`/JSON `null` result is represented by `NSNull`, not Objective-C `nil`, so transport/API failure remains distinguishable.

## Live smoke test

With KoLmafia running:

```bash
export KOLMAFIA_PWD='<your active pwd hash>'
./build/kmash-smoke
```

The example performs read-only calls only.

## Scope

This binds Objective-C to KoLmafia's **runtime function surface**. It does not yet provide a protocol for invoking arbitrary user-defined functions exported from an imported `.ash` script. A logical next layer is a tiny ASH bridge script that exposes named module/function dispatch while keeping the Objective-C transport unchanged.

## Why It Exists

It exposes the same local ASH runtime surface to Objective-C while preserving typed values and explicit effectful calls.

## Files

- `Makefile` — packaged source/support material.
- `TEST_STATUS.md` — packaged source/support material.
- `examples/` — packaged source/support material.
- `include/` — packaged source/support material.
- `src/` — packaged source/support material.
- `tests/` — packaged source/support material.

## Status

Experimental.

## Compatibility

macOS Foundation framework and Clang/Xcode command-line tools for compilation; source checks are portable Python.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-objective-c-ash-binding.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT License. See `LICENSE`.

## Packaging Verification

**PARTIAL**

- portable Objective-C source checks

Foundation toolchain is unavailable on this Linux host; native compile is not claimed.
