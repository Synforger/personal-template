// MyCsharpLib — library entry
// `personalize.py` will rename the namespace + class names.

namespace MyCsharpLib;

public static class Greeter
{
    public const string Version = "0.1.13";

    public static string Hello(string name) => $"hello, {name}!";
}
