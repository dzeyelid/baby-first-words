# baby-first-words

赤ちゃんの初めての言葉を記録し、Azure インフラストラクチャを管理するプロジェクトです。MCP（Model Context Protocol）サーバーが組み込まれており、AI コーディングエージェントとの統合をサポートします。

## 前提条件

- GitHub Codespaces またはVisual Studio Codeなどdevcontainerを利用できる環境
- Azureサブスクリプション
- Node.js 18.0.0 以上 (MCP サーバー用)

## セットアップ

### GitHub Codespacesでの開発

このリポジトリはGitHub Codespacesに最適化されています。Codespacesを起動すると、以下のツールが自動的にインストールされます：

- Azure CLI
- Azure Developer CLI (azd)
- Azure CLI（Bicep拡張機能付き）
- Node.js および npm (MCP サーバー用)
- VS Code拡張機能（Bicep、Azure Developer CLI）

### ローカル開発

ローカルで開発する場合は、以下のツールをインストールしてください：

1. [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
2. [Azure Developer CLI](https://docs.microsoft.com/azure/developer/azure-developer-cli/install-azd)
3. [Bicep CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install)
4. [Node.js](https://nodejs.org/) (18.0.0 以上)

セットアップ後、以下のコマンドを実行してください：

```bash
npm install
```

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

## MCPサーバー

このプロジェクトにはMCP（Model Context Protocol）サーバーが組み込まれており、AI コーディングエージェントとの統合をサポートします。

### MCPサーバーの機能

1. **赤ちゃんの初めての言葉の記録**
   - 言葉、タイムスタンプ、コンテキストを記録
   - 赤ちゃんの名前での管理

2. **記録された言葉の一覧表示**
   - 全ての記録の表示
   - 赤ちゃんの名前でのフィルタリング

3. **Azureリソースの状態確認**
   - ストレージアカウントの状態確認
   - リソースグループの状態確認
   - 全てのリソースの状態確認

4. **環境の検証**
   - 開発環境の自動チェック

### MCPサーバーの起動

```bash
npm start
```

### MCPサーバーの開発用起動（ファイル監視付き）

```bash
npm run dev
```

### MCPサーバーのテスト

```bash
npm test
```

### MCPサーバーの使用例

#### 初めての言葉を記録

```bash
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "record_first_word", "arguments": {"word": "ママ", "timestamp": "2024-01-01T10:00:00Z", "context": "朝食の時間", "babyName": "太郎"}}}' | node src/index.js
```

#### 記録された言葉の一覧表示

```bash
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "list_recorded_words", "arguments": {}}}' | node src/index.js
```

#### Azureリソースの状態確認

```bash
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "azure_resource_status", "arguments": {"resourceType": "all"}}}' | node src/index.js
```

### MCP設定ファイル

`mcp-server-config.json` に MCP サーバーの設定が含まれています。AI コーディングエージェントで使用する際は、この設定ファイルを参照してください。

## インフラストラクチャ

このプロジェクトは以下のAzureリソースを使用します：

- **Resource Group**: `rg-baby-first-words`
- **Storage Account**: 赤ちゃんの記録データを保存するため

インフラストラクチャはBicepテンプレートで定義されており、以下のファイルで管理されています：

- `infra/main.bicep`: メインのインフラストラクチャ定義
- `infra/resources.bicep`: リソースの定義
- `infra/storage.bicep`: ストレージアカウントの定義

## 検証

### 環境の検証

提供されている検証スクリプトを実行して、必要なツールが正しくインストールされているか確認できます：

```bash
./validate-environment.sh
```

### デプロイ後の検証

デプロイ後、以下のコマンドでリソースが正常に作成されているか確認できます：

```bash
# リソースグループの確認
az group show --name rg-baby-first-words

# ストレージアカウントの確認
az storage account list --resource-group rg-baby-first-words
```

### MCPサーバーの動作確認

```bash
# ツール一覧の確認
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' | node src/index.js

# 環境検証の実行
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "validate_environment", "arguments": {}}}' | node src/index.js
```

## 開発

### プロジェクト構造

```
baby-first-words/
├── .devcontainer/          # Dev Container設定
├── .github/               # GitHub設定
├── infra/                 # Bicepテンプレート
├── src/                   # MCPサーバーのソースコード
├── test/                  # テストファイル
├── data/                  # 記録データ（自動生成）
├── package.json           # Node.js依存関係
├── mcp-server-config.json # MCP設定ファイル
└── validate-environment.sh # 環境検証スクリプト
```

### 貢献

このプロジェクトに貢献する際は、以下の[カスタム指示](.github/copilot-instructions.md)に従ってください：

- プルリクエストやIssueは日本語で記述
- コードのコメントは英語で記述
- 適切なテストを追加