package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Location(EnumRef ref) implements AshArgument {
    public Location(String name) { this(new EnumRef("Location", name)); }
    public Location(long id) { this(new EnumRef("Location", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
