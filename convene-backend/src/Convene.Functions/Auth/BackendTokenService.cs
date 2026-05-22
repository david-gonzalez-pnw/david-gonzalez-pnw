using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Convene.Functions.Options;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Convene.Functions.Auth;

/// <summary>Issues and validates the backend's own JWTs (HMAC-signed).</summary>
public interface IBackendTokenService
{
    (string token, int expiresIn) Issue(string principalId, string principalType, TimeSpan lifetime);
    bool TryValidate(string token, out ConvenePrincipal principal);
}

public sealed class BackendTokenService : IBackendTokenService
{
    private readonly AuthOptions _options;
    private readonly SymmetricSecurityKey _key;
    private readonly JwtSecurityTokenHandler _handler = new();

    public BackendTokenService(IOptions<AuthOptions> options)
    {
        _options = options.Value;
        _key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.SigningKey));
    }

    public (string token, int expiresIn) Issue(string principalId, string principalType, TimeSpan lifetime)
    {
        var now = DateTime.UtcNow;
        var descriptor = new SecurityTokenDescriptor
        {
            Issuer = _options.Issuer,
            Audience = _options.Issuer,
            IssuedAt = now,
            NotBefore = now,
            Expires = now.Add(lifetime),
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, principalId),
                new Claim("ptype", principalType),
            }),
            SigningCredentials = new SigningCredentials(_key, SecurityAlgorithms.HmacSha256),
        };
        var token = _handler.CreateToken(descriptor);
        return (_handler.WriteToken(token), (int)lifetime.TotalSeconds);
    }

    public bool TryValidate(string token, out ConvenePrincipal principal)
    {
        principal = default!;
        var parameters = new TokenValidationParameters
        {
            ValidIssuer = _options.Issuer,
            ValidAudience = _options.Issuer,
            IssuerSigningKey = _key,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1),
        };
        try
        {
            var result = _handler.ValidateToken(token, parameters, out _);
            var id = result.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
            var ptype = result.FindFirst("ptype")?.Value ?? "anonymous";
            if (string.IsNullOrEmpty(id)) return false;
            principal = new ConvenePrincipal(id, ptype);
            return true;
        }
        catch
        {
            return false;
        }
    }
}
