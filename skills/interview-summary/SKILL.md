---
name: interview-summary
description: インタビュー文字起こし→JTBD・満足度シグナル・アクションアイテム要約
---

# /interview-summary - インタビュー構造化要約

## 概要
インタビューの **文字起こし・録音・メモ** から、JTBDフレームワーク・満足度シグナル・アクションアイテムを抽出し、意思決定に直結する構造化サマリーを生成。

## 入力形式

| 形式 | 対応 | 備考 |
|------|------|------|
| テキストファイル | ✅ | 文字起こし・メモ |
| JSON (構造化) | ✅ | 質問・回答ペア |
| VTT/SRT | ✅ | 字幕ファイル |
| 音声ファイル | ⚠️ | 別途Whisper等で文字起こし要 |
| Notion/Google Docs URL | ✅ | アクセス権限必要 |

## 分析フレームワーク

### 1. JTBD抽出 (Jobs-to-be-Done)
```json
{
  "jobs": [
    {
      "job_statement": "When I need to share design specs with developers, I want to generate a live-updating design token file so that implementation matches design without manual handoff.",
      "context": "Figmaでデザイン完了→開発者へ共有→実装ズレ発生→手戻り",
      "current_solution": "PDF仕様書・Zeplin・手動トークン管理",
      "pain_points": ["更新漏れ","バージョン管理困難","開発者が見ない"],
      "desired_outcome": "デザイン変更即座にコード反映・差分通知・単一情報源",
      "hiring_criteria": ["リアルタイム同期","Git連携","VS Codeプラグイン","権限管理"],
      "switching_barrier": "既存ワークフロー変更・学習コスト・移行期間"
    }
  ]
}
```

### 2. 満足度シグナル (Satisfaction Signals)

| シグナル | 定義 | 検出キーワード・パターン |
|---------|------|------------------------|
| **💚 Delight (感動)** | 期待超過・感謝・推奨意向 | "amazing", "game-changer", "まさに欲しかった", "即導入したい" |
| **✅ Satisfied (満足)** | 要件充足・問題解決 | "解決できた", "期待通り", "十分使える", "不満ない" |
| **😐 Neutral (中立)** | 可もなく不可もなし | "普通", "特に問題ない", "まあいいかな" |
| **⚠️ Frustrated (不満)** | 期待未達・機能不足・UX悪 | "使いにくい", "遅い", "バグ多い", "機能足りない" |
| **🔴 At Risk (離反リスク)** | 解約・乗り換え検討・強い不満 | "やめたい", "他検討", "我慢できない", "二度と使わない" |

### 3. アクションアイテム分類

| カテゴリ | 定義 | 例 |
|---------|------|-----|
| **Product** | 機能追加・改善・削除 | "ダークモード追加", "検索高速化", "不要機能削除" |
| **UX/UI** | 画面・フロー・コピー改善 | "オンボーディング簡素化", "エラー文言改善" |
| **Technical** | アーキ・性能・セキュリティ・インフラ | "DBインデックス追加", "キャッシュ導入", "脆弱性修正" |
| **Process** | 運用・サポート・ドキュメント・オンボーディング | "FAQ追加", "リリース手順自動化", "サポートフロー見直し" |
| **Strategy** | 価格・ポジショニング・ターゲット・パートナーシップ | "プラン見直し", "エンタープライズ機能", "API公開" |

## 出力構成

### 1. エグゼクティブサマリー
```
## インタビュー要約: [プロジェクト名] - [対象者/セグメント]

**実施日**: 2026-07-28 | **時間**: 45分 | **形式**: オンライン/対面
**インタビュアー**: [名前] | **対象**: [役割/ペルソナ/企業]

### 核心インサイト (Top 3)
1. **JTBD**: 「デザイントークンの単一情報源化」が最優先課題。現状PDF/Zeplinで二重管理→ズレ発生
2. **満足度**: 現行ツールに 😐 Neutral〜⚠️ Frustrated。「同期手動・更新漏れ・通知ない」が三大不満
3. **購買意向**: 解決すれば 💚 Delight 判定。「Git連携・VS Codeプラグイン・リアルタイム」が購買条件

### 推奨アクション (優先度順)
1. [Product] Git連携・自動同期機能 (MVP必須)
2. [Product] VS Code拡張・トークン参照UI (MVP必須)
3. [UX] 変更通知・差分表示・履歴 (Phase 2)
4. [Technical] 権限管理・監査ログ (Enterprise)
```

### 2. 詳細分析

#### JTBD詳細
| Job | 現状解決策 | ペイン | 期待成果 | 採用基準 | 切替障壁 |
|-----|----------|--------|---------|---------|---------|
| デザイントークン単一管理 | PDF/Zeplin/手動 | 更新漏れ/バージョン管理/開発者未参照 | リアルタイム同期/単一ソース | Git連携/VS Code/リアルタイム | 既存ワークフロー変更/学習コスト |

#### 満足度タイムライン
```
面接開始 → 現状説明(😐) → 課題深掘り(⚠️) → 理想像語り(💚) → 競合比較(✅) → 価格感度(😐) → 終了
```

#### 発言引用 (エビデンス)
> **💚 Delight**: "Figmaで色変えた瞬間にVS Codeで確認できたら、もう手放せないですね。今の手動エクスポートは本当にストレスで。"
> **⚠️ Frustrated**: "先月、デザイナーがスペーシング変えたのに開発が気づかず、本番で崩れて2時間ロールバックしたんですよ。"
> **🔴 At Risk**: "正直、今のツール年間契約更新するか微妙です。来月競合のベータ試す予定で。"

### 3. アクションアイテム一覧

| ID | カテゴリ | アクション | 優先度 | 担当 | 期限 | 依存 | 成功指標 |
|----|---------|-----------|--------|------|------|------|---------|
| ACT-01 | Product | Git webhook受信・トークン自動同期 | P0 | Backend | M1 | - | 同期遅延<5秒 |
| ACT-02 | Product | VS Code拡張・トークン検索・挿入 | P0 | Frontend | M1 | ACT-01 | 開発者MAU>80% |
| ACT-03 | UX | 変更差分・履歴・ロールバックUI | P1 | Design | M2 | ACT-01 | 手戻り時間50%削減 |
| ACT-04 | Technical | 権限・チーム・監査ログ | P2 | Backend | M3 | - | 監査要件充足 |

### 4. 競合・代替比較 (言及時)

| 競合 | 言及文脈 | 評価 | 我々への示唆 |
|------|---------|------|-------------|
| Figma Tokens Plugin | "無料でそこそこ使える" | ✅ Satisfied | 無料層・プラグインエコシステム対抗必須 |
| Specify | "Enterprise向け・高い" | 😐 Neutral | 価格帯・機能で差別化余地 |
| Style Dictionary | "設定複雑・開発者向け" | ⚠️ Frustrated | 非開発者でも使える易しさで勝負 |

## コマンド

```
/interview-summary <文字起こしファイル>           # 要約生成
/interview-summary --input=transcript.txt --output=SUMMARY.md
/interview-summary --format=markdown|json|notion|slides
/interview-summary --framework=jtbd|satisfaction|actions|all
/interview-summary --extract-quotes --min-confidence=0.8
/interview-summary --compare=previous_summary.md  # 前回比較・変化検出
/interview-summary --batch=interviews/            # 複数一括・クロス分析
```

## クロス分析 (複数インタビュー時)

```
/interview-summary --batch=interviews/ --cross-analysis
```

### 出力: パターン検出
```
## クロスインタビュー分析 (N=12)

### 共通JTBD (出現率)
1. デザイントークン単一管理 (92%)
2. 変更通知・差分把握 (83%)
3. 開発者向け参照UI (75%)

### 満足度分布
💚 Delight: 15% | ✅ Satisfied: 25% | 😐 Neutral: 30% | ⚠️ Frustrated: 20% | 🔴 At Risk: 10%

### セグメント別傾向
| セグメント | N | Top JTBD | 満足度中央値 | 購買意向 |
|-----------|---|----------|-------------|---------|
| デザイナー | 5 | 単一管理・通知 | 😐 Neutral | 高 |
| フロントエンド | 4 | 参照UI・型安全 | ⚠️ Frustrated | 高 |
| エンジニアリングMGR | 3 | ガバナンス・監査 | ✅ Satisfied | 中 |
```

## 統合連携

| ツール | 連携内容 |
|--------|----------|
| `/interview-script` | スクリプト→実施→要約の一連フロー |
| `/design-doc` | インサイト→設計書反映 |
| `/impl-doc` | アクション→実装計画タスク化 |
| Notion/Linear/Jira | アクションアイテム自動チケット化 |
| Productboard/Pendo | インサイト蓄積・優先度付け |

---

*移行日: 2026-07-27 | 元: CmdC summarize-interview skill*