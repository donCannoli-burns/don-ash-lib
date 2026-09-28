package dev.kolmafia.ash

import org.json.JSONArray
import org.json.JSONObject

class AshBatch {
    private val properties = JSONArray()
    private val functions = JSONArray()

    fun property(name: String): AshBatch = apply {
        properties.put(name)
    }

    fun call(ashName: String, vararg args: Any?): AshBatch = apply {
        functions.put(
            JSONObject()
                .put("name", ashNameToJs(ashName))
                .put("args", JSONArray(args.map(::jsonValue))),
        )
    }

    internal fun toJson(): String {
        val request = JSONObject()
        if (properties.length() > 0) request.put("properties", properties)
        if (functions.length() > 0) request.put("functions", functions)
        return request.toString()
    }
}

internal fun ashNameToJs(name: String): String {
    val out = StringBuilder(name.length)
    var uppercaseNext = false
    name.forEach { ch ->
        if (ch == '_') {
            uppercaseNext = true
        } else if (uppercaseNext) {
            out.append(ch.uppercaseChar())
            uppercaseNext = false
        } else {
            out.append(ch)
        }
    }
    return out.toString()
}

internal fun jsonValue(value: Any?): Any = when (value) {
    null -> JSONObject.NULL
    is JSONObject, is JSONArray,
    is String, is Boolean,
    is Byte, is Short, is Int, is Long,
    is Float, is Double -> value
    else -> throw IllegalArgumentException(
        "Unsupported ASH JSON argument type: ${value::class.java.name}",
    )
}
