package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Familiar(EnumRef ref) implements AshArgument {
    public Familiar(String name) { this(new EnumRef("Familiar", name)); }
    public Familiar(long id) { this(new EnumRef("Familiar", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
