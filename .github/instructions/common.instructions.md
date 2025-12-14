---
applyTo:
  - src/api/**
  - src/web/**
---

# 共通コーディング規約

このファイルは `src/api` と `src/web` の両方に適用される共通の開発ガイドラインです。

## TypeScript コーディング規約

### 型の扱い
- Always use explicit type annotations for function parameters and return values
- Use TypeScript's strict mode features
- Prefer `interface` over `type` for object type definitions when possible
- Use generic types (`<T>`) for reusable service methods that handle different data types

### エラーハンドリング
- Always wrap external service calls (database, HTTP requests) in try-catch blocks
- Use descriptive error messages that include context about what operation failed
- Rethrow errors after logging when the error should propagate to the caller

### 非同期処理
- Use `async/await` syntax for all asynchronous operations
- Always return `Promise<T>` types explicitly for async functions
- Avoid callback-based patterns in favor of Promise-based APIs

## データベース（Cosmos DB）の扱い

### 接続管理
- Use singleton pattern for database service instances to reuse connections
  - Cosmos DB SDK handles connection pooling and thread safety internally
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
- Use Azure Key Vault or environment variables for production secrets
- Ensure connection strings and credentials are stored as environment variables

## パフォーマンス

### リソース効率
- Reuse database client instances (singleton pattern)
- Use appropriate query patterns (avoid SELECT * when specific fields are needed)
- Implement caching where appropriate for frequently accessed read-only data

## テスト

### テスタビリティ
- Design code to be testable with dependency injection patterns
- Separate business logic from framework-specific code when possible
- Mock external dependencies (database, HTTP clients) in tests

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
- Keep handlers thin - delegate business logic to service classes
- Place shared service classes in `services/` directory
