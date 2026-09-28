package dev.doncannoli.kolmafia.ash;

import java.util.List;
import java.util.Objects;

public record AshFunctionCall(String name, List<Object> args) {
    public AshFunctionCall {
        Objects.requireNonNull(name, "name");
        args = List.copyOf(args);
    }

    public AshFunctionCall(String name, Object... args) {
        this(name, List.of(args));
    }
}
