package dev.doncannoli.kolmafia.ash;

import java.util.List;

public record AshBatchRequest(List<String> properties, List<AshFunctionCall> functions) {
    public AshBatchRequest {
        properties = properties == null ? List.of() : List.copyOf(properties);
        functions = functions == null ? List.of() : List.copyOf(functions);
    }

    public static AshBatchRequest functions(AshFunctionCall... calls) {
        return new AshBatchRequest(List.of(), List.of(calls));
    }
}
