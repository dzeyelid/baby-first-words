# インフラストラクチャ

このディレクトリには、baby-first-wordsアプリケーションのインフラストラクチャをデプロイするためのAzure Bicepテンプレートが含まれています。

## 📋 設計原則と参考資料

このインフラストラクチャは以下の公式ベストプラクティスとガイドラインに従って設計されています：

### 📚 参考資料（英語版を参照すること）
- **[Azure Bicep Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)** - Modularization, parameterization, security
- **[Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)** - Reliability, security, cost optimization
- **[Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/)** - Developer experience
- **[Azure Functions Best Practices](https://learn.microsoft.com/azure/azure-functions/functions-best-practices)** - Performance, monitoring
- **[Azure Cosmos DB Best Practices](https://learn.microsoft.com/azure/cosmos-db/best-practice-performance)** - Performance, cost optimization
- **[What is Azure Static Web Apps?](https://learn.microsoft.com/azure/static-web-apps/overview)** - Service overview, features
- **[Azure Resource Naming Guidelines](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)** - Standard resource abbreviations and naming

### 🎯 設計原則
- **モジュール化**: 各Azureサービスが独立したBicepモジュールとして実装
- **パラメータ化**: 環境固有の設定をパラメータファイルで管理
- **セキュリティ**: マネージドIDとロール割り当てによるゼロトラスト
- **監視**: 包括的なログ記録とメトリクス収集
- **コスト最適化**: 環境に応じた適切なサービス階層の選択

## 🏗️ アーキテクチャ

インフラストラクチャは3つの主要なAzureサービスで構成されています：

1. **Azure Cosmos DB** - 赤ちゃんの言葉データを保存するNoSQLデータベース
2. **Azure Functions** - TypeScriptベースのサーバーレスAPI
3. **Azure Static Web Apps** - CDNを備えたフロントエンドホスティング

## 🔧 作成されるリソース

### Azure Cosmos DB
- サーバーレス課金モデルのCosmos DBアカウント
- データベース: `cosmos-baby-first-words`
- コンテナ: `words`（パーティションキー `/wordId`）
- 単語クエリ用に最適化されたインデックスポリシー
- 7日間のバックアップ保持（開発環境）
- 一意性制約とコンポジットインデックス

### Azure Functions
- Node.js 20ランタイムのFunction App
- コスト最適化のための従量課金プラン
- Japan East（japaneast）リージョンに配置
- Cosmos DBへのセキュアアクセスのためのシステム割り当てマネージドID
- 監視とログ記録のためのApplication Insights
- 一元化されたログ記録のためのLog Analyticsワークスペース
- Function実行時のためのストレージアカウント
- 診断設定と自動ヒーリング（本番環境）

### Azure Static Web Apps
- グローバルCDNを備えた静的Webホスティング
- APIバックエンドとしてのAzure Functionsとの統合
- 開発に適した無料ティア
- ステージング環境のサポート
- 構成可能なCORSとルーティング設定
- East Asia（eastasia）リージョンに配置（CDNによりグローバル配信）

## 🚀 デプロイ


### 前提条件

1. Azure CLI または Azure Developer CLI (azd) がインストールされていること
2. 適切な権限を持つAzureサブスクリプション


### Azure CLIでのデプロイ（参考）

```bash
# リソースグループを作成（存在しない場合）
az group create --name rg-baby-first-words-dev --location japaneast

# インフラストラクチャをデプロイ
az deployment group create \
  --resource-group rg-baby-first-words-dev \
  --template-file infra/main.bicep \
  --parameters environmentName=dev location=japaneast appName=baby-first-words
```


### Azure Developer CLI (azd)でのデプロイ（推奨）

このテンプレートはAzure Developer CLIと互換性があります。

```bash
# 初期化
azd init

# 環境設定
azd env set AZURE_LOCATION japaneast
azd env set AZURE_ENV_NAME dev

# デプロイ
azd up
```


### デプロイメントスクリプト（CLI利用時の補助）

```bash
# 検証付きデプロイ
./infra/deploy.sh dev rg-baby-first-words-dev
```

> **Note:** このスクリプトは従来のAzure CLIデプロイ用です。推奨は`azd up`コマンドです。

## ⚙️ 設定

### パラメータ

Azure Developer CLIを使用する場合、以下の環境変数が使用されます：

- `AZURE_ENV_NAME`: 環境名（dev、test、prod）
- `AZURE_LOCATION`: リソースのAzureリージョン
- `AZURE_SUBSCRIPTION_ID`: Azureサブスクリプション ID

従来のAzure CLIを使用する場合は、以下のパラメータを指定できます：

- `environmentName`: 環境サフィックス（dev、test、prod）
- `location`: リソースのAzureリージョン
- `appName`: アプリケーション名のプレフィックス
- `cosmosDbDatabaseName`: Cosmos DBデータベース名
- `cosmosDbContainerName`: Cosmos DBコンテナ名
- `enableMonitoring`: 監視機能の有効/無効
- `enableBackup`: バックアップ機能の有効/無効

### 環境固有の設定

Azure Developer CLIを使用する場合、環境設定は`.env`ファイルで管理されます。

例：
```env
AZURE_LOCATION=japaneast
AZURE_ENV_NAME=dev
AZURE_SUBSCRIPTION_ID=your-subscription-id
```

従来のAzure CLIを使用する場合は、コマンドラインパラメータで設定を指定できます。

## 🔒 セキュリティ

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
- Cosmos DBでキーベースのメタデータ書き込みアクセスが無効化されています

## 📊 監視

### Application Insights
- Function Appの自動テレメトリ収集
- カスタムメトリクスとログ記録が利用可能
- 環境に応じた適切なデータ保持期間
- サンプリング設定による コスト最適化

### Log Analytics
- すべてのリソースの一元化されたログ記録
- 環境に応じた適切な保持期間
- トラブルシューティングのためのクエリ機能
- 診断設定による詳細ログ記録

## 💰 コスト最適化

### 開発環境
- Cosmos DB: サーバーレス課金（リクエスト毎の課金）
- Functions: 従量課金プラン（実行毎の課金）
- Static Web Apps: 無料ティア
- Storage: Standard LRS（最も安価な冗長化）
- 短期バックアップ保持（7日間）

### 本番環境での考慮事項
本番デプロイでは、以下を検討してください：

- Cosmos DB: 予測可能なワークロード用の予約容量
- Functions: より良いパフォーマンスのためのより高いメモリ設定
- Static Web Apps: カスタムドメイン用のStandardティア
- Storage: 災害復旧のための地理冗長ストレージ
- 長期バックアップ保持（14日間）

## 📤 出力

デプロイ後、テンプレートは以下の出力を提供します：

- `resourceGroupName`: リソースグループ名
- `cosmosDbAccountName`: Cosmos DBアカウント名
- `cosmosDbEndpoint`: Cosmos DBエンドポイントURL
- `cosmosDbConnectionString`: Cosmos DB接続文字列（開発用）
- `functionAppName`: Function App名
- `functionAppHostname`: Function Appのデフォルトホスト名
- `functionAppPrincipalId`: Function AppのマネージドID
- `staticWebAppName`: Static Web App名
- `staticWebAppHostname`: Static Web Appのデフォルトホスト名
- `staticWebAppDeploymentToken`: Static Web Appのデプロイトークン
- `applicationInsightsConnectionString`: Application Insights接続文字列

## 🔧 トラブルシューティング

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
5. 診断設定が有効になっていること

## 🎯 次のステップ

1. 作成されたFunction AppにFunction Appコードをデプロイ
2. Static Web Appにフロントエンドコードをデプロイ
3. カスタムドメインの設定（必要に応じて）
4. 自動デプロイのためのCI/CDパイプラインの設定
5. 監視とアラートの設定
6. セキュリティ設定の追加強化

## 🔄 アップデート履歴

- **v1.0.0**: 初期リリース
  - Azure Bicep ベストプラクティス適用
  - TypeScript サポート
  - 包括的な監視とログ記録
  - 環境固有の設定最適化