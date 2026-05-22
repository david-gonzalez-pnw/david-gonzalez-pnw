using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Convene.Functions.Options;
using Microsoft.Extensions.Options;

namespace Convene.Functions.Services;

public sealed record CronofyTokens(
    string AccessToken,
    string RefreshToken,
    int ExpiresIn,
    string AccountId,
    string? ProviderName,
    string? Scope);

public interface ICronofyClient
{
    Task<CronofyTokens> ExchangeCodeAsync(string code, string redirectUri, CancellationToken ct);
    Task<CronofyTokens> RefreshAsync(string refreshToken, CancellationToken ct);
}

public sealed class CronofyClient : ICronofyClient
{
    private readonly HttpClient _http;
    private readonly CronofyOptions _options;

    public CronofyClient(HttpClient http, IOptions<CronofyOptions> options)
    {
        _http = http;
        _options = options.Value;
    }

    public async Task<CronofyTokens> ExchangeCodeAsync(string code, string redirectUri, CancellationToken ct)
    {
        var body = new
        {
            client_id = _options.ClientId,
            client_secret = _options.ClientSecret,
            grant_type = "authorization_code",
            code,
            redirect_uri = redirectUri,
        };
        return await PostTokenAsync(body, ct);
    }

    public async Task<CronofyTokens> RefreshAsync(string refreshToken, CancellationToken ct)
    {
        var body = new
        {
            client_id = _options.ClientId,
            client_secret = _options.ClientSecret,
            grant_type = "refresh_token",
            refresh_token = refreshToken,
        };
        return await PostTokenAsync(body, ct);
    }

    private async Task<CronofyTokens> PostTokenAsync(object body, CancellationToken ct)
    {
        using var response = await _http.PostAsJsonAsync($"{_options.ApiBaseUrl}/oauth/token", body, ct);
        response.EnsureSuccessStatusCode();
        var token = await response.Content.ReadFromJsonAsync<TokenResponse>(cancellationToken: ct)
                    ?? throw new InvalidOperationException("Empty token response from Cronofy.");

        return new CronofyTokens(
            AccessToken: token.AccessToken,
            RefreshToken: token.RefreshToken ?? "",
            ExpiresIn: token.ExpiresIn,
            AccountId: token.AccountId ?? token.Sub ?? "",
            ProviderName: token.LinkingProfile?.ProviderName,
            Scope: token.Scope);
    }

    private sealed class TokenResponse
    {
        [JsonPropertyName("access_token")] public string AccessToken { get; set; } = "";
        [JsonPropertyName("refresh_token")] public string? RefreshToken { get; set; }
        [JsonPropertyName("expires_in")] public int ExpiresIn { get; set; }
        [JsonPropertyName("scope")] public string? Scope { get; set; }
        [JsonPropertyName("account_id")] public string? AccountId { get; set; }
        [JsonPropertyName("sub")] public string? Sub { get; set; }
        [JsonPropertyName("linking_profile")] public LinkingProfile? LinkingProfile { get; set; }
    }

    private sealed class LinkingProfile
    {
        [JsonPropertyName("provider_name")] public string? ProviderName { get; set; }
    }
}
