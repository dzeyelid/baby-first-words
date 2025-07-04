#!/bin/bash

# Test script for MCP integration
echo "🧪 Testing MCP integration..."

# Check if required files exist
echo "📁 Checking required files..."

files_to_check=(
    ".vscode/settings.json"
    ".devcontainer/setup-mcp.sh"
    "docs/mcp-integration.md"
    "baby-first-words.code-workspace"
)

all_files_exist=true
for file in "${files_to_check[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        all_files_exist=false
    fi
done

# Check VS Code settings content
echo ""
echo "🔍 Checking VS Code settings..."
if grep -q "microsoft.docs.mcp" ".vscode/settings.json"; then
    echo "✅ Microsoft Docs MCP server configuration found"
else
    echo "❌ Microsoft Docs MCP server configuration not found"
    all_files_exist=false
fi

# Check devcontainer configuration
echo ""
echo "🐳 Checking devcontainer configuration..."
if grep -q "github.copilot" ".devcontainer/devcontainer.json"; then
    echo "✅ GitHub Copilot extensions configured"
else
    echo "❌ GitHub Copilot extensions not configured"
    all_files_exist=false
fi

# Check workspace configuration
echo ""
echo "🏗️  Checking workspace configuration..."
if grep -q "microsoft.docs.mcp" "baby-first-words.code-workspace"; then
    echo "✅ Workspace MCP configuration found"
else
    echo "❌ Workspace MCP configuration not found"
    all_files_exist=false
fi

echo ""
if [[ "$all_files_exist" == true ]]; then
    echo "🎉 All MCP integration tests passed!"
    echo ""
    echo "Next steps for manual testing:"
    echo "1. Open VS Code with the workspace file: baby-first-words.code-workspace"
    echo "2. Ensure GitHub Copilot is enabled and authenticated"
    echo "3. Switch to Agent mode in GitHub Copilot"
    echo "4. Test with queries like:"
    echo "   - 'What are the az cli commands to create an Azure container app according to official Microsoft Learn documentation?'"
    echo "   - 'How do I deploy Azure resources using Bicep according to Microsoft docs?'"
    echo ""
    echo "📚 For more details, see: docs/mcp-integration.md"
    exit 0
else
    echo "❌ Some MCP integration tests failed!"
    exit 1
fi