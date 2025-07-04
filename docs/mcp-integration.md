# Microsoft Docs MCP Server Integration

このプロジェクトは、GitHub Copilot Coding Agentに[Microsoft Docs MCP Server](https://github.com/MicrosoftDocs/mcp)を統合しています。

## 概要

Microsoft Docs MCP Server は、Model Context Protocol (MCP) を実装したクラウドホスト型サービスで、AI アシスタントが公式のMicrosoft ドキュメントにリアルタイムでアクセスできるようにします。

## 統合内容

### 1. VS Code 設定
- `.vscode/settings.json` に MCP サーバー設定を追加
- Microsoft Docs MCP Server エンドポイント: `https://learn.microsoft.com/api/mcp`

### 2. devcontainer 設定
- GitHub Copilot と Copilot Chat 拡張機能を追加
- MCP セットアップスクリプトを自動実行

### 3. 自動セットアップ
- `.devcontainer/setup-mcp.sh` で MCP 設定を自動化
- 環境検証とエンドポイント確認

## 使用方法

### 1. 環境の起動
GitHub Codespaces または VS Code の devcontainer で環境を起動します。

### 2. GitHub Copilot の設定
1. VS Code で GitHub Copilot が有効であることを確認
2. GitHub Copilot を Agent モードに切り替え
3. Microsoft Docs MCP Server がツールとして利用可能になります

### 3. MCP Server の使用
以下のようなクエリでMicrosoft公式ドキュメントにアクセスできます：

```
公式のMicrosoft Learnドキュメントに従って、Azure Container Appを作成するaz cliコマンドを教えてください。
```

## 利用可能なツール

| ツール名 | 説明 | 入力パラメータ |
|---------|------|---------------|
| `microsoft_docs_search` | Microsoft公式技術ドキュメントのセマンティック検索 | `query` (文字列): 検索クエリ |

## 検証方法

### 1. 環境検証
```bash
./validate-environment.sh
```

### 2. MCP 設定確認
```bash
./.devcontainer/setup-mcp.sh
```

### 3. 手動テスト
1. VS Code で GitHub Copilot を開く
2. Agent モードに切り替え
3. Microsoft Learn ドキュメントを参照するクエリを実行
4. MCP サーバーがドキュメント検索に使用されることを確認

## トラブルシューティング

### よくある問題

| 問題 | 解決方法 |
|------|---------|
| 接続エラー | ネットワーク接続とサーバーURL を確認 |
| 結果が返らない | より具体的な技術用語でクエリを再構成 |
| VS Code でツールが表示されない | VS Code を再起動するか MCP 拡張機能を確認 |
| HTTP 405 エラー | ブラウザから直接アクセスしようとした場合に発生（正常な動作） |

### システムプロンプトの推奨

Copilot により頻繁に MCP ツールを使用させるため、以下のようなシステムプロンプトを設定することを推奨します：

```md
## Microsoft ドキュメントのクエリ

`microsoft.docs.mcp` という MCP サーバーにアクセスできます。このツールは Microsoft の最新公式ドキュメントを検索でき、あなたの訓練データよりも詳細または新しい情報を提供できる場合があります。

C#、F#、ASP.NET Core、Microsoft.Extensions、NuGet、Entity Framework、`dotnet` ランタイムなどの Microsoft ネイティブ技術について質問される場合は、特定の狭い範囲の質問に対して、このツールを研究目的で使用してください。
```

## 参考資料

- [Microsoft Docs MCP Server GitHub](https://github.com/MicrosoftDocs/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [VS Code MCP 公式ガイド](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Microsoft Learn](https://learn.microsoft.com)