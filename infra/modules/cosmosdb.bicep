/*
  Azure Cosmos DB module for baby-first-words application
  Creates Cosmos DB account with database and container
  
  References:
  - Azure Cosmos DB Best Practices: https://learn.microsoft.com/en-us/azure/cosmos-db/best-practice-performance
  - Azure Cosmos DB Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts
*/

targetScope = 'resourceGroup'

// === METADATA ===
metadata description = 'Azure Cosmos DB module for baby-first-words application'
metadata version = '1.0.0'

// === PARAMETERS ===
@description('Cosmos DB account name')
@minLength(3)
@maxLength(44)
param accountName string

@description('Location for the Cosmos DB account')
param location string

@description('Tags to apply to the Cosmos DB account')
param tags object

@description('Cosmos DB database name')
@minLength(1)
@maxLength(255)
param databaseName string

@description('Cosmos DB container name')
@minLength(1)
@maxLength(255)
param containerName string

@description('Environment name for configuration')
@allowed(['dev', 'test', 'prod'])
param environmentName string = 'dev'

@description('Cosmos DB consistency level')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param consistencyLevel string = 'Session'

@description('Enable backup for Cosmos DB')
param enableBackup bool = true

@description('Backup retention interval in hours')
@minValue(1)
@maxValue(720)
param backupRetentionIntervalInHours int = environmentName == 'dev' ? 168 : 336 // 7 days for dev, 14 days for prod

// === VARIABLES ===
var isProd = environmentName == 'prod'
var backupIntervalInMinutes = isProd ? 240 : 1440 // 4 hours for prod, 24 hours for dev
var backupStorageRedundancy = isProd ? 'Geo' : 'Local'

// === RESOURCES ===

// Cosmos DB Account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: accountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    // Enable serverless for cost optimization in development
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
    networkAclBypass: 'AzureServices'
    disableKeyBasedMetadataWriteAccess: true
    enableFreeTier: environmentName == 'dev'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Cosmos DB Database
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: cosmosDbAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    // Note: For serverless accounts, throughput is not specified at database level
  }
}

// Cosmos DB Container
resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: cosmosDbDatabase
  name: containerName
  properties: {
    resource: {
      id: containerName
      // Partition key for baby words - using wordId for even distribution
      partitionKey: {
        paths: [
          '/wordId'
        ]
      }
    }
    // Note: For serverless accounts, throughput is not specified at container level
  }
}

// === OUTPUTS ===
@description('Cosmos DB account name')
output accountName string = cosmosDbAccount.name

@description('Cosmos DB account endpoint')
output endpoint string = cosmosDbAccount.properties.documentEndpoint

@description('Cosmos DB account resource ID')
output resourceId string = cosmosDbAccount.id

@description('Cosmos DB database name')
output databaseName string = cosmosDbDatabase.name

@description('Cosmos DB container name')
output containerName string = cosmosDbContainer.name

@description('Cosmos DB account connection string (for development only)')
@secure()
output connectionString string = 'AccountEndpoint=${cosmosDbAccount.properties.documentEndpoint};AccountKey=${cosmosDbAccount.listKeys().primaryMasterKey};'

@description('Cosmos DB account system assigned identity principal ID')
output principalId string = cosmosDbAccount.identity.principalId
