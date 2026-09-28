package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Path(EnumRef ref) implements AshArgument {
    public Path(String name) { this(new EnumRef("Path", name)); }
    public Path(long id) { this(new EnumRef("Path", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
