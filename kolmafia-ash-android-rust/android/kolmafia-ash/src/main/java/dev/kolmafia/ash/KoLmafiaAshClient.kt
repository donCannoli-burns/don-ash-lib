package dev.kolmafia.ash

import java.io.Closeable
import org.json.JSONArray
import org.json.JSONObject
import org.json.JSONTokener

class KoLmafiaAshClient private constructor(
    private var handle: Long,
) : Closeable {

    companion object {
        /**
         * Safe default for a physical Android device when using:
         *   adb reverse tcp:60080 tcp:60080
         */
        fun loopback(pwd: String): KoLmafiaAshClient =
            connect("http://127.0.0.1:60080", pwd, allowNonLoopback = false)

        fun connect(
            baseUrl: String,
            pwd: String,
            allowNonLoopback: Boolean = false,
        ): KoLmafiaAshClient {
            val handle = NativeBridge.nativeCreate(baseUrl, pwd, allowNonLoopback)
            check(handle != 0L) { "native KoLmafia ASH client creation failed" }
            return KoLmafiaAshClient(handle)
        }
    }

    @Synchronized
    override fun close() {
        if (handle != 0L) {
            NativeBridge.nativeDestroy(handle)
            handle = 0L
        }
    }

    @Synchronized
    fun call(ashName: String, vararg args: Any?): Any? {
        checkOpen()
        val argsJson = JSONArray(args.map(::jsonValue)).toString()
        val raw = NativeBridge.nativeCallJson(handle, ashName, argsJson)
        return parseJsonValue(raw)
    }

    @Synchronized
    fun execute(batch: AshBatch): JSONObject {
        checkOpen()
        val raw = NativeBridge.nativeExecuteJson(handle, batch.toJson())
        return JSONObject(raw)
    }

    fun myName(): String = call("my_name") as String
    fun myLevel(): Long = (call("my_level") as Number).toLong()
    fun myAdventures(): Long = (call("my_adventures") as Number).toLong()
    fun myMeat(): Long = (call("my_meat") as Number).toLong()
    fun availableAmount(item: JSONObject): Long =
        (call("available_amount", item) as Number).toLong()
    fun getProperty(name: String): String = call("get_property", name) as String

    // Explicit mutation/effect boundary.
    fun setProperty(name: String, value: String): Any? =
        call("set_property", name, value)

    fun cliExecute(command: String): Boolean =
        call("cli_execute", command) as Boolean

    fun visitUrl(url: String): String =
        call("visit_url", url) as String

    private fun checkOpen() {
        check(handle != 0L) { "KoLmafiaAshClient is closed" }
    }

    private fun parseJsonValue(raw: String): Any? {
        val value = JSONTokener(raw).nextValue()
        return if (value === JSONObject.NULL) null else value
    }
}
