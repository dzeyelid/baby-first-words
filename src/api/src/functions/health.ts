import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
import { checkDatabaseConnection, checkMemoryUsage } from 'baby-first-words-shared';

export async function healthCheck(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log('HTTP trigger function processed a request.');
    context.log(`Http function processed request for url "${request.url}"`);

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

        return {
            status: 200,
            headers: {
                'Content-Type': 'application/json',
                'Cache-Control': 'no-cache'
            },
            body: JSON.stringify({
                ...healthStatus,
                checks
            })
        };
    } catch (error) {
        context.log('Health check failed:', error);
        
        return {
            status: 503,
            headers: {
                'Content-Type': 'application/json',
                'Cache-Control': 'no-cache'
            },
            body: JSON.stringify({
                ...healthStatus,
                status: 'unhealthy',
                error: error instanceof Error ? error.message : 'Unknown error'
            })
        };
    }
}

app.http('health', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: healthCheck
});