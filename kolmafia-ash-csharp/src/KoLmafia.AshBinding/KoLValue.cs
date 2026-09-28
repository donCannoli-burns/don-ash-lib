using System.Text.Json;
using System.Text.Json.Serialization;

namespace KoLmafia.AshBinding;

/// <summary>
/// Placeholder/full-object representation for a KoLmafia enumerated ASH value.
/// The Browser JSON API accepts objectType + identifierString/identifierNumber.
/// Returned enum objects can contain additional proxy fields, preserved in Fields.
/// </summary>
public sealed record KoLValue
{
    [JsonPropertyName("objectType")]
    public required string ObjectType { get; init; }

    [JsonPropertyName("identifierString")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? IdentifierString { get; init; }

    [JsonPropertyName("identifierNumber")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public long? IdentifierNumber { get; init; }

    [JsonExtensionData]
    public Dictionary<string, JsonElement>? Fields { get; init; }

    public static KoLValue ByName(string objectType, string identifier) => new()
    {
        ObjectType = objectType,
        IdentifierString = identifier
    };

    public static KoLValue ById(string objectType, long identifier) => new()
    {
        ObjectType = objectType,
        IdentifierNumber = identifier
    };
}

/// <summary>Convenience constructors mirroring common ASH enumerated datatypes.</summary>
public static class KoL
{
    public static KoLValue Item(string name) => KoLValue.ByName("Item", name);
    public static KoLValue Item(long id) => KoLValue.ById("Item", id);
    public static KoLValue Familiar(string name) => KoLValue.ByName("Familiar", name);
    public static KoLValue Familiar(long id) => KoLValue.ById("Familiar", id);
    public static KoLValue Skill(string name) => KoLValue.ByName("Skill", name);
    public static KoLValue Skill(long id) => KoLValue.ById("Skill", id);
    public static KoLValue Effect(string name) => KoLValue.ByName("Effect", name);
    public static KoLValue Effect(long id) => KoLValue.ById("Effect", id);
    public static KoLValue Location(string name) => KoLValue.ByName("Location", name);
    public static KoLValue Location(long id) => KoLValue.ById("Location", id);
    public static KoLValue Monster(string name) => KoLValue.ByName("Monster", name);
    public static KoLValue Monster(long id) => KoLValue.ById("Monster", id);
    public static KoLValue Class(string name) => KoLValue.ByName("Class", name);
    public static KoLValue Path(string name) => KoLValue.ByName("Path", name);
    public static KoLValue Slot(string name) => KoLValue.ByName("Slot", name);
    public static KoLValue Stat(string name) => KoLValue.ByName("Stat", name);
    public static KoLValue Element(string name) => KoLValue.ByName("Element", name);
    public static KoLValue Modifier(string name) => KoLValue.ByName("Modifier", name);
    public static KoLValue Coinmaster(string name) => KoLValue.ByName("Coinmaster", name);
    public static KoLValue Phylum(string name) => KoLValue.ByName("Phylum", name);
}
