package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Thrall(EnumRef ref) implements AshArgument {
    public Thrall(String name) { this(new EnumRef("Thrall", name)); }
    public Thrall(long id) { this(new EnumRef("Thrall", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
