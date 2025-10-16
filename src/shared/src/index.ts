// Export services
export { CosmosDbService, getCosmosDbService } from './services/cosmosdb';

// Export health utilities
export { 
  checkDatabaseConnection, 
  checkMemoryUsage,
  type DatabaseHealthCheck,
  type MemoryUsage
} from './utils/health';
