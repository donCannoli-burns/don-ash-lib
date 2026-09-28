package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Slot(EnumRef ref) implements AshArgument {
    public Slot(String name) { this(new EnumRef("Slot", name)); }
    public Slot(long id) { this(new EnumRef("Slot", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
