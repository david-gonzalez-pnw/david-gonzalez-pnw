using Microsoft.Azure.Functions.Worker;

namespace Convene.Functions.Auth;

public sealed record ConvenePrincipal(string Id, string Type)
{
    public bool IsApple => Type == "apple";
}

public static class FunctionContextAuthExtensions
{
    private const string Key = "convene.principal";

    public static void SetPrincipal(this FunctionContext context, ConvenePrincipal principal)
        => context.Items[Key] = principal;

    public static ConvenePrincipal? GetPrincipal(this FunctionContext context)
        => context.Items.TryGetValue(Key, out var value) ? value as ConvenePrincipal : null;
}
