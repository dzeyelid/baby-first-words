# MCP Integration Demo

このファイルは、Microsoft Docs MCP Server の統合をデモンストレーションするためのサンプルクエリを含んでいます。

## GitHub Copilot Agent モードでのテスト用クエリ

以下のクエリを GitHub Copilot Agent モードで試してみてください：

### 1. Azure Container Apps
```
公式のMicrosoft Learnドキュメントに従って、Azure Container Appを作成するaz cliコマンドを教えてください。
```

### 2. Bicep テンプレート
```
Microsoft公式ドキュメントに基づいて、Azure Storage Accountを作成するBicepテンプレートの書き方を教えてください。
```

### 3. Azure Developer CLI
```
Microsoft Learn の最新情報に基づいて、Azure Developer CLIを使用してAzureリソースをデプロイする方法を教えてください。
```

### 4. Azure Functions
```
Microsoft公式ドキュメントによると、Azure Functionsを作成してデプロイするための推奨される方法は何ですか？
```

### 5. Azure Resource Manager
```
ARM テンプレートとBicepテンプレートの違いについて、Microsoft公式ドキュメントの情報を基に説明してください。
```

## 期待される動作

GitHub Copilot Agent モードでこれらのクエリを実行すると、以下のような動作が期待されます：

1. **MCP Tool の自動利用**: Copilot が自動的に `microsoft_docs_search` ツールを使用
2. **最新情報の取得**: Microsoft Learn の最新の公式ドキュメントから情報を取得
3. **正確な回答**: 公式ドキュメントに基づいた正確で詳細な回答
4. **ソース情報**: 回答に使用したドキュメントのURL参照を含む

## トラブルシューティング

もし MCP ツールが使用されない場合は、以下を確認してください：

1. VS Code で GitHub Copilot が Agent モードになっているか
2. MCP サーバーが正しく設定されているか（`./test-mcp-integration.sh` で確認）
3. ネットワーク接続が正常か
4. より具体的な技術用語を使用してクエリを再構成

## 参考資料

- [MCP統合ドキュメント](mcp-integration.md)
- [Microsoft Docs MCP Server](https://github.com/MicrosoftDocs/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io)