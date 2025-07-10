# Baby First Words API

Azure Functions TypeScript API for the Baby First Words application.

## 概要

このプロジェクトは、赤ちゃんの初めての言葉を記録するアプリケーションのバックエンドAPIです。Azure Functions v4 TypeScriptプログラミングモデルを使用しています。

## 主な機能

- ヘルスチェックAPI エンドポイント
- Cosmos DB接続とデータアクセス
- TypeScriptサポート
- Azure Functions v4プログラミングモデル

## セットアップ

### 前提条件

- Node.js 18以上
- Azure Functions Core Tools v4
- Azure サブスクリプション

### ローカル開発環境の構築

1. 依存関係のインストール:
```bash
npm install
```

2. TypeScriptのビルド:
```bash
npm run build
```

3. ローカル環境設定:
`local.settings.json`を編集して、必要な環境変数を設定してください。

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "COSMOS_DB_CONNECTION_STRING": "your_cosmos_db_connection_string",
    "COSMOS_DB_DATABASE_NAME": "baby-first-words",
    "COSMOS_DB_CONTAINER_NAME": "words"
  }
}
```

4. 関数アプリの起動:
```bash
npm start
```

## API エンドポイント

### GET /api/health

ヘルスチェックエンドポイント。アプリケーションとデータベースの状態を確認します。

**レスポンス例:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "baby-first-words-api",
  "version": "1.0.0",
  "environment": "development",
  "checks": {
    "database": {
      "status": "healthy",
      "message": "Database connection is ready"
    },
    "memory": {
      "used": 12345678,
      "total": 23456789,
      "percentage": 52
    },
    "uptime": 123.45
  }
}
```

## プロジェクト構造

```
src/
├── functions/          # Azure Functions
│   └── health.ts      # ヘルスチェック関数
├── services/          # サービスクラス
│   └── cosmosdb.ts    # Cosmos DB サービス
dist/                  # ビルド出力
host.json             # Azure Functions 設定
local.settings.json   # ローカル設定
package.json          # NPM パッケージ設定
tsconfig.json         # TypeScript 設定
```

## 技術スタック

- **Azure Functions v4**: サーバーレスコンピューティング
- **TypeScript**: 型安全性とコード品質
- **@azure/functions**: Azure Functions TypeScript SDK
- **@azure/cosmos**: Cosmos DB TypeScript SDK
- **Node.js 18+**: JavaScript ランタイム

## 開発コマンド

```bash
# 依存関係のインストール
npm install

# TypeScript ビルド
npm run build

# ウォッチモード（自動ビルド）
npm run watch

# 関数アプリの起動
npm start

# テスト実行
npm test
```

## デプロイメント

Azure Developer CLI (azd) を使用してデプロイします：

```bash
azd up
```

詳細は、プロジェクトルートの README.md を参照してください。