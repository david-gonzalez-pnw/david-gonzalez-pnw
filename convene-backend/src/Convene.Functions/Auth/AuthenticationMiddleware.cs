using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Middleware;

namespace Convene.Functions.Auth;

/// <summary>
/// Validates the backend JWT (if present) and stashes the principal on the
/// context. Functions that require auth call <c>context.GetPrincipal()</c> and
/// return 401 when it's null. The /auth/anonymous and webhook endpoints simply
/// don't require a principal.
/// </summary>
public sealed class AuthenticationMiddleware : IFunctionsWorkerMiddleware
{
    private readonly IBackendTokenService _tokens;

    public AuthenticationMiddleware(IBackendTokenService tokens) => _tokens = tokens;

    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        var http = context.GetHttpContext();
        if (http is not null &&
            http.Request.Headers.TryGetValue("Authorization", out var header))
        {
            var value = header.ToString();
            if (value.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            {
                var token = value["Bearer ".Length..].Trim();
                if (_tokens.TryValidate(token, out var principal))
                {
                    context.SetPrincipal(principal);
                }
            }
        }

        await next(context);
    }
}
