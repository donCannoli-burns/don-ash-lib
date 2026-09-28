package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Effect(EnumRef ref) implements AshArgument {
    public Effect(String name) { this(new EnumRef("Effect", name)); }
    public Effect(long id) { this(new EnumRef("Effect", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
