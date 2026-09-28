package dev.doncannoli.kolmafia.ash

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class SmokeTest {
    @Test
    fun enumEncodingUsesBrowserApiPlaceholderShape() {
        val encoded = Item("filthy lucre").toJson()
        assertEquals("Item", encoded.values["objectType"]?.stringOrNull())
        assertEquals("filthy lucre", encoded.values["identifierString"]?.stringOrNull())
    }

    @Test
    fun jsonRoundTrip() {
        val source = JsonValue.Obj(mapOf(
            "ok" to JsonValue.Bool(true),
            "n" to JsonValue.Num("42"),
            "text" to JsonValue.Str("hello\\nworld"),
        ))
        assertEquals(source, JsonCodec.parse(JsonCodec.stringify(source)))
    }

    @Test
    fun policyCanDenySpecificRuntimeCalls() {
        val policy = AshCallPolicy.deny("cliExecute")
        assertFailsWith<IllegalArgumentException> { policy.check("cliExecute", listOf("anything")) }
    }
}
