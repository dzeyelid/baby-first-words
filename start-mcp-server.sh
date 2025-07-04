#!/bin/bash

# MCP Server startup script for baby-first-words project

echo "🚀 Starting Baby First Words MCP Server..."

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18.0.0 or higher."
    exit 1
fi

# Check if npm dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing npm dependencies..."
    npm install
fi

# Start the MCP server
echo "🔧 Starting MCP server..."
node src/index.js