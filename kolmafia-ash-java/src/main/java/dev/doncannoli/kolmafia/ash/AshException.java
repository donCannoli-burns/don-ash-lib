package dev.doncannoli.kolmafia.ash;

public class AshException extends RuntimeException {
    private static final long serialVersionUID = 1L;
    public AshException(String message) { super(message); }
    public AshException(String message, Throwable cause) { super(message, cause); }
}
