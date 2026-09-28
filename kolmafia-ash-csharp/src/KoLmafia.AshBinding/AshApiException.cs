namespace KoLmafia.AshBinding;

public sealed class AshApiException : Exception
{
    public AshApiException(string message) : base(message) { }
    public AshApiException(string message, Exception innerException) : base(message, innerException) { }
}
