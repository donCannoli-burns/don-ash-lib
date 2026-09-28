package dev.doncannoli.kolmafia.ash;

@FunctionalInterface
public interface PasswordProvider {
    String get() throws Exception;
}
