import dev.doncannoli.kolmafia.ash.*

fun main() {
    val client = AshClient(
        AshClientOptions(
            pwdProvider = {
                System.getenv("KOLMAFIA_PWD")
                    ?: error("Set KOLMAFIA_PWD for this example; do not commit it")
            }
        )
    )

    println("name = ${client.myNameBlocking()}")
    println("meat = ${client.myMeatBlocking()}")
    println("adventures = ${client.myAdventuresBlocking()}")
    println("seal-clubbing clubs = ${client.availableAmountBlocking(Item("seal-clubbing club"))}")
}
