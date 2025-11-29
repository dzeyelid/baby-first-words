# GitHub Copilot Custom Instructions ガイド

このドキュメントでは、このリポジトリで使用されているGitHub Copilot Custom Instructionsの構成と使い方を説明します。

## 概要

このプロジェクトでは、GitHub Copilotの動作を最適化するために、以下の3種類のカスタム指示ファイルを使用しています：

1. **Repository-wide instructions** (`.github/copilot-instructions.md`)
2. **Path-specific instructions** (`.github/instructions/*.instructions.md`)

これらの指示ファイルにより、コード生成とコードレビューの両方で一貫性のある高品質な出力が得られます。

## ファイル構成

```
.github/
├── copilot-instructions.md          # リポジトリ全体に適用される指示
└── instructions/
    ├── api.instructions.md          # src/api/ に特化した指示
    └── web.instructions.md          # src/web/ に特化した指示
```

## 1. Repository-wide Instructions

### ファイル: `.github/copilot-instructions.md`

このファイルは、リポジトリ全体に適用される一般的なガイドラインを定義しています。

### 含まれる内容

- **言語使用ガイドライン**: 日本語と英語の使い分けルール
- **Microsoft公式ドキュメント検索**: MCP統合に関する指示
- **Microsoft Azure作業ガイドライン**: Azure開発の基本方針
- **GitHub Copilot Code Reviewガイドライン**: コードレビュー時の確認項目

### 主な特徴

#### コードレビューガイドライン

`.github/copilot-instructions.md` には、GitHub Copilot Code Review専用のセクションが含まれています：

- **全般的なコード品質**: 明確性、保守性、命名規則
- **セキュリティ**: 機密情報の保護、入力検証
- **TypeScript固有**: 型安全性、非同期処理
- **データベース（Cosmos DB）関連**: 接続管理、CRUD操作の一貫性
- **Azure Functions固有**: 関数設計、レスポンス形式
- **Nuxt/Vue固有**: コンポーネント設計、サーバーAPI
- **パフォーマンス**: リソース効率、最適化
- **テスタビリティ**: テスト容易性の確保

## 2. Path-specific Instructions

### 概要

Path-specific instructionsは、特定のディレクトリやファイルパターンに対して適用される詳細な指示です。これにより、モジュールごとに最適化されたコーディング規約を提供できます。

### ファイル: `.github/instructions/api.instructions.md`

#### 適用範囲
```yaml
applyTo:
  - src/api/**
```

#### 含まれる内容

- **TypeScript コーディング規約**: 型の扱い、エラーハンドリング、非同期処理
- **Azure Functions 固有の規約**: 関数構成、リクエスト/レスポンス処理
- **データベース（Cosmos DB）の扱い**: 接続管理、CRUD操作、エラーハンドリング
- **セキュリティ**: 入力検証、機密情報の扱い
- **パフォーマンス**: リソース効率
- **テスト**: テスタビリティ
- **コード品質**: 命名規則、コメント、ファイル構成

#### 重要なポイント

1. **シングルトンパターン**: データベースサービスインスタンスの再利用
2. **明示的な型注釈**: すべての関数パラメータと戻り値に型を付与
3. **一貫したエラーハンドリング**: try-catchとロギングの標準化
4. **環境変数の検証**: 起動時に必須環境変数をチェック

### ファイル: `.github/instructions/web.instructions.md`

#### 適用範囲
```yaml
applyTo:
  - src/web/**
```

#### 含まれる内容

- **TypeScript コーディング規約**: 型の扱い、エラーハンドリング、非同期処理
- **Nuxt 4 / Vue 3 固有の規約**: コンポーネント、ルーティング、サーバーAPI、スタイリング
- **データベース（Cosmos DB）の扱い**: 接続管理、CRUD操作、エラーハンドリング、サービス配置
- **API エンドポイント設計**: エンドポイント構成、レスポンス形式、ヘルスチェック
- **セキュリティ**: 入力検証、機密情報の扱い、CSPとセキュリティヘッダー
- **パフォーマンス**: リソース効率、バンドル最適化
- **テスト**: テスタビリティ
- **コード品質**: 命名規則、コメント、ファイル構成
- **Azure Static Web Apps 固有の規約**: 設定ファイル、デプロイ

#### 重要なポイント

1. **Composition API**: すべてのVueコンポーネントで`<script setup>`を使用
2. **Auto-imports**: Nuxt composablesの自動インポートを活用
3. **サーバーAPI設計**: `defineEventHandler()`を使った一貫したAPI設計
4. **シングルトンパターン**: データベースサービスの再利用（src/apiと同様）

## Cosmos DB 処理の統一化

### 背景

`src/api` と `src/web` の両方でCosmos DBを使用しており、以下の点で共通のパターンが必要でした：

- 接続管理の方法
- CRUD操作のメソッド名と実装パターン
- エラーハンドリングの方法
- 型安全性の確保

### 統一されたパターン

両方のpath-specific instructionsに同じガイドラインを記載することで、以下の統一を実現しています：

