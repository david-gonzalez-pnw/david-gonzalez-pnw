namespace Convene.Functions.Options;

public sealed class CronofyOptions
{
    public string ClientId { get; set; } = "";
    public string ClientSecret { get; set; } = "";
    /// <summary>Cronofy data center: us, de, au, sg, uk.</summary>
    public string DataCenter { get; set; } = "us";

    public string ApiBaseUrl =>
        DataCenter.Equals("us", StringComparison.OrdinalIgnoreCase)
            ? "https://api.cronofy.com"
            : $"https://api-{DataCenter}.cronofy.com";
}

public sealed class CosmosOptions
{
    public string AccountEndpoint { get; set; } = "";
    public string DatabaseName { get; set; } = "convene";
}

public sealed class AuthOptions
{
    /// <summary>HMAC signing key for backend JWTs. In production this is a Key Vault secret.</summary>
    public string SigningKey { get; set; } = "";
    public string Issuer { get; set; } = "https://convene.local";
    /// <summary>Safety valve: must stay false until App Attest verification is implemented.</summary>
    public bool AllowUnverifiedAttestation { get; set; }
}

public sealed class AppleOptions
{
    public string BundleId { get; set; } = "";
}
