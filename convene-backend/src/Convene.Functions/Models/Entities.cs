using System.Text.Json.Serialization;

namespace Convene.Functions.Models;

public enum PrincipalType { Anonymous, Apple }

/// <summary>Cosmos container: principals (pk /id).</summary>
public sealed class Principal
{
    [JsonPropertyName("id")] public string Id { get; set; } = Guid.NewGuid().ToString("N");
    [JsonPropertyName("type")] public PrincipalType Type { get; set; } = PrincipalType.Anonymous;
    [JsonPropertyName("appleSub")] public string? AppleSub { get; set; }
    [JsonPropertyName("attestKeyId")] public string? AttestKeyId { get; set; }
    [JsonPropertyName("subscriptionActive")] public bool SubscriptionActive { get; set; }
    [JsonPropertyName("createdAt")] public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}

/// <summary>Cosmos container: cronofyAccounts (pk /principalId).</summary>
public sealed class CronofyAccount
{
    [JsonPropertyName("id")] public string Id { get; set; } = "";          // Cronofy account_id
    [JsonPropertyName("principalId")] public string PrincipalId { get; set; } = "";
    [JsonPropertyName("refreshTokenEnc")] public string RefreshTokenEnc { get; set; } = "";
    [JsonPropertyName("dataCenter")] public string DataCenter { get; set; } = "us";
    [JsonPropertyName("scope")] public string? Scope { get; set; }
    [JsonPropertyName("providerName")] public string? ProviderName { get; set; }
    [JsonPropertyName("createdAt")] public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
