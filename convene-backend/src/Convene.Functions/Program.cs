using Azure.Identity;
using Convene.Functions.Auth;
using Convene.Functions.Options;
using Convene.Functions.Services;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication(worker =>
    {
        worker.UseMiddleware<AuthenticationMiddleware>();
    })
    .ConfigureServices((context, services) =>
    {
        var config = context.Configuration;

        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();

        services.Configure<CronofyOptions>(config.GetSection("Cronofy"));
        services.Configure<CosmosOptions>(config.GetSection("Cosmos"));
        services.Configure<AuthOptions>(config.GetSection("Auth"));
        services.Configure<AppleOptions>(config.GetSection("Apple"));

        // Managed identity everywhere (DefaultAzureCredential resolves to the
        // Function's system-assigned identity in Azure, dev creds locally).
        var credential = new DefaultAzureCredential();

        services.AddSingleton(_ =>
        {
            var endpoint = config["Cosmos:accountEndpoint"]
                ?? throw new InvalidOperationException("Cosmos:accountEndpoint not configured.");
            return new CosmosClient(endpoint, credential, new CosmosClientOptions
            {
                SerializerOptions = new CosmosSerializationOptions
                {
                    PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase,
                },
            });
        });

        services.AddHttpClient<ICronofyClient, CronofyClient>();

        services.AddSingleton<IConveneStore, ConveneStore>();
        services.AddSingleton<ITokenProtector, PassthroughTokenProtector>();
        services.AddSingleton<IBackendTokenService, BackendTokenService>();
        services.AddSingleton<IAppAttestVerifier, AppAttestVerifier>();
        services.AddSingleton<IAppleIdentityVerifier, AppleIdentityVerifier>();
    })
    .Build();

host.Run();
