# カスタム指示 (Custom Instructions)

このプロジェクトで開発作業を行う際は、以下のガイドラインに従ってください。

## 言語使用に関するガイドライン

### 日本語で記述するもの
- プルリクエストのタイトルと概要
- プルリクエストのコメント
- Issueのタイトルと説明
- Issueのコメント
- コミットメッセージ（日本語推奨）
- ドキュメントの説明文

### 英語で記述するもの
- コードのコメント（インライン、ブロックコメント）
- スクリプトファイルのコメント
- 変数名、関数名、クラス名
- 技術的なドキュメントのコードサンプル内のコメント

## 例

### プルリクエストの例
```
タイトル: 新機能：赤ちゃんの発話記録機能を追加
概要: 
このプルリクエストでは、赤ちゃんの初めての言葉を記録する機能を実装しました。
主な変更点：
- 発話記録のデータモデルを作成
- 記録画面のUIを実装
- データの保存機能を追加
```

### コードコメントの例
```javascript
// Record baby's first words with timestamp
function recordFirstWord(word, timestamp) {
  // Validate input parameters
  if (!word || !timestamp) {
    throw new Error('Word and timestamp are required');
  }
  
  // Save to local storage
  saveToStorage(word, timestamp);
}
```

このガイドラインに従うことで、プロジェクトのコミュニケーションと技術文書の一貫性を保つことができます。

---

## Microsoft公式ドキュメント検索（MCPサーバ利用）

あなたは `microsoft.docs.mcp` というMCPサーバにアクセスできます。このツールを使うことで、Microsoft公式ドキュメントの最新情報を検索できます。これはあなたの学習データセットよりも新しく、より詳細な情報が含まれている場合があります。

特に、Microsoft Azure、C#、F#、ASP.NET Core、Microsoft.Extensions、NuGet、Entity Framework、`dotnet` ランタイムなど、Microsoftのネイティブ技術に関する具体的・限定的な質問に対応する際は、このツールを積極的に活用して調査・回答してください。

## Microsoft Azure作業時のガイドライン（Copilot/AI向け）

- Azureリソースの作成・構成・デプロイ・管理に関する作業は、必ず[Microsoft Learn](https://learn.microsoft.com/azure/)や公式ドキュメント（英語版）を参照し、最新の仕様・推奨事項に従うこと。
- Bicep/ARMテンプレート、CLI、Portal操作なども同様。
- AzureリソースのBicep/ARM記述は「必須・推奨プロパティのみ明示」し、デフォルト値は極力省略する。
- セキュリティ・運用要件で明示が必要な場合のみ、デフォルト値を明記する。
- サンプルやテンプレートは[Azure公式サンプル](https://github.com/Azure-Samples)やMicrosoft Learn掲載例（英語版）を優先的に参考にする。
- コードや設定の根拠となる公式URLをコメントやPRに必ず添付する。
- コードコメントやドキュメントにも、Azureの公式用語・命名規則・推奨表現を使う。
- PRやIssueには「なぜその設定・構成にしたか」「公式ドキュメントのどこを根拠にしたか」を日本語で明記する。
- Azureの仕様変更や新機能リリース時は、必ずMicrosoft Learn（英語版）で最新情報を確認し、必要に応じてBicep/ARMやREADME、運用手順を更新する。

### 参考リンク（英語版を参照すること）

- [Microsoft Learn: Azure](https://learn.microsoft.com/azure/)
- [Azure Bicep Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- [What is Azure Static Web Apps?](https://learn.microsoft.com/azure/static-web-apps/overview)
- [Azure Functions Best Practices](https://learn.microsoft.com/azure/azure-functions/functions-best-practices)
