using Convene.Functions.Auth;
using Convene.Functions.Models;
using Convene.Functions.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Convene.Functions.Functions;

public sealed class AuthFunctions
{
    private static readonly TimeSpan AnonymousLifetime = TimeSpan.FromHours(1);
    private static readonly TimeSpan AppleLifetime = TimeSpan.FromHours(1);

    private readonly IConveneStore _store;
    private readonly IBackendTokenService _tokens;
    private readonly IAppAttestVerifier _attest;
    private readonly IAppleIdentityVerifier _apple;
    private readonly ILogger<AuthFunctions> _log;

    public AuthFunctions(
        IConveneStore store,
        IBackendTokenService tokens,
        IAppAttestVerifier attest,
        IAppleIdentityVerifier apple,
        ILogger<AuthFunctions> log)
    {
        _store = store;
        _tokens = tokens;
        _attest = attest;
        _apple = apple;
        _log = log;
    }

    /// <summary>Anonymous device principal, gated by App Attest.</summary>
    [Function("AuthAnonymous")]
    public async Task<IActionResult> Anonymous(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "auth/anonymous")] HttpRequest req,
        CancellationToken ct)
    {
        var body = await req.ReadFromJsonAsync<AnonymousAuthRequest>(ct);
        if (body is null) return new BadRequestResult();

        var result = await _attest.VerifyAsync(body.KeyId, body.Attestation, body.Challenge, ct);
        if (!result.Success)
        {
            _log.LogWarning("App Attest rejected: {Error}", result.Error);
            return new UnauthorizedResult();
        }

        var principal = new Principal
        {
            Type = PrincipalType.Anonymous,
            AttestKeyId = result.KeyId,
        };
        await _store.UpsertPrincipalAsync(principal, ct);

        var (token, expiresIn) = _tokens.Issue(principal.Id, "anonymous", AnonymousLifetime);
        return new OkObjectResult(new AuthTokenResponse
        {
            Token = token,
            PrincipalId = principal.Id,
            ExpiresIn = expiresIn,
        });
    }

    /// <summary>Upgrade/link to a durable Apple identity (unlocks broadcasting + subscription).</summary>
    [Function("AuthApple")]
    public async Task<IActionResult> Apple(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "auth/apple")] HttpRequest req,
        CancellationToken ct)
    {
        var body = await req.ReadFromJsonAsync<AppleAuthRequest>(ct);
        if (body is null || string.IsNullOrEmpty(body.IdentityToken)) return new BadRequestResult();

        var result = await _apple.VerifyAsync(body.IdentityToken, ct);
        if (!result.Success || string.IsNullOrEmpty(result.Sub))
        {
            _log.LogWarning("Apple identity rejected: {Error}", result.Error);
            return new UnauthorizedResult();
        }

        var principal = await _store.FindByAppleSubAsync(result.Sub, ct) ?? new Principal();
        principal.Type = PrincipalType.Apple;
        principal.AppleSub = result.Sub;
        await _store.UpsertPrincipalAsync(principal, ct);

        var (token, expiresIn) = _tokens.Issue(principal.Id, "apple", AppleLifetime);
        return new OkObjectResult(new AuthTokenResponse
        {
            Token = token,
            PrincipalId = principal.Id,
            ExpiresIn = expiresIn,
        });
    }
}
