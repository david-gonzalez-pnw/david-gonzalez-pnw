// Convene backend infrastructure.
// Deploy: az deployment group create -g <rg> -f main.bicep -p main.bicepparam
// NOT bicep build-validated in this environment — expect minor first-deploy fixes.

targetScope = 'resourceGroup'

@description('Short prefix for resource names, e.g. "convene".')
param namePrefix string = 'convene'

@description('Environment suffix, e.g. "dev" / "prod".')
param environment string = 'dev'

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Cronofy data center matching your Cronofy account: us, de, au, sg, uk.')
@allowed(['us', 'de', 'au', 'sg', 'uk'])
param cronofyDataCenter string = 'us'

@description('Cronofy OAuth client id (from the Cronofy dashboard).')
param cronofyClientId string = ''

@description('Cronofy OAuth client secret. Stored in Key Vault, never in app settings.')
@secure()
param cronofyClientSecret string = ''

@description('APIM publisher email (required by APIM).')
param apimPublisherEmail string = 'admin@convene.example.com'

@description('APIM publisher org name (required by APIM).')
param apimPublisherName string = 'Convene'

var tags = {
  app: 'convene'
  env: environment
}

var suffix = uniqueString(resourceGroup().id, namePrefix, environment)
var storageName = toLower('${namePrefix}st${suffix}')
var deploymentContainerName = 'deployments'
var functionAppName = '${namePrefix}-func-${environment}-${suffix}'
var planName = '${namePrefix}-plan-${environment}'
var kvName = toLower('${namePrefix}-kv-${suffix}')
var cosmosName = toLower('${namePrefix}-cosmos-${suffix}')
var apimName = '${namePrefix}-apim-${environment}-${suffix}'
var insightsName = '${namePrefix}-ai-${environment}'
var lawName = '${namePrefix}-law-${environment}'

// Built-in role definition IDs.
var roleKeyVaultSecretsUser = '4633458b-17de-408a-b874-0445c86b69e6'
var roleStorageBlobDataOwner = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var roleMonitoringMetricsPublisher = '3913510d-42f4-4e42-8a64-420c390055eb'
// Cosmos DB built-in data-plane role: Data Contributor.
var cosmosDataContributorId = '00000000-0000-0000-0000-000000000002'

// ---------------------------------------------------------------- Monitoring
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: insightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
  }
}

// ------------------------------------------------------------------- Storage
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  tags: tags
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: false // identity-based connections only
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

resource deploymentContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: deploymentContainerName
  properties: { publicAccess: 'None' }
}

// ----------------------------------------------------------------- Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  tags: tags
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
  }
}

resource cronofySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(cronofyClientSecret)) {
  parent: keyVault
  name: 'CronofyClientSecret'
  properties: {
    value: cronofyClientSecret
  }
}

// Key used to envelope-encrypt stored Cronofy refresh tokens.
resource tokenEncryptionKey 'Microsoft.KeyVault/vaults/keys@2023-07-01' = {
  parent: keyVault
  name: 'token-encryption-key'
  properties: {
    kty: 'RSA'
    keySize: 2048
    keyOps: ['wrapKey', 'unwrapKey']
  }
}

// ------------------------------------------------------------------- Cosmos
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
  name: cosmosName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    disableLocalAuth: true // force AAD/RBAC data-plane auth, no keys
    capabilities: [
      { name: 'EnableServerless' }
    ]
    consistencyPolicy: { defaultConsistencyLevel: 'Session' }
    locations: [
      { locationName: location, failoverPriority: 0, isZoneRedundant: false }
    ]
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-11-15' = {
  parent: cosmos
  name: 'convene'
  properties: {
    resource: { id: 'convene' }
  }
}

var containers = [
  { name: 'principals', pk: '/id' }
  { name: 'cronofyAccounts', pk: '/principalId' }
  { name: 'eventMappings', pk: '/principalId' }
]

resource cosmosContainers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-11-15' = [
  for c in containers: {
    parent: cosmosDb
    name: c.name
    properties: {
      resource: {
        id: c.name
        partitionKey: { paths: [c.pk], kind: 'Hash' }
      }
    }
  }
]

