#!/bin/bash

# Validation script for Bicep and Azure Developer CLI setup
# Run this script in GitHub Codespaces to verify the environment

echo "🔍 Validating Azure development environment..."

# Check Azure CLI
if command -v az &> /dev/null; then
    echo "✅ Azure CLI is available"
    az version --query '{"azure-cli": "azure-cli"}' -o table
else
    echo "❌ Azure CLI is not available"
    exit 1
fi

# Check Azure Developer CLI
if command -v azd &> /dev/null; then
    echo "✅ Azure Developer CLI is available"
    azd version
else
    echo "❌ Azure Developer CLI is not available"
    exit 1
fi

# Check Bicep CLI
if command -v bicep &> /dev/null; then
    echo "✅ Bicep CLI is available"
    bicep --version
else
    echo "❌ Bicep CLI is not available"
    echo "Please run the setup script or install manually with: az bicep install"
    exit 1
fi

# Validate Bicep templates
echo "🔧 Validating Bicep templates..."
if bicep build infra/main.bicep --stdout > /dev/null; then
    echo "✅ main.bicep is valid"
else
    echo "❌ main.bicep has errors"
    exit 1
fi

if bicep build infra/resources.bicep --stdout > /dev/null; then
    echo "✅ resources.bicep is valid"
else
    echo "❌ resources.bicep has errors"
    exit 1
fi

if bicep build infra/storage.bicep --stdout > /dev/null; then
    echo "✅ storage.bicep is valid"
else
    echo "❌ storage.bicep has errors"
    exit 1
fi

echo "🎉 All validations passed! The environment is ready for Azure development."

# Validate MCP integration
echo ""
echo "🔍 Validating MCP integration..."
if [ -f ".vscode/settings.json" ]; then
    echo "✅ VS Code settings file exists"
    if grep -q "microsoft.docs.mcp" ".vscode/settings.json"; then
        echo "✅ Microsoft Docs MCP server configuration found"
    else
        echo "❌ Microsoft Docs MCP server configuration not found"
    fi
else
    echo "❌ VS Code settings file not found"
fi

if [ -f ".devcontainer/setup-mcp.sh" ]; then
    echo "✅ MCP setup script exists"
else
    echo "❌ MCP setup script not found"
fi

echo ""
echo "🌟 Environment validation complete!"
echo "📚 For MCP integration details, see: docs/mcp-integration.md"