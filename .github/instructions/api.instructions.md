---
applyTo:
  - src/api/**
---

# Azure Functions API コーディング規約

このファイルは `src/api` ディレクトリ配下のAzure Functions APIコードに適用される開発ガイドラインです。

## TypeScript コーディング規約

### 型の扱い
- Always use explicit type annotations for function parameters and return values
- Use TypeScript's `strict` mode features (enabled in tsconfig.json)
- Prefer `interface` over `type` for object type definitions when possible
- Use generic types (`<T>`) for reusable service methods that handle different data types

### エラーハンドリング
- Always wrap external service calls (database, HTTP requests) in try-catch blocks
- Log errors using `context.log()` (for function handlers) or `console.error()` (for service classes)
  - Azure Functions: Use `context.log()` in function handlers to integrate with Application Insights
  - Service classes: Use `console.error()` for consistency with shared code patterns
- Use descriptive error messages that include context about what operation failed
- Rethrow errors after logging when the error should propagate to the caller

### 非同期処理
- Use `async/await` syntax for all asynchronous operations
- Always return `Promise<T>` types explicitly for async functions
- Avoid callback-based patterns in favor of Promise-based APIs

## Azure Functions 固有の規約

### ロギング戦略
- **Function handlers**: Use `context.log()`, `context.error()`, `context.warn()` for logging
  - Integrates with Application Insights for function-specific telemetry
  - Associates logs with specific function invocations
- **Service classes** (e.g., CosmosDbService): Use `console.error()`, `console.log()`
  - Maintains consistency with shared code patterns between api and web modules
  - Automatically collected by Application Insights at app-level

### 関数構成
- Each function should have a single responsibility
- Use the `@azure/functions` v4 programming model
- Set appropriate `authLevel` based on security requirements (prefer 'function' or higher for production)
- Use descriptive function names that reflect the HTTP route or operation

### リクエスト/レスポンス処理
- Always validate environment variables at function startup
- Set appropriate HTTP response headers (Content-Type, Cache-Control)
- Return consistent response structures with status, data, and error fields
- Use proper HTTP status codes (200 for success, 4xx for client errors, 5xx for server errors)

## データベース（Cosmos DB）の扱い

### 接続管理
- Use singleton pattern for database service instances to reuse connections
- Initialize database connections lazily (on first use) not eagerly (at startup)
- Store connection strings in environment variables, never hardcode them
- Validate required environment variables and throw clear errors if missing

### CRUD操作
- Use consistent method naming: `createItem`, `getItem`, `queryItems`, `updateItem`, `deleteItem`
- Always include proper error handling for all database operations
- Use partition keys appropriately for optimal Cosmos DB performance
- Return typed results using TypeScript generics (`async createItem<T>(item: T): Promise<T>`)

### エラーハンドリング
- Log database errors with `console.error()` before throwing or returning error responses
- Distinguish between connection errors and data operation errors in error messages
- For connection test methods, return boolean or status object rather than throwing

## セキュリティ

### 入力検証
- Validate all user input before processing
- Sanitize input data to prevent injection attacks
- Use environment variables for sensitive configuration (connection strings, API keys)

### 機密情報の扱い
- Never log sensitive data (passwords, tokens, connection strings)
- Use Azure Key Vault for production secrets management
- Ensure connection strings and credentials are stored as environment variables

## パフォーマンス

### リソース効率
- Reuse database client instances across function invocations (singleton pattern)
- Use appropriate query patterns (avoid SELECT * when specific fields are needed)
- Implement caching where appropriate for frequently accessed read-only data

## テスト

### テスタビリティ
- Design functions to be testable with dependency injection patterns
- Separate business logic from Azure Functions-specific code when possible
- Mock external dependencies (database, HTTP clients) in unit tests

## コード品質

### 命名規則
- Use camelCase for variables and functions
- Use PascalCase for classes and interfaces
- Use UPPER_CASE for constants
- Use descriptive names that reflect the purpose of the code

### コメント
- Write comments in English for code-level documentation
- Document complex business logic with inline comments
- Add JSDoc comments for public APIs and exported functions
- Keep comments concise and focused on "why" rather than "what"

### ファイル構成
- Organize code into logical directories: `functions/` for HTTP handlers, `services/` for business logic
- Keep function handlers thin - delegate business logic to service classes
- One function per file in the `functions/` directory
