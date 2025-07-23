#!/bin/bash
set -euo pipefail

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

# Install Azure Functions Core Tools v4 (func) via apt (official recommended)
echo "Installing Azure Functions Core Tools v4 via apt..."
# Import Microsoft GPG key and add the package repository
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-functions.list'
# Update package list and install
sudo apt-get update
sudo apt-get install -y azure-functions-core-tools-4

echo "Azure Functions Core Tools installation complete!"

echo "Setup completed successfully!"