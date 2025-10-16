import { getCosmosDbService } from '../services/cosmosdb';

export interface DatabaseHealthCheck {
  status: string;
  message: string;
}

export interface MemoryUsage {
  used: number;
  total: number;
  percentage: number;
}

export async function checkDatabaseConnection(): Promise<DatabaseHealthCheck> {
  // Check for Cosmos DB connection
  const connectionString = process.env.COSMOS_DB_CONNECTION_STRING;
  
  if (!connectionString) {
    return {
      status: 'warning',
      message: 'Cosmos DB connection string not configured'
    };
  }

  try {
    const cosmosService = getCosmosDbService();
    const isConnected = await cosmosService.testConnection();
    
    if (isConnected) {
      return {
        status: 'healthy',
        message: 'Database connection is ready'
      };
    } else {
      return {
        status: 'unhealthy',
        message: 'Database connection failed'
      };
    }
  } catch (error) {
    return {
      status: 'unhealthy',
      message: `Database connection error: ${error instanceof Error ? error.message : 'Unknown error'}`
    };
  }
}

export function checkMemoryUsage(): MemoryUsage {
  const memoryUsage = process.memoryUsage();
  const totalMemory = memoryUsage.heapTotal;
  const usedMemory = memoryUsage.heapUsed;
  const percentage = Math.round((usedMemory / totalMemory) * 100);
  
  return {
    used: usedMemory,
    total: totalMemory,
    percentage
  };
}
