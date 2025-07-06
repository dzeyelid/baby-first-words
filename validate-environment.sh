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
    echo "⚠️  Note: Azure Developer CLI is not required for MCP integration"
fi

# Check Bicep CLI
if command -v bicep &> /dev/null; then
    echo "✅ Bicep CLI is available"
    bicep --version
else
    echo "❌ Bicep CLI is not available"
    echo "Please run the setup script or install manually with: az bicep install"
fi

# Validate Bicep templates
echo "🔧 Validating Bicep templates..."
BICEP_VALID=true

if command -v bicep &> /dev/null; then
    if bicep build infra/main.bicep --stdout > /dev/null 2>&1; then
        echo "✅ main.bicep is valid"
    else
        echo "❌ main.bicep has errors"
        BICEP_VALID=false
    fi
    
    if bicep build infra/resources.bicep --stdout > /dev/null 2>&1; then
        echo "✅ resources.bicep is valid"
    else
        echo "❌ resources.bicep has errors"
        BICEP_VALID=false
    fi
    
    if bicep build infra/storage.bicep --stdout > /dev/null 2>&1; then
        echo "✅ storage.bicep is valid"
    else
        echo "❌ storage.bicep has errors"
        BICEP_VALID=false
    fi
    
    if [ "$BICEP_VALID" = true ]; then
        echo "🎉 All Bicep templates are valid!"
    else
        echo "⚠️  Some Bicep templates have validation errors"
    fi
else
    echo "⚠️  Bicep CLI not available, skipping template validation"
fi

# Validate MCP integration
echo ""
echo "🔍 Validating MCP integration..."
if [ -f ".vscode/mcp.json" ]; then
    echo "✅ VS Code MCP configuration file exists"
    if grep -q "microsoft.docs.mcp" ".vscode/mcp.json"; then
        echo "✅ Microsoft Docs MCP server configuration found"
        
        # Check if MCP is enabled in environment
        if [ "$COPILOT_MCP_ENABLED" = "true" ]; then
            echo "✅ MCP is enabled in environment (COPILOT_MCP_ENABLED=true)"
        else
            echo "⚠️  MCP environment variable not set (COPILOT_MCP_ENABLED)"
        fi
        
        # Check for MCP feature flags
        if echo "$COPILOT_FEATURE_FLAGS" | grep -q "copilot_swe_agent_mcp_filtering"; then
            echo "✅ MCP filtering feature flag is enabled"
        else
            echo "⚠️  MCP filtering feature flag not found"
        fi
        
        # Validate JSON format
        if python3 -c "
import json
try:
    with open('.vscode/mcp.json', 'r') as f:
        config = json.load(f)
    print('✅ MCP configuration JSON is valid')
except Exception as e:
    print(f'❌ MCP configuration JSON is invalid: {e}')
    exit(1)
" 2>/dev/null; then
            echo "✅ MCP JSON configuration is valid"
        else
            echo "❌ MCP JSON configuration is invalid"
        fi
    else
        echo "❌ Microsoft Docs MCP server configuration not found"
    fi
else
    echo "❌ VS Code MCP configuration file not found"
fi

echo ""
echo "🔬 For comprehensive MCP testing, run: ./test-mcp-integration.sh"
echo "🌟 Environment validation complete!"
echo "📚 For MCP integration details, see: docs/mcp-integration.md"