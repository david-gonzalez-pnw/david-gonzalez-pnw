using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Convene.Functions.Functions;

/// <summary>
/// Ingests Cronofy push notifications. Phase 3 will verify the request HMAC,
/// map the changed events back to a principal/conversation, update attendee
/// RSVP state in Cosmos, and fan out to APNs / Azure Notification Hubs so the
/// iMessage event bubble updates live. Today it acknowledges and logs.
/// </summary>
public sealed class CronofyWebhookFunctions
{
    private readonly ILogger<CronofyWebhookFunctions> _log;

    public CronofyWebhookFunctions(ILogger<CronofyWebhookFunctions> log) => _log = log;

    [Function("CronofyWebhook")]
    public async Task<IActionResult> Receive(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "webhooks/cronofy")] HttpRequest req,
        CancellationToken ct)
    {
        // TODO(phase 3): verify Cronofy HMAC signature before trusting the body.
        using var reader = new StreamReader(req.Body);
        var payload = await reader.ReadToEndAsync(ct);
        _log.LogInformation("Cronofy webhook received ({Length} bytes)", payload.Length);

        // TODO(phase 3): parse notification, update RSVP, push via APNs.
        return new OkResult();
    }
}
