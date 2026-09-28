package dev.doncannoli.kolmafia.ash;

import java.util.List;

public record AshBatchResult(List<Object> properties, List<Object> functions) {
    public AshBatchResult {
        properties = properties == null ? List.of() : List.copyOf(properties);
        functions = functions == null ? List.of() : List.copyOf(functions);
    }
}
