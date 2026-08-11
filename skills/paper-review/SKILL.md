---
name: paper-review
description: 学術論文多視点査読シミュレーション - 5人格レビュア・動的ペルソナ・6モード対応
---

# /paper-review - 多視点査読シミュレーション

## 概要
論文を **5人の独立したレビュア** (EIC + 査読者3名 + Devil's Advocate) が多視点で査読し、統合レポートを生成。実査読・著者リバット・投稿前セルフチェックに活用。

## レビュアペルソナ

| 役割 | 専門性 | 視点 | 重み |
|------|--------|------|------|
| **EIC (Editor-in-Chief)** | 広範・俯瞰 | 採録判定・範囲適合・影響度・倫理 | 30% |
| **Reviewer 1: Methodologist** | 手法・理論・数学 | 理論的妥当性・仮定・証明・一般化 | 20% |
| **Reviewer 2: Practitioner** | 実装・応用・システム | 再現性・実用性・計算効率・デプロイ | 20% |
| **Reviewer 3: Domain Expert** | 領域知識・先行研究 | 関連研究網羅・位置づけ・データ妥当性 | 20% |
| **Devil's Advocate** | 批判的思考・反例探索 | 反例・境界ケース・過大主張・バイアス | 10% |

## モード

| モード | 用途 | レビュア | 出力 |
|--------|------|----------|------|
| `full` | 模擬査読・投稿前チェック | 全5人 | 採録判定・詳細査読レポート・改善指示 |
| `re-review` | 再査読・リバット検証 | 全5人 | 修正対応評価・残存懸念・最終判定 |
| `quick` | 迅速スクリーニング | EIC + 1名 | Accept/Reject/Revise・主要懸念3点 |
| `methodology` | 手法特化深掘り | Methodologist + DA | 理論・実験設計・統計的妥当性詳細 |
| `socratic` | ガイド付き改善対話 | 全5人 (対話) | 質問リスト・著者への改善誘導 |
| `calibration` | 査読者精度校正 | 既知判定論文で実行 | 採録率・判定一致度・バイアス検出 |

## 入力

| 形式 | 対応 | 備考 |
|------|------|------|
| PDF | ✅ | 本文・補足・付録込み |
| LaTeXソース | ✅ | 数式・擬似コード抽出容易 |
| arXiv ID / DOI | ✅ | 自動取得・バージョン管理 |
| OpenReview URL | ✅ | 過去査読履歴参照可 |

## 出力構成

### 1. 採録判定サマリー

```markdown
# 査読レポート: "Attention Is All You Need" (模擬)

## メタデータ
- **論文ID**: NeurIPS2017_1234 / arXiv:1706.03762
- **査読日**: 2026-07-27 | **モード**: full
- **査読者**: EIC, Methodologist, Practitioner, Domain Expert, Devil's Advocate

## 判定結果
| レビュア | 判定 | 信頼度 | 主要懸念 |
|---------|------|--------|----------|
| EIC | **Strong Accept** | 95% | なし (パラダイムシフト) |
| Methodologist | **Accept** | 90% | 位置エンコード理論的根拠薄い |
| Practitioner | **Accept** | 85% | O(n²)長文実用性・実装詳細不足 |
| Domain Expert | **Strong Accept** | 95% | 関連研究網羅・位置づけ明確 |
| Devil's Advocate | **Weak Accept** | 70% | アテンション≠説明性・過大主張リスク |

**統合判定**: **Accept (Oral/Spotlight推奨)**
**信頼区間**: 85-95% Accept
**条件付き採録**: 位置エンコード議論補強・計算量言及・倫理声明追加
```

### 2. 詳細査読レポート (レビュア別)

#### EIC (Editor-in-Chief)
```
## 評価: Strong Accept (95%)

### 範囲適合性
- NeurIPS範囲内: 機械学習基礎・アーキテクチャ革新・広範応用 ✅
- 新規性: RNN/CNN脱却・Self-Attentionのみ・パラダイムシフト ✅
- 影響度: 以降全NLP・Vision・Multimodal基盤になる可能性極大 ✅

### 倫理・再現性
- データ: WMT公開データ・ベンチマーク標準 ✅
- 計算資源: 8×P100 3.5日・再現可能範囲 ✅
- コード: tensor2tensor公開予定 (当時) → 後日公開済み ✅

### 懸念・条件
1. 位置エンコーディングの理論的正当性補強 (Minor Revision)
2. O(n²)計算量への言及・将来展望追加 (Minor Revision)
3. 責任あるAI声明追加 (事務的)
```

#### Methodologist (手法専門)
```
## 評価: Accept (90%)

### 理論的妥当性
- Scaled Dot-Product Attention: スケーリング√d_kの理妥当性 (勾配分散制御) ✅
- Multi-Head: 異常部分空間への投影・アンサンブル効果 ✅
- Positional Encoding: sin/cos選択の理論的根拠不足 (相対位置・外挿性未議論) ⚠️

### 実験設計
- アブレーション: 適切 (Positional/Heads/Big-Base) ✅
- 統計的有意性: 単一ラン・分散未報告 (BLEU差1-2点の信頼区間不明) ⚠️
- ベースライン: 適切 (GNMT, ConvS2S, ByteNet等SOTA網羅) ✅

### 改善提案
1. 位置エンコーディング数学的導出・性質解析追加
2. 複数シード平均・信頼区間報告
3. Attention重み分布・エントロピー分析追加
```

#### Practitioner (実装・応用)
```
## 評価: Accept (85%)

### 再現性・実用性
- ハイパラ: Appendix詳細・Tensor2Tensorデフォルトで再現可能 ✅
- 計算資源: 8×P100 3.5日 (Base) - 学術標準だが産業界では高コスト ⚠️
- O(n²)メモリ: 512次元・4096トークンで約1GB/層・長文困難 ⚠️

### 実装詳細不足
- 数値安定性: -inf mask・softmax温度・gradient clipping詳細なし
- 分散学習: 8GPUデータ並列のみ・モデル並列・パイプライン未言及
- 推論最適化: KV-cache・量子化・蒸留・Flash Attention等後続技術前提

### 改善提案
1. 計算量・メモリ・推論遅延の定量分析追加
2. 実装トリック・数値安定性Tips補足資料化
3. 長文対応 (Longformer等) への道筋言及
```

#### Domain Expert (領域専門)
```
## 評価: Strong Accept (95%)

### 関連研究・位置づけ
- RNN/CNN/Attention-only 系統的整理・差分明確 ✅
- 先行研究 (Bahdanau Attention, Neural GPU, ByteNet等) 適切引用 ✅
- 翻訳以外 (言語モデリング・生成・理解) への展開示唆 ✅

### データ・ベンチマーク
- WMT 2014: 標準的・再現性高い ✅
- En-De/En-Fr: 言語対多様性・難易度差で堅牢性示唆 ✅
- キャラクター単位・サブワード (BPE) 詳細・効果検証 ✅
```

#### Devil's Advocate (批判的検証)
```
## 評価: Weak Accept (70%)

### 反例・境界ケース
- アテンション重み ≠ 説明性・因果性 (Jain & Wallace 2019予見) ⚠️
- 位置エンコード固定長・外挿失敗・相対位置不得手 ⚠️
- 低リソース言語・ドメイン外・敵対的例での脆弱性未検証 ⚠️

### 過大主張リスク
- "Attention is All You Need" タイトル・RNN/CNN完全否定ニュアンス ⚠️
- 産業界即適用可能な成熟度ではない (工夫必要) ⚠️
- 倫理・バイアス・環境影響 (炭素排出) 言及なし (当時) ⚠️

### 指摘事項
1. タイトル・抽象での謙虚な表現修正
2. 限界・失敗ケース・適用外ドメイン明記
3. 責任ある研究声明・ブロードキャスト影響考慮
```

### 3. 統合改善指示 (Author向け)

| 優先度 | カテゴリ | 指示内容 | 担当レビュア | 期限 |
|--------|---------|---------|-------------|------|
| **必須** | 理論 | 位置エンコーディング数学的正当性・性質・限界の補強議論追加 | Methodologist | Revision 1 |
| **必須** | 実験 | 複数シード平均・信頼区間・統計的有意性検定結果追加 | Methodologist | Revision 1 |
| **必須** | 実用性 | 計算量・メモリ・推論遅延の定量分析・長文対応展望追加 | Practitioner | Revision 1 |
| **推奨** | 倫理 | 責任あるAI声明・バイアス・環境影響・悪用リスク言及 | Devil's Advocate | Revision 1 |
| **推奨** | 明確性 | アテンション重みの解釈性限界・因果性ではない旨明記 | Devil's Advocate | Revision 1 |
| **任意** | 分析 | Attention分布エントロピー・ヘッド別役割分析追加 | Methodologist | Camera Ready |

### 4. 著者リバットテンプレート

```markdown
# Rebuttal: "Attention Is All You Need" (Response to Reviewers)

## Reviewer 1 (Methodologist) - 位置エンコーディング理論的根拠
**指摘**: sin/cos選択の数学的根拠不足
**対応**: 付録A.1に相対位置線形関係保持・外挿性・周期性の数学的導出を追加。
相対位置 k に対する PE(pos+k) が PE(pos) の線形関数で表現可能임을証明。

## Reviewer 2 (Practitioner) - O(n²)計算量・長文実用性
**指摘**: 長文でのメモリ・計算量懸念
**対応**: 第4.3節に複雑度分析表追加 (n=4096でBase 1.2GB/層)。Longformer等線形アテンションへの道筋をDiscussionに追記。

## Reviewer 3 (Devil's Advocate) - アテンション≠説明性・過大主張
**指摘**: タイトル・解釈性過大評価リスク
**対応**: Abstract冒頭に "We show that attention mechanisms can replace recurrence..." に修正。
第5節 Limitations に "Attention weights do not necessarily correspond to feature importance" 明記。
```

## コマンド

```
/paper-review <論文PDF/URL/arXiv>           # フル査読実行
/paper-review --mode=quick --arxiv=1706.03762
/paper-review --mode=methodology --file=paper.pdf
/paper-review --mode=socratic --output=rebuttal_guide.md
/paper-review --mode=calibration --known-decision=accept
/paper-review --reviewers=custom --personas=personas.yaml
/paper-review --output=REVIEW_REPORT.md --format=markdown|json|openreview
```

## 統合連携

| ツール | 連携内容 |
|--------|----------|
| `/paper-read` | 理解深化→査読精度向上 |
| `/research` | 関連研究収集・比較・位置づけ支援 |
| `/impl-doc` | 査読指摘→実装改善タスク化 |
| `/write` | Rebuttal・Response letter執筆支援 |
| OpenReview/ CMT | 実査読プラットフォーム連携 |

---

*移行日: 2026-07-27 | 元: CmdC academic-paper-reviewer skill*