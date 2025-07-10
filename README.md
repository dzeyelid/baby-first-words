# baby-first-words

## 前提条件

- GitHub Codespaces またはVisual Studio Codeなどdevcontainerを利用できる環境
- Azureサブスクリプション

## MCPサーバーテスト結果

このリポジトリではMicrosoft Docs MCPサーバーを設定し、その機能をテストしました。詳細な結果は [`docs/mcp-server-test-results.md`](./docs/mcp-server-test-results.md) をご覧ください。

**主要な成果:**
- ✅ MCPサーバーが正常に動作確認済み
- ✅ Azure/Bicep関連の質問に高品質で回答
- ✅ 9つのテストケースすべてで優秀な結果
- ✅ 総合評価: 95%

GitHub Copilot Coding agentによるAzure開発支援が大幅に向上しています。

## セットアップ

### GitHub Codespacesでの開発

このリポジトリはGitHub Codespacesに最適化されています。Codespacesを起動すると、以下のツールが自動的にインストールされます：

- Azure CLI
- Azure Developer CLI (azd)
- Azure CLI（Bicep拡張機能付き）
- VS Code拡張機能（Bicep、Azure Developer CLI）
- GitHub Copilot（Microsoft Docs MCP Server統合付き）

### Microsoft Docs MCP Server統合

このプロジェクトには、GitHub Copilot Coding Agentに[Microsoft Docs MCP Server](https://github.com/MicrosoftDocs/mcp)が統合されています。これにより、Copilotが公式のMicrosoft ドキュメントにリアルタイムでアクセスできるようになります。

詳細は[MCP統合ドキュメント](docs/mcp-integration.md)を参照してください。

### ローカル開発

ローカルで開発する場合は、以下のツールをインストールしてください：

1. [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
2. [Azure Developer CLI](https://docs.microsoft.com/azure/developer/azure-developer-cli/install-azd)
3. [Bicep CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install)
4. [VS Code](https://code.visualstudio.com/) with GitHub Copilot extension

## Dev Containerでの開発環境

Dev Containerでは、Azure Functions Core Tools（funcコマンド）も自動インストールされており、ローカル開発・デバッグ・デプロイがすぐに利用できます。

```bash
func --version
func start
```

## 使用方法


### 推奨デプロイ手順（Azure Developer CLI）

1. Azureにログイン
2. プロジェクト初期化・環境設定・デプロイ

```bash
az login
azd auth login
azd init
azd env set AZURE_LOCATION japaneast
# （任意）リソース グループ名を指定したい場合は以下も設定可能。リソース グループは存在している必要がある。
# azd env set AZURE_RESOURCE_GROUP rg-baby-first-words-dev
azd up
```

従来の Consumption/Premium プランや詳細なパラメータ・CLI/スクリプトによる運用方法は [infra/README.md](infra/README.md) を参照してください。


## インフラストラクチャ

インフラ設計・Bicepテンプレートの詳細、パラメータやコスト・セキュリティ・トラブルシューティング等は [infra/README.md](infra/README.md) を参照してください。

`infra/` ディレクトリには以下のBicepテンプレートが含まれています：
- `main.bicep` - メインのデプロイメントテンプレート
- `resources.bicep` - リソースグループスコープのリソース定義
- `storage.bicep` - ストレージアカウントの定義


## 検証・トラブルシューティング

インフラの検証・トラブルシューティング手順も [infra/README.md](infra/README.md) にまとめています。
必要なツールの検証スクリプト（`./validate-environment.sh`）や、デプロイ後のリソース確認コマンド例もそちらを参照してください。


## 追加ファイル・MCP統合

MCP統合に関連するファイルや詳細は以下を参照してください：
- `.vscode/mcp.json` - VS Code用のMCP設定
- `docs/mcp-integration.md` - MCP統合の詳細ドキュメント
- `docs/mcp-demo.md` - MCP統合のデモとテスト用クエリ