# baby-first-words

## 前提条件

- GitHub Codespaces またはVisual Studio Codeなどdevcontainerを利用できる環境
- Azureサブスクリプション

## セットアップ

### GitHub Codespacesでの開発

このリポジトリはGitHub Codespacesに最適化されています。Codespacesを起動すると、以下のツールが自動的にインストールされます：

- Azure CLI
- Azure Developer CLI (azd)
- Azure CLI（Bicep拡張機能付き）
- VS Code拡張機能（Bicep、Azure Developer CLI）

### ローカル開発

ローカルで開発する場合は、以下のツールをインストールしてください：

1. [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
2. [Azure Developer CLI](https://docs.microsoft.com/azure/developer/azure-developer-cli/install-azd)
3. [Bicep CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install)

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

### デプロイ後の検証

デプロイ後、以下のコマンドでリソースが正常に作成されているか確認できます：

```bash
# リソースグループの確認
az group show --name rg-baby-first-words

# ストレージアカウントの確認
az storage account list --resource-group rg-baby-first-words
```