#### 接続管理
```typescript
// Singleton pattern for database service instances
let cosmosDbService: CosmosDbService | null = null;

export function getCosmosDbService(): CosmosDbService {
    if (!cosmosDbService) {
        cosmosDbService = new CosmosDbService();
    }
    return cosmosDbService;
}
```

#### CRUD操作のメソッド命名
- `createItem<T>(item: T): Promise<T>`
- `getItem<T>(id: string, partitionKey: string): Promise<T | undefined>`
- `queryItems<T>(query: string): Promise<T[]>`
- `updateItem<T>(id: string, partitionKey: string, item: T): Promise<T>`
- `deleteItem(id: string, partitionKey: string): Promise<void>`

#### エラーハンドリング
```typescript
try {
    // Database operation
} catch (error) {
    console.error('Failed to [operation]:', error);
    throw error; // or return error response
}
```

#### 環境変数の検証
```typescript
const connectionString = process.env.COSMOS_DB_CONNECTION_STRING;
if (!connectionString) {
    throw new Error('COSMOS_DB_CONNECTION_STRING environment variable is not set');
}
```

## 使い方

### GitHub Copilot Chat での利用

1. **コード生成時**: Copilotは自動的にこれらの指示を参照し、プロジェクトの規約に従ったコードを生成します。

2. **特定のモジュールでの作業時**: 
   - `src/api` 配下で作業する場合、`api.instructions.md` が自動適用されます
   - `src/web` 配下で作業する場合、`web.instructions.md` が自動適用されます

### GitHub Copilot Code Review での利用

プルリクエストを作成すると、GitHub Copilot Code Reviewが自動的に以下を確認します：

1. **Repository-wide instructions**: すべてのファイルに対して基本的なコード品質チェック
2. **Path-specific instructions**: 変更されたファイルのパスに応じた詳細なチェック

#### コードレビューの確認項目例

- コードの明確性と保守性
- セキュリティ（機密情報、入力検証）
- TypeScript型の安全性
- Cosmos DB操作の一貫性
- エラーハンドリングの適切性
- パフォーマンスの考慮
- テスタビリティ

## ベストプラクティス

### 指示ファイルのメンテナンス

1. **定期的な見直し**: プロジェクトの進化に応じて指示を更新する
2. **具体的な例を含める**: 抽象的な指示よりも具体例を示す
3. **簡潔に保つ**: 各ファイルは1000行以内を推奨
4. **一貫性を保つ**: 複数の指示ファイル間で矛盾しないようにする

### 新しいモジュールの追加

新しいモジュールやディレクトリを追加する場合：

1. `.github/instructions/` に新しい `.instructions.md` ファイルを作成
2. YAMLフロントマターで `applyTo` パターンを指定
3. モジュール固有のガイドラインを記述
4. このドキュメントを更新して新しいファイルを説明

### 指示の優先順位

1. **Path-specific instructions**: 最も具体的で優先度が高い
2. **Repository-wide instructions**: 全体的なガイドライン
3. GitHub Copilotのデフォルトの動作

## トラブルシューティング

### Copilotが指示に従わない場合

1. **指示が明確か確認**: 曖昧な表現を避け、具体的に記述する
2. **ファイルパスの確認**: path-specific instructionsの `applyTo` パターンが正しいか確認
3. **指示の長さ**: ファイルが長すぎないか確認（1000行以内推奨）
4. **矛盾の確認**: 複数の指示ファイルで矛盾する内容がないか確認

### 指示の効果を確認する方法

1. **GitHub Copilot Chat**: Chatで「このファイルに適用される規約は？」と質問
2. **Code Review**: プルリクエストでの自動レビューコメントを確認
3. **コード生成**: 実際にコードを生成させて、規約に従っているか確認

## 参考資料

### 公式ドキュメント

- [Using custom instructions to unlock the power of Copilot code review](https://docs.github.com/en/copilot/tutorials/use-custom-instructions)
- [Configure custom instructions for GitHub Copilot](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions)
- [Copilot code review: Path-scoped custom instruction file support](https://github.blog/changelog/2025-09-03-copilot-code-review-path-scoped-custom-instruction-file-support/)
- [Unlocking the full power of Copilot code review: Master your instructions files](https://github.blog/ai-and-ml/unlocking-the-full-power-of-copilot-code-review-master-your-instructions-files/)

### このプロジェクトの関連ドキュメント

- [README.md](../README.md): プロジェクト全体の説明
- [infra/README.md](../infra/README.md): インフラストラクチャの詳細
- [docs/mcp-integration.md](./mcp-integration.md): Microsoft Docs MCP Server統合

## まとめ

このプロジェクトのGitHub Copilot Custom Instructionsは、以下の目標を達成しています：

1. **一貫性**: `src/api` と `src/web` で共通のパターン（特にCosmos DB処理）を統一
2. **品質**: コード生成とレビューの両方で高品質な出力を保証
3. **セキュリティ**: セキュリティベストプラクティスの自動チェック
4. **保守性**: 明確な規約により、長期的な保守性を向上
5. **汎用性**: 特定のコードに依存せず、将来の拡張にも対応可能

これらの指示ファイルは、プロジェクトの成長に合わせて継続的に改善していく必要があります。新しいパターンやベストプラクティスが確立されたら、適宜この指示ファイルを更新してください。
