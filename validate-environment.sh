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
    echo "⚠️  Azure Developer CLI is not available (optional for MCP server)"
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

# Check Node.js for MCP server
if command -v node &> /dev/null; then
    echo "✅ Node.js is available"
    node --version
else
    echo "❌ Node.js is not available"
    echo "Please install Node.js for MCP server support"
    exit 1
fi

# Check npm for MCP server
if command -v npm &> /dev/null; then
    echo "✅ npm is available"
    npm --version
else
    echo "❌ npm is not available"
    echo "Please install npm for MCP server support"
    exit 1
fi

# Check MCP server dependencies
if [ -f "package.json" ]; then
    echo "✅ MCP server package.json found"
    if [ -d "node_modules" ]; then
        echo "✅ MCP server dependencies installed"
    else
        echo "⚠️  MCP server dependencies not installed. Run 'npm install'"
    fi
else
    echo "❌ MCP server package.json not found"
    exit 1
fi

# Test MCP server basic functionality
echo "🧪 Testing MCP server functionality..."
if echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' | node src/index.js > /dev/null 2>&1; then
    echo "✅ MCP server is functional"
else
    echo "❌ MCP server failed to start or respond"
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

echo "🎉 All validations passed! The environment is ready for Azure development with MCP server support."