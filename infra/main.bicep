/*
  Main Bicep template for baby-first-words application
  Creates Azure Cosmos DB, Azure Functions, and Azure Static Web Apps
  
  References:
  - Azure Bicep Best Practices: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices
  - Azure Well-Architected Framework: https://learn.microsoft.com/en-us/azure/well-architected/
  - Azure Developer CLI: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/
*/

targetScope = 'resourceGroup'

// === METADATA ===
metadata description = 'Main template for baby-first-words application infrastructure'
metadata version = '1.0.0'
metadata author = 'Baby First Words Team'

// === PARAMETERS ===
@description('Environment name (e.g., dev, prod)')
@allowed(['dev', 'test', 'prod'])
param environmentName string = 'dev'

@description('Location for all resources')
@allowed([
  'japaneast'
  'japanwest'
])
param location string = 'japaneast'

@description('Application name prefix')
@minLength(3)
@maxLength(20)
param appName string = 'baby-first-words'

@description('Tags to apply to all resources')
param tags object = {
  environment: environmentName
  application: appName
  deployedBy: 'azure-developer-cli'
  project: 'baby-first-words'
}

@description('Cosmos DB database name')
@minLength(1)
@maxLength(255)
param cosmosDbDatabaseName string = 'cosdb-baby-first-words'

@description('Cosmos DB container name')
@minLength(1)
@maxLength(255)
param cosmosDbContainerName string = 'cont-words'

@description('Enable monitoring and diagnostics')
param enableMonitoring bool = true

@description('Enable backup for Cosmos DB')
param enableBackup bool = true

// === VARIABLES ===
var resourceSuffix = '${appName}-${environmentName}'
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 6)
var location_staticwebapp = 'eastus2' // Static Web Apps has limited region availability, Japan regions not yet supported

// === RESOURCES ===

// Azure Cosmos DB
module cosmosDb 'modules/cosmosdb.bicep' = {
  name: 'cosmosdb-deployment-${uniqueSuffix}'
  params: {
    accountName: 'cosmos-${resourceSuffix}-${uniqueSuffix}'
    location: location
    tags: tags
    databaseName: cosmosDbDatabaseName
    containerName: cosmosDbContainerName
    enableBackup: enableBackup
    environmentName: environmentName
  }
}

// Azure Functions
module functions 'modules/functions.bicep' = {
  name: 'functions-deployment-${uniqueSuffix}'
  params: {
    functionAppName: 'func-${resourceSuffix}-${uniqueSuffix}'
    location: location
    tags: tags
    cosmosDbAccountName: cosmosDb.outputs.accountName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbContainerName: cosmosDbContainerName
    cosmosDbEndpoint: cosmosDb.outputs.endpoint
    enableMonitoring: enableMonitoring
    environmentName: environmentName
  }
}

// Azure Static Web Apps
module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticwebapp-deployment-${uniqueSuffix}'
  params: {
    staticWebAppName: 'swa-${resourceSuffix}-${uniqueSuffix}'
    location: location_staticwebapp
    tags: tags
    functionAppName: functions.outputs.functionAppName
    environmentName: environmentName
  }
}

// === OUTPUTS ===
@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('Cosmos DB account name')
output cosmosDbAccountName string = cosmosDb.outputs.accountName

@description('Cosmos DB endpoint')
output cosmosDbEndpoint string = cosmosDb.outputs.endpoint

@description('Cosmos DB connection string (for development only)')
output cosmosDbConnectionString string = cosmosDb.outputs.connectionString

@description('Function App name')
output functionAppName string = functions.outputs.functionAppName

@description('Function App default hostname')
output functionAppHostname string = functions.outputs.defaultHostname

@description('Function App principal ID')
output functionAppPrincipalId string = functions.outputs.principalId

@description('Static Web App name')
output staticWebAppName string = staticWebApp.outputs.staticWebAppName

@description('Static Web App default hostname')
output staticWebAppHostname string = staticWebApp.outputs.defaultHostname

@description('Static Web App deployment token')
@secure()
output staticWebAppDeploymentToken string = staticWebApp.outputs.deploymentToken

@description('Application Insights connection string')
output applicationInsightsConnectionString string = functions.outputs.applicationInsightsConnectionString
