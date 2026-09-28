package dev.kolmafia.ash

import org.json.JSONObject

object KoLValue {
    fun enum(objectType: String, identifier: String): JSONObject =
        JSONObject()
            .put("objectType", objectType)
            .put("identifierString", identifier)

    fun enum(objectType: String, identifier: Long): JSONObject =
        JSONObject()
            .put("objectType", objectType)
            .put("identifierNumber", identifier)

    fun item(name: String) = enum("Item", name)
    fun item(id: Long) = enum("Item", id)
    fun skill(name: String) = enum("Skill", name)
    fun skill(id: Long) = enum("Skill", id)
    fun effect(name: String) = enum("Effect", name)
    fun effect(id: Long) = enum("Effect", id)
    fun familiar(name: String) = enum("Familiar", name)
    fun familiar(id: Long) = enum("Familiar", id)
    fun location(name: String) = enum("Location", name)
    fun location(id: Long) = enum("Location", id)
    fun monster(name: String) = enum("Monster", name)
    fun monster(id: Long) = enum("Monster", id)
    fun path(name: String) = enum("Path", name)
    fun path(id: Long) = enum("Path", id)
    fun characterClass(name: String) = enum("Class", name)
    fun stat(name: String) = enum("Stat", name)
    fun slot(name: String) = enum("Slot", name)
    fun coinmaster(name: String) = enum("Coinmaster", name)
    fun thrall(name: String) = enum("Thrall", name)
}
