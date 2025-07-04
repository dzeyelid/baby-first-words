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
@minLength(2)
@maxLength(60)
param functionAppName string

@description('Location for the Function App')
param location string

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

@description('Node.js version for the Function App')
@allowed(['18', '20'])
param nodeVersion string = '20'

@description('Enable monitoring and diagnostics')
param enableMonitoring bool = true

@description('Enable detailed logging')
param enableDetailedLogging bool = true

// === VARIABLES ===
var hostingPlanName = 'plan-${functionAppName}'
var storageAccountName = 'st${replace(functionAppName, '-', '')}${substring(uniqueString(resourceGroup().id), 0, 6)}'
var applicationInsightsName = 'ai-${functionAppName}'
var logAnalyticsWorkspaceName = 'law-${functionAppName}'
var isProd = environmentName == 'prod'

// === RESOURCES ===

// Storage Account for Function App
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: isProd ? 'Standard_GRS' : 'Standard_LRS' // Geo-redundant for prod, local for dev
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    // Enhanced security settings
    allowSharedKeyAccess: true
    allowCrossTenantReplication: false
    defaultToOAuthAuthentication: false
    // Network access restrictions
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    // Encryption settings
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: isProd
    }
  }
}

// Log Analytics Workspace for Application Insights
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = if (enableMonitoring) {
  name: logAnalyticsWorkspaceName
  location: location
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
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    // Retention period in days
    RetentionInDays: isProd ? 90 : 30
    // Workspace-based Application Insights
    WorkspaceResourceId: enableMonitoring ? logAnalyticsWorkspace.id : null
    // Sampling settings
    SamplingPercentage: isProd ? 100 : 50
    // Disable IP masking for better diagnostics (dev only)
    DisableIpMasking: !isProd
  }
}

// Hosting Plan (Flex Consumption Plan for automatic scaling)
resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: location
  tags: tags
  sku: {
    name: 'FC1' // Flex Consumption plan
    tier: 'FlexConsumption'
  }
  kind: 'functionapp'
  properties: {
    // Reserved for Linux (false for Windows)
    reserved: false
    // Maximum number of workers
    maximumElasticWorkerCount: isProd ? 100 : 10
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
    // Enhanced security settings
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    keyVaultReferenceIdentity: 'SystemAssigned'
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
        {
          name: 'FUNCTIONS_WORKER_RUNTIME_VERSION'
          value: '~${nodeVersion}'
        }
        // Application Insights
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: enableMonitoring ? applicationInsights.properties.InstrumentationKey : ''
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: enableMonitoring ? applicationInsights.properties.ConnectionString : ''
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
        // Environment settings
        {
          name: 'ENVIRONMENT'
          value: environmentName
        }
        {
          name: 'NODE_ENV'
          value: isProd ? 'production' : 'development'
        }
        // Performance settings
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
          value: 'true'
        }
        // CORS settings for Static Web Apps integration
        {
          name: 'WEBSITE_CORS_ALLOWED_ORIGINS'
          value: '*' // This should be restricted to specific origins in production
        }
        {
          name: 'WEBSITE_CORS_SUPPORT_CREDENTIALS'
          value: 'false'
        }
      ]
      // Node.js version
      nodeVersion: '~${nodeVersion}'
      // TypeScript support
      powerShellVersion: null
      // Enable detailed error messages
      detailedErrorLoggingEnabled: enableDetailedLogging
      // Enable HTTP logging
      httpLoggingEnabled: enableDetailedLogging
      // Enable request tracing
      requestTracingEnabled: enableDetailedLogging
      // CORS configuration
      cors: {
        allowedOrigins: [
          '*' // This should be restricted to specific origins in production
        ]
        supportCredentials: false
      }
      // Use 64-bit platform
      use32BitWorkerProcess: false
      // Always on (not applicable for Flex Consumption)
      alwaysOn: false
      // Enable remote debugging (dev only)
      remoteDebuggingEnabled: !isProd
      remoteDebuggingVersion: 'VS2022'
      // Minimum TLS version
      minTlsVersion: '1.2'
      // Disable FTP/FTPS
      ftpsState: 'Disabled'
      // Health check path
      healthCheckPath: '/api/health'
      // Virtual applications
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: false
        }
      ]
      // Auto-heal settings
      autoHealEnabled: isProd
      autoHealRules: isProd ? {
        triggers: {
          requests: {
            count: 100
            timeInterval: '00:05:00'
          }
          statusCodes: [
            {
              status: 500
              subStatus: 0
              win32Status: 0
              count: 10
              timeInterval: '00:05:00'
            }
          ]
        }
        actions: {
          actionType: 'Recycle'
          minProcessExecutionTime: '00:01:00'
        }
      } : null
    }
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
    workspaceId: enableMonitoring ? logAnalyticsWorkspace.id : null
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: isProd ? 90 : 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: isProd ? 90 : 30
        }
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
output applicationInsightsInstrumentationKey string = enableMonitoring ? applicationInsights.properties.InstrumentationKey : ''

@description('Application Insights connection string')
output applicationInsightsConnectionString string = enableMonitoring ? applicationInsights.properties.ConnectionString : ''

@description('Storage account name')
output storageAccountName string = storageAccount.name

@description('Log Analytics workspace ID')
output logAnalyticsWorkspaceId string = enableMonitoring ? logAnalyticsWorkspace.id : ''