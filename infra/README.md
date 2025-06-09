# インフラストラクチャ

このディレクトリには、baby-first-wordsアプリケーションのインフラストラクチャをデプロイするためのAzure Bicepテンプレートが含まれています。

## アーキテクチャ

インフラストラクチャは3つの主要なAzureサービスで構成されています：

1. **Azure Cosmos DB** - 赤ちゃんの言葉データを保存するNoSQLデータベース
2. **Azure Functions** - TypeScriptベースのサーバーレスAPI
3. **Azure Static Web Apps** - CDNを備えたフロントエンドホスティング

## 作成されるリソース

### Azure Cosmos DB
- サーバーレス課金モデルのCosmos DBアカウント
- データベース: `BabyFirstWords`
- コンテナ: `Words`（パーティションキー `/wordId`）
- 単語クエリ用に最適化されたインデックスポリシー
- 30日間のバックアップ保持

### Azure Functions
- Node.js 18ランタイムのFunction App
- コスト最適化のための従量課金プラン
- Cosmos DBへのセキュアアクセスのためのシステム割り当てマネージドID
- 監視とログ記録のためのApplication Insights
- 一元化されたログ記録のためのLog Analyticsワークスペース
- Function実行時のためのストレージアカウント

### Azure Static Web Apps
- グローバルCDNを備えた静的Webホスティング
- APIバックエンドとしてのAzure Functionsとの統合
- 開発に適した無料ティア
- ステージング環境のサポート

## デプロイ

### 前提条件

1. Azure CLIがインストールされ、ログインしていること
2. 適切な権限を持つAzureサブスクリプション
3. リソースグループが作成されていること

### Azure CLIでのデプロイ

```bash
# リソースグループを作成（存在しない場合）
az group create --name rg-baby-first-words-dev --location japaneast

# インフラストラクチャをデプロイ
az deployment group create \
  --resource-group rg-baby-first-words-dev \
  --template-file infra/main.bicep \
  --parameters @infra/parameters/dev.json
```

### Azure Developer CLI (azd)でのデプロイ

このテンプレートはAzure Developer CLIと互換性があります：

```bash
# 初期化（azdを使用する場合）
azd init

# デプロイ
azd up
```

## 設定

### パラメータ

デプロイはパラメータを使用してカスタマイズできます：

- `environmentName`: 環境サフィックス（dev、prodなど）
- `location`: リソースのAzureリージョン
- `appName`: アプリケーション名のプレフィックス
- `cosmosDbDatabaseName`: Cosmos DBデータベース名
- `cosmosDbContainerName`: Cosmos DBコンテナ名

### 環境固有のパラメータ

- `infra/parameters/dev.json` - 開発環境
- `infra/parameters/prod.json` - 本番環境

## セキュリティ

### マネージドID

Function Appはシステム割り当てマネージドIDを使用してCosmos DBにアクセスし、アプリケーション設定での接続文字列やキーの必要性を排除します。

### ロール割り当て

- Function AppマネージドIDはCosmos DBアカウントに対して**Cosmos DB Data Contributor**ロールを持ちます
- これによりCosmos DBデータへの読み取り/書き込みアクセスが可能になります

### ネットワークセキュリティ

- すべてのリソースがHTTPS必須で構成されています
- 最小TLSバージョン1.2
- ストレージアカウントのパブリックBlobアクセスが無効化されています
- Function AppでFTPアクセスが無効化されています

## 監視

### Application Insights

- Function Appの自動テレメトリ収集
- カスタムメトリクスとログ記録が利用可能
- 90日間のデータ保持

### Log Analytics

- すべてのリソースの一元化されたログ記録
- コスト最適化のための30日間保持
- トラブルシューティングのためのクエリ機能

## コスト最適化

### 開発環境

- Cosmos DB: サーバーレス課金（リクエスト毎の課金）
- Functions: 従量課金プラン（実行毎の課金）
- Static Web Apps: 無料ティア
- Storage: Standard LRS（最も安価な冗長化）

### 本番環境での考慮事項

本番デプロイでは、以下を検討してください：

- Cosmos DB: 予測可能なワークロード用の予約容量
- Functions: より良いパフォーマンスのためのPremiumプラン
- Static Web Apps: カスタムドメイン用のStandardティア
- Storage: 災害復旧のための地理冗長ストレージ

## 出力

デプロイ後、テンプレートは以下の出力を提供します：

- `cosmosDbAccountName`: Cosmos DBアカウント名
- `cosmosDbEndpoint`: Cosmos DBエンドポイントURL
- `functionAppName`: Function App名
- `functionAppHostname`: Function Appのデフォルトホスト名
- `staticWebAppName`: Static Web App名
- `staticWebAppHostname`: Static Web Appのデフォルトホスト名

## トラブルシューティング

### よくある問題

1. **リソース名の競合**: 異なる環境名を使用して一意のリソース名を確保してください
2. **ロール割り当ての遅延**: マネージドIDのロール割り当てが反映されるまで数分かかる場合があります
3. **Static Web Appのリージョン**: 利用可能リージョンが限定されており、テンプレートではEast US 2を使用しています

### 検証

デプロイ後、以下を確認してください：

1. Function AppからCosmos DBにアクセス可能であること
2. Function AppマネージドIDが適切なロール割り当てを持っていること
3. Static Web AppがFunction App APIに接続できること
4. Application Insightsがテレメトリを収集していること

## 次のステップ

1. 作成されたFunction AppにFunction Appコードをデプロイ
2. Static Web Appにフロントエンドコードをデプロイ
3. カスタムドメインの設定（必要に応じて）
4. 自動デプロイのためのCI/CDパイプラインの設定