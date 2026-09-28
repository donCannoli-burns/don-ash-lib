package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Element(EnumRef ref) implements AshArgument {
    public Element(String name) { this(new EnumRef("Element", name)); }
    public Element(long id) { this(new EnumRef("Element", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
