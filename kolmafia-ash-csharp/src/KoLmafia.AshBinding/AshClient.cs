using System.Net;
using System.Text.Json;

namespace KoLmafia.AshBinding;

/// <summary>
/// C# client for KoLmafia's ASH runtime exposed by /KoLmafia/jsonApi.
/// </summary>
public sealed class AshClient : IDisposable
{
    private readonly HttpClient _http;
    private readonly bool _ownsHttp;
    private readonly string _pwd;
    private readonly Uri _endpoint;
    private readonly JsonSerializerOptions _json;

    public AshClient(
        string pwd,
        Uri? baseUri = null,
        HttpClient? httpClient = null,
        bool allowNonLoopback = false)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(pwd);

        baseUri ??= new Uri("http://127.0.0.1:60080/");
        if (!baseUri.IsAbsoluteUri)
            throw new ArgumentException("baseUri must be absolute.", nameof(baseUri));

        if (!allowNonLoopback && !IsLoopback(baseUri))
        {
            throw new ArgumentException(
                "Refusing a non-loopback KoLmafia endpoint by default. " +
                "Pass allowNonLoopback: true only if you intentionally secured that transport.",
                nameof(baseUri));
        }

        _pwd = pwd;
        _endpoint = new Uri(baseUri, "/KoLmafia/jsonApi");
        _http = httpClient ?? new HttpClient();
        _ownsHttp = httpClient is null;
        _json = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            PropertyNameCaseInsensitive = true
        };
    }

    /// <summary>
    /// Invoke any ASH runtime-library function. Snake_case ASH names are
    /// automatically translated to the camelCase names required by jsonApi.
    /// </summary>
    public async Task<T?> CallAsync<T>(
        string ashFunctionName,
        params object?[] args)
    {
        var batch = new AshBatch().Call(ashFunctionName, args);
        var result = await ExecuteBatchAsync(batch).ConfigureAwait(false);
        return result.Function<T>(0);
    }

    public async Task<JsonElement> CallRawAsync(
        string ashFunctionName,
        params object?[] args)
    {
        var batch = new AshBatch().Call(ashFunctionName, args);
        var result = await ExecuteBatchAsync(batch).ConfigureAwait(false);
        return result.Functions[0];
    }

    /// <summary>
    /// Read a KoLmafia preference through the Browser JSON API's property surface.
    /// This is distinct from calling get_property(), which always exposes ASH's
    /// function semantics.
    /// </summary>
    public async Task<T?> ReadPropertyAsync<T>(string propertyName)
    {
        var batch = new AshBatch().Property(propertyName);
        var result = await ExecuteBatchAsync(batch).ConfigureAwait(false);
        return result.Property<T>(0);
    }

    public async Task<AshBatchResult> ExecuteBatchAsync(
        AshBatch batch,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(batch);

        var request = new AshApiRequest
        {
            Properties = batch.Properties.Count == 0 ? null : batch.Properties,
            Functions = batch.Functions.Count == 0 ? null : batch.Functions
        };

        var bodyJson = JsonSerializer.Serialize(request, _json);
        using var form = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["pwd"] = _pwd,
            ["body"] = bodyJson
        });

        HttpResponseMessage response;
        try
        {
            response = await _http.PostAsync(_endpoint, form, cancellationToken).ConfigureAwait(false);
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        {
            throw new AshApiException($"Could not reach KoLmafia at {_endpoint}.", ex);
        }

        using (response)
        {
            var text = await response.Content.ReadAsStringAsync(cancellationToken).ConfigureAwait(false);
            if (!response.IsSuccessStatusCode)
            {
                throw new AshApiException(
                    $"KoLmafia jsonApi returned HTTP {(int)response.StatusCode} {response.ReasonPhrase}. " +
                    $"Response: {Truncate(text, 500)}");
            }

            AshApiResponse? api;
            try
            {
                api = JsonSerializer.Deserialize<AshApiResponse>(text, _json);
            }
            catch (JsonException ex)
            {
                throw new AshApiException(
                    $"KoLmafia returned invalid JSON: {Truncate(text, 500)}", ex);
            }

            if (api is null)
                throw new AshApiException("KoLmafia returned an empty JSON response.");

            if (!string.IsNullOrEmpty(api.Error))
                throw new AshApiException(api.Error);

            var properties = CloneAll(api.Properties);
            var functions = CloneAll(api.Functions);

            if (properties.Length != batch.Properties.Count)
            {
                throw new AshApiException(
                    $"Property result count mismatch: requested {batch.Properties.Count}, got {properties.Length}.");
            }

            if (functions.Length != batch.Functions.Count)
            {
                throw new AshApiException(
                    $"Function result count mismatch: requested {batch.Functions.Count}, got {functions.Length}.");
            }

            return new AshBatchResult(properties, functions, _json);
        }
    }

    // Small typed convenience layer. The generic CallAsync remains the full escape hatch.
    public Task<string?> MyNameAsync() => CallAsync<string>("my_name");
    public Task<int> MyLevelAsync() => CallAsync<int>("my_level")!;
    public Task<int> MyAdventuresAsync() => CallAsync<int>("my_adventures")!;
    public Task<long> MyMeatAsync() => CallAsync<long>("my_meat")!;
    public Task<int> AvailableAmountAsync(KoLValue item) => CallAsync<int>("available_amount", item)!;
    public Task<int> ItemAmountAsync(KoLValue item) => CallAsync<int>("item_amount", item)!;
    public Task<int> HaveEffectAsync(KoLValue effect) => CallAsync<int>("have_effect", effect)!;
    public Task<string?> GetPropertyAsync(string name) => CallAsync<string>("get_property", name);
    public Task<bool> SetPropertyAsync(string name, string value) => CallAsync<bool>("set_property", name, value)!;
    public Task<string?> VisitUrlAsync(string url) => CallAsync<string>("visit_url", url);
    public Task<bool> CliExecuteAsync(string command) => CallAsync<bool>("cli_execute", command)!;

    public async Task<KoLValue?> IdentityAsync(KoLValue value)
    {
        var raw = await CallRawAsync("identity", value).ConfigureAwait(false);
        return raw.Deserialize<KoLValue>(_json);
    }

    public void Dispose()
    {
        if (_ownsHttp)
            _http.Dispose();
    }

    private static JsonElement[] CloneAll(JsonElement[]? source) =>
        source is null ? [] : source.Select(static value => value.Clone()).ToArray();

    private static bool IsLoopback(Uri uri)
    {
        if (uri.IsLoopback)
            return true;

        return IPAddress.TryParse(uri.Host, out var ip) && IPAddress.IsLoopback(ip);
    }

    private static string Truncate(string text, int max) =>
        text.Length <= max ? text : text[..max] + "…";
}
