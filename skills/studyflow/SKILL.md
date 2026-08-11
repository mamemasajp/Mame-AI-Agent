---
name: studyflow
description: 統合学習システム - 目標設定→計画→実行→振り返り→改善の学習サイクル
---

# /studyflow - 統合学習フロー (StudyFlow)

## 概要
**学習全プロセス**を一元管理: 目標設定 → 計画立案 → 実行支援 → 振り返り → 改善。クイズ駆動・論文読解・技術習得等、あらゆる学習スタイルに対応。

## アーキテクチャ

```
学習目標設定
    ↓
カリキュラム生成 (教材・順序・マイルストーン)
    ↓
日次/週次セッション実行
    ├─ インプット (読書・動画・論文・ハンズオン)
    ├─ アウトプット (クイズ・要約・実装・説明)
    └─ 記録 (進捗・理解度・時間・気づき)
    ↓
定期振り返り (週次/月次/四半期)
    ↓
計画修正・目標更新 → ループ
```

## データ構造

### `studyflow-state.json`
```json
{
  "goals": [
    {
      "id": "goal_2026_q3_01",
      "title": "RAGシステム設計・実装習得",
      "target_date": "2026-09-30",
      "status": "active",
      "metrics": {"understanding": 0.65, "hands_on": 0.4, "teaching": 0.1},
      "milestones": [
        {"id": "m1", "title": "RAG基礎理論理解", "due": "2026-08-15", "status": "done"},
        {"id": "m2", "title": "ベクトルDB選定・検証", "due": "2026-08-31", "status": "active"},
        {"id": "m3", "title": "実装・評価パイプライン", "due": "2026-09-15", "status": "pending"},
        {"id": "m4", "title": "本番級デモ構築", "due": "2026-09-30", "status": "pending"}
      ],
      "resources": [
        {"type": "paper", "ref": "arXiv:2301.08727", "status": "read"},
        {"type": "course", "ref": "LangChain RAG Tutorial", "status": "in_progress"},
        {"type": "book", "ref": "Designing ML Systems Ch.8", "status": "planned"}
      ]
    }
  ],
  "sessions": [
    {
      "date": "2026-07-27",
      "goal_id": "goal_2026_q3_01",
      "duration_min": 90,
      "activities": [
        {"type": "input", "content": "RAG論文読解", "resource": "arXiv:2301.08727", "understanding": 0.8},
        {"type": "output", "content": "/quiz-study", "score": 0.75, "weakness": "retrieval戦略"},
        {"type": "hands_on", "content": "ChromaDB検証", "progress": "setup完了"}
      ],
      "reflection": "検索精度向上のためrerank必要。来週実装。",
      "next_actions": ["rerank実装", "評価指標決定"]
    }
  ],
  "weekly_reviews": [],
  "monthly_reviews": []
}
```

## コマンド体系

### 1. 目標管理 (`/studyflow goal`)
```
/studyflow goal create "RAGシステム習得" --target=2026-09-30 --metrics=understanding,hands_on,teaching
/studyflow goal list --status=active
/studyflow goal update goal_2026_q3_01 --metrics={"understanding":0.7}
/studyflow goal milestone add goal_2026_q3_01 "ベクトルDB選定" --due=2026-08-31
```

### 2. 計画・カリキュラム (`/studyflow plan`)
```
/studyflow plan generate goal_2026_q3_01 --resources=papers,docs,courses --style=balanced
/studyflow plan show goal_2026_q3_01 --week=current
/studyflow plan adjust goal_2026_q3_01 --delay=1w --reason="検証遅延"
```

### 3. セッション実行 (`/studyflow session`)
```
/studyflow session start goal_2026_q3_01 --duration=90 --focus=input
/studyflow session log --type=output --content="/quiz-study RAG" --score=0.75
/studyflow session log --type=hands_on --content="ChromaDB検証" --progress="setup完了"
/studyflow session end --reflection="検索精度向上のためrerank必要" --next="rerank実装"
```

### 4. 振り返り (`/studyflow review`)
```
/studyflow review weekly --goal=goal_2026_q3_01
/studyflow review monthly --all
/studyflow review quarterly --export=obsidian
```

