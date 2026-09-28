package ash

import "encoding/json"

// EnumRef is the wire representation accepted by KoLmafia's Browser JSON API
// for ASH enumerated values.
type EnumRef struct {
	ObjectType       string `json:"objectType"`
	IdentifierString string `json:"identifierString,omitempty"`
	IdentifierNumber *int64 `json:"identifierNumber,omitempty"`
}

func enumName(objectType, name string) EnumRef {
	return EnumRef{ObjectType: objectType, IdentifierString: name}
}

func enumID(objectType string, id int64) EnumRef {
	return EnumRef{ObjectType: objectType, IdentifierNumber: &id}
}

// Enumerated creates a fallback ASH enumerated reference by string identifier.
func Enumerated(objectType, name string) EnumRef { return enumName(objectType, name) }

// EnumeratedID creates a fallback ASH enumerated reference by numeric identifier.
func EnumeratedID(objectType string, id int64) EnumRef { return enumID(objectType, id) }

// Strongly named wrappers keep call sites readable while preserving the exact
// Browser JSON API placeholder shape.
type Item struct{ EnumRef }
type Familiar struct{ EnumRef }
type Skill struct{ EnumRef }
type Effect struct{ EnumRef }
type Monster struct{ EnumRef }
type Location struct{ EnumRef }
type Slot struct{ EnumRef }
type Stat struct{ EnumRef }
type Path struct{ EnumRef }
type AscensionClass struct{ EnumRef }
type Element struct{ EnumRef }
type Phylum struct{ EnumRef }
type Thrall struct{ EnumRef }
type Servant struct{ EnumRef }
type Coinmaster struct{ EnumRef }

func NewItem(name string) Item                     { return Item{enumName("Item", name)} }
func NewItemID(id int64) Item                      { return Item{enumID("Item", id)} }
func NewFamiliar(name string) Familiar             { return Familiar{enumName("Familiar", name)} }
func NewFamiliarID(id int64) Familiar              { return Familiar{enumID("Familiar", id)} }
func NewSkill(name string) Skill                   { return Skill{enumName("Skill", name)} }
func NewSkillID(id int64) Skill                    { return Skill{enumID("Skill", id)} }
func NewEffect(name string) Effect                 { return Effect{enumName("Effect", name)} }
func NewEffectID(id int64) Effect                  { return Effect{enumID("Effect", id)} }
func NewMonster(name string) Monster               { return Monster{enumName("Monster", name)} }
func NewMonsterID(id int64) Monster                { return Monster{enumID("Monster", id)} }
func NewLocation(name string) Location             { return Location{enumName("Location", name)} }
func NewLocationID(id int64) Location              { return Location{enumID("Location", id)} }
func NewSlot(name string) Slot                     { return Slot{enumName("Slot", name)} }
func NewStat(name string) Stat                     { return Stat{enumName("Stat", name)} }
func NewPath(name string) Path                     { return Path{enumName("Path", name)} }
func NewAscensionClass(name string) AscensionClass { return AscensionClass{enumName("Class", name)} }
func NewElement(name string) Element               { return Element{enumName("Element", name)} }
func NewPhylum(name string) Phylum                 { return Phylum{enumName("Phylum", name)} }
func NewThrall(name string) Thrall                 { return Thrall{enumName("Thrall", name)} }
func NewServant(name string) Servant               { return Servant{enumName("Servant", name)} }
func NewCoinmaster(name string) Coinmaster         { return Coinmaster{enumName("Coinmaster", name)} }

// Value wraps an arbitrary ASH JSON result without forcing callers into map[string]any.
type Value struct{ raw json.RawMessage }

func newValue(raw json.RawMessage) Value {
	copyRaw := append(json.RawMessage(nil), raw...)
	return Value{raw: copyRaw}
}

func (v Value) Raw() json.RawMessage { return append(json.RawMessage(nil), v.raw...) }
func (v Value) Decode(dst any) error { return json.Unmarshal(v.raw, dst) }

func (v Value) String() (string, error) {
	var out string
	err := json.Unmarshal(v.raw, &out)
	return out, err
}

func (v Value) Int64() (int64, error) {
	var out int64
	err := json.Unmarshal(v.raw, &out)
	return out, err
}

func (v Value) Float64() (float64, error) {
	var out float64
	err := json.Unmarshal(v.raw, &out)
	return out, err
}

func (v Value) Bool() (bool, error) {
	var out bool
	err := json.Unmarshal(v.raw, &out)
	return out, err
}
