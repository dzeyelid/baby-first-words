---
applyTo:
  - src/web/**
---

# Nuxt 4 / Vue 3 Webアプリケーション コーディング規約

このファイルは `src/web` ディレクトリ配下のNuxt 4 / Vue 3 Webアプリケーションコードに適用される開発ガイドラインです。

## TypeScript コーディング規約

### 型の扱い
- Always use explicit type annotations for function parameters and return values
- Use TypeScript's strict mode features (auto-configured by Nuxt)
- Prefer `interface` over `type` for object type definitions when possible
- Use generic types (`<T>`) for reusable service methods that handle different data types

### エラーハンドリング
- Always wrap external service calls (database, HTTP requests) in try-catch blocks
- Log errors using `console.error()` with descriptive messages
- Use descriptive error messages that include context about what operation failed
- Rethrow errors after logging when the error should propagate to the caller

### 非同期処理
- Use `async/await` syntax for all asynchronous operations
- Always return `Promise<T>` types explicitly for async functions
- Avoid callback-based patterns in favor of Promise-based APIs

## Nuxt 4 / Vue 3 固有の規約

### コンポーネント
- Use Composition API (`<script setup>`) for all Vue components
- Use auto-imports for Nuxt composables (useState, useFetch, navigateTo, etc.)
- Keep components focused and single-purpose
- Use TypeScript with proper typing for props and emits

### ルーティング
- Use file-based routing in `pages/` directory
- Implement dynamic routes using `[id].vue` naming convention
- Use `definePageMeta()` for page-level configuration (middleware, layout)

### サーバーAPI
- Place server API routes in `server/api/` directory
- Use `defineEventHandler()` for all API route handlers
- Set response headers using `setHeaders()` and status codes using `setResponseStatus()`
- Return consistent response structures across all endpoints

### スタイリング
- Use Tailwind CSS utility classes for styling (configured in project)
- Follow mobile-first responsive design approach
- Use Nuxt's `assets/` directory for global CSS and resources

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

### サービス配置
- Place shared service classes (like CosmosDbService) in `services/` directory
- Import services using Nuxt's auto-import or explicit imports with `~/services/`
- Reuse service instances across server API routes (singleton pattern)

## API エンドポイント設計

### エンドポイント構成
- Use RESTful conventions for API routes (GET for read, POST for create, PUT/PATCH for update, DELETE for delete)
- Place API handlers in `server/api/` directory with descriptive names
- Use `.get.ts`, `.post.ts`, etc. suffixes for HTTP method-specific handlers
- Return JSON responses with appropriate content-type headers

### レスポンス形式
- Use consistent response structures across all endpoints
- Include appropriate metadata (timestamp, version, status)
- Set proper HTTP status codes (200 for success, 4xx for client errors, 5xx for server errors)
- Set Cache-Control headers appropriately based on endpoint purpose

### ヘルスチェック
- Implement health check endpoints at `/api/health`
- Include checks for critical dependencies (database, external services)
- Return detailed status information including uptime, memory, and dependency status

## セキュリティ

### 入力検証
- Validate all user input before processing
- Sanitize input data to prevent injection attacks
- Use environment variables for sensitive configuration (connection strings, API keys)

### 機密情報の扱い
- Never log sensitive data (passwords, tokens, connection strings)
- Use Azure Key Vault or environment variables for production secrets
- Ensure connection strings and credentials are stored as environment variables
- Never commit `local.settings.json` with real credentials to version control

### CSP とセキュリティヘッダー
- Configure security headers in `nuxt.config.ts` or `staticwebapp.config.json`
- Implement appropriate Content Security Policy headers
- Use HTTPS in production environments

## パフォーマンス

### リソース効率
- Reuse database client instances across server route invocations (singleton pattern)
- Use appropriate query patterns (avoid SELECT * when specific fields are needed)
- Implement caching strategies using `useFetch` with proper cache keys
- Optimize component rendering with proper key usage in v-for loops

### バンドル最適化
- Use code splitting with dynamic imports for large components
- Lazy load routes that are not immediately needed
- Optimize asset sizes (images, fonts) before including in project

## テスト

### テスタビリティ
- Design components and composables to be testable
- Separate business logic from UI components when possible
- Mock external dependencies (database, API calls) in tests

## コード品質

### 命名規則
- Use camelCase for variables, functions, and composables
- Use PascalCase for component names and classes
- Use kebab-case for file names (except components which use PascalCase)
- Use UPPER_CASE for constants
- Use descriptive names that reflect the purpose of the code

### コメント
- Write comments in English for code-level documentation
- Document complex business logic with inline comments
- Add JSDoc comments for public APIs and exported functions
- Keep comments concise and focused on "why" rather than "what"

### ファイル構成
- Organize code into logical directories: `pages/` for routes, `components/` for reusable UI, `composables/` for shared logic, `services/` for business logic
- Keep server API handlers thin - delegate business logic to service classes
- Place reusable types in `types/` directory or co-locate with relevant files

## Azure Static Web Apps 固有の規約

### 設定ファイル
- Configure routes and security in `staticwebapp.config.json`
- Set appropriate response headers and redirects
- Define route permissions when authentication is implemented

### デプロイ
- Use GitHub Actions workflow for CI/CD (pre-configured in repository)
- Test builds locally using `npm run build` before pushing
- Use `@azure/static-web-apps-cli` for local testing with API integration
