#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { exec } from 'child_process';
import { promisify } from 'util';
import { readFile, writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import path from 'path';

const execAsync = promisify(exec);

class BabyFirstWordsMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'baby-first-words-mcp-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
          resources: {},
        },
      }
    );

    this.setupToolHandlers();
    this.setupResourceHandlers();
  }

  setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'record_first_word',
            description: 'Record a baby\'s first word with timestamp and context',
            inputSchema: {
              type: 'object',
              properties: {
                word: {
                  type: 'string',
                  description: 'The first word spoken by the baby',
                },
                timestamp: {
                  type: 'string',
                  description: 'When the word was spoken (ISO 8601 format)',
                },
                context: {
                  type: 'string',
                  description: 'Additional context about when/where the word was spoken',
                },
                babyName: {
                  type: 'string',
                  description: 'Name of the baby',
                },
              },
              required: ['word', 'timestamp', 'babyName'],
            },
          },
          {
            name: 'list_recorded_words',
            description: 'List all recorded first words',
            inputSchema: {
              type: 'object',
              properties: {
                babyName: {
                  type: 'string',
                  description: 'Filter by baby name (optional)',
                },
              },
            },
          },
          {
            name: 'azure_resource_status',
            description: 'Check the status of Azure resources for the baby-first-words project',
            inputSchema: {
              type: 'object',
              properties: {
                resourceType: {
                  type: 'string',
                  enum: ['storage', 'resource-group', 'all'],
                  description: 'Type of resource to check',
                },
              },
              required: ['resourceType'],
            },
          },
          {
            name: 'validate_environment',
            description: 'Validate the Azure development environment setup',
            inputSchema: {
              type: 'object',
              properties: {},
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'record_first_word':
            return await this.recordFirstWord(args);
          case 'list_recorded_words':
            return await this.listRecordedWords(args);
          case 'azure_resource_status':
            return await this.checkAzureResourceStatus(args);
          case 'validate_environment':
            return await this.validateEnvironment();
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error.message}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  setupResourceHandlers() {
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      return {
        resources: [
          {
            uri: 'file://data/first-words.json',
            mimeType: 'application/json',
            name: 'First Words Database',
            description: 'JSON file containing recorded first words',
          },
          {
            uri: 'file://infra/main.bicep',
            mimeType: 'text/plain',
            name: 'Main Bicep Template',
            description: 'Main infrastructure template',
          },
        ],
      };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const { uri } = request.params;
      
      if (uri === 'file://data/first-words.json') {
        const dataPath = path.join(process.cwd(), 'data', 'first-words.json');
        try {
          const data = await readFile(dataPath, 'utf8');
          return {
            contents: [
              {
                uri,
                mimeType: 'application/json',
                text: data,
              },
            ],
          };
        } catch (error) {
          return {
            contents: [
              {
                uri,
                mimeType: 'application/json',
                text: JSON.stringify({ words: [] }, null, 2),
              },
            ],
          };
        }
      }
      
      if (uri === 'file://infra/main.bicep') {
        const bicepPath = path.join(process.cwd(), 'infra', 'main.bicep');
        try {
          const data = await readFile(bicepPath, 'utf8');
          return {
            contents: [
              {
                uri,
                mimeType: 'text/plain',
                text: data,
              },
            ],
          };
        } catch (error) {
          throw new Error(`Could not read file: ${error.message}`);
        }
      }
      
      throw new Error(`Unknown resource: ${uri}`);
    });
  }

  async recordFirstWord(args) {
    const { word, timestamp, context, babyName } = args;
    
    // Ensure data directory exists
    const dataDir = path.join(process.cwd(), 'data');
    if (!existsSync(dataDir)) {
      await mkdir(dataDir, { recursive: true });
    }
    
    const dataPath = path.join(dataDir, 'first-words.json');
    
    // Read existing data or create new
    let data = { words: [] };
    try {
      const existingData = await readFile(dataPath, 'utf8');
      data = JSON.parse(existingData);
    } catch (error) {
      // File doesn't exist, use empty data
    }
    
    // Add new word record
    const newRecord = {
      id: Date.now().toString(),
      word,
      timestamp,
      context: context || '',
      babyName,
      recordedAt: new Date().toISOString(),
    };
    
    data.words.push(newRecord);
    
    // Save updated data
    await writeFile(dataPath, JSON.stringify(data, null, 2), 'utf8');
    
    return {
      content: [
        {
          type: 'text',
          text: `Successfully recorded first word "${word}" for ${babyName} at ${timestamp}`,
        },
      ],
    };
  }

  async listRecordedWords(args) {
    const { babyName } = args || {};
    
    const dataPath = path.join(process.cwd(), 'data', 'first-words.json');
    
    try {
      const data = await readFile(dataPath, 'utf8');
      const parsedData = JSON.parse(data);
      
      let words = parsedData.words || [];
      
      if (babyName) {
        words = words.filter(word => word.babyName === babyName);
      }
      
      if (words.length === 0) {
        return {
          content: [
            {
              type: 'text',
              text: babyName 
                ? `No recorded words found for ${babyName}`
                : 'No recorded words found',
            },
          ],
        };
      }
      
      const wordList = words.map(word => 
        `- ${word.word} (${word.babyName}) at ${word.timestamp}${word.context ? ` - ${word.context}` : ''}`
      ).join('\n');
      
      return {
        content: [
          {
            type: 'text',
            text: `Recorded first words:\n${wordList}`,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: 'No recorded words found (data file does not exist)',
          },
        ],
      };
    }
  }

  async checkAzureResourceStatus(args) {
    const { resourceType } = args;
    
    try {
      let command = '';
      let description = '';
      
      switch (resourceType) {
        case 'storage':
          command = 'az storage account list --resource-group rg-baby-first-words --query "[].{Name:name,Location:location,Status:statusOfPrimary}" --output table';
          description = 'Storage account status';
          break;
        case 'resource-group':
          command = 'az group show --name rg-baby-first-words --query "{Name:name,Location:location,State:properties.provisioningState}" --output table';
          description = 'Resource group status';
          break;
        case 'all':
          command = 'az resource list --resource-group rg-baby-first-words --query "[].{Name:name,Type:type,Location:location}" --output table';
          description = 'All resources status';
          break;
        default:
          throw new Error(`Unknown resource type: ${resourceType}`);
      }
      
      const { stdout, stderr } = await execAsync(command);
      
      if (stderr) {
        throw new Error(stderr);
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `${description}:\n\`\`\`\n${stdout}\n\`\`\``,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Error checking Azure resources: ${error.message}`,
          },
        ],
      };
    }
  }

  async validateEnvironment() {
    try {
      const { stdout, stderr } = await execAsync('./validate-environment.sh');
      
      return {
        content: [
          {
            type: 'text',
            text: `Environment validation result:\n\`\`\`\n${stdout}\n\`\`\`${stderr ? `\n\nErrors:\n\`\`\`\n${stderr}\n\`\`\`` : ''}`,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Environment validation failed: ${error.message}`,
          },
        ],
      };
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Baby First Words MCP Server running on stdio');
  }
}

// Start the server
const server = new BabyFirstWordsMCPServer();
server.run().catch(console.error);