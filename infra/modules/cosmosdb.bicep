/*
  Azure Cosmos DB module for baby-first-words application
  Creates Cosmos DB account with database and container
*/

// Parameters
@description('Cosmos DB account name')
param accountName string

@description('Location for the Cosmos DB account')
param location string

@description('Tags to apply to the Cosmos DB account')
param tags object

@description('Cosmos DB database name')
param databaseName string

@description('Cosmos DB container name')
param containerName string

@description('Cosmos DB consistency level')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param consistencyLevel string = 'Session'

// Cosmos DB Account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
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
    consistencyPolicy: {
      defaultConsistencyLevel: consistencyLevel
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    // Enable automatic failover
    enableAutomaticFailover: false
    // Enable multiple write locations for global distribution (disabled for serverless)
    enableMultipleWriteLocations: false
    // Enable analytical storage for reporting scenarios
    enableAnalyticalStorage: false
    // Network access restrictions
    publicNetworkAccess: 'Enabled'
    networkAclBypass: 'AzureServices'
    // Backup policy
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 1440 // 24 hours
        backupRetentionIntervalInHours: 720 // 30 days
        backupStorageRedundancy: 'Local'
      }
    }
  }
}

// Cosmos DB Database
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
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
resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
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
        kind: 'Hash'
      }
      // Indexing policy optimized for baby words queries
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      // Default TTL (time to live) - disabled by default
      defaultTtl: -1
    }
    // Note: For serverless accounts, throughput is not specified at container level
  }
}

// Outputs
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