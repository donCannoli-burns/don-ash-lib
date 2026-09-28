package dev.doncannoli.kolmafia.ash

sealed interface AshEnum {
    val objectType: String
    val identifierString: String?
    val identifierNumber: Int?

    fun toJson(): JsonValue.Obj = JsonValue.Obj(buildMap {
        put("objectType", JsonValue.Str(objectType))
        identifierString?.let { put("identifierString", JsonValue.Str(it)) }
        identifierNumber?.let { put("identifierNumber", JsonValue.Num(it.toString())) }
    })
}

abstract class NamedAshEnum(
    final override val objectType: String,
    final override val identifierString: String?,
    final override val identifierNumber: Int?
) : AshEnum {
    init { require(identifierString != null || identifierNumber != null) { "ASH enum needs a string or numeric identifier" } }
    override fun toString(): String = "$objectType(${identifierString ?: identifierNumber})"
}

class Item : NamedAshEnum { constructor(name: String) : super("Item", name, null); constructor(id: Int) : super("Item", null, id) }
class Familiar : NamedAshEnum { constructor(name: String) : super("Familiar", name, null); constructor(id: Int) : super("Familiar", null, id) }
class Skill : NamedAshEnum { constructor(name: String) : super("Skill", name, null); constructor(id: Int) : super("Skill", null, id) }
class Effect : NamedAshEnum { constructor(name: String) : super("Effect", name, null); constructor(id: Int) : super("Effect", null, id) }
class Monster : NamedAshEnum { constructor(name: String) : super("Monster", name, null); constructor(id: Int) : super("Monster", null, id) }
class Location(name: String) : NamedAshEnum("Location", name, null)
class Slot(name: String) : NamedAshEnum("Slot", name, null)
class Stat(name: String) : NamedAshEnum("Stat", name, null)
class Path(name: String) : NamedAshEnum("Path", name, null)
class AscensionClass(name: String) : NamedAshEnum("Class", name, null)
class Element(name: String) : NamedAshEnum("Element", name, null)
class Phylum(name: String) : NamedAshEnum("Phylum", name, null)
class Coinmaster(name: String) : NamedAshEnum("Coinmaster", name, null)
class Bounty(name: String) : NamedAshEnum("Bounty", name, null)
class Thrall(name: String) : NamedAshEnum("Thrall", name, null)
class Servant(name: String) : NamedAshEnum("Servant", name, null)
class Vykea(name: String) : NamedAshEnum("Vykea", name, null)
class Modifier(name: String) : NamedAshEnum("Modifier", name, null)
class AshEnumRef(objectType: String, name: String) : NamedAshEnum(objectType, name, null)

internal fun encodeArgument(value: Any?): JsonValue = when (value) {
    null -> JsonValue.Null
    is JsonValue -> value
    is AshEnum -> value.toJson()
    is String -> JsonValue.Str(value)
    is Char -> JsonValue.Str(value.toString())
    is Boolean -> JsonValue.Bool(value)
    is Byte, is Short, is Int, is Long, is Float, is Double -> JsonValue.Num(value.toString())
    is Enum<*> -> JsonValue.Str(value.name)
    is Iterable<*> -> JsonValue.Arr(value.map(::encodeArgument))
    is Array<*> -> JsonValue.Arr(value.map(::encodeArgument))
    is Map<*, *> -> JsonValue.Obj(value.entries.associate { (k, v) -> k.toString() to encodeArgument(v) })
    else -> error("Unsupported ASH argument type: ${value::class.qualifiedName}")
}
