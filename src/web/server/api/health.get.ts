import { checkDatabaseConnection, checkMemoryUsage } from 'baby-first-words-shared';

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
