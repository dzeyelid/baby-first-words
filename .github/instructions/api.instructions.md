---
applyTo:
  - src/api/**
---

# Azure Functions API コーディング規約

このファイルは `src/api` ディレクトリ配下のAzure Functions APIコードに適用される開発ガイドラインです。

共通のコーディング規約については `.github/instructions/common.instructions.md` を参照してください。

## エラーハンドリング（Azure Functions 固有）

- Log errors using `context.log()` (for function handlers) or `console.error()` (for service classes)
  - Azure Functions: Use `context.log()` in function handlers to integrate with Application Insights
  - Service classes: Use `console.error()` for consistency with shared code patterns

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

## データベース（Cosmos DB）の扱い（Azure Functions 固有）

### 接続管理
- Azure Functions v4 maintains warm instances, allowing connection reuse across invocations

## ファイル構成（Azure Functions 固有）

- Organize code into logical directories: `src/functions/` for HTTP handlers, `src/services/` for business logic
- One function per file in the `src/functions/` directory
