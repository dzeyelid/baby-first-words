# Baby First Words - Azure Static Web Apps (Nuxt 4)

Azure Static Web Apps を使用したNuxt 4アプリケーションです。サーバーAPIルートを使用してフロントエンドとバックエンドが統合されています。

## 🚀 クイックスタート

### ローカル開発

```bash
# 依存関係のインストール
npm install

# 開発サーバー起動 (http://localhost:3000)
npm run dev

# Static Web Apps CLI による開発（推奨）
npx @azure/static-web-apps-cli start
```

### ビルド

```bash
# アプリケーションのビルド
npm run build

# プレビューモード
npm run preview
```

## 📁 ディレクトリ構造

```
src/web/
├── app.vue                 # ルートアプリケーション
├── pages/                  # ページコンポーネント（ファイルベースルーティング）
│   ├── index.vue           # ホームページ (/)
│   ├── api-demo.vue        # API連携デモ (/api-demo)
│   └── first-words.vue     # はじめての言葉 (/first-words)
├── server/                 # Nuxt サーバーAPI
│   └── api/               # APIルート
│       └── health.get.ts   # ヘルスチェックAPI
├── services/               # サービスクラス
│   └── cosmosdb.ts        # Cosmos DB サービス
├── public/                 # 静的アセット
├── nuxt.config.ts          # Nuxt 4 設定
├── staticwebapp.config.json # Static Web Apps 設定
├── swa-cli.config.json     # SWA CLI 設定
└── local.settings.json.template # 環境変数テンプレート
```

## 🔧 技術スタック

- **フロントエンド**: Nuxt 4.0.1, Vue.js 3, TypeScript
- **スタイリング**: Tailwind CSS
- **バックエンド**: Nuxt サーバーAPI（Node.js 20）
- **データベース**: Azure Cosmos DB (NoSQL)
- **デプロイ**: Azure Static Web Apps
- **ビルドツール**: Nitro（Azure preset）

## 🌐 デプロイ

### GitHub Actions (自動)

1. `main` ブランチにプッシュ
2. GitHub Actions が自動実行
3. Azure Static Web Apps にデプロイ

### Azure Developer CLI (手動)

```bash
# プロジェクトルートから実行
azd up
```

## 📚 ページ説明

### ホームページ (`/`)
- プロジェクトの概要
- 機能紹介
- ナビゲーション

### API連携デモ (`/api-demo`)
- ヘルスチェックAPI（Nuxt サーバーAPI）呼び出し
- レスポンス表示
- エラーハンドリング例
- データベース接続状況の確認

### はじめての言葉 (`/first-words`)
- 赤ちゃんの言葉記録フォーム
- サンプルデータ表示
- ローカルストレージ保存

## 🔌 API エンドポイント

### `GET /api/health`
アプリケーションのヘルスチェック

**レスポンス例:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "service": "baby-first-words-api",
  "version": "1.0.0",
  "environment": "development",
  "checks": {
    "database": {
      "status": "warning",
      "message": "Cosmos DB connection string not configured"
    },
    "memory": {
      "used": 25165824,
      "total": 33554432,
      "percentage": 75
    },
    "uptime": 123.456
  }
}
```

## 📝 設定

### 環境変数

API関連の環境変数は Azure Static Web Apps の設定画面で管理:

- `COSMOS_DB_CONNECTION_STRING`: Cosmos DB接続文字列
- `COSMOS_DB_DATABASE_NAME`: データベース名 (デフォルト: baby-first-words)
- `COSMOS_DB_CONTAINER_NAME`: コンテナ名 (デフォルト: words)

### ローカル開発設定

`local.settings.json.template` をコピーして `local.settings.json` を作成:

```bash
cp local.settings.json.template local.settings.json
```

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "COSMOS_DB_CONNECTION_STRING": "your_cosmos_db_connection_string_here",
    "COSMOS_DB_DATABASE_NAME": "baby-first-words",
    "COSMOS_DB_CONTAINER_NAME": "words"
  }
}
```
