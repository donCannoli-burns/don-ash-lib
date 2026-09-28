package dev.doncannoli.kolmafia.ash;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import dev.doncannoli.kolmafia.ash.types.Item;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.URI;
import java.net.URLDecoder;
import java.net.http.HttpClient;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public final class SmokeTest {
    public static void main(String[] args) throws Exception {
        AtomicInteger hits = new AtomicInteger();
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/KoLmafia/jsonApi", ex -> handle(ex, hits));
        server.start();
        try {
            int port=server.getAddress().getPort();
            AshClient client = new AshClient(new AshClientOptions(
                URI.create("http://127.0.0.1:"+port),
                () -> "pw+d&=?",
                AshPolicy.deny("visitUrl"),
                HttpClient.newHttpClient(),
                null));

            var result = client.batch(new AshBatchRequest(
                List.of("kingLiberated"),
                List.of(
                    new AshFunctionCall("myName"),
                    new AshFunctionCall("availableAmount", new Item("filthy lucre"))
                )));
            check(result.properties().equals(List.of(true)), "property result");
            check(result.functions().equals(List.of("donCannoli", 7L)), "function result/order");
            check(hits.get()==1, "single transport");

            boolean denied=false;
            try { client.call("visitUrl", "main.php"); } catch (AshException e) { denied=true; }
            check(denied, "policy rejection");
            check(hits.get()==1, "policy before network");

            Object normalized = new Item(123).toJsonValue();
            check(normalized instanceof Map<?,?> m && Long.valueOf(123).equals(m.get("identifierNumber")), "numeric enum");
            System.out.println("JAVA_ASH_BINDING_SMOKE=PASS");
        } finally { server.stop(0); }
    }

    private static void handle(HttpExchange ex, AtomicInteger hits) throws IOException {
        hits.incrementAndGet();
        check(ex.getRequestURI().getPath().equals("/KoLmafia/jsonApi"), "path");
        check("application/x-www-form-urlencoded".equals(ex.getRequestHeaders().getFirst("Content-Type")), "content type");
        String raw=new String(ex.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
        Map<String,String> form=parseForm(raw);
        check("pw+d&=?".equals(form.get("pwd")), "pwd form decoding");
        Object body=Json.parse(form.get("body"));
        check(body instanceof Map<?,?>, "request object");
        Map<?,?> request=(Map<?,?>)body;
        check(request.get("properties").equals(List.of("kingLiberated")), "properties");
        List<?> funcs=(List<?>)request.get("functions");
        check(funcs.size()==2, "function count");
        Map<?,?> second=(Map<?,?>)funcs.get(1);
        check("availableAmount".equals(second.get("name")), "camelCase function");
        Map<?,?> item=(Map<?,?>)((List<?>)second.get("args")).get(0);
        check("Item".equals(item.get("objectType")), "item type");
        check("filthy lucre".equals(item.get("identifierString")), "item name");

        byte[] response="{\"properties\":[true],\"functions\":[\"donCannoli\",7]}".getBytes(StandardCharsets.UTF_8);
        ex.getResponseHeaders().set("Content-Type","application/json");
        ex.sendResponseHeaders(200,response.length);
        ex.getResponseBody().write(response);
        ex.close();
    }

    private static Map<String,String> parseForm(String raw) {
        java.util.LinkedHashMap<String,String> out=new java.util.LinkedHashMap<>();
        for(String part:raw.split("&")) {
            int p=part.indexOf('=');
            String k=p<0?part:part.substring(0,p), v=p<0?"":part.substring(p+1);
            out.put(URLDecoder.decode(k,StandardCharsets.UTF_8), URLDecoder.decode(v,StandardCharsets.UTF_8));
        }
        return out;
    }

    private static void check(boolean ok, String what) { if(!ok) throw new AssertionError(what); }
}
