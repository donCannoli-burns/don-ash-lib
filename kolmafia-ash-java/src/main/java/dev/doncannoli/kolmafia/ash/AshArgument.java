package dev.doncannoli.kolmafia.ash;

/** Value that knows how to represent itself to KoLmafia's Browser JSON API. */
public interface AshArgument {
    Object toJsonValue();
}
