package dev.doncannoli.kolmafia.ash;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionException;

public final class AshClient {
    private final AshClientOptions options;

    public AshClient(AshClientOptions options) {
        this.options = options;
    }

    public AshValue call(String functionName, Object... args) {
        try { return callAsync(functionName, args).join(); }
        catch (CompletionException e) { throw unwrap(e); }
    }

    public CompletableFuture<AshValue> callAsync(String functionName, Object... args) {
        List<Object> arguments = List.of(args);
        options.policy().check(functionName, arguments);
        return batchAsync(AshBatchRequest.functions(new AshFunctionCall(functionName, arguments)))
                .thenApply(result -> {
                    if (result.functions().size() != 1) throw new AshException("KoLmafia returned unexpected function result count");
                    return new AshValue(result.functions().get(0));
                });
    }

    public AshBatchResult batch(AshBatchRequest request) {
        try { return batchAsync(request).join(); }
        catch (CompletionException e) { throw unwrap(e); }
    }

    public CompletableFuture<AshBatchResult> batchAsync(AshBatchRequest request) {
        for (AshFunctionCall call : request.functions()) options.policy().check(call.name(), call.args());

        String pwd;
        try { pwd = options.passwordProvider().get(); }
        catch (Exception e) { return CompletableFuture.failedFuture(new AshException("password provider failed", e)); }

        Map<String,Object> body = new LinkedHashMap<>();
        if (!request.properties().isEmpty()) body.put("properties", request.properties());
        if (!request.functions().isEmpty()) {
            List<Object> calls = new ArrayList<>();
            for (AshFunctionCall call : request.functions()) {
                Map<String,Object> c = new LinkedHashMap<>();
                c.put("name", call.name());
                c.put("args", call.args().stream().map(Json::normalize).toList());
                calls.add(c);
            }
            body.put("functions", calls);
        }

        String form = "pwd=" + enc(pwd) + "&body=" + enc(Json.stringify(body));
        URI endpoint = options.baseUri().resolve("/KoLmafia/jsonApi");
        HttpRequest httpRequest = HttpRequest.newBuilder(endpoint)
                .timeout(options.timeout())
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(form))
                .build();

        return options.httpClient().sendAsync(httpRequest, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8))
                .thenApply(response -> decodeResponse(response.statusCode(), response.body()));
    }

    private AshBatchResult decodeResponse(int status, String body) {
        if (status < 200 || status >= 300) throw new AshException("KoLmafia HTTP " + status + ": " + body);
        Object parsed = Json.parse(body);
        if (!(parsed instanceof Map<?,?> map)) throw new AshException("KoLmafia returned non-object JSON");
        Object error = map.get("error");
        if (error instanceof String s && !s.isBlank()) throw new AshException("KoLmafia: " + s);
        return new AshBatchResult(asList(map.get("properties")), asList(map.get("functions")));
    }

    @SuppressWarnings("unchecked")
    private static List<Object> asList(Object value) {
        if (value == null) return List.of();
        if (value instanceof List<?> list) return (List<Object>) list;
        throw new AshException("KoLmafia returned an invalid batch field");
    }

    private static String enc(String s) { return URLEncoder.encode(s, StandardCharsets.UTF_8); }
    private static AshException unwrap(CompletionException e) {
        if (e.getCause() instanceof AshException ae) return ae;
        return new AshException("ASH request failed", e.getCause() == null ? e : e.getCause());
    }

    // Common read-only conveniences. The generator can create many more from ashref.
    public String myName() { return call("myName").stringValue(); }
    public long myMeat() { return call("myMeat").longValue(); }
    public long myAdventures() { return call("myAdventures").longValue(); }
    public long availableAmount(dev.doncannoli.kolmafia.ash.types.Item item) { return call("availableAmount", item).longValue(); }
    public boolean haveSkill(dev.doncannoli.kolmafia.ash.types.Skill skill) { return call("haveSkill", skill).booleanValue(); }
}
