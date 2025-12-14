---
applyTo:
  - src/web/**
---

# Nuxt 4 / Vue 3 Webアプリケーション コーディング規約

このファイルは `src/web` ディレクトリ配下のNuxt 4 / Vue 3 Webアプリケーションコードに適用される開発ガイドラインです。

共通のコーディング規約については `.github/instructions/common.instructions.md` を参照してください。

## Nuxt 4 / Vue 3 固有の規約

### ロギング戦略
- **Server API routes and Service classes**: Use `console.log()`, `console.error()`, `console.warn()`
  - Standard Node.js logging for Azure Static Web Apps
  - Maintains consistency with shared service code patterns (e.g., CosmosDbService)
  - Can be integrated with Application Insights for monitoring (requires additional configuration)
  - Automatically collected at app-level for debugging

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

## データベース（Cosmos DB）の扱い（Nuxt 固有）

### 接続管理
- Nuxt server maintains warm instances in production environments, allowing connection reuse across requests

### サービス配置
- Import services using Nuxt's auto-import or explicit imports with `~/services/`

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

## セキュリティ（Nuxt 固有）

### 機密情報の扱い
- Never commit `local.settings.json` with real credentials to version control

### CSP とセキュリティヘッダー
- Configure security headers in `nuxt.config.ts` or `staticwebapp.config.json`
- Implement appropriate Content Security Policy headers
- Use HTTPS in production environments

## パフォーマンス（Nuxt 固有）

### リソース効率
- Implement caching strategies using `useFetch` with proper cache keys
- Optimize component rendering with proper key usage in v-for loops

### バンドル最適化
- Use code splitting with dynamic imports for large components
- Lazy load routes that are not immediately needed
- Optimize asset sizes (images, fonts) before including in project

## コード品質（Nuxt 固有）

### 命名規則
- Use kebab-case for file names (except components which use PascalCase)
- Use camelCase for composables

### ファイル構成
- Organize code into logical directories: `pages/` for routes, `components/` for reusable UI, `composables/` for shared logic, `services/` for business logic
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
