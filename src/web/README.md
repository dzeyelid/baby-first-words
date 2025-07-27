# Baby First Words - Azure Static Web Apps (Nuxt)

Azure Static Web Apps を使用したNuxt.jsアプリケーションです。

## 🚀 クイックスタート

### ローカル開発

```bash
# 依存関係のインストール
npm install

# 開発サーバー起動 (http://localhost:3000)
npm run dev

# APIサーバー起動 (別ターミナル)
cd api
npm install
npm run start
```

### ビルド

```bash
# フロントエンドのビルド
npm run build

# APIのビルド
cd api
npm run build
```

## 📁 ディレクトリ構造

```
src/web/
├── app/                    # Nuxt アプリケーション
│   └── app.vue            # ルートレイアウト
├── pages/                 # ページコンポーネント
│   ├── index.vue          # ホームページ (/)
│   ├── api-demo.vue       # API連携デモ (/api-demo)
│   └── first-words.vue    # はじめての言葉 (/first-words)
├── api/                   # Azure Functions API
│   ├── src/functions/     # 関数定義
│   └── src/services/      # サービスクラス
├── public/                # 静的アセット
├── nuxt.config.ts         # Nuxt 設定
└── staticwebapp.config.json # Static Web Apps 設定
```

## 🔧 技術スタック

- **フロントエンド**: Nuxt 3, Vue.js 3, TypeScript
- **スタイリング**: Tailwind CSS
- **バックエンド**: Azure Functions v4 (TypeScript)
- **デプロイ**: Azure Static Web Apps
- **ビルドツール**: Nitro (azure-functions preset)

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
- ヘルスチェックAPI呼び出し
- レスポンス表示
- エラーハンドリング例

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

### 開発用

ローカル開発時は `api/local.settings.json` を作成:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "COSMOS_DB_CONNECTION_STRING": "your-connection-string"
  }
}
```
