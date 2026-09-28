package dev.doncannoli.kolmafia.ash

fun interface AshCallPolicy {
    fun check(functionName: String, arguments: List<Any?>)

    companion object {
        val AllowAll = AshCallPolicy { _, _ -> }

        fun deny(vararg names: String): AshCallPolicy {
            val blocked = names.toSet()
            return AshCallPolicy { name, _ ->
                require(name !in blocked) { "ASH call '$name' denied by policy" }
            }
        }
    }
}
