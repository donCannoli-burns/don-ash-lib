package dev.doncannoli.kolmafia.ash;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;

/** Placeholder for a KoLmafia enumerated ASH value. */
public record EnumRef(String objectType, String identifierString, Long identifierNumber) implements AshArgument {
    public EnumRef {
        Objects.requireNonNull(objectType, "objectType");
        if ((identifierString == null) == (identifierNumber == null)) {
            throw new IllegalArgumentException("exactly one identifier must be supplied");
        }
    }

    public EnumRef(String objectType, String identifierString) {
        this(objectType, Objects.requireNonNull(identifierString, "identifierString"), null);
    }

    public EnumRef(String objectType, long identifierNumber) {
        this(objectType, null, identifierNumber);
    }

    @Override
    public Object toJsonValue() {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("objectType", objectType);
        if (identifierNumber != null) out.put("identifierNumber", identifierNumber);
        else out.put("identifierString", identifierString);
        return out;
    }
}
