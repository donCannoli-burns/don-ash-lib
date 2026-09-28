using System.Text.Json;
using System.Text.Json.Serialization;

namespace KoLmafia.AshBinding;

public sealed record AshFunctionCall
{
    [JsonPropertyName("name")]
    public required string Name { get; init; }

    [JsonPropertyName("args")]
    public required IReadOnlyList<object?> Args { get; init; }
}

internal sealed record AshApiRequest
{
    [JsonPropertyName("properties")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public IReadOnlyList<string>? Properties { get; init; }

    [JsonPropertyName("functions")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public IReadOnlyList<AshFunctionCall>? Functions { get; init; }
}

internal sealed record AshApiResponse
{
    [JsonPropertyName("error")]
    public string? Error { get; init; }

    [JsonPropertyName("properties")]
    public JsonElement[]? Properties { get; init; }

    [JsonPropertyName("functions")]
    public JsonElement[]? Functions { get; init; }
}

public sealed class AshBatch
{
    internal List<string> Properties { get; } = [];
    internal List<AshFunctionCall> Functions { get; } = [];

    public AshBatch Property(string name)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(name);
        Properties.Add(name);
        return this;
    }

    public AshBatch Call(string ashFunctionName, params object?[] args)
    {
        Functions.Add(new AshFunctionCall
        {
            Name = AshNaming.ToJavaScriptName(ashFunctionName),
            Args = args
        });
        return this;
    }
}

public sealed class AshBatchResult
{
    private readonly JsonSerializerOptions _json;

    internal AshBatchResult(JsonElement[] properties, JsonElement[] functions, JsonSerializerOptions json)
    {
        Properties = properties;
        Functions = functions;
        _json = json;
    }

    public IReadOnlyList<JsonElement> Properties { get; }
    public IReadOnlyList<JsonElement> Functions { get; }

    public T? Property<T>(int index) => Properties[index].Deserialize<T>(_json);
    public T? Function<T>(int index) => Functions[index].Deserialize<T>(_json);
}
