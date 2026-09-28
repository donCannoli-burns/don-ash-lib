package dev.doncannoli.kolmafia.ash

sealed interface JsonValue {
    data class Obj(val values: Map<String, JsonValue>) : JsonValue {
        operator fun get(key: String): JsonValue? = values[key]
    }
    data class Arr(val values: List<JsonValue>) : JsonValue
    data class Str(val value: String) : JsonValue
    data class Num(val raw: String) : JsonValue {
        fun asLong(): Long = raw.toLong()
        fun asDouble(): Double = raw.toDouble()
    }
    data class Bool(val value: Boolean) : JsonValue
    data object Null : JsonValue
}

internal object JsonCodec {
    fun stringify(value: JsonValue): String = when (value) {
        is JsonValue.Obj -> value.values.entries.joinToString(prefix = "{", postfix = "}") {
            "\"${escape(it.key)}\":" + stringify(it.value)
        }
        is JsonValue.Arr -> value.values.joinToString(prefix = "[", postfix = "]") { stringify(it) }
        is JsonValue.Str -> "\"${escape(value.value)}\""
        is JsonValue.Num -> value.raw
        is JsonValue.Bool -> value.value.toString()
        JsonValue.Null -> "null"
    }

    fun parse(text: String): JsonValue = Parser(text).parse()

    private fun escape(s: String): String = buildString(s.length + 8) {
        for (c in s) when (c) {
            '\\' -> append("\\\\")
            '"' -> append("\\\"")
            '\b' -> append("\\b")
            '\u000C' -> append("\\f")
            '\n' -> append("\\n")
            '\r' -> append("\\r")
            '\t' -> append("\\t")
            else -> if (c.code < 0x20) append("\\u%04x".format(c.code)) else append(c)
        }
    }

    private class Parser(private val text: String) {
        private var i = 0

        fun parse(): JsonValue {
            skipWhitespace()
            val value = parseValue()
            skipWhitespace()
            require(i == text.length) { "Unexpected trailing JSON at offset $i" }
            return value
        }

        private fun parseValue(): JsonValue {
            skipWhitespace()
            require(i < text.length) { "Unexpected end of JSON" }
            return when (text[i]) {
                '{' -> parseObject()
                '[' -> parseArray()
                '"' -> JsonValue.Str(parseString())
                't' -> { expect("true"); JsonValue.Bool(true) }
                'f' -> { expect("false"); JsonValue.Bool(false) }
                'n' -> { expect("null"); JsonValue.Null }
                else -> parseNumber()
            }
        }

        private fun parseObject(): JsonValue.Obj {
            expectChar('{')
            skipWhitespace()
            val out = linkedMapOf<String, JsonValue>()
            if (peek('}')) { i++; return JsonValue.Obj(out) }
            while (true) {
                skipWhitespace()
                require(peek('"')) { "Expected object key at offset $i" }
                val key = parseString()
                skipWhitespace(); expectChar(':')
                out[key] = parseValue()
                skipWhitespace()
                when {
                    peek(',') -> i++
                    peek('}') -> { i++; return JsonValue.Obj(out) }
                    else -> error("Expected ',' or '}' at offset $i")
                }
            }
        }

        private fun parseArray(): JsonValue.Arr {
            expectChar('[')
            skipWhitespace()
            val out = mutableListOf<JsonValue>()
            if (peek(']')) { i++; return JsonValue.Arr(out) }
            while (true) {
                out += parseValue()
                skipWhitespace()
                when {
                    peek(',') -> i++
                    peek(']') -> { i++; return JsonValue.Arr(out) }
                    else -> error("Expected ',' or ']' at offset $i")
                }
            }
        }

        private fun parseString(): String {
            expectChar('"')
            val out = StringBuilder()
            while (i < text.length) {
                val c = text[i++]
                if (c == '"') return out.toString()
                if (c != '\\') { out.append(c); continue }
                require(i < text.length) { "Incomplete JSON escape" }
                when (val e = text[i++]) {
                    '"', '\\', '/' -> out.append(e)
                    'b' -> out.append('\b')
                    'f' -> out.append('\u000C')
                    'n' -> out.append('\n')
                    'r' -> out.append('\r')
                    't' -> out.append('\t')
                    'u' -> {
                        require(i + 4 <= text.length) { "Incomplete unicode escape" }
                        out.append(text.substring(i, i + 4).toInt(16).toChar())
                        i += 4
                    }
                    else -> error("Invalid JSON escape \\$e")
                }
            }
            error("Unterminated JSON string")
        }

        private fun parseNumber(): JsonValue.Num {
            val start = i
            if (peek('-')) i++
            while (i < text.length && text[i].isDigit()) i++
            if (peek('.')) { i++; while (i < text.length && text[i].isDigit()) i++ }
            if (i < text.length && (text[i] == 'e' || text[i] == 'E')) {
                i++
                if (i < text.length && (text[i] == '+' || text[i] == '-')) i++
                while (i < text.length && text[i].isDigit()) i++
            }
            require(i > start) { "Expected JSON value at offset $start" }
            return JsonValue.Num(text.substring(start, i))
        }

        private fun skipWhitespace() { while (i < text.length && text[i].isWhitespace()) i++ }
        private fun peek(c: Char): Boolean = i < text.length && text[i] == c
        private fun expect(s: String) { require(text.startsWith(s, i)) { "Expected '$s' at offset $i" }; i += s.length }
        private fun expectChar(c: Char) { require(peek(c)) { "Expected '$c' at offset $i" }; i++ }
    }
}

fun JsonValue.stringOrNull(): String? = (this as? JsonValue.Str)?.value
fun JsonValue.longOrNull(): Long? = (this as? JsonValue.Num)?.raw?.toLongOrNull()
fun JsonValue.doubleOrNull(): Double? = (this as? JsonValue.Num)?.raw?.toDoubleOrNull()
fun JsonValue.booleanOrNull(): Boolean? = (this as? JsonValue.Bool)?.value
