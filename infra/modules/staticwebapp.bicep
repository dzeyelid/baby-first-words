/*
  Azure Static Web Apps module for baby-first-words application
  Creates Static Web App with Functions integration
  
  References:
  - Azure Static Web Apps Best Practices: https://learn.microsoft.com/en-us/azure/static-web-apps/best-practices
  - Azure Static Web Apps Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.web/staticsites
*/

targetScope = 'resourceGroup'

// === METADATA ===
metadata description = 'Azure Static Web Apps module for baby-first-words application'
metadata version = '1.0.0'

// === PARAMETERS ===
@description('Static Web App name')
@minLength(1)
@maxLength(60)
param staticWebAppName string

@description('Tags to apply to the Static Web App')
param tags object

@description('Environment name for configuration')
@allowed(['dev', 'test', 'prod'])
param environmentName string = 'dev'

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

@description('Enable staging environment')
param enableStagingEnvironment bool = true

@description('Enable enterprise-grade CDN')
param enableEnterpriseGradeCdn bool = false

// === VARIABLES ===
var isProd = environmentName == 'prod'
// Static Web Apps専用のロケーション（East Asiaで固定）
var staticWebAppLocation = 'eastasia'
var buildProperties = {
  skipGithubActionWorkflowGeneration: empty(repositoryUrl) ? true : false
  appLocation: '/src/web' // Updated to match azure.yaml structure
  apiLocation: '' // Empty since we're using separate Function App
  outputLocation: '/dist' // Build output location
  appBuildCommand: 'npm run build'
}

// === RESOURCES ===

// Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: staticWebAppName
  location: staticWebAppLocation
  tags: tags
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    buildProperties: buildProperties
    // GitHub連携時のみリポジトリ情報を指定
    repositoryUrl: empty(repositoryUrl) ? null : repositoryUrl
    branch: empty(repositoryUrl) ? null : repositoryBranch
    repositoryToken: empty(repositoryUrl) ? null : repositoryToken
    // 必要な場合のみ下記を明示
    stagingEnvironmentPolicy: enableStagingEnvironment ? 'Enabled' : null
    enterpriseGradeCdnStatus: enableEnterpriseGradeCdn ? 'Enabled' : null
  }
}

// Reference to existing Function App for linking
resource functionApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: functionAppName
}

// Linked backend configuration for Function App integration
resource linkedBackend 'Microsoft.Web/staticSites/linkedBackends@2024-04-01' = {
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
    ENVIRONMENT: environmentName
    NODE_ENV: isProd ? 'production' : 'development'
    // Version information
    APP_VERSION: '1.0.0'
    // Feature flags
    ENABLE_ANALYTICS: toUpper(string(isProd))
    ENABLE_DEBUG: toUpper(string(!isProd))
    // CORS settings
    CORS_ALLOW_ORIGIN: '*'
    CORS_ALLOW_METHODS: 'GET,POST,PUT,DELETE,OPTIONS'
    CORS_ALLOW_HEADERS: 'Content-Type,Authorization,X-Requested-With'
  }
}

// Function configuration for routing
resource staticWebAppFunctionConfig 'Microsoft.Web/staticSites/config@2023-01-01' = {
  parent: staticWebApp
  name: 'functionappsettings'
  properties: {
    // Function App integration settings
    FUNCTION_APP_ENDPOINT: 'https://${functionApp.properties.defaultHostName}'
    FUNCTION_APP_NAME: functionAppName
    // Authentication settings
    AUTH_ENABLED: 'false' // Set to true if authentication is required
    AUTH_PROVIDER: 'github' // Example: github, aad, twitter, etc.
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

// === OUTPUTS ===
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
output deploymentToken string = staticWebApp.listSecrets().properties.apiKey

@description('Static Web App API key (sensitive)')
@secure()
output apiKey string = staticWebApp.listSecrets().properties.apiKey

@description('Static Web App custom domains')
output customDomains array = staticWebApp.properties.customDomains

@description('Static Web App linked backend ID')
output linkedBackendId string = linkedBackend.id
