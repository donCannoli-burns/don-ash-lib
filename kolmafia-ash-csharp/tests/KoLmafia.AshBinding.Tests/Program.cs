using System.Net;
using System.Text.Json;
using KoLmafia.AshBinding;

static void Assert(bool condition, string message)
{
    if (!condition) throw new Exception("ASSERT FAILED: " + message);
}

Assert(AshNaming.ToJavaScriptName("available_amount") == "availableAmount", "snake_case -> camelCase");
Assert(AshNaming.ToJavaScriptName("my_name") == "myName", "my_name -> myName");
Assert(AshNaming.ToJavaScriptName("alreadyCamel") == "alreadyCamel", "camelCase pass-through");

var handler = new FakeHandler(async request =>
{
    Assert(request.RequestUri?.AbsolutePath == "/KoLmafia/jsonApi", "endpoint path");
    Assert(request.Method == HttpMethod.Post, "POST");
    Assert(request.Content?.Headers.ContentType?.MediaType == "application/x-www-form-urlencoded", "form content type");

    var form = await request.Content!.ReadAsStringAsync();
    var decoded = ParseForm(form);
    Assert(decoded["pwd"] == "test-pwd", "pwd forwarded");

    using var body = JsonDocument.Parse(decoded["body"]);
    var fn = body.RootElement.GetProperty("functions")[0];
    Assert(fn.GetProperty("name").GetString() == "availableAmount", "function normalized");
    var arg = fn.GetProperty("args")[0];
    Assert(arg.GetProperty("objectType").GetString() == "Item", "enum objectType");
    Assert(arg.GetProperty("identifierString").GetString() == "seal-clubbing club", "enum identifier");

    return new HttpResponseMessage(HttpStatusCode.OK)
    {
        Content = new StringContent("{\"functions\":[3]}")
    };
});

using var http = new HttpClient(handler);
using var client = new AshClient("test-pwd", httpClient: http);
var amount = await client.AvailableAmountAsync(KoL.Item("seal-clubbing club"));
Assert(amount == 3, "typed int return");

var errorHandler = new FakeHandler(_ => Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK)
{
    Content = new StringContent("{\"error\":\"nope\"}")
}));

using var errorHttp = new HttpClient(errorHandler);
using var errorClient = new AshClient("test-pwd", httpClient: errorHttp);
var threw = false;
try
{
    await errorClient.CallAsync<int>("my_level");
}
catch (AshApiException ex)
{
    threw = ex.Message == "nope";
}
Assert(threw, "API error propagated");

Console.WriteLine("KoLmafia.AshBinding self-test: PASS");

static Dictionary<string, string> ParseForm(string form)
{
    return form.Split('&', StringSplitOptions.RemoveEmptyEntries)
        .Select(part => part.Split('=', 2))
        .ToDictionary(
            pair => Uri.UnescapeDataString(pair[0].Replace('+', ' ')),
            pair => Uri.UnescapeDataString(pair[1].Replace('+', ' ')));
}

sealed class FakeHandler(Func<HttpRequestMessage, Task<HttpResponseMessage>> responder) : HttpMessageHandler
{
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        => responder(request);
}
