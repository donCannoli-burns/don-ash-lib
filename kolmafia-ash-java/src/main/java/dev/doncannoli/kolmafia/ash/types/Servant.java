package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Servant(EnumRef ref) implements AshArgument {
    public Servant(String name) { this(new EnumRef("Servant", name)); }
    public Servant(long id) { this(new EnumRef("Servant", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
