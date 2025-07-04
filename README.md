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

## 使用方法

### 1. Azureにログイン

```bash
az login
azd auth login
```

### 2. ロケーションの設定

Azureリソースのデプロイ先リージョン（location）を設定します。例として日本東（japaneast）を指定します。

```bash
azd env set AZURE_LOCATION japaneast
```

### 3. プロジェクトの初期化

```bash
azd init
```

### 4. リソースのデプロイ

```bash
azd up
```

### 5. リソースの削除

```bash
azd down
```

## インフラストラクチャ

`infra/` ディレクトリには以下のBicepテンプレートが含まれています：

- `main.bicep` - メインのデプロイメントテンプレート（サブスクリプションスコープ）
- `resources.bicep` - リソースグループスコープのリソース定義
- `storage.bicep` - ストレージアカウントの定義

## 検証

### 環境の検証

提供されている検証スクリプトを実行して、必要なツールが正しくインストールされているか確認できます：

```bash
./validate-environment.sh
```

### MCP 統合の検証

Microsoft Docs MCP Server の統合が正しく設定されているか確認できます：

```bash
./test-mcp-integration.sh
```

### デプロイ後の検証

デプロイ後、以下のコマンドでリソースが正常に作成されているか確認できます：

```bash
# リソースグループの確認
az group show --name rg-baby-first-words

# ストレージアカウントの確認
az storage account list --resource-group rg-baby-first-words
```

## 追加されたファイル

MCP統合に関連して、以下のファイルが追加されています：

- `.vscode/settings.json` - VS Code用のMCP設定
- `.devcontainer/setup-mcp.sh` - MCP自動セットアップスクリプト
- `baby-first-words.code-workspace` - ワークスペース設定
- `docs/mcp-integration.md` - MCP統合の詳細ドキュメント
- `docs/mcp-demo.md` - MCP統合のデモとテスト用クエリ
- `test-mcp-integration.sh` - MCP統合テストスクリプト