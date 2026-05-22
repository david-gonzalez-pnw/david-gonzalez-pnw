using System.Text;

namespace Convene.Functions.Services;

/// <summary>Envelope-encrypts Cronofy refresh tokens before they touch Cosmos.</summary>
public interface ITokenProtector
{
    string Protect(string plaintext);
    string Unprotect(string ciphertext);
}

/// <summary>
/// PLACEHOLDER. Phase 2 must replace this with real envelope encryption using the
/// Key Vault key from <c>TokenEncryption:keyId</c> (Azure.Security.KeyVault.Keys
/// <c>CryptographyClient.WrapKey</c> over a per-record data key). Today it only
/// base64-encodes, which is NOT encryption — do not ship to production.
/// </summary>
public sealed class PassthroughTokenProtector : ITokenProtector
{
    public string Protect(string plaintext) =>
        Convert.ToBase64String(Encoding.UTF8.GetBytes(plaintext));

    public string Unprotect(string ciphertext) =>
        Encoding.UTF8.GetString(Convert.FromBase64String(ciphertext));
}
