# Baby First Words - Azure Static Web Apps (Nuxt 4)

Azure Static Web Apps を使用したNuxt 4アプリケーションです。サーバーAPIルートを使用してフロントエンドとバックエンドが統合されています。

## 🚀 クイックスタート

### ローカル開発

```bash
# 依存関係のインストール
npm install
```

以下のいずれかの方法で起動します。

- Nuxtのみ（最速）

```bash
# 開発サーバー起動（http://localhost:3000）
npm run dev
```

- SWA CLI 経由（127.0.0.1:4280 にプロキシ）

```bash
# 1) SWA の dev プロファイルでビルド（必要に応じて）
swa build preview

# 2) SWA の dev プロファイルで起動（http://127.0.0.1:4280）
swa start preview
```

備考:
- SWA 経由のURLは http://127.0.0.1:4280（または http://localhost:4280）。

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
## 🧪 VS Codeでの起動/デバッグ

このリポジトリには VS Code のデバッグ構成（`.vscode/launch.json`）とタスク（`.vscode/tasks.json`）が用意されています。以下の手順でフロント/バックエンドのブレークポイントデバッグが可能です。

### 前提
- Node.js 20（`package.json#engines`）
- Google Chrome（VS Code の内蔵 JavaScript Debugger が利用）
- Azure Static Web Apps CLI（グローバルにインストール済み推奨）
  - インストール済みの確認: `swa --version`

### よく使う起動構成

- Nuxt: Dev (Server + Auto Chrome)
  - Nuxt の開発サーバー（http://localhost:3000）を起動し、Chrome が自動でデバッグ接続します。
  - クライアント（`pages/*.vue`）とサーバーAPI（`server/api/*.ts`）にブレークポイントを設定できます。

- SWA: Debug (Nuxt + SWA)
  - 複合構成で「Nuxt: Dev (Server only)」→「SWA: Dev (CLI + Auto Chrome)」の順に起動します。
  - SWA 経由のURLは http://127.0.0.1:4280 です（localhost でも可）。
  - SWA は `swa-cli.config.json` の `debug` 構成を使用し、Nuxt dev（http://localhost:3000）へプロキシします。

### 起動手順（おすすめ）
1. VS Code 左側の「実行とデバッグ」を開く
2. ドロップダウンから「SWA: Debug (Nuxt + SWA)」を選択して開始
3. ブラウザ（Chrome）が自動で開きます（http://127.0.0.1:4280）
4. 以下の場所にブレークポイントを設定して動作確認
   - クライアント: `pages/first-words.vue` など
   - サーバー: `server/api/health.get.ts` など

### よくあるハマりどころと対処

- 自動起動時にダイアログ「Format uri must contain exactly one substitution placeholder」
  - `launch.json` の `serverReadyAction.uriFormat` は必ず `%s` を指定してください。
  - `serverReadyAction.pattern` は URL 全体を 1 グループでキャプチャする正規表現にしてください。

  - 開発時は `staticwebapp.config.json` のルート書き換えを無効化してあります（本番SSR向けの設定は不要なため）。
  - それでも崩れる場合はブラウザキャッシュクリア、`nuxt.config.ts` の設定確認を行ってください。

- SWA 経由で `/api` が 404
  - まずは http://127.0.0.1:4280/api/health を直接開いて確認。
  - `swa-cli.config.json` の `debug` 構成で
    - `appDevserverUrl`: `http://localhost:3000`
    - `apiDevserverUrl`: `http://localhost:3000`
    を指定しています。Nuxt 側で `/api/*` を扱うため、これで問題なくプロキシされます。

### 補足
- 長時間動作する `npm run dev` は `preLaunchTask` ではなく「複合構成」で並行起動しています。
- SWA を使わず最速で動かしたい場合は「Nuxt: Dev (Server + Auto Chrome)」だけでも開発可能です（http://localhost:3000）。

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
