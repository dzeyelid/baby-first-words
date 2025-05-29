/*
  Azure Functions module for baby-first-words application
  Creates Function App with TypeScript runtime and Cosmos DB integration
*/

// Parameters
@description('Function App name')
param functionAppName string

@description('Location for the Function App')
param location string

@description('Tags to apply to the Function App')
param tags object

@description('Cosmos DB account name for connection')
param cosmosDbAccountName string

@description('Cosmos DB database name')
param cosmosDbDatabaseName string

@description('Cosmos DB container name')
param cosmosDbContainerName string

@description('Cosmos DB endpoint')
param cosmosDbEndpoint string

@description('Node.js version for the Function App')
param nodeVersion string = '18'

// Variables
var hostingPlanName = 'plan-${functionAppName}'
var storageAccountName = 'st${replace(functionAppName, '-', '')}${uniqueString(resourceGroup().id)}'
var applicationInsightsName = 'ai-${functionAppName}'

// Storage Account for Function App
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS' // Locally redundant storage for cost optimization
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    // Network access restrictions
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Application Insights for monitoring
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    // Retention period in days
    RetentionInDays: 90
    // Workspace-based Application Insights
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Log Analytics Workspace for Application Insights
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law-${functionAppName}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Hosting Plan (Consumption Plan for cost optimization)
resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: location
  tags: tags
  sku: {
    name: 'Y1' // Consumption plan
    tier: 'Dynamic'
  }
  properties: {
    // Reserved for Linux
    reserved: false
  }
}

// Function App with Managed Identity
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned' // Enable System Assigned Managed Identity
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    siteConfig: {
      // Function App configuration
      appSettings: [
        // Function App runtime settings
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~${nodeVersion}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        // Application Insights
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        // Cosmos DB settings for application use
        {
          name: 'COSMOS_DB_ENDPOINT'
          value: cosmosDbEndpoint
        }
        {
          name: 'COSMOS_DB_DATABASE_NAME'
          value: cosmosDbDatabaseName
        }
        {
          name: 'COSMOS_DB_CONTAINER_NAME'
          value: cosmosDbContainerName
        }
        {
          name: 'COSMOS_DB_ACCOUNT_NAME'
          value: cosmosDbAccountName
        }
        // CORS settings for Static Web Apps integration
        {
          name: 'WEBSITE_CORS_ALLOWED_ORIGINS'
          value: '*' // This will be updated to specific Static Web App URL in production
        }
        {
          name: 'WEBSITE_CORS_SUPPORT_CREDENTIALS'
          value: 'false'
        }
      ]
      // Node.js version
      nodeVersion: '~${nodeVersion}'
      // Enable detailed error messages
      detailedErrorLoggingEnabled: true
      // Enable HTTP logging
      httpLoggingEnabled: true
      // Enable request tracing
      requestTracingEnabled: true
      // CORS configuration
      cors: {
        allowedOrigins: [
          '*' // This should be restricted to specific origins in production
        ]
        supportCredentials: false
      }
      // Use 64-bit platform
      use32BitWorkerProcess: false
      // Enable remote debugging
      remoteDebuggingEnabled: false
      // Minimum TLS version
      minTlsVersion: '1.2'
      // Enable FTP/FTPS
      ftpsState: 'Disabled'
    }
    // Client affinity (disabled for stateless functions)
    clientAffinityEnabled: false
  }
}

// Reference to existing Cosmos DB account for role assignment
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosDbAccountName
}

// Role assignment for Function App to access Cosmos DB using Managed Identity
// Using built-in Cosmos DB Data Contributor role
resource cosmosDbRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosDbAccount.id, functionApp.id, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  scope: cosmosDbAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Cosmos DB Data Contributor
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
@description('Function App name')
output functionAppName string = functionApp.name

@description('Function App resource ID')
output resourceId string = functionApp.id

@description('Function App default hostname')
output defaultHostname string = functionApp.properties.defaultHostName

@description('Function App system assigned managed identity principal ID')
output principalId string = functionApp.identity.principalId

@description('Application Insights instrumentation key')
output applicationInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Application Insights connection string')
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString