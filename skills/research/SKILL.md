---
name: research
description: 統合リサーチコマンド - エージェント横断調査から論文読解・情報源評価まで
---

# /research - 統合リサーチワークフロー

## 概要
**あらゆる調査タスク**を単一エントリーポイントから実行。用途に応じて最適なサブエージェント・ツールを自動選択・連携し、引用付き構造化レポートを出力。

## 使い方

```
/research <調査テーマ>                    # 自動モード選択で実行
/research <テーマ> --mode=<モード>         # モード明示
/research --paper=<PDF/URL/DOI>           # 論文読解モード
/research --source=<URL/リスト>           # 情報源評価モード
```

## モード一覧

| モード | 適用場面 | 実行内容 | 出力 |
|--------|---------|---------|------|
| `auto` (既定) | 一般的調査 | テーマ分析→最適戦略選択→実行→統合 | 構造化レポート |
| `quick` | 概要把握・事実確認 | 3-5ソース横断→要約→信頼度付与 | 1ページサマリー |
| `deep` | 包括的分析・比較・トレンド | 20+ソース・反復深掘り・証拠永続化 | 完全レポート |
| `paper` | 論文1-3本深読み | スケルトン抽出→各セクション解説→批判的検討 | 論文理解ドキュメント |
| `papers` | 複数論文比較・俯瞰 | 共通スケルトン適用→比較マトリクス→ギャップ分析 | 比較レビュー |
| `source-check` | 情報源信頼性評価 | 3軸(信頼性・新しさ・関連性)スコアリング・格付け | 格付けレポート |
| `trend` | 技術・市場トレンド | 時系列収集→クラスタリング→シグナル抽出 | トレンド分析 |

## ワークフロー（autoモード例）

### Phase 1: テーマ分析・戦略決定
```
入力テーマ → 意図分類 (fact/comparison/trend/technical/academic)
          → ソース戦略決定 (Web/学術/ニュース/技術ブログ/公式Doc)
          → サブエージェント割当 (並列実行)
```

### Phase 2: 並列情報収集
```
サブエージェント配下で並列:
  ├─ Web検索エージェント (Tavily/Google/Perplexity)
  ├─ 学術検索エージェント (Semantic Scholar/arXiv/PubMed/Crossref)
  ├─ 技術検索エージェント (GitHub/Docs/Blog/RFC)
  ├─ ニュースエージェント (NewsAPI/Feedly)
  └─ ソーシャルエージェント (X/Reddit/HackerNews)
```

### Phase 3: 統合・構造化
```
収集データ → 重複除去・矛盾検出 → クラスタリング
          → テーマ別セクション構成 → 引用正規化
          → 信頼性評価適用 (全ソース格付け)
          → 構造化レポート生成
```

### Phase 4: 品質ゲート・出力
```
整合性チェック → 引用完全性 → バイアス検出 → 信頼区間表示
              → ユーザー確認 → 形式別出力 (MD/PDF/JSON/Notion)
```

## オプション

| オプション | 説明 | デフォルト |
|-----------|------|-----------|
| `--mode` | 実行モード (auto/quick/deep/paper/papers/source-check/trend) | auto |
| `--sources` | ソース指定 (web/academic/tech/news/social/all) | all |
| `--depth` | 深度 (shallow/normal/deep/exhaustive) | normal |
| `--time-range` | 期間指定 (1d/7d/30d/90d/1y/all) | 90d |
| `--lang` | 言語 (ja/en/zh/ko/all) | ja,en |
| `--format` | 出力形式 (markdown/pdf/json/notion/obsidian) | markdown |
| `--citations` | 引用スタイル (apa/ieee/acm/numbered/inline) | inline |
| `--output` | 出力ファイルパス | stdout |
| `--save` | ナレッジベース保存 (true/false) | true |
| `--compare` | 比較対象指定 (テーマ/論文URLリスト) | - |

## 論文読解モード（--paper）

```
/research --paper=2301.08727
/research --paper=./paper.pdf --mode=paper
/research --paper="URL1,URL2" --mode=papers --compare
```

**論文理解スケルトン適用:**
```
1. Problem Statement (何の問題を解くか)
2. Approach/Method (どう解くか・核心アイデア)
3. Experiments/Validation (どう検証したか)
4. Results (定量・定性結果)
5. Discussion/Limitations (解釈・限界・一般化)
6. Related Work (位置づけ・差分)
7. Reproducibility (再現性・コード・データ)
8. Critical Assessment (強み・弱み・適用可能性)
9. Follow-up Questions (次に読むべき・実装時の注意)
```

## 情報源評価（3軸スコアリング）

全ソースに自動適用される3軸スコア（0-100）:

| 軸 | 指標 | 重み |
|---|------|------|
| **信頼性** | ドメイン権威・著者実績・査読有無・機関・履歴 | 40% |
| **新しさ** | 公開日・更新頻度・版数・引用半減期 | 30% |
| **関連性** | キーワードマッチ・文脈適合・質問カバレッジ | 30% |

**格付け:** AAA(90+) / AA(80-89) / A(70-79) / BBB(60-69) / BB(50-59) / B(40-49) / C(40未満)

## 使用例

```
/research "RAGシステムの最新アーキテクチャ比較" --mode=deep --sources=academic,tech
/research "Transformer効率化手法のトレンド" --mode=trend --time-range=1y
/research --paper="attention-is-all-you-need" --mode=paper
/research --source="https://arxiv.org/abs/2301.08727,https://blog.example.com/rag" --mode=source-check
/research "LLM推論コスト最適化" --mode=quick --format=json
```

## 品質基準
- **エビデンスベース**: 全主張にソース・引用・格付け
- **透明性**: 検索クエリ・除外基準・バイアスリスクを明記
- **再現性**: 同一クエリで同等結果（決定的パイプライン）
- **更新可能**: 増分更新・バージョン管理・差分表示
