import dev.doncannoli.kolmafia.ash.*;
import dev.doncannoli.kolmafia.ash.types.Item;

public class ReadOnlyExample {
    public static void main(String[] args) {
        // Supply the active KoLmafia pwd hash at runtime; do not hard-code it.
        AshClient mafia = new AshClient(AshClientOptions.defaults(() -> System.getenv("KOLMAFIA_PWD")));
        System.out.println("name=" + mafia.myName());
        System.out.println("meat=" + mafia.myMeat());
        System.out.println("filthy lucre=" + mafia.availableAmount(new Item("filthy lucre")));
    }
}
