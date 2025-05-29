/*
  Main Bicep template for baby-first-words application
  Creates Azure Cosmos DB, Azure Functions, and Azure Static Web Apps
*/

// Parameters
@description('Environment name (e.g., dev, prod)')
param environmentName string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Application name prefix')
param appName string = 'baby-first-words'

@description('Tags to apply to all resources')
param tags object = {
  environment: environmentName
  application: appName
}

@description('Cosmos DB database name')
param cosmosDbDatabaseName string = 'BabyFirstWords'

@description('Cosmos DB container name')
param cosmosDbContainerName string = 'Words'

// Variables
var resourceSuffix = '${appName}-${environmentName}'

// Azure Cosmos DB
module cosmosDb 'modules/cosmosdb.bicep' = {
  name: 'cosmosdb-deployment'
  params: {
    accountName: 'cosmos-${resourceSuffix}'
    location: location
    tags: tags
    databaseName: cosmosDbDatabaseName
    containerName: cosmosDbContainerName
  }
}

// Azure Functions
module functions 'modules/functions.bicep' = {
  name: 'functions-deployment'
  params: {
    functionAppName: 'func-${resourceSuffix}'
    location: location
    tags: tags
    cosmosDbAccountName: cosmosDb.outputs.accountName
    cosmosDbDatabaseName: cosmosDbDatabaseName
    cosmosDbContainerName: cosmosDbContainerName
    cosmosDbEndpoint: cosmosDb.outputs.endpoint
  }
}

// Azure Static Web Apps
module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticwebapp-deployment'
  params: {
    staticWebAppName: 'swa-${resourceSuffix}'
    location: 'eastus2' // Static Web Apps has limited region availability
    tags: tags
    functionAppName: functions.outputs.functionAppName
  }
}

// Outputs
@description('Cosmos DB account name')
output cosmosDbAccountName string = cosmosDb.outputs.accountName

@description('Cosmos DB endpoint')
output cosmosDbEndpoint string = cosmosDb.outputs.endpoint

@description('Function App name')
output functionAppName string = functions.outputs.functionAppName

@description('Function App default hostname')
output functionAppHostname string = functions.outputs.defaultHostname

@description('Static Web App name')
output staticWebAppName string = staticWebApp.outputs.staticWebAppName

@description('Static Web App default hostname')
output staticWebAppHostname string = staticWebApp.outputs.defaultHostname