// ------------------------------------------------- Functions (Flex Consumption)
resource plan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: planName
  location: location
  tags: tags
  sku: { name: 'FC1', tier: 'FlexConsumption' }
  kind: 'functionapp'
  properties: { reserved: true }
}

resource functionApp 'Microsoft.Web/sites@2024-11-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storage.properties.primaryEndpoints.blob}${deploymentContainerName}'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '10.0'
      }
      scaleAndConcurrency: {
        instanceMemoryMB: 2048
        maximumInstanceCount: 100
      }
    }
    siteConfig: {
      appSettings: [
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsights.properties.ConnectionString }
        { name: 'AzureWebJobsStorage__accountName', value: storage.name }
        { name: 'Cosmos__accountEndpoint', value: cosmos.properties.documentEndpoint }
        { name: 'Cosmos__databaseName', value: cosmosDb.name }
        { name: 'KeyVault__uri', value: keyVault.properties.vaultUri }
        { name: 'Cronofy__ClientId', value: cronofyClientId }
        { name: 'Cronofy__DataCenter', value: cronofyDataCenter }
        { name: 'Cronofy__ClientSecret', value: empty(cronofyClientSecret) ? '' : '@Microsoft.KeyVault(SecretUri=${keyVault.properties.vaultUri}secrets/CronofyClientSecret)' }
        { name: 'TokenEncryption__keyId', value: tokenEncryptionKey.properties.keyUriWithVersion }
      ]
    }
  }
}

// ------------------------------------------------------------ Role assignments
resource kvSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, functionApp.id, roleKeyVaultSecretsUser)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleKeyVaultSecretsUser)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobOwner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, functionApp.id, roleStorageBlobDataOwner)
  scope: storage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleStorageBlobDataOwner)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource metricsPublisher 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appInsights.id, functionApp.id, roleMonitoringMetricsPublisher)
  scope: appInsights
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleMonitoringMetricsPublisher)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource cosmosDataRole 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-11-15' = {
  parent: cosmos
  name: guid(cosmos.id, functionApp.id, cosmosDataContributorId)
  properties: {
    roleDefinitionId: '${cosmos.id}/sqlRoleDefinitions/${cosmosDataContributorId}'
    principalId: functionApp.identity.principalId
    scope: cosmos.id
  }
}

// --------------------------------------------------------- APIM (Consumption)
resource apim 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: apimName
  location: location
  tags: tags
  sku: { name: 'Consumption', capacity: 0 }
  identity: { type: 'SystemAssigned' }
  properties: {
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2024-05-01' = {
  parent: apim
  name: 'appinsights'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsights.id
    credentials: {
      instrumentationKey: appInsights.properties.InstrumentationKey
    }
  }
}

resource conveneApi 'Microsoft.ApiManagement/service/apis@2024-05-01' = {
  parent: apim
  name: 'convene'
  properties: {
    displayName: 'Convene API'
    path: 'v1'
    protocols: ['https']
    subscriptionRequired: false
    serviceUrl: 'https://${functionApp.properties.defaultHostName}/api'
  }
}

// API-level policy: rate-limit + forward. JWT validation is templated below;
// fill in <openid-config>/issuer once the backend's signing key is finalized.
resource conveneApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-05-01' = {
  parent: conveneApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: '''<policies>
  <inbound>
    <base />
    <rate-limit-by-key calls="60" renewal-period="60" counter-key="@(context.Request.IpAddress)" />
    <!-- Enable once the backend JWT signing key/issuer is set:
    <validate-jwt header-name="Authorization" require-scheme="Bearer" failed-validation-httpcode="401">
      <openid-config url="https://YOUR-ISSUER/.well-known/openid-configuration" />
    </validate-jwt>
    -->
  </inbound>
  <backend><base /></backend>
  <outbound><base /></outbound>
  <on-error><base /></on-error>
</policies>'''
  }
}

output functionAppName string = functionApp.name
output functionDefaultHostName string = functionApp.properties.defaultHostName
output apimGatewayUrl string = apim.properties.gatewayUrl
output cosmosEndpoint string = cosmos.properties.documentEndpoint
output keyVaultUri string = keyVault.properties.vaultUri
output deploymentStorageAccount string = storage.name
output deploymentContainer string = deploymentContainerName
