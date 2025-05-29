# Infrastructure

This directory contains the Azure Bicep templates for deploying the baby-first-words application infrastructure.

## Architecture

The infrastructure consists of three main Azure services:

1. **Azure Cosmos DB** - NoSQL database for storing baby words data
2. **Azure Functions** - TypeScript-based serverless API
3. **Azure Static Web Apps** - Frontend hosting with CDN

## Resources Created

### Azure Cosmos DB
- Cosmos DB account with serverless billing model
- Database: `BabyFirstWords`
- Container: `Words` with partition key `/wordId`
- Optimized indexing policy for word queries
- 30-day backup retention

### Azure Functions
- Function App with Node.js 18 runtime
- Consumption plan for cost optimization
- System-assigned managed identity for secure Cosmos DB access
- Application Insights for monitoring and logging
- Log Analytics workspace for centralized logging
- Storage account for function runtime

### Azure Static Web Apps
- Static web hosting with global CDN
- Integration with Azure Functions as API backend
- Free tier suitable for development
- Support for staging environments

## Deployment

### Prerequisites

1. Azure CLI installed and logged in
2. Azure subscription with appropriate permissions
3. Resource group created

### Deploy with Azure CLI

```bash
# Create resource group (if not exists)
az group create --name rg-baby-first-words-dev --location japaneast

# Deploy the infrastructure
az deployment group create \
  --resource-group rg-baby-first-words-dev \
  --template-file infra/main.bicep \
  --parameters @infra/parameters/dev.json
```

### Deploy with Azure Developer CLI (azd)

This template is compatible with Azure Developer CLI:

```bash
# Initialize (if using azd)
azd init

# Deploy
azd up
```

## Configuration

### Parameters

The deployment can be customized using parameters:

- `environmentName`: Environment suffix (dev, prod, etc.)
- `location`: Azure region for resources
- `appName`: Application name prefix
- `cosmosDbDatabaseName`: Cosmos DB database name
- `cosmosDbContainerName`: Cosmos DB container name

### Environment-specific Parameters

- `infra/parameters/dev.json` - Development environment
- `infra/parameters/prod.json` - Production environment

## Security

### Managed Identity

The Function App uses system-assigned managed identity to access Cosmos DB, eliminating the need for connection strings or keys in application settings.

### Role Assignments

- Function App managed identity has **Cosmos DB Data Contributor** role on the Cosmos DB account
- This allows read/write access to Cosmos DB data

### Network Security

- All resources are configured with HTTPS only
- Minimum TLS version 1.2
- Storage accounts have public blob access disabled
- FTP access is disabled on Function Apps

## Monitoring

### Application Insights

- Automatic telemetry collection for Function App
- Custom metrics and logging available
- 90-day data retention

### Log Analytics

- Centralized logging for all resources
- 30-day retention for cost optimization
- Query capabilities for troubleshooting

## Cost Optimization

### Development Environment

- Cosmos DB: Serverless billing (pay per request)
- Functions: Consumption plan (pay per execution)
- Static Web Apps: Free tier
- Storage: Standard LRS (cheapest redundancy)

### Production Considerations

For production deployments, consider:

- Cosmos DB: Reserved capacity for predictable workloads
- Functions: Premium plan for better performance
- Static Web Apps: Standard tier for custom domains
- Storage: Geo-redundant storage for disaster recovery

## Outputs

After deployment, the template provides these outputs:

- `cosmosDbAccountName`: Cosmos DB account name
- `cosmosDbEndpoint`: Cosmos DB endpoint URL
- `functionAppName`: Function App name
- `functionAppHostname`: Function App default hostname
- `staticWebAppName`: Static Web App name
- `staticWebAppHostname`: Static Web App default hostname

## Troubleshooting

### Common Issues

1. **Resource naming conflicts**: Ensure unique resource names by using different environment names
2. **Role assignment delays**: Managed identity role assignments may take a few minutes to propagate
3. **Static Web App regions**: Limited region availability, template uses East US 2

### Verification

After deployment, verify:

1. Cosmos DB is accessible from Function App
2. Function App managed identity has proper role assignments
3. Static Web App can connect to Function App API
4. Application Insights is collecting telemetry

## Next Steps

1. Deploy your Function App code to the created Function App
2. Deploy your frontend code to the Static Web App
3. Configure custom domains (if needed)
4. Set up CI/CD pipelines for automated deployments