using Convene.Functions.Auth;
using Convene.Functions.Models;
using Convene.Functions.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Convene.Functions.Functions;

public sealed class CronofyAuthFunctions
{
    private readonly ICronofyClient _cronofy;
    private readonly IConveneStore _store;
    private readonly ITokenProtector _protector;
    private readonly ILogger<CronofyAuthFunctions> _log;

    public CronofyAuthFunctions(
        ICronofyClient cronofy,
        IConveneStore store,
        ITokenProtector protector,
        ILogger<CronofyAuthFunctions> log)
    {
        _cronofy = cronofy;
        _store = store;
        _protector = protector;
        _log = log;
    }

    [Function("CronofyTokenExchange")]
    public async Task<IActionResult> Exchange(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "cronofy/token")] HttpRequest req,
        FunctionContext context,
        CancellationToken ct)
    {
        var principal = context.GetPrincipal();
        if (principal is null) return new UnauthorizedResult();

        var body = await req.ReadFromJsonAsync<CronofyExchangeRequest>(ct);
        if (body is null || string.IsNullOrEmpty(body.Code))
            return new BadRequestObjectResult(new { error = "code is required" });

        var tokens = await _cronofy.ExchangeCodeAsync(body.Code, body.RedirectUri, ct);

        await _store.UpsertCronofyAccountAsync(new CronofyAccount
        {
            Id = tokens.AccountId,
            PrincipalId = principal.Id,
            RefreshTokenEnc = _protector.Protect(tokens.RefreshToken),
            Scope = tokens.Scope,
            ProviderName = tokens.ProviderName,
        }, ct);

        _log.LogInformation("Connected Cronofy account {AccountId} for principal {PrincipalId}",
            tokens.AccountId, principal.Id);

        return new OkObjectResult(new CronofyExchangeResponse
        {
            AccessToken = tokens.AccessToken,
            ExpiresIn = tokens.ExpiresIn,
            AccountId = tokens.AccountId,
            ProviderName = tokens.ProviderName,
        });
    }

    [Function("CronofyTokenRefresh")]
    public async Task<IActionResult> Refresh(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "cronofy/token/refresh")] HttpRequest req,
        FunctionContext context,
        CancellationToken ct)
    {
        var principal = context.GetPrincipal();
        if (principal is null) return new UnauthorizedResult();

        var body = await req.ReadFromJsonAsync<CronofyRefreshRequest>(ct);
        if (body is null || string.IsNullOrEmpty(body.AccountId))
            return new BadRequestObjectResult(new { error = "accountID is required" });

        var account = await _store.GetCronofyAccountAsync(principal.Id, body.AccountId, ct);
        if (account is null) return new NotFoundResult();

        var refreshToken = _protector.Unprotect(account.RefreshTokenEnc);
        var tokens = await _cronofy.RefreshAsync(refreshToken, ct);

        // Cronofy may rotate the refresh token; persist if it changed.
        if (!string.IsNullOrEmpty(tokens.RefreshToken))
        {
            account.RefreshTokenEnc = _protector.Protect(tokens.RefreshToken);
            await _store.UpsertCronofyAccountAsync(account, ct);
        }

        return new OkObjectResult(new CronofyRefreshResponse
        {
            AccessToken = tokens.AccessToken,
            ExpiresIn = tokens.ExpiresIn,
        });
    }
}
