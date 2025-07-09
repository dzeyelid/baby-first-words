/*
  Azure Functions module for baby-first-words application
  Creates Function App with TypeScript runtime and Cosmos DB integration
  
  References:
  - Azure Functions Best Practices: https://learn.microsoft.com/en-us/azure/azure-functions/functions-best-practices
  - Azure Functions Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites
  - Flex Consumption: https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan
*/

targetScope = 'resourceGroup'

// === METADATA ===
metadata description = 'Azure Functions module for baby-first-words application'
metadata version = '1.0.0'

// === PARAMETERS ===
@description('Function App name')
// NOTE: logAnalyticsWorkspaceName = 'log-${functionAppName}' の63文字制限に収めるため、54文字に制限
@minLength(2)
@maxLength(54)
param functionAppName string


// Functions関連リソース専用のロケーション変数（常にeastasiaで固定）
var functionsLocation = 'southeastasia'

@description('Tags to apply to the Function App')
param tags object

@description('Environment name for configuration')
@allowed(['dev', 'test', 'prod'])
param environmentName string = 'dev'

@description('Cosmos DB account name for connection')
param cosmosDbAccountName string

@description('Cosmos DB database name')
param cosmosDbDatabaseName string

@description('Cosmos DB container name')
param cosmosDbContainerName string

@description('Cosmos DB endpoint')
param cosmosDbEndpoint string

@description('Enable monitoring and diagnostics')
param enableMonitoring bool = true

// === VARIABLES ===
var hostingPlanName = 'plan-${functionAppName}'
var sanitizedFunctionAppName = toLower(replace(replace(functionAppName, '-', ''), '_', ''))
var storageAccountName = 'st${substring(sanitizedFunctionAppName, 0, 16)}${substring(uniqueString(resourceGroup().id), 0, 6)}'
var applicationInsightsName = 'appi-${functionAppName}'
var logAnalyticsWorkspaceName = 'log-${functionAppName}'
var isProd = environmentName == 'prod'
var storageBlobContainerName = 'app-package-${functionAppName}-${substring(uniqueString(resourceGroup().id), 0, 7)}'

// === RESOURCES ===

// Storage Account for Function App
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: functionsLocation
  tags: tags
  sku: {
    name: isProd ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

// Blob container for deployment packages
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/${storageBlobContainerName}'
  properties: {
    publicAccess: 'None'
  }
}

// Log Analytics Workspace for Application Insights
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = if (enableMonitoring) {
  name: logAnalyticsWorkspaceName
  location: functionsLocation
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: isProd ? 90 : 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: isProd ? 10 : 1 // 10GB for prod, 1GB for dev
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Application Insights for monitoring
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableMonitoring) {
  name: applicationInsightsName
  location: functionsLocation
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    // Retention period in days
    RetentionInDays: isProd ? 90 : 30
    // Workspace-based Application Insights
    WorkspaceResourceId: enableMonitoring ? logAnalyticsWorkspace!.id : null
    // Sampling settings
    SamplingPercentage: isProd ? 100 : 50
    // Disable IP masking for better diagnostics (dev only)
    DisableIpMasking: !isProd
  }
}

// Hosting Plan (Flex Consumption Plan for automatic scaling)
resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: functionsLocation
  tags: tags
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
  }
  kind: 'linux'
  properties: {
    // Flex Consumption specific properties
    reserved: true
    zoneRedundant: false
  }
}

// Function App with Managed Identity
resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: functionsLocation
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'DEPLOYMENT_STORAGE_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: enableMonitoring ? applicationInsights!.properties.InstrumentationKey : ''
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: enableMonitoring ? applicationInsights!.properties.ConnectionString : ''
        }
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
        {
          name: 'ENVIRONMENT'
          value: environmentName
        }
        {
          name: 'NODE_ENV'
          value: isProd ? 'production' : 'development'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: 'https://${storageAccount.name}.blob.${environment().suffixes.storage}/${storageBlobContainerName}'
          authentication: {
            type: 'StorageAccountConnectionString'
            storageAccountConnectionStringName: 'DEPLOYMENT_STORAGE_CONNECTION_STRING'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
      runtime: { 
        name: 'node'
        version: '22'
      }
    }
  }
}

// Basic publishing credentials policies - disable for security
resource scmPublishingCredentials 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'scm'
  parent: functionApp
  properties: {
    allow: false
  }
}

resource ftpPublishingCredentials 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'ftp'
  parent: functionApp
  properties: {
    allow: false
  }
}

// Reference to existing Cosmos DB account for role assignment
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' existing = {
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

// Diagnostic settings for Function App
resource functionAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableMonitoring) {
  name: '${functionAppName}-diagnostics'
  scope: functionApp
  properties: {
    workspaceId: enableMonitoring ? logAnalyticsWorkspace!.id : null
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// === OUTPUTS ===
@description('Function App name')
output functionAppName string = functionApp.name

@description('Function App resource ID')
output resourceId string = functionApp.id

@description('Function App default hostname')
output defaultHostname string = functionApp.properties.defaultHostName

@description('Function App system assigned managed identity principal ID')
output principalId string = functionApp.identity.principalId

@description('Application Insights instrumentation key')
output applicationInsightsInstrumentationKey string = enableMonitoring ? applicationInsights!.properties.InstrumentationKey : ''

@description('Application Insights connection string')
output applicationInsightsConnectionString string = enableMonitoring ? applicationInsights!.properties.ConnectionString : ''

@description('Storage account name')
output storageAccountName string = storageAccount.name

@description('Log Analytics workspace ID')
output logAnalyticsWorkspaceId string = enableMonitoring ? logAnalyticsWorkspace!.id : ''
