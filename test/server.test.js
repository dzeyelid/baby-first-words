import { test } from 'node:test';
import assert from 'node:assert';
import { spawn } from 'child_process';
import { readFile, writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import path from 'path';

test('MCP server can list tools', async (t) => {
  const server = spawn('node', ['src/index.js'], {
    stdio: ['pipe', 'pipe', 'pipe'],
  });

  // Send a list tools request
  const request = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/list',
    params: {},
  };

  server.stdin.write(JSON.stringify(request) + '\n');
  server.stdin.end();

  let output = '';
  server.stdout.on('data', (data) => {
    output += data.toString();
  });

  return new Promise((resolve, reject) => {
    server.on('close', (code) => {
      try {
        // Parse the response - skip stderr output from console.error
        const lines = output.trim().split('\n');
        const jsonLines = lines.filter(line => {
          const trimmed = line.trim();
          return trimmed.startsWith('{') && trimmed.includes('"jsonrpc"');
        });
        
        if (jsonLines.length === 0) {
          reject(new Error('No JSON-RPC responses found in output: ' + output));
          return;
        }
        
        const responses = jsonLines.map(line => JSON.parse(line));
        
        // Find the tools/list response
        const toolsResponse = responses.find(r => r.id === 1);
        
        assert(toolsResponse, 'Should receive a response for tools/list');
        assert(toolsResponse.result, 'Response should have a result');
        assert(Array.isArray(toolsResponse.result.tools), 'Should return an array of tools');
        assert(toolsResponse.result.tools.length > 0, 'Should have at least one tool');
        
        // Check that expected tools are present
        const toolNames = toolsResponse.result.tools.map(tool => tool.name);
        assert(toolNames.includes('record_first_word'), 'Should include record_first_word tool');
        assert(toolNames.includes('list_recorded_words'), 'Should include list_recorded_words tool');
        
        resolve();
      } catch (error) {
        reject(error);
      }
    });

    server.on('error', reject);
  });
});

test('Can record and list first words', async (t) => {
  // Clean up any existing data
  const dataDir = path.join(process.cwd(), 'data');
  const dataPath = path.join(dataDir, 'first-words.json');
  
  if (existsSync(dataPath)) {
    await writeFile(dataPath, JSON.stringify({ words: [] }, null, 2));
  }

  // Test recording a first word
  const { stdout: recordOutput } = await new Promise((resolve, reject) => {
    const server = spawn('node', ['src/index.js'], {
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    const recordRequest = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/call',
      params: {
        name: 'record_first_word',
        arguments: {
          word: 'mama',
          timestamp: '2024-01-01T10:00:00Z',
          context: 'During breakfast',
          babyName: 'Test Baby',
        },
      },
    };

    server.stdin.write(JSON.stringify(recordRequest) + '\n');
    server.stdin.end();

    let output = '';
    server.stdout.on('data', (data) => {
      output += data.toString();
    });

    server.on('close', (code) => {
      resolve({ stdout: output });
    });

    server.on('error', reject);
  });

  // Test listing recorded words
  const { stdout: listOutput } = await new Promise((resolve, reject) => {
    const server = spawn('node', ['src/index.js'], {
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    const listRequest = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/call',
      params: {
        name: 'list_recorded_words',
        arguments: {},
      },
    };

    server.stdin.write(JSON.stringify(listRequest) + '\n');
    server.stdin.end();

    let output = '';
    server.stdout.on('data', (data) => {
      output += data.toString();
    });

    server.on('close', (code) => {
      resolve({ stdout: output });
    });

    server.on('error', reject);
  });

  // Parse responses
  const recordLines = recordOutput.trim().split('\n');
  const recordJsonLines = recordLines.filter(line => {
    const trimmed = line.trim();
    return trimmed.startsWith('{') && trimmed.includes('"jsonrpc"');
  });
  
  const listLines = listOutput.trim().split('\n');
  const listJsonLines = listLines.filter(line => {
    const trimmed = line.trim();
    return trimmed.startsWith('{') && trimmed.includes('"jsonrpc"');
  });

  assert(recordJsonLines.length > 0, 'Should receive a response for record_first_word');
  assert(listJsonLines.length > 0, 'Should receive a response for list_recorded_words');

  const recordResponse = JSON.parse(recordJsonLines[0]);
  const listResponse = JSON.parse(listJsonLines[0]);

  assert(recordResponse.result, 'Record response should have a result');
  assert(recordResponse.result.content[0].text.includes('Successfully recorded'), 'Should confirm successful recording');

  assert(listResponse.result, 'List response should have a result');
  assert(listResponse.result.content[0].text.includes('mama'), 'Should list the recorded word');
});