# Baby First Words - Shared Library

This package contains shared utilities and services used by both the API (Azure Functions) and Web (Nuxt) applications.

## Purpose

This library was created to eliminate code duplication between the API and Web projects by consolidating common functionality into a single, reusable package.

## Contents

### Services

- **CosmosDbService**: Service for interacting with Azure Cosmos DB
  - Connection management
  - CRUD operations (create, read, update, delete)
  - Query functionality
  - Singleton pattern for connection reuse

### Utilities

- **Health Check Utilities**: Common health check functions
  - `checkDatabaseConnection()`: Verifies Cosmos DB connectivity
  - `checkMemoryUsage()`: Reports process memory usage

## Usage

### In API Project (Azure Functions)

```typescript
import { getCosmosDbService, checkDatabaseConnection, checkMemoryUsage } from 'baby-first-words-shared';

// Use Cosmos DB service
const cosmosService = getCosmosDbService();
await cosmosService.testConnection();

// Use health check utilities
const dbHealth = await checkDatabaseConnection();
const memory = checkMemoryUsage();
```

### In Web Project (Nuxt)

```typescript
import { getCosmosDbService, checkDatabaseConnection, checkMemoryUsage } from 'baby-first-words-shared';

// Same usage as API project
const cosmosService = getCosmosDbService();
const dbHealth = await checkDatabaseConnection();
```

## Development

### Building

```bash
npm install
npm run build
```

### Watch Mode

```bash
npm run watch
```

## Environment Variables

The following environment variables are required:

- `COSMOS_DB_CONNECTION_STRING`: Connection string for Azure Cosmos DB
- `COSMOS_DB_DATABASE_NAME`: Database name (optional, defaults to 'baby-first-words')
- `COSMOS_DB_CONTAINER_NAME`: Container name (optional, defaults to 'words')
