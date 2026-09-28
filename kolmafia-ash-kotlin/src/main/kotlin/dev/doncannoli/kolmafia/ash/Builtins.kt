package dev.doncannoli.kolmafia.ash

fun AshClient.myNameBlocking(): String =
    callBlocking("myName").stringOrNull() ?: error("myName returned non-string")

suspend fun AshClient.myName(): String =
    call("myName").stringOrNull() ?: error("myName returned non-string")

fun AshClient.myMeatBlocking(): Long =
    callBlocking("myMeat").longOrNull() ?: error("myMeat returned non-integer")

suspend fun AshClient.myMeat(): Long =
    call("myMeat").longOrNull() ?: error("myMeat returned non-integer")

fun AshClient.myAdventuresBlocking(): Long =
    callBlocking("myAdventures").longOrNull() ?: error("myAdventures returned non-integer")

suspend fun AshClient.myAdventures(): Long =
    call("myAdventures").longOrNull() ?: error("myAdventures returned non-integer")

fun AshClient.availableAmountBlocking(item: Item): Long =
    callBlocking("availableAmount", item).longOrNull() ?: error("availableAmount returned non-integer")

suspend fun AshClient.availableAmount(item: Item): Long =
    call("availableAmount", item).longOrNull() ?: error("availableAmount returned non-integer")

fun AshClient.haveSkillBlocking(skill: Skill): Boolean =
    callBlocking("haveSkill", skill).booleanOrNull() ?: error("haveSkill returned non-boolean")

suspend fun AshClient.haveSkill(skill: Skill): Boolean =
    call("haveSkill", skill).booleanOrNull() ?: error("haveSkill returned non-boolean")

fun AshClient.numericModifierBlocking(name: String): Double =
    callBlocking("numericModifier", name).doubleOrNull() ?: error("numericModifier returned non-number")

suspend fun AshClient.numericModifier(name: String): Double =
    call("numericModifier", name).doubleOrNull() ?: error("numericModifier returned non-number")
