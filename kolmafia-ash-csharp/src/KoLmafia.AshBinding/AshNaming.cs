using System.Text;

namespace KoLmafia.AshBinding;

public static class AshNaming
{
    /// <summary>
    /// Converts an ASH function name such as available_amount to the camelCase
    /// name expected by KoLmafia's Browser JSON API. Existing camelCase names
    /// pass through unchanged.
    /// </summary>
    public static string ToJavaScriptName(string ashName)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(ashName);

        if (!ashName.Contains('_'))
            return ashName;

        var sb = new StringBuilder(ashName.Length);
        var upperNext = false;

        foreach (var ch in ashName)
        {
            if (ch == '_')
            {
                upperNext = true;
                continue;
            }

            sb.Append(upperNext ? char.ToUpperInvariant(ch) : ch);
            upperNext = false;
        }

        return sb.ToString();
    }
}
