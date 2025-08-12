import { getCosmosDbService } from '~/services/cosmosdb';

export default defineEventHandler(async (event) => {
  // Health check logic
  const healthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'baby-first-words-api',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  };

  try {
    // Basic health checks
    const checks = {
      database: await checkDatabaseConnection(),
      memory: checkMemoryUsage(),
      uptime: process.uptime()
    };

    // Set response headers
    setHeaders(event, {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache'
    });

    return {
      ...healthStatus,
      checks
    };
  } catch (error) {
    console.error('Health check failed:', error);
    
    // Set error status and headers
    setResponseStatus(event, 503);
    setHeaders(event, {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache'
    });

    return {
      ...healthStatus,
      status: 'unhealthy',
      error: error instanceof Error ? error.message : 'Unknown error'
    };
  }
});

async function checkDatabaseConnection(): Promise<{ status: string; message: string }> {
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

function checkMemoryUsage(): { used: number; total: number; percentage: number } {
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
