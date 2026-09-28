package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Phylum(EnumRef ref) implements AshArgument {
    public Phylum(String name) { this(new EnumRef("Phylum", name)); }
    public Phylum(long id) { this(new EnumRef("Phylum", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
