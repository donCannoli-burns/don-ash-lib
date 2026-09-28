package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Coinmaster(EnumRef ref) implements AshArgument {
    public Coinmaster(String name) { this(new EnumRef("Coinmaster", name)); }
    public Coinmaster(long id) { this(new EnumRef("Coinmaster", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
