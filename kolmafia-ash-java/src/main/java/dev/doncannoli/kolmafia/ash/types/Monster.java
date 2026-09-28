package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Monster(EnumRef ref) implements AshArgument {
    public Monster(String name) { this(new EnumRef("Monster", name)); }
    public Monster(long id) { this(new EnumRef("Monster", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
