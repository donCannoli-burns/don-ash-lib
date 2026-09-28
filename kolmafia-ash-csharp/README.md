# KoLmafia.AshBinding

A small **C#/.NET 8 binding for KoLmafia's ASH runtime**.

Instead of scraping gCLI output or starting a second interpreter, this library talks to KoLmafia's native Browser JSON API at:

```text
http://127.0.0.1:60080/KoLmafia/jsonApi
```

That API exposes KoLmafia properties and ASH runtime-library functions. ASH names such as `available_amount` are automatically translated to the camelCase form expected by the API (`availableAmount`).

## Why this boundary

KoLmafia's Browser JSON API accepts requests shaped like:

```json
{
  "properties": ["kingLiberated"],
  "functions": [
    {
      "name": "availableAmount",
      "args": [
        {
          "objectType": "Item",
          "identifierString": "seal-clubbing club"
        }
      ]
    }
  ]
}
```

and POSTs them as `application/x-www-form-urlencoded` fields named `pwd` and `body`.

Official reference:

- https://wiki.kolmafia.us/index.php?title=Browser_JSON_API
- https://wiki.kolmafia.us/index.php/Ash_Functions
- `ashref` in your own KoLmafia build remains the authoritative list of functions actually available to that build.

## Features

- Generic access to the ASH runtime: `CallAsync<T>("my_level")`
- Accepts native ASH snake_case names and converts them automatically
- Typed placeholders for KoL enum types (`Item`, `Skill`, `Effect`, `Location`, etc.)
- Supports returned enum/proxy fields through `KoLValue`
- Batched property + function requests in one HTTP round trip
- Raw `JsonElement` escape hatch for functions with complex return types
- A starter typed convenience layer for common ASH functions
- Loopback-only transport by default
- No third-party NuGet dependencies
- Mocked self-test with no live KoL actions

## Quick start

Reference the project:

```xml
<ProjectReference Include="../KoLmafia.AshBinding/KoLmafia.AshBinding.csproj" />
```

Then:

```csharp
using KoLmafia.AshBinding;

using var mafia = new AshClient(
    pwd: Environment.GetEnvironmentVariable("KOLMAFIA_PWD")!,
    baseUri: new Uri("http://127.0.0.1:60080/"));

Console.WriteLine(await mafia.MyNameAsync());
Console.WriteLine(await mafia.MyLevelAsync());

var item = KoL.Item("seal-clubbing club");
var count = await mafia.AvailableAmountAsync(item);
Console.WriteLine(count);
```

Any ASH runtime function is reachable without waiting for a hand-written wrapper:

```csharp
bool interact = await mafia.CallAsync<bool>("can_interact");
long meat = await mafia.CallAsync<long>("my_meat");
string? pref = await mafia.CallAsync<string>("get_property", "lastAdventure");
```

Complex enum arguments use placeholders:

```csharp
var item = KoL.Item("seal-clubbing club");
var effect = KoL.Effect("Leash of Linguini");
var location = KoL.Location("Noob Cave");

int amount = await mafia.CallAsync<int>("available_amount", item);
int turns = await mafia.CallAsync<int>("have_effect", effect);
```

You can ask KoLmafia for the full identity/proxy object:

```csharp
KoLValue? fullItem = await mafia.IdentityAsync(KoL.Item("seal-clubbing club"));
```

## Batching

```csharp
var batch = new AshBatch()
    .Property("kingLiberated")
    .Call("my_name")
    .Call("my_level")
    .Call("available_amount", KoL.Item("seal-clubbing club"));

var result = await mafia.ExecuteBatchAsync(batch);

bool liberated = result.Property<bool>(0);
string? name = result.Function<string>(0);
int level = result.Function<int>(1);
int clubs = result.Function<int>(2);
```

## Mutating functions

This is a **binding**, not a policy engine. Calls such as these can mutate live game/client state:

```csharp
await mafia.SetPropertyAsync("somePreference", "value");
await mafia.CliExecuteAsync("...");
await mafia.VisitUrlAsync("...");
```

If this is used behind an LLM or agent, place your confirmation/allowlist/policy layer *above* `AshClient`; do not expose generic `CallAsync`, `CliExecuteAsync`, or arbitrary `VisitUrlAsync` directly to an untrusted agent.

## Session `pwd`

The JSON endpoint requires the current KoLmafia password hash (`pwd`). Treat it as session-sensitive data:

- do not commit it;
- do not print it;
- do not put it in test fixtures;
- inject it at runtime (for example with `KOLMAFIA_PWD`).

The included client never logs the hash.

## Run the example

```bash
export KOLMAFIA_PWD='your-current-session-hash'
dotnet run --project examples/SmokeTest/SmokeTest.csproj
```

Optional:

```bash
export KOLMAFIA_URL='http://127.0.0.1:60080/'
```

## Run the offline self-test

```bash
dotnet run --project tests/KoLmafia.AshBinding.Tests/KoLmafia.AshBinding.Tests.csproj
```

The self-test uses a fake HTTP handler; it does not connect to KoLmafia or perform game actions.

## Extending the typed layer

The generic call is the stable center:

```csharp
await mafia.CallAsync<TReturn>("ash_function_name", arg1, arg2);
```

Thin typed wrappers can therefore be added mechanically from `ashref` output. A future generator can consume an `ashref` snapshot for a specific KoLmafia revision and generate strongly typed methods while leaving `CallAsync` available for newly added functions.

## Why It Exists

It gives .NET callers a typed, policy-aware wrapper over the local ASH runtime API with no third-party NuGet runtime dependency.

## Files

- `.gitignore` — packaged source/support material.
- `LICENSE` — packaged source/support material.
- `examples/` — packaged source/support material.
- `src/` — packaged source/support material.
- `tests/` — packaged source/support material.

## Status

Experimental.

## Compatibility

.NET SDK required for compilation/tests; live calls require a running KoLmafia relay.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-csharp-ash-binding.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**UNVERIFIED**

- C# project XML/source consistency

No .NET SDK/compiler is installed here; compilation/tests are not claimed.
