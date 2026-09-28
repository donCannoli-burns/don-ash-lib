package dev.doncannoli.kolmafia.ash;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/** Lightweight typed accessors over a JSON value returned by ASH. */
public record AshValue(Object raw) {
    public String stringValue() {
        if (raw instanceof String s) return s;
        throw mismatch("string");
    }

    public long longValue() {
        if (raw instanceof Number n) return n.longValue();
        throw mismatch("integer");
    }

    public double doubleValue() {
        if (raw instanceof Number n) return n.doubleValue();
        throw mismatch("number");
    }

    public boolean booleanValue() {
        if (raw instanceof Boolean b) return b;
        throw mismatch("boolean");
    }

    @SuppressWarnings("unchecked")
    public List<Object> listValue() {
        if (raw instanceof List<?> l) return (List<Object>) l;
        throw mismatch("array");
    }

    @SuppressWarnings("unchecked")
    public Map<String,Object> objectValue() {
        if (raw instanceof Map<?,?> m) return (Map<String,Object>) m;
        throw mismatch("object");
    }

    public boolean isNull() { return raw == null; }

    private AshException mismatch(String expected) {
        return new AshException("expected " + expected + " but got " + (raw == null ? "null" : raw.getClass().getSimpleName()));
    }
}
