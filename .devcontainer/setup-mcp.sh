#!/bin/bash

# MCP Setup Script for Microsoft Docs MCP Server Integration
# This script sets up the Microsoft Docs MCP server for use with GitHub Copilot

echo "🔧 Setting up Microsoft Docs MCP Server integration..."

# Check if MCP directory exists in VS Code settings
VSCODE_SETTINGS_FILE=".vscode/settings.json"

if [ ! -f "$VSCODE_SETTINGS_FILE" ]; then
    echo "❌ VS Code settings file not found. Creating basic MCP configuration..."
    mkdir -p .vscode
    cat > "$VSCODE_SETTINGS_FILE" << 'EOF'
{
  "mcp.servers": {
    "microsoft.docs.mcp": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp",
      "name": "Microsoft Learn Docs MCP Server",
      "description": "Access to official Microsoft documentation through MCP"
    }
  }
}
EOF
    echo "✅ Created VS Code settings with MCP configuration"
else
    echo "✅ VS Code settings file already exists"
fi

# Verify MCP server endpoint accessibility
echo "🌐 Verifying MCP server endpoint accessibility..."
if curl -s --fail --max-time 10 "https://learn.microsoft.com/api/mcp" > /dev/null; then
    echo "✅ Microsoft Docs MCP server endpoint is accessible"
else
    echo "⚠️  Microsoft Docs MCP server endpoint check failed (this is expected for HTTP GET requests)"
    echo "   The endpoint is designed for programmatic MCP access, not direct browser access"
fi

# Check if GitHub Copilot is configured (this would be done in VS Code interface)
echo "📝 MCP Integration Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Open VS Code and ensure GitHub Copilot is enabled"
echo "2. Switch to Agent mode in GitHub Copilot"
echo "3. The Microsoft Docs MCP server should be available as a tool"
echo "4. Test with a query like: 'What are the az cli commands to create an Azure container app according to official Microsoft Learn documentation?'"
echo ""
echo "📚 For more information, visit: https://github.com/MicrosoftDocs/mcp"