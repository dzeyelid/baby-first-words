# PRDテンプレート（Product Requirements Document）

> このテンプレートをコピーしてプロダクトに合わせて編集してください。日本語で記述してください。コードやデータ定義の例内のコメントは英語でも構いません。

## メタ情報
- プロダクト名: 
- バージョン: 
- 作成者: 
- 最終更新日: 
- ステータス: Draft/Review/Approved

## 1. 概要
- 背景・課題: どんな問題を誰が抱えているか
- 目的・ビジョン: このプロダクトが実現したい状態
- 成功指標（KPI/NSM）: 何で成功を測るか（例: WAU/DAU、留存、NPS 等）

## 2. スコープ
- インスコープ: 今回必ず提供する範囲（MVP/P0）
- アウトオブスコープ: 今回はやらないこと（将来検討やP2）

## 3. ターゲットユーザー/ペルソナ
- ペルソナ概要（属性・動機・状況）
- 主要シナリオ

## 4. ユースケース/ユーザーストーリー
- Given/When/Then 形式で3〜7件
- 例: Given 保護者として、When 子の新しい発話を記録すると、Then タイムラインに表示される

## 5. 競合・代替手段
- 既存手段/競合の比較（やらない理由/差別化）

## 6. 機能要件（Functional Requirements）
- 優先度: P0（MVP）/P1（次）/P2（将来）
- 各機能の受け入れ条件（Acceptance Criteria）

## 7. 非機能要件（Non-Functional Requirements）
- 信頼性/可用性（SLO、バックアップ、RTO/RPO）
- 性能（レスポンスタイム、同時接続、データ量）
- セキュリティ/プライバシー/コンプライアンス（データ分類、暗号化、ログ方針、DPA）
- アクセシビリティ/ローカリゼーション
- コスト/運用（目標コスト、監視、アラート、運用手順）

## 8. UX設計
- 画面一覧/情報設計/主要フロー（簡易ワイヤーでも可）
- ナビゲーション/IA、用語・トーン&マナー
- 空状態（Empty state）、エラー状態

## 9. データ設計/API
- データモデル/スキーマ（主要エンティティ、制約）
- API一覧（メソッド、エンドポイント、認可、入出力）
- 外部サービス依存（ID/権限/レート制限）

## 10. 計測/テレメトリ
- KPI分解、主要イベント、ダッシュボード
- プライバシー配慮（匿名化/保持期間）

## 11. リリース計画
- マイルストーン（M0/M1/M2…）、段階的ロールアウト/実験（Feature flag/A-B）
- 既存ユーザーへの影響、移行/互換性

## 12. 運用/サポート
- アラート/Runbook、SOP、障害時連絡体制
- サポート窓口、FAQ

## 13. リスク/前提/依存
- 主要リスク、回避/軽減策
- 重要な前提、外部依存

## 14. 成功判定/出口基準
- リリース可否のGo/NoGo条件
- MVPの完了定義

## 15. 参考資料
- 仕様メモ、調査結果、設計資料、関連Issue/PR、公式ドキュメントURL

---

### 付録A: データモデル例（参考）
```
Word {
  id: string // UUID
  userId: string // partition key
  word: string // required
  heardAt: string // ISO8601
  note?: string
  tags?: string[]
  createdAt: string
  updatedAt: string
}
```

### 付録B: API定義例（参考）
- GET /api/words?limit&after
- POST /api/words
- PUT /api/words/{id}
- DELETE /api/words/{id}

各APIは AuthZ 必須、Rate limit/Idempotency を検討。
