package dev.doncannoli.kolmafia.ash

import java.net.URI
import java.net.URLEncoder
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.nio.charset.StandardCharsets
import java.time.Duration
import java.util.concurrent.CompletableFuture
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

data class AshClientOptions(
    val baseUrl: String = "http://127.0.0.1:60080",
    val pwdProvider: () -> String,
    val connectTimeout: Duration = Duration.ofSeconds(5),
    val requestTimeout: Duration = Duration.ofSeconds(30),
    val policy: AshCallPolicy = AshCallPolicy.AllowAll,
)

data class AshFunctionCall(val name: String, val args: List<Any?> = emptyList())

data class AshBatchResult(
    val properties: List<JsonValue> = emptyList(),
    val functions: List<JsonValue> = emptyList(),
)

class AshApiException(message: String) : RuntimeException(message)
class AshTransportException(message: String, cause: Throwable? = null) : RuntimeException(message, cause)

class AshClient(private val options: AshClientOptions) {
    private val http = HttpClient.newBuilder()
        .connectTimeout(options.connectTimeout)
        .build()

    fun callBlocking(name: String, vararg args: Any?): JsonValue =
        callManyBlocking(listOf(AshFunctionCall(name, args.toList()))).functions.single()

    suspend fun call(name: String, vararg args: Any?): JsonValue =
        callFuture(name, *args).await()

    fun callFuture(name: String, vararg args: Any?): CompletableFuture<JsonValue> =
        callManyFuture(listOf(AshFunctionCall(name, args.toList())))
            .thenApply { it.functions.single() }

    fun callManyBlocking(
        calls: List<AshFunctionCall>,
        properties: List<String> = emptyList(),
    ): AshBatchResult = try {
        execute(buildRequest(calls, properties), calls).join()
    } catch (e: Exception) {
        val cause = e.cause ?: e
        if (cause is RuntimeException) throw cause
        throw AshTransportException("KoLmafia request failed", cause)
    }

    suspend fun callMany(
        calls: List<AshFunctionCall>,
        properties: List<String> = emptyList(),
    ): AshBatchResult = callManyFuture(calls, properties).await()

    fun callManyFuture(
        calls: List<AshFunctionCall>,
        properties: List<String> = emptyList(),
    ): CompletableFuture<AshBatchResult> = execute(buildRequest(calls, properties), calls)

    fun getPropertyBlocking(name: String): JsonValue =
        callManyBlocking(emptyList(), listOf(name)).properties.single()

    suspend fun getProperty(name: String): JsonValue =
        callMany(emptyList(), listOf(name)).properties.single()

    fun getPropertiesBlocking(vararg names: String): List<JsonValue> =
        callManyBlocking(emptyList(), names.toList()).properties

    fun identityBlocking(value: AshEnum): JsonValue = callBlocking("identity", value)
    suspend fun identity(value: AshEnum): JsonValue = call("identity", value)

    private fun buildRequest(calls: List<AshFunctionCall>, properties: List<String>): JsonValue.Obj {
        calls.forEach { call -> options.policy.check(call.name, call.args) }
        val fields = linkedMapOf<String, JsonValue>()
        if (properties.isNotEmpty()) {
            fields["properties"] = JsonValue.Arr(properties.map { JsonValue.Str(it) })
        }
        if (calls.isNotEmpty()) {
            fields["functions"] = JsonValue.Arr(calls.map { call ->
                JsonValue.Obj(linkedMapOf(
                    "name" to JsonValue.Str(call.name),
                    "args" to JsonValue.Arr(call.args.map(::encodeArgument)),
                ))
            })
        }
        return JsonValue.Obj(fields)
    }

    private fun execute(body: JsonValue.Obj, calls: List<AshFunctionCall>): CompletableFuture<AshBatchResult> {
        val pwd = options.pwdProvider()
        require(pwd.isNotBlank()) { "pwdProvider returned an empty KoLmafia session hash" }

        val form = "pwd=${urlEncode(pwd)}&body=${urlEncode(JsonCodec.stringify(body))}"
        val uri = URI.create(options.baseUrl.trimEnd('/') + "/KoLmafia/jsonApi")
        val request = HttpRequest.newBuilder(uri)
            .timeout(options.requestTimeout)
            .header("Content-Type", "application/x-www-form-urlencoded")
            .POST(HttpRequest.BodyPublishers.ofString(form))
            .build()

        return http.sendAsync(request, HttpResponse.BodyHandlers.ofString())
            .thenApply { response ->
                if (response.statusCode() !in 200..299) {
                    throw AshTransportException("KoLmafia returned HTTP ${response.statusCode()}")
                }
                parseResponse(response.body(), calls)
            }
    }

    private fun parseResponse(text: String, calls: List<AshFunctionCall>): AshBatchResult {
        val root = JsonCodec.parse(text) as? JsonValue.Obj
            ?: throw AshTransportException("KoLmafia JSON response was not an object")
        root["error"]?.stringOrNull()?.let { throw AshApiException(it) }

        val properties = (root["properties"] as? JsonValue.Arr)?.values.orEmpty()
        val functions = (root["functions"] as? JsonValue.Arr)?.values.orEmpty()
        if (calls.isNotEmpty() && functions.size != calls.size) {
            throw AshTransportException("KoLmafia returned ${functions.size} function results for ${calls.size} calls")
        }
        return AshBatchResult(properties, functions)
    }

    private fun urlEncode(value: String): String =
        URLEncoder.encode(value, StandardCharsets.UTF_8)
}

private suspend fun <T> CompletableFuture<T>.await(): T = suspendCoroutine { continuation ->
    whenComplete { value, error ->
        if (error != null) continuation.resumeWithException(error.cause ?: error)
        else continuation.resume(value)
    }
}
