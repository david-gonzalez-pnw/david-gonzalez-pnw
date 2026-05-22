using Convene.Functions.Models;
using Convene.Functions.Options;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;

namespace Convene.Functions.Services;

public interface IConveneStore
{
    Task<Principal> UpsertPrincipalAsync(Principal principal, CancellationToken ct);
    Task<Principal?> GetPrincipalAsync(string id, CancellationToken ct);
    Task<Principal?> FindByAppleSubAsync(string appleSub, CancellationToken ct);

    Task UpsertCronofyAccountAsync(CronofyAccount account, CancellationToken ct);
    Task<CronofyAccount?> GetCronofyAccountAsync(string principalId, string accountId, CancellationToken ct);
}

public sealed class ConveneStore : IConveneStore
{
    private readonly Container _principals;
    private readonly Container _cronofyAccounts;

    public ConveneStore(CosmosClient client, IOptions<CosmosOptions> options)
    {
        var db = client.GetDatabase(options.Value.DatabaseName);
        _principals = db.GetContainer("principals");
        _cronofyAccounts = db.GetContainer("cronofyAccounts");
    }

    public async Task<Principal> UpsertPrincipalAsync(Principal principal, CancellationToken ct)
    {
        var response = await _principals.UpsertItemAsync(
            principal, new PartitionKey(principal.Id), cancellationToken: ct);
        return response.Resource;
    }

    public async Task<Principal?> GetPrincipalAsync(string id, CancellationToken ct)
    {
        try
        {
            var response = await _principals.ReadItemAsync<Principal>(id, new PartitionKey(id), cancellationToken: ct);
            return response.Resource;
        }
        catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            return null;
        }
    }

    public async Task<Principal?> FindByAppleSubAsync(string appleSub, CancellationToken ct)
    {
        var query = new QueryDefinition("SELECT * FROM c WHERE c.appleSub = @sub")
            .WithParameter("@sub", appleSub);
        using var iterator = _principals.GetItemQueryIterator<Principal>(query);
        while (iterator.HasMoreResults)
        {
            foreach (var item in await iterator.ReadNextAsync(ct))
            {
                return item;
            }
        }
        return null;
    }

    public async Task UpsertCronofyAccountAsync(CronofyAccount account, CancellationToken ct)
    {
        await _cronofyAccounts.UpsertItemAsync(
            account, new PartitionKey(account.PrincipalId), cancellationToken: ct);
    }

    public async Task<CronofyAccount?> GetCronofyAccountAsync(string principalId, string accountId, CancellationToken ct)
    {
        try
        {
            var response = await _cronofyAccounts.ReadItemAsync<CronofyAccount>(
                accountId, new PartitionKey(principalId), cancellationToken: ct);
            return response.Resource;
        }
        catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            return null;
        }
    }
}
