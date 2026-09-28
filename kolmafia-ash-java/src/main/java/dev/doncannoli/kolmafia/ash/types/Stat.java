package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Stat(EnumRef ref) implements AshArgument {
    public Stat(String name) { this(new EnumRef("Stat", name)); }
    public Stat(long id) { this(new EnumRef("Stat", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
