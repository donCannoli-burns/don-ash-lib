package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record AscensionClass(EnumRef ref) implements AshArgument {
    public AscensionClass(String name) { this(new EnumRef("AscensionClass", name)); }
    public AscensionClass(long id) { this(new EnumRef("AscensionClass", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
