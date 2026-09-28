package dev.doncannoli.kolmafia.ash;

import java.net.URI;
import java.net.http.HttpClient;
import java.time.Duration;
import java.util.Objects;

public record AshClientOptions(
        URI baseUri,
        PasswordProvider passwordProvider,
        AshPolicy policy,
        HttpClient httpClient,
        Duration timeout) {

    public AshClientOptions {
        baseUri = baseUri == null ? URI.create("http://127.0.0.1:60080") : baseUri;
        Objects.requireNonNull(passwordProvider, "passwordProvider");
        policy = policy == null ? AshPolicy.allowAll() : policy;
        httpClient = httpClient == null ? HttpClient.newHttpClient() : httpClient;
        timeout = timeout == null ? Duration.ofSeconds(15) : timeout;
    }

    public static AshClientOptions defaults(PasswordProvider provider) {
        return new AshClientOptions(null, provider, null, null, null);
    }
}
