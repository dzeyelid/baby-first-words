import { CosmosClient, Database, Container } from '@azure/cosmos';

export class CosmosDbService {
    private client: CosmosClient;
    private database: Database;
    private container: Container;

    constructor() {
        const connectionString = process.env.COSMOS_DB_CONNECTION_STRING;
        const databaseName = process.env.COSMOS_DB_DATABASE_NAME || 'baby-first-words';
        const containerName = process.env.COSMOS_DB_CONTAINER_NAME || 'words';

        if (!connectionString) {
            throw new Error('COSMOS_DB_CONNECTION_STRING environment variable is not set');
        }

        this.client = new CosmosClient(connectionString);
        this.database = this.client.database(databaseName);
        this.container = this.database.container(containerName);
    }

    async testConnection(): Promise<boolean> {
        try {
            await this.database.read();
            return true;
        } catch (error) {
            console.error('Failed to connect to Cosmos DB:', error);
            return false;
        }
    }

    async createItem<T>(item: T): Promise<T> {
        try {
            const { resource } = await this.container.items.create(item);
            return resource as T;
        } catch (error) {
            console.error('Failed to create item:', error);
            throw error;
        }
    }

    async getItem<T>(id: string, partitionKey: string): Promise<T | undefined> {
        try {
            const { resource } = await this.container.item(id, partitionKey).read();
            return resource as T;
        } catch (error) {
            console.error('Failed to get item:', error);
            throw error;
        }
    }

    async queryItems<T>(query: string): Promise<T[]> {
        try {
            const { resources } = await this.container.items
                .query(query)
                .fetchAll();
            return resources as T[];
        } catch (error) {
            console.error('Failed to query items:', error);
            throw error;
        }
    }

    async updateItem<T>(id: string, partitionKey: string, item: T): Promise<T> {
        try {
            const { resource } = await this.container.item(id, partitionKey).replace(item);
            return resource as T;
        } catch (error) {
            console.error('Failed to update item:', error);
            throw error;
        }
    }

    async deleteItem(id: string, partitionKey: string): Promise<void> {
        try {
            await this.container.item(id, partitionKey).delete();
        } catch (error) {
            console.error('Failed to delete item:', error);
            throw error;
        }
    }
}

// Singleton instance for reuse across functions
let cosmosDbService: CosmosDbService | null = null;

export function getCosmosDbService(): CosmosDbService {
    if (!cosmosDbService) {
        cosmosDbService = new CosmosDbService();
    }
    return cosmosDbService;
}