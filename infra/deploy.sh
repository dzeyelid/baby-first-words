#!/bin/bash

# Deployment script for baby-first-words infrastructure
# Usage: ./deploy.sh [environment] [resource-group]
# Example: ./deploy.sh dev rg-baby-first-words-dev

set -e

# Default values
ENVIRONMENT=${1:-dev}
RESOURCE_GROUP=${2:-rg-baby-first-words-${ENVIRONMENT}}
LOCATION=${3:-japaneast}

echo "🚀 Deploying baby-first-words infrastructure"
echo "📍 Environment: $ENVIRONMENT"
echo "📦 Resource Group: $RESOURCE_GROUP"
echo "🌏 Location: $LOCATION"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Check if parameter file exists
PARAM_FILE="infra/parameters/${ENVIRONMENT}.json"
if [ ! -f "$PARAM_FILE" ]; then
    echo "❌ Parameter file not found: $PARAM_FILE"
    echo "Available parameter files:"
    ls -la infra/parameters/
    exit 1
fi

# Create resource group if it doesn't exist
echo "🏗️  Creating resource group (if not exists)..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Validate the Bicep template
echo "✅ Validating Bicep template..."
az deployment group validate \
    --resource-group "$RESOURCE_GROUP" \
    --template-file infra/main.bicep \
    --parameters "@$PARAM_FILE" \
    --output none

# Deploy the infrastructure
echo "🔧 Deploying infrastructure..."
DEPLOYMENT_NAME="baby-first-words-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file infra/main.bicep \
    --parameters "@$PARAM_FILE" \
    --name "$DEPLOYMENT_NAME" \
    --output table

# Get deployment outputs
echo ""
echo "📊 Deployment outputs:"
az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs" \
    --output table

echo ""
echo "✅ Deployment completed successfully!"
echo "🔗 View resources in Azure Portal:"
echo "   https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP"