# Feature Specification: 発語・フリーメモ記録 MVP 基盤

**Feature Branch**: `001-utterance-note-mvp`  
**Created**: 2025-09-06  
**Status**: Draft  
**Input**: User description: "発語・ジェスチャー記録基盤の初期仕様: 発語イベント(utterance)とフリーメモ(note)を記録し語彙カウントと意味タイムライン集計の前提データを蓄積する。MVPは: (1) イベント入力要件定義 (2) 語彙/意味タイムライン要約ビュー要件 (3) 発達段階判定の判定条件定義 (4) 集計出力（語彙数, 新出語, 意味拡張件数, 推定段階）要件。除外: UI詳細実装, 認証, 意味推定アルゴリズム自動化。"

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies  
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
保護者は日常で子どもの発語や関連ジェスチャーを素早く入力し、後で語彙数推移や意味拡張（同一語の意味変化）を確認できる。記録時点では一次データ（イベント）を失わず保存し、集計ビュー（語彙数/段階/意味タイムライン）は後処理で再構成される。

### Acceptance Scenarios
1. **Given** 子どもプロフィール(子ID)が存在し入力画面が開いている, **When** 保護者が単語テキスト「おっぱい」と分類 form=word を入力し保存, **Then** システムは発語イベント(utterance)をイベントID付きで永続化し直後に日次語彙集計に未出語としてカウントされる。
2. **Given** 同一 `word_id` に過去 exact meaning のイベントがある, **When** 新しい発語イベントで `semantics.relation=overextension` と異なる intended_meaning を記録, **Then** システムは語意味タイムラインに新しい状態開始をマークし前状態に終了日を設定する(ロジックは後処理定義)。
3. **Given** 保護者が自由メモ入力画面を開いている, **When** メモテキストを保存, **Then** note イベントがイベントID付きで保存され語彙統計へ影響しない。
4. **Given** 一日内に複数の新出語が登録されている, **When** 保護者が日次サマリを要求, **Then** システムは「当日新出語数」「累積語彙数」「現在推定段階」を返す。
5. **Given** 累積語彙が 50 語を超えた, **When** 日次集計が再計算される, **Then** 推定段階が "語彙増加期" に更新される。

### Edge Cases
- 空文字や空白のみの発語テキスト入力 → 保存拒否し明確なエラー理由をユーザへ提示。
- 同一タイムスタンプ・同一 word_id の重複投稿 → システムは別イベントとして保持（重複除外はしない）ただしクライアントに軽警告表示。[NEEDS CLARIFICATION: 重複検出を行ってブロックすべきかポリシー未定]
- 意味関係 `relation` を指定せず保存 → デフォルト `unknown` として扱い後処理で再分類可能にする。
- 年齢 `age_month` が提供されない → `timestamp` から逆算するか [NEEDS CLARIFICATION: 年齢計算に基準日(誕生日)管理方法 未定]
- 子ID が存在しない/未選択 → 保存前にブロック。

### Non-happy Failure Handling (Testing Focus)
- 無効な `form` 値 (定義外文字列) → バリデーションエラー。
- `semantics.relation` が allowed set 外 → バリデーションエラー。
- 大量一括入力（>500 イベント/日）時 → パフォーマンス要件未定。[NEEDS CLARIFICATION: MVP の性能境界値]

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: システムは発語イベント(utterance)を必須フィールド `event_id, type=utterance, child_id, timestamp, utterance.text, utterance.form` を含め保存できること。
- **FR-002**: システムは発語イベント `utterance.form` を {coo, babble, word_like, word, phrase} のいずれかに制限し不正値を拒否すること。
- **FR-003**: システムは発語イベントに語彙同一性を示す `word_id` を受け取り保存し後続集計で同一語として扱えること。
- **FR-004**: システムは `semantics.relation` を {exact, overextension, underextension, shift, unknown} の列挙から受け取り未指定時は `unknown` をセットすること。
- **FR-005**: システムはジェスチャー情報 `gesture.present (bool)` が true の場合のみ `gesture.type` を必須にするバリデーションを行うこと。
- **FR-006**: システムは自由メモ(note)イベントを `event_id, type=note, child_id, timestamp, note.text` を必須項目として保存できること。
- **FR-007**: システムは保存されたすべてのイベントを時系列で取得するタイムラインビュー生成用クエリ要件を満たすこと（ソート順: timestamp ASC, event_id で安定ソート）。
- **FR-008**: システムは日次集計で (a) 当日新出語数 (b) 累積語彙数 (c) 意味拡張イベント件数 (d) 推定段階 を算出すること。
- **FR-009**: システムは語単位集約で meaning timeline を構築する際、relation が exact 以外に変化したイベント出現時に新たな状態セグメントを開始できること。[NEEDS CLARIFICATION: exact→exact 連続時のセグメント結合ルール]
- **FR-010**: 推定段階は以下の優先順位ルールで一意に決定すること: 複雑な文期 > 文の発達期 > 二語文期 > 語彙増加期 > 初語期。
- **FR-011**: システムは語彙増加期への遷移条件を「累積語彙 >= 50」として評価できること。
- **FR-012**: システムは二語文期への遷移条件を「MLU >= 2 のイベント初出」が満たされた日付以降に適用できること。[NEEDS CLARIFICATION: MLU 算出対象イベント範囲]
- **FR-013**: システムは意味タイムライン states に evidence_event_ids を 1 件以上保持すること。
- **FR-014**: システムは保存イベントを後から改変せず、更新操作は新イベント追加による状態差分で表現する（イベントは不変）。
- **FR-015**: システムは無効入力（必須欠落/列挙外/空文字）に対しエラー理由を返すこと。
- **FR-016**: システムは日次集計再計算を同一日に複数回実行しても結果が決定的であること（冪等性）。
- **FR-017**: システムは時間帯が異なる同一 `word_id` の複数イベントを重複として削除しないこと。
- **FR-018**: システムは `age_month` が渡されない場合に [NEEDS CLARIFICATION: 誕生日保持方法] が確立するまでフィールドを null 許容にする。
- **FR-019**: システムは列挙値・必須チェックに失敗したイベントを集計に含めないこと。
- **FR-020**: システムは意味拡張種別( overextension / underextension / shift ) 件数を日次集計レポートに含めること。

### Key Entities *(include if feature involves data)*
- **UtteranceEvent**: 子どもの発語行為一次データ。属性: event_id, child_id, timestamp, age_month (nullable), word_id, form, text, semantics(relation, intended_meaning, original_meaning, judged_by), gesture(present, type, target?), context(routine, interlocutor, location), notes_free。
- **NoteEvent**: 自由観察メモ。属性: event_id, child_id, timestamp, age_month (nullable), note.text, tags[]。
- **WordMeaningState**: 同一 word_id の意味解釈区間。属性: state_id, word_id, start_date, end_date?, meaning, relation, judged_by, evidence_event_ids[]。
- **DailyLexicalSummary**: 日単位集計レコード。属性: date, new_words_count, cumulative_words_count, overextension_count, underextension_count, shift_count, stage, generated_at。
- **DevelopmentStageRule**: 発達段階判定ルール抽象化（条件集合名と適用優先順位）。

### Key Entities *(include if feature involves data)*
- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain (残存: 重複扱い方, 年齢計算基準, exact セグメント結合, MLU 算出範囲)
- [x] Requirements are testable and unambiguous (一部 Clarification マーカーあり)
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [ ] Review checklist passed

---