### 5. 統計・可視化 (`/studyflow stats`)
```
/studyflow stats --goal=goal_2026_q3_01 --period=month
/studyflow stats --all --viz=heatmap --output=obsidian
/studyflow stats --understanding-trend --goal=goal_2026_q3_01
```

## 学習スタイル別プリセット

| スタイル | インプット配分 | アウトプット手法 | 指標 |
|----------|--------------|----------------|------|
| **論文駆動** | 論文60%/実装30%/他10% | スケルトン抽出・実装・クイズ | 理解度・実装完了率 |
| **クイズ駆動** | 教材40%/クイズ40%/実装20% | 間隔反復・弱点特化 | 想起率・転移率 |
| **プロジェクト駆動** | 必要知識30%/実装60%/ドキュメント10% | タスク分解・TDD・振り返り | マイルストーン完了率 |
| **バランス** | 各25% | 全手法併用 | 総合スコア |

## 統合連携

| ツール | 役割 |
|--------|------|
| `/quiz-study` | セッション内アウトプット・弱点特定・間隔反復 |
| `/research` | 新規トピック調査・教材収集・比較検証 |
| `/paper-read` | 論文深読み・スケルトン抽出・批判的検討 |
| `/write` | 学習ノート・要約・ブログ記事・説明文作成 |
| `/tdd` | 実装学習時のTDDサイクル支援 |
| `/prompt` | 学習用プロンプト設計・最適化 |
| Obsidian | ナレッジグラフ構築・リンク・検索・可視化 |
| GitHub | 実装コード・ドキュメント・進捗管理 |

## オプション

| オプション | 説明 | デフォルト |
|-----------|------|-----------|
| `--goal` | 対象ゴールID | 対話選択 |
| `--style` | 学習スタイル (paper/quiz/project/balanced) | balanced |
| `--duration` | セッション時間 (分) | 90 |
| `--focus` | セッション焦点 (input/output/hands_on/reflection) | 対話 |
| `--period` | 統計期間 (week/month/quarter/all) | month |
| `--viz` | 可視化 (timeline/heatmap/radar/gantt) | timeline |
| `--export` | 出力先 (obsidian/json/md/csv) | stdout |
| `--auto-schedule` | カレンダー自動スケジューリング | false |

## 使用例

```
/studyflow goal create "LLM推論最適化" --target=2026-10-31 --style=project
/studyflow plan generate --goal=goal_2026_q3_02 --resources="vLLM,TensorRT,ONNX" --style=project
/studyflow session start --goal=goal_2026_q3_02 --duration=120 --focus=hands_on
/studyflow session log --type=output --content="/quiz-study vLLM" --score=0.8
/studyflow session log --type=hands_on --content="TensorRT変換検証" --progress="FP16成功/INT8失敗"
/studyflow session end --reflection="INT8量子化で精度劣化大。キャリブレーション要調査" --next="キャリブレーション手法比較"
/studyflow review weekly --goal=goal_2026_q3_02 --export=obsidian
/studyflow stats --goal=goal_2026_q3_02 --viz=radar --output=obsidian
```

## 品質指標・追跡項目

| 指標 | 定義 | 目標 | 測定 |
|------|------|------|------|
| **理解度** | 概念・原理・関係性の把握度 | ≥0.8 | クイズ・説明・実装成功率 |
| **実装力** | 設計→実装→検証の自走度 | ≥0.7 | タスク完了率・コード品質 |
| **教示力** | 他者に説明・メンタリング可能度 | ≥0.5 | ブログ・発表・ペアプロ |
| **学習効率** | 単位時間あたり理解度上昇 | ↑トレンド | Δ理解度/時間 |
| **知識保持** | 遅延テスト正解率 | 30日後≥0.7 | 間隔反復スコア |
| **転移力** | 未知問題・新文脈への適用 | ≥0.6 | 類題・変形問題成功率 |

## 学習サイクル品質ゲート

| フェーズ | ゲート条件 | 不合格時 |
|----------|-----------|---------|
| 計画 | リソース・順序・マイルストーン妥当 | 専門家レビュー/再計画 |
| 実行 | セッション完了率≥80%・記録完全 | 原因分析・スケジュール調整 |
| 振り返り | 気づき≥3・アクション具体的 | 深掘り質問・再振り返り |
| 改善 | 次期計画に反映・指標改善傾向 | 根本原因特定・戦略変更 |

