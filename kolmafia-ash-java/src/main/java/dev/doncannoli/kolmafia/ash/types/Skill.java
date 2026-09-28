package dev.doncannoli.kolmafia.ash.types;

import dev.doncannoli.kolmafia.ash.AshArgument;
import dev.doncannoli.kolmafia.ash.EnumRef;

public record Skill(EnumRef ref) implements AshArgument {
    public Skill(String name) { this(new EnumRef("Skill", name)); }
    public Skill(long id) { this(new EnumRef("Skill", id)); }
    @Override public Object toJsonValue() { return ref.toJsonValue(); }
}
