# kolmafia-ash-go

Idiomatic Go binding for KoLmafia's ASH runtime through KoLmafia's local Browser JSON API.

## Design

```text
Go application / agent
        ↓
optional CallPolicy
        ↓
ash.Client
        ↓
POST /KoLmafia/jsonApi
        ↓
KoLmafia
        ↓
ASH runtime
```

The library does **not** embed KoLmafia, scrape gCLI output, or store a `pwd` hash. A `PasswordProvider` callback supplies the current session hash at call time.

## Requirements

- Go 1.20+
- running local KoLmafia relay/browser server (normally `127.0.0.1:60080`)
- current KoLmafia `pwd`/session hash supplied by the host application

The runtime library uses only the Go standard library.

## Basic usage

```go
package main

import (
    "context"
    "fmt"

    ash "github.com/doncannoli-burns/kolmafia-ash-go/ash"
)

func main() {
    mafia, err := ash.NewClient(ash.Options{
        PasswordProvider: func(context.Context) (string, error) {
            return obtainCurrentPwd(), nil
        },
    })
    if err != nil { panic(err) }

    ctx := context.Background()

    name, _ := mafia.MyName(ctx)
    meat, _ := mafia.MyMeat(ctx)
    clubs, _ := mafia.AvailableAmount(ctx, ash.NewItem("seal-clubbing club"))

    fmt.Println(name, meat, clubs)
}
```

## Generic ASH calls

```go
value, err := mafia.Call(ctx, "numericModifier", "Item Drop")
if err != nil { ... }
modifier, err := value.Float64()
```

Or decode directly:

```go
var result SomeStruct
err := mafia.CallInto(ctx, &result, "identity", ash.NewItem("filthy lucre"))
```

## ASH enumerated values

```go
ash.NewItem("filthy lucre")
ash.NewItemID(1)
ash.NewMonster("Knob Goblin Embezzler")
ash.NewSkill("Lunging Thrust-Smack")
ash.NewEffect("Ode to Booze")
ash.NewLocation("Noob Cave")
ash.NewFamiliar("Mosquito")
ash.NewSlot("hat")
ash.NewStat("Muscle")
ash.NewPath("Actually Ed the Undying")
```

A string-backed item serializes as:

```json
{"objectType":"Item","identifierString":"filthy lucre"}
```

For uncommon/new KoL types, use the generic fallback:

```go
ash.Enumerated("SomeType", "some value")
ash.EnumeratedID("SomeType", 123)
```

## Batching

```go
result, err := mafia.Batch(ctx, ash.BatchRequest{
    Properties: []string{"kingLiberated"},
    Functions: []ash.FunctionCall{
        {Name: "myName", Args: []any{}},
        {Name: "myMeat", Args: []any{}},
        {Name: "availableAmount", Args: []any{ash.NewItem("filthy lucre")}},
    },
})
```

`result.Properties` and `result.Functions` preserve request order.

## Structural policy hook

The transport itself does not decide which ASH functions an application should trust, but it can enforce a host-supplied policy before any request is sent.

```go
mafia, _ := ash.NewClient(ash.Options{
    PasswordProvider: provider,
    Policy: ash.Deny("cliExecute", "visitUrl"),
})
```

For a strict agent surface:

```go
Policy: ash.AllowOnly(
    "myName",
    "myMeat",
    "myAdventures",
    "availableAmount",
)
```

This is intended as a low-level enforcement hook; applications should define policy appropriate to their own authority model.

## Generate wrappers from `ashref`

Capture the output of KoLmafia's `ashref` command, then run:

```bash
go run ./cmd/ashrefgen \
  -in ashref.txt \
  -out ash/generated_ash.go \
  -package ash
```

For example:

```text
string my_name( )
int available_amount( item )
boolean have_skill( skill )
float numeric_modifier( string )
```

produces typed Go methods using the Browser JSON API's camelCase names.

The generator deliberately skips overload collisions and signatures containing complex/aggregate types it cannot represent safely. This is preferable to silently generating the wrong ABI. The generic `Client.Call` API remains available for those cases.

## Tests

```bash
go test ./...
go vet ./...
```

The transport test uses an `httptest` fake `/KoLmafia/jsonApi` server. It checks form encoding, `pwd` encoding, request JSON, `Item` placeholders, response decoding, batching, and policy rejection without touching a live KoL character.

## Scope

This package binds the **built-in ASH runtime exposed by KoLmafia's Browser JSON API**. It does not yet directly expose arbitrary top-level functions declared in a third-party `.ash` library as Go methods. A future library-binding layer can generate a small adapter around those functions while preserving a statically defined surface.

## Why It Exists

It gives Go programs a small typed/runtime-call boundary for ASH without requiring a Java embedding layer.

## Files

- `CHANGELOG.md` — packaged source/support material.
- `LICENSE` — packaged source/support material.
- `VERSION` — packaged source/support material.
- `ash/` — packaged source/support material.
- `ashref.sample.txt` — packaged source/support material.
- `cmd/` — packaged source/support material.
- `examples/` — packaged source/support material.
- `go.mod` — packaged source/support material.

## Status

Prototype.

## Compatibility

Go toolchain; live calls require a running KoLmafia relay and active pwd hash.

## Provenance

Extracted and packaged as a standalone repository from `kolmafia-ash-go-v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT license file supplied in the source archive.

## Packaging Verification

**PASS**

- go test ./...

No live KoLmafia call was used.
