---
name: prompt
description: プロンプトエンジニアリング統合 - テンプレート・最適化・ライブラリ管理
---

# /prompt - プロンプトエンジニアリング統合

## 概要
プロンプトの**設計・最適化・管理・共有**を一元化。ゼロからの作成から既存改善、ライブラリ運用までをカバー。

## 使い方

```
/prompt                           # 対話式でプロンプト作成
/prompt <目的>                     # 目的指定でテンプレート提案
/prompt --optimize=<既存プロンプト> # 既存プロンプト最適化
/prompt --library                  # ライブラリブラウズ・検索
/prompt --framework=<名前>         # フレームワーク適用
```

## 機能別サブコマンド

### 1. 作成・設計 (`/prompt create`)
```
入力: 目的・タスク・制約・期待出力・文脈
処理: 
  1. 6要素分析 (役割・文脈・制約・形式・品質基準・具体例)
  2. タスクタイプ分類 → 最適テンプレート選択
  3. フレームワーク適用 (RTF/RISEN/CoT/RODES/RACE/RISE/STAR/SOAP/CLEAR/GROW)
  4. ドラフト生成 → ユーザー確認 → 反復改善
出力: 完成プロンプト + メタデータ (用途・変数・期待トークン・品質スコア)
```

### 2. 最適化 (`/prompt optimize`)
```
入力: 既存プロンプト + 改善目標 (品質/トークン/明確性/一貫性)
処理:
  1. 構造解析 (要素欠落・冗長・曖昧・矛盾検出)
  2. 技法適用 (Chain of Thought / Few-shot / Self-consistency / 
     Tree of Thoughts / ReAct / Reflexion / Step-back / Persona)
  3. A/Bテスト設計 (複数バリエーション生成)
  4. 評価基準定義 → 実行推奨
出力: 最適化版複数案 + 改善点解説 + テストプラン
```

### 3. ライブラリ管理 (`/prompt library`)
```
機能:
  - 一覧・検索・フィルタ (カテゴリ/タグ/用途/フレームワーク)
  - 詳細表示 (テンプレート・変数・使用例・実績)
  - 追加・更新・削除・バージョン管理
  - エクスポート/インポート (JSON/Markdown/YAML)
  - 共有リンク生成
  - 使用統計・人気ランキング
```

### 4. フレームワーク適用 (`/prompt framework`)
```
利用可能フレームワーク:
  RTF        | Role-Task-Format              | 汎用・シンプル
  RISEN      | Role-Input-Steps-Expectation-Narrow | 手順明確化
  CoT        | Chain of Thought              | 推論・複雑タスク
  RODES      | Role-Objective-Details-Examples-Steps | 詳細指示
  RACE       | Role-Action-Context-Expectation | アクション指向
  RISE       | Role-Input-Steps-Expectation  | 構造化
  STAR       | Situation-Task-Action-Result  | ケーススタディ
  SOAP       | Subjective-Objective-Assessment-Plan | 診断・分析
  CLEAR      | Context-Limitation-Expectation-Action-Refinement | 反復改善
  GROW       | Goal-Reality-Options-Will     | コーチング・目標設定

適用: プロンプト + フレームワーク → 構造化版自動生成
```

## 6要素設計原則（全機能共通）

| 要素 | 説明 | 必須度 |
|------|------|--------|
| **役割** | ペルソナ・専門性・トーン・スタンス | ★★★ |
| **文脈** | 背景・前提・制約・前回までの流れ | ★★★ |
| **制約** | 禁止事項・必須事項・形式・長さ・スタイル | ★★★ |
| **形式** | 出力構造・フォーマット・セクション・例 | ★★☆ |
| **品質基準** | 正確性・完全性・一貫性・評価ルーブリック | ★★☆ |
| **具体例** | Few-shot・入出力例・アンチパターン | ★★☆ |

## カテゴリ・テンプレート一覧

| カテゴリ | テンプレート数 | 代表テンプレート |
|---------|--------------|----------------|
| **Writing** | 8 | blog-post, technical-doc, email, report, creative, translation, summary, editing |
| **Analysis** | 7 | swot, competitor, root-cause, trend, risk, decision-matrix, data-interpretation |
| **Technical** | 9 | code-review, debug, architecture, api-design, db-design, testing, refactor, security, performance |
| **Productivity** | 6 | planning, task-breakdown, meeting-notes, habit, prioritization, automation |
| **Data/Research** | 5 | literature-review, survey-design, sql-generation, visualization, statistical-analysis |
| **Communication** | 5 | negotiation, feedback, presentation, interview, conflict-resolution |

**計: 40テンプレート**

## オプション

| オプション | 説明 |
|-----------|------|
| `--category` | カテゴリフィルタ (writing/analysis/technical/productivity/data/communication) |
| `--framework` | フレームワーク指定 (rtf/risen/cot/rodes/race/rise/star/soap/clear/grow) |
| `--variables` | 変数定義 (JSON: {"key": "description", "required": true}) |
| `--quality-target` | 品質目標 (accuracy/brevity/creativity/consistency/token-efficiency) |
| `--iterations` | 反復改善回数 (default: 3) |
| `--save` | ライブラリ保存 (true/false) |
| `--export` | エクスポート形式 (json/md/yaml) |

## 使用例

```
/prompt create "技術ブログ記事の構成案作成" --category=writing --framework=rtf
/prompt optimize "このコードをレビューして" --quality-target=accuracy,brevity
/prompt library --category=technical --tag=code-review
/prompt framework --name=cot --apply-to="複雑な数学問題を解いて"
/prompt library --search="debug" --export=json --output=debug-prompts.json
```

## 品質スコアリング（自動評価）

| 指標 | 重み | 評価方法 |
|------|------|---------|
| 完全性 (6要素揃い) | 25% | 構造解析 |
| 明確性 (曖昧さなし) | 20% | NLP解析・ルール |
| 実行可能性 (実行時エラーなし) | 20% | シミュレーション |
| トークン効率 | 15% | 予測トークン数/品質 |
| 再現性 (同一入力→同一品質) | 10% | 複数回実行比較 |
| 学習適応性 (フィードバック反映) | 10% | 履歴分析 |

**総合80点以上** を「本番推奨」とする

## 学習・蓄積
- 使用履歴・評価・修正履歴をローカルDBに蓄積
- ユーザー固有の「効くプロンプトパターン」を学習
- コミュニティ共有テンプレートとの差分分析
- 定期的な「プロンプト健康診断」レポート生成
