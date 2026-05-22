using System.Text.Json.Serialization;

namespace Convene.Functions.Models;

// Request/response DTOs. JSON keys MUST match the Swift client's default
// (member-name) encoding exactly — note "accountID" and "redirectURI".

public sealed class CronofyExchangeRequest
{
    [JsonPropertyName("code")] public string Code { get; set; } = "";
    [JsonPropertyName("redirectURI")] public string RedirectUri { get; set; } = "";
}

public sealed class CronofyExchangeResponse
{
    [JsonPropertyName("accessToken")] public string AccessToken { get; set; } = "";
    [JsonPropertyName("expiresIn")] public int ExpiresIn { get; set; }
    [JsonPropertyName("accountID")] public string AccountId { get; set; } = "";
    [JsonPropertyName("providerName")] public string? ProviderName { get; set; }
}

public sealed class CronofyRefreshRequest
{
    [JsonPropertyName("accountID")] public string AccountId { get; set; } = "";
}

public sealed class CronofyRefreshResponse
{
    [JsonPropertyName("accessToken")] public string AccessToken { get; set; } = "";
    [JsonPropertyName("expiresIn")] public int ExpiresIn { get; set; }
}

// Auth (not yet in the Swift contract; add matching client methods in Phase 2).

public sealed class AnonymousAuthRequest
{
    /// <summary>Base64 App Attest attestation object (first call) or assertion.</summary>
    [JsonPropertyName("attestation")] public string Attestation { get; set; } = "";
    [JsonPropertyName("keyId")] public string KeyId { get; set; } = "";
    /// <summary>Server-issued challenge the client signed.</summary>
    [JsonPropertyName("challenge")] public string Challenge { get; set; } = "";
}

public sealed class AppleAuthRequest
{
    [JsonPropertyName("identityToken")] public string IdentityToken { get; set; } = "";
}

public sealed class AuthTokenResponse
{
    [JsonPropertyName("token")] public string Token { get; set; } = "";
    [JsonPropertyName("principalId")] public string PrincipalId { get; set; } = "";
    [JsonPropertyName("expiresIn")] public int ExpiresIn { get; set; }
}
