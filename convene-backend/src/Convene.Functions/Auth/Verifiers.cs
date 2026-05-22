using Convene.Functions.Options;
using Microsoft.Extensions.Options;

namespace Convene.Functions.Auth;

public sealed record AttestationResult(bool Success, string? KeyId, string? Error);
public sealed record AppleIdentityResult(bool Success, string? Sub, string? Error);

public interface IAppAttestVerifier
{
    Task<AttestationResult> VerifyAsync(string keyId, string attestationBase64, string challenge, CancellationToken ct);
}

public interface IAppleIdentityVerifier
{
    Task<AppleIdentityResult> VerifyAsync(string identityToken, CancellationToken ct);
}

/// <summary>
/// PLACEHOLDER. Phase 2 must implement Apple App Attest verification:
/// decode the CBOR attestation object, validate the x5c chain to Apple's App
/// Attest root, check the nonce against <paramref name="challenge"/>, the rpId
/// hash, and persist the public key for later assertion checks.
/// Gated by <c>Auth:AllowUnverifiedAttestation</c> so it fails closed by default.
/// </summary>
public sealed class AppAttestVerifier : IAppAttestVerifier
{
    private readonly AuthOptions _options;

    public AppAttestVerifier(IOptions<AuthOptions> options) => _options = options.Value;

    public Task<AttestationResult> VerifyAsync(string keyId, string attestationBase64, string challenge, CancellationToken ct)
    {
        if (_options.AllowUnverifiedAttestation && !string.IsNullOrEmpty(keyId))
        {
            // DEV ONLY: trust the supplied key id without cryptographic proof.
            return Task.FromResult(new AttestationResult(true, keyId, null));
        }

        return Task.FromResult(new AttestationResult(
            false, null, "App Attest verification not implemented (see Verifiers.cs)."));
    }
}

/// <summary>
/// PLACEHOLDER. Phase 2 must validate the Apple identity token against Apple's
/// JWKS (https://appleid.apple.com/auth/keys): verify the RS256 signature,
/// issuer (https://appleid.apple.com), audience (the app bundle id), and expiry,
/// then return the stable <c>sub</c>.
/// </summary>
public sealed class AppleIdentityVerifier : IAppleIdentityVerifier
{
    private readonly AppleOptions _options;

    public AppleIdentityVerifier(IOptions<AppleOptions> options) => _options = options.Value;

    public Task<AppleIdentityResult> VerifyAsync(string identityToken, CancellationToken ct)
        => Task.FromResult(new AppleIdentityResult(
            false, null, "Apple identity-token verification not implemented (see Verifiers.cs)."));
}
