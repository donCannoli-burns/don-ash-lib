package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Item(EnumRef ref) implements AshArgument {
    public Item(String name) { this(new EnumRef("Item", name)); }
    public Item(long id) { this(new EnumRef("Item", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
