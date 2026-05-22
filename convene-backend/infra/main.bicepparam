using './main.bicep'

param namePrefix = 'convene'
param environment = 'dev'
param cronofyDataCenter = 'us'

// Set from the Cronofy dashboard. Leave the secret out of source control —
// pass it at deploy time or via a pipeline secret:
//   az deployment group create ... -p cronofyClientSecret=$CRONOFY_CLIENT_SECRET
param cronofyClientId = ''

param apimPublisherEmail = 'admin@convene.example.com'
param apimPublisherName = 'Convene'
