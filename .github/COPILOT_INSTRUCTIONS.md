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