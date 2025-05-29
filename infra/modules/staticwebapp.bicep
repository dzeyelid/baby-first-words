/*
  Azure Static Web Apps module for baby-first-words application
  Creates Static Web App with Functions integration
*/

// Parameters
@description('Static Web App name')
param staticWebAppName string

@description('Location for the Static Web App')
param location string

@description('Tags to apply to the Static Web App')
param tags object

@description('Function App name for API integration')
param functionAppName string

@description('Static Web App SKU')
@allowed([
  'Free'
  'Standard'
])
param sku string = 'Free'

@description('Repository URL for source control (optional)')
param repositoryUrl string = ''

@description('Repository branch for source control (optional)')
param repositoryBranch string = 'main'

@description('Repository token for source control (optional)')
@secure()
param repositoryToken string = ''

// Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: staticWebAppName
  location: location
  tags: tags
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    // Build properties for automatic deployment (when using GitHub integration)
    buildProperties: {
      skipGithubActionWorkflowGeneration: empty(repositoryUrl) ? true : false
      appLocation: '/src' // Adjust based on your frontend source location
      apiLocation: '' // Empty since we're using separate Function App
      outputLocation: '/dist' // Adjust based on your build output location
    }
    // Repository configuration (optional)
    repositoryUrl: repositoryUrl
    branch: repositoryBranch
    repositoryToken: repositoryToken
    // Staging environment policy
    stagingEnvironmentPolicy: 'Enabled'
    // Allow configuration file updates
    allowConfigFileUpdates: true
    // Note: contentDistributionPolicy is not available in this API version
    // contentDistributionPolicy: 'Disabled'
    // Enterprise edge
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

// Reference to existing Function App for linking
resource functionApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: functionAppName
}

// Linked backend configuration for Function App integration
resource linkedBackend 'Microsoft.Web/staticSites/linkedBackends@2023-01-01' = {
  parent: staticWebApp
  name: functionAppName
  properties: {
    backendResourceId: functionApp.id
    region: functionApp.location
  }
}

// Configuration for API integration
resource staticWebAppConfig 'Microsoft.Web/staticSites/config@2023-01-01' = {
  parent: staticWebApp
  name: 'appsettings'
  properties: {
    // API endpoint configuration
    API_ENDPOINT: 'https://${functionApp.properties.defaultHostName}'
    // Environment specific settings
    ENVIRONMENT: 'production'
  }
}

// Custom domain configuration (placeholder for future use)
// Uncomment and configure when you have a custom domain
/*
resource customDomain 'Microsoft.Web/staticSites/customDomains@2023-01-01' = {
  parent: staticWebApp
  name: 'your-custom-domain.com'
  properties: {
    validationMethod: 'cname-delegation'
  }
}
*/

// Outputs
@description('Static Web App name')
output staticWebAppName string = staticWebApp.name

@description('Static Web App resource ID')
output resourceId string = staticWebApp.id

@description('Static Web App default hostname')
output defaultHostname string = staticWebApp.properties.defaultHostname

@description('Static Web App repository URL')
output repositoryUrl string = staticWebApp.properties.repositoryUrl

@description('Static Web App deployment token (sensitive)')
@secure()
output apiKey string = staticWebApp.listSecrets().properties.apiKey

@description('Static Web App custom domains')
output customDomains array = staticWebApp.properties.customDomains