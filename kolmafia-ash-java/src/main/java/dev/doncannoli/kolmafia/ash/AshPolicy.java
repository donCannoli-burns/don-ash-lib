package dev.doncannoli.kolmafia.ash;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@FunctionalInterface
public interface AshPolicy {
    void check(String functionName, List<Object> args);

    static AshPolicy allowAll() {
        return (name, args) -> {};
    }

    static AshPolicy deny(String... names) {
        Set<String> denied = new HashSet<>(Arrays.asList(names));
        return (name, args) -> {
            if (denied.contains(name)) throw new AshException("ASH function denied by policy: " + name);
        };
    }

    static AshPolicy allowOnly(String... names) {
        Set<String> allowed = new HashSet<>(Arrays.asList(names));
        return (name, args) -> {
            if (!allowed.contains(name)) throw new AshException("ASH function not allowlisted: " + name);
        };
    }
}
