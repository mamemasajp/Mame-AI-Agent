---
name: paper-read
description: 論文理解スケルトン駆動型 - 問題→手法→実験→結果→議論→限界→再現性→評価→追跡
---

# /paper-read - 論文深読みスケルトン

## 概要
論文を **9ステップのスケルトン** に沿って構造的に理解・記録する。受動的読解から能動的分析へ転換し、実装・調査・レビューに即活かせる知識として定着させる。

## スケルトン (9ステップ)

```
1. Problem Statement      ── 何の問題を解くか
2. Approach / Method      ── どう解くか (核心アイデア)
3. Experiments / Validation ── どう検証したか
4. Results                ── 定量・定性結果
5. Discussion / Limitations ── 解釈・限界・一般化
6. Related Work           ── 位置づけ・差分
7. Reproducibility        ── 再現性・コード・データ・計算資源
8. Critical Assessment    ── 強み・弱み・適用可能性・懸念
9. Follow-up Questions    ── 次に読むべき・実装時の注意・未解決問
```

## 使い方

```
/paper-read <PDF/URL/DOI/arXiv ID>           # 論文指定で開始
/paper-read --file=paper.pdf --mode=deep     # モード指定
/paper-read --arxiv=2301.08727 --output=obsidian
/paper-read --batch=papers.txt --format=markdown
```

## モード

| モード | 深度 | 時間目安 | 用途 |
|--------|------|----------|------|
| `quick` | スケルトンのみ (1-2行/ステップ) | 10-15分 | 概要把握・大量スクリーニング |
| `standard` | スケルトン + 根拠引用・図表言及 | 30-45分 | 通常の深読み・記録 |
| `deep` | 標準 + 数式導出・擬似コード・実装メモ | 60-90分 | 実装・改良・レビュー準備 |
| `teaching` | 標準 + 説明用スライド構成・質問集 | 45-60分 | 勉強会・メンタリング |

## 出力形式

### Markdown (標準)
```markdown
# 論文理解: "Attention Is All You Need" (arXiv:1706.03762)

## メタデータ
- **タイトル**: Attention Is All You Need
- **著者**: Vaswani et al. (Google Brain)
- **会場**: NeurIPS 2017
- **DOI/arXiv**: 1706.03762
- **読了日**: 2026-07-27
- **モード**: deep

## 1. Problem Statement
**何の問題か**: RNN/CNNベースのSeq2Seqが長距離依存・並列化・勾配消失で限界
**なぜ重要か**: 翻訳品質・訓練速度・長文対応の同時改善が必要
**既存手法の限界**: 
- RNN: 順次処理で並列化不可・長距離依存弱い
- CNN: 階層的だが固定窓・長距離に層必要
- Attention単体: 位置情報欠如・計算量O(n²)

## 2. Approach / Method
**核心アイデア**: Self-AttentionのみでSeq2Seq実現 (Transformer)
**主要コンポーネント**:
- Scaled Dot-Product Attention: Q,K,V射影・スケーリング・Softmax
- Multi-Head Attention: 並列アテンション・異なる表現空間
- Positional Encoding: 絶対位置・相対位置情報付与 (sin/cos)
- Feed-Forward: 位置ごと独立・同一パラメータ
- LayerNorm + Residual: 勾配流・安定化

**アーキテクチャ**: Encoder 6層 / Decoder 6層 / d_model=512 / h=8 heads

## 3. Experiments / Validation
**データセット**: WMT 2014 En-De (4.5M文) / En-Fr (36M文)
**ベースライン**: GNMT+RL, ConvS2S, ByteNet, Deep-Att + PosUnk
**指標**: BLEU (単語/文字), 訓練コスト (FLOPs), 翻訳長別性能
**アブレーション**: 
- Positional encoding除去 → 大幅劣化
- Attention heads削減 → 段階的劣化 (8→4→2→1)
- Big vs Base モデル比較

## 4. Results
| Model | En-De BLEU | En-Fr BLEU | Params | Training (GPU days) |
|-------|-----------|-----------|--------|---------------------|
| Transformer (Base) | 27.3 | 38.1 | 65M | 3.5 (8×P100) |
| Transformer (Big) | 28.4 | 41.8 | 213M | 12 (8×P100) |
| GNMT + RL | 24.6 | 39.9 | 87M | - |
| ConvS2S | 25.2 | 40.5 | - | - |

**追加知見**: 長文で性能差拡大・アンサンブルで+1-2 BLEU・ビームサーチ幅効果

## 5. Discussion / Limitations
**解釈**: Self-Attentionが依存関係を直接モデル化・並列化・勾配パス短縮
**限界**: 
- 計算量O(n²)で長文困難 (当時)
- 位置エンコーディング固定・一般化限界
- 大量データ・計算資源必要
- 解釈性: アテンション重み≠説明

**一般化**: NLP以外 (Vision, Audio, Graph) への適用可能性示唆

## 6. Related Work (位置づけ)
| 手法 | アプローチ | Transformerとの差分 |
|------|-----------|-------------------|
| RNN (LSTM/GRU) | 順次処理・隠れ状態 | 並列不可・長距離弱い |
| CNN (ByteNet, ConvS2S) | 畳み込み・階層 | 固定受容野・位置情報暗黙 |
| Attention-only | アテンション単体 | 位置情報なし・順序考慮なし |
| **Transformer** | **Self-Attention + Positional** | **並列・長距離・位置明示** |

## 7. Reproducibility
- **コード**: tensor2tensor (OSS) / OpenNMT-py / fairseq
- **事前学習モデル**: 公開なし (当時) → 後続 BERT/GPT で公開
- **計算資源**: 8×P100 3.5-12日 (Base/Big)
- **ハイパラ**: 論文Appendix詳細・Tensor2Tensorデフォルト

## 8. Critical Assessment
**強み**:
- パラダイムシフト: RNN/CNN脱却・全アーキテクチャ基盤に
- 並列化による訓練高速化・スケール則発見の契機
- アテンション機構の汎用性・解釈可能性(部分的)獲得

**弱み・懸念**:
- 二次計算量: Longformer/Performer/Linear Attention等で後続改良
- 位置エンコーディング: RoPE/ALiBi/Relative等で改良継続中
- データ効率: 事前学習大量必要・少データ微調整で過適合リスク

**適用可能性判定**:
- ✅ NLP全般 (翻訳・要約・生成・理解)
- ✅ Vision (ViT・DETR・Swin等派生多数)
- ✅ Multimodal (CLIP・Flamingo・GPT-4V)
- ⚠️ リアルタイム・エッジ・低リソース: 量子化・蒸留・線形アテンション必須

## 9. Follow-up Questions
- [ ] **次読む論文**: BERT (1810.04805), GPT (1806.09847), RoBERTa (1907.11692)
- [ ] **派生アーキテクチャ**: Longformer, Performer, Reformer, Linformer
- [ ] **位置エンコーディング改良**: RoPE, ALiBi, T5 Relative, xPos
- [ ] **実装時の注意**: 
  - 数値安定性: Attention scoreスケーリング・masked fill -inf
  - メモリ効率: Flash Attention・Gradient Checkpointing
  - 学習安定化: Warmup・Label Smoothing・Dropout配置
- [ ] **未解決問**: 
  - アテンション重みの真の解釈性・因果性
  - 文脈長無限化の理論的限界・実用的解
  - 事前学習データバイアス・公平性・著作権
```

## オプション

| オプション | 説明 |
|-----------|------|
| `--mode` | quick/standard/deep/teaching |
| `--output` | 出力ファイルパス |
| `--format` | markdown/json/obsidian/notion/slides |
| `--language` | ja/en (出力言語) |
| `--extract-figures` | 図表キャプション・画像抽出 |
| `--extract-math` | 数式・アルゴリズム擬似コード抽出 |
| `--compare` | 類似論文との比較表生成 |
| `--tags` | タグ付け (自動/手動) |

## 統合連携

| ツール | 連携内容 |
|--------|----------|
| `/research` | 複数論文比較・トレンド分析・サーベイ生成 |
| `/quiz-study` | 論文からクイズ自動生成・間隔反復 |
| `/studyflow` | 学習セッション・進捗・振り返り統合 |
| `/impl-doc` | 手法→実装計画タスク分解 |
| Obsidian | ナレッジグラフ・バックリンク・検索 |
| Zotero/Notion | 文献管理・メモ同期 |

