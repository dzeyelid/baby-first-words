#!/bin/bash

# Install Bicep extension for Azure CLI
echo "Installing Bicep extension for Azure CLI..."
az extension add --name bicep

# Install Bicep CLI if not present
if ! command -v bicep &> /dev/null; then
    echo "Installing Bicep CLI via az bicep..."
    az bicep install
else
    echo "Bicep CLI is already installed."
fi

# Ensure ~/.azure/bin is in PATH after Bicep CLI install
if [[ ":$PATH:" != *":$HOME/.azure/bin:"* ]]; then
    echo "export PATH=\"$HOME/.azure/bin:$PATH\"" >> "$HOME/.bashrc"
    export PATH="$HOME/.azure/bin:$PATH"
    echo "Added ~/.azure/bin to PATH in ~/.bashrc"
fi

# Setup Microsoft Docs MCP Server integration
echo "Setting up Microsoft Docs MCP Server integration..."
./.devcontainer/setup-mcp.sh

echo "Setup completed successfully!"