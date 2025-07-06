# MCP統合クイックスタートガイド

## 概要
このガイドでは、GitHub Copilot Coding AgentでMicrosoft Docs MCP Serverの統合を素早く始める方法について説明します。

## 前提条件
- VS Code
- GitHub Copilot 拡張機能
- GitHub Copilot Chat 拡張機能

## 設定確認

### 1. 基本的な設定確認
```bash
./validate-environment.sh
```

### 2. 包括的なMCPテスト
```bash
./test-mcp-integration.sh
```

### 3. 対話的なテストとデモ
```bash
./mcp-demo.sh
```

## 使用方法

### VS Code での使用

1. VS Code を開く
2. GitHub Copilot Chat を開く（`Ctrl+Shift+I` または `Cmd+Shift+I`）
3. 以下のようなクエリを入力してテスト：

```
Azure Bicepとは何ですか？主な特徴と利点を教えてください。
```

### テストクエリの例

#### Azure Bicep関連
- "Azure Bicepとは何ですか？主な特徴と利点を教えてください。"
- "Bicepテンプレートでパラメータを定義する方法を教えてください。"
- "Azure Storage AccountをBicepで作成する方法を教えてください。"

#### Azure Developer CLI関連
- "Azure Developer CLI (azd) の基本的な使用方法を教えてください。"
- "azd deployコマンドの使用方法と主要なオプションを教えてください。"

#### GitHub Codespaces関連
- "GitHub CodespacesでAzure開発環境を設定する際の推奨事項は何ですか？"

## 設定の詳細

### .vscode/mcp.json の内容
```json
{
  "servers": {
    "microsoft.docs.mcp": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp",
      "tools": [
        "microsoft_docs_search"
      ]
    }
  }
}
```

### 環境変数の確認
以下の環境変数が設定されていることを確認してください：
- `COPILOT_MCP_ENABLED=true`
- `COPILOT_FEATURE_FLAGS` にMCP関連のフラグが含まれている

## トラブルシューティング

### よくある問題

1. **MCPが動作しない**
   - `.vscode/mcp.json` ファイルが存在することを確認
   - JSON形式が正しいことを確認
   - 環境変数が設定されていることを確認

2. **テストが失敗する**
   - `./test-mcp-integration.sh` を実行してエラーの詳細を確認
   - VS Code拡張機能が正しくインストールされていることを確認

3. **GitHub Copilot ChatでMCPが使用されない**
   - GitHub Copilot が最新バージョンであることを確認
   - VS Code を再起動してみる

## 参考資料

- [Microsoft Docs MCP Server GitHub](https://github.com/MicrosoftDocs/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [VS Code MCP 公式ガイド](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Microsoft Learn](https://learn.microsoft.com)

## ログと診断

### テスト結果の生成
```bash
./mcp-demo.sh
# 選択肢 6 を選んでテスト結果を生成
```

### 詳細なログ
MCP統合の詳細なログを確認するには：
```bash
./test-mcp-integration.sh > mcp-test-log.txt 2>&1
```

## サポート

問題が発生した場合は：
1. `./test-mcp-integration.sh` を実行してエラーの詳細を確認
2. 生成されたテスト結果を確認
3. GitHub Issue を作成して報告