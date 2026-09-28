package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Modifier(EnumRef ref) implements AshArgument {
    public Modifier(String name) { this(new EnumRef("Modifier", name)); }
    public Modifier(long id) { this(new EnumRef("Modifier", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
