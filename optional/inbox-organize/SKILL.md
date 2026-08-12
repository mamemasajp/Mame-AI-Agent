---
name: inbox-organize
description: Obsidian Inbox整理 - 00-InboxからPARA構造へ自動振り分け
---

# /inbox-organize — Obsidian Inbox 自動整理

> これは **Claude Code 個人運用スキル**です（`optional/` 収録）。既定ではインストールされません。
> Vault の絶対パスは `${OBSIDIAN_VAULT}` プレースホルダで収録しています。自分の環境の実値へ置き換えてください（例: `/mnt/c/Users/<you>/ObsidianVault`・`/Users/<you>/ObsidianVault`）。詳細は [`optional/README.md`](../README.md) を参照。

## 概要
`00-Inbox/` に溜まったノートを **内容確認 → 適切なPARAディレクトリへ移動** する自動化。ファイル名だけでなく中身を読んで判断し、整理ログを `99-Meta/inbox-organizer-log-YYYY-MM-DD.md` に保存。

## PARA構造・配置ルール

| ディレクトリ | 対象 | 判断基準 |
|-------------|------|----------|
| `10-Projects/` | 期限・ゴールある作業 | 完了条件・期限・ステークホルダー明確 |
| `20-Areas/Life/` | 継続的責任・生活 | 健康・財務・習慣・人間関係・メンテ |
| `20-Areas/Dev/` | 継続的技術領域 | 言語・FW・インフラ・ツール・学習 |
| `20-Areas/AI-Agents/` | AIエージェント運用 | プロンプト・評価・記憶・ワークフロー |
| `30-Resources/` | 参照・知識・素材 | 論文・記事・仕様書・テンプレ・スニペット |
| `40-Archive/` | 完了・非アクティブ | 完了プロジェクト・古い資料・参考済み |
| `99-Meta/` | システム・設定・ログ | 設定・スクリプト・整理ログ・メタ情報 |

## 使い方

```
/inbox-organize                     # 実行 (ドライラン表示後確認)
/inbox-organize --dry-run           # 移動先のみ表示・実行しない
/inbox-organize --force             # 確認スキップ・即実行
/inbox-organize --log               # 最新整理ログ表示
/inbox-organize --stats             # Inbox統計・滞留分析
/inbox-organize --rule <ファイル>     # 個別ファイルの配置先判断のみ
```

## 判断ロジック

### 1. フロントマター解析
```yaml
---
title: "プロジェクト計画書"
date: <YYYY-MM-DD>
tags:
  - type/plan
  - project/<name>
  - status/active
  - area/dev
---
```
→ `type/plan` + `project/*` + `status/active` → `10-Projects/<name>/`

### 2. 本文内容解析（フロントマター不足時）
- キーワード・エンティティ抽出
- 文脈分類（プロジェクト/領域/リソース/アーカイブ）
- 既存ノートとの類似度検索（Obsidianグラフ活用）

### 3. 配置先決定マトリクス

| 検出パターン | 配置先 | 例 |
|------------|--------|-----|
| `type/plan` + `project/*` | `10-Projects/<project>/` | 計画・設計・仕様 |
| `type/report` + `project/*` | `10-Projects/<project>/` | 進捗・完了報告 |
| `type/note` + `area/life` | `20-Areas/Life/` | 健康・習慣・家計 |
| `type/note` + `area/dev` | `20-Areas/Dev/` | 技術メモ・チートシート |
| `type/note` + `area/ai` | `20-Areas/AI-Agents/` | プロンプト・評価ログ |
| `type/reference` / `type/clipping` | `30-Resources/` | 論文・記事・仕様書 |
| `status/done` + `project/*` | `40-Archive/Projects/<project>/` | 完了プロジェクト |
| `type/meta` / `99-meta` | `99-Meta/` | 設定・ログ・スクリプト |

### 4. 同名ファイル・重複処理
- 同名存在時: `_v2`, `_v3`... またはタイムスタンプ付与
- 内容同一（ハッシュ一致）: 重複としてスキップ・ログ記録
- 内容異同名: バージョン管理・最新を配置・旧をArchive

## 整理ログ形式

```markdown
# Inbox Organizer Log - <YYYY-MM-DD>

## 統計
- 処理前: 23ファイル
- 移動: 18
- スキップ (重複): 2
- 判断保留 (手動要): 3
- 処理後: 3ファイル

## 移動詳細
| 元ファイル | 配置先 | 判断根拠 | 信頼度 |
|-----------|--------|---------|--------|
| <date>_計画.md | 10-Projects/<project>/ | type/plan + project/<project> | 0.95 |
| <date>_論文メモ.md | 30-Resources/Papers/ | type/clipping + topic/rag | 0.90 |

## 判断保留 (要手動)
- <date>_雑記.md: タグ不足・内容多岐 → 手動分類要
```

## オプション

| オプション | 説明 |
|-----------|------|
| `--dry-run` | 移動先表示のみ・実行しない |
| `--force` | 確認プロンプトなし即実行 |
| `--log` | 最新ログ表示 |
| `--stats` | Inbox内訳・滞留日数・タグカバレッジ |
| `--rule` | 単一ファイルの配置先判断のみ |
| `--auto-tag` | タグ不足ファイルに推奨タグ付与 |
| `--since` | 指定日以降のみ処理 (YYYY-MM-DD) |

## 設定: `.inbox-organizer.toml`

Vault の絶対パスは `${OBSIDIAN_VAULT}` プレースホルダ。

```toml
[vault]
path = "${OBSIDIAN_VAULT}"
inbox = "00-Inbox"
para = ["10-Projects", "20-Areas", "30-Resources", "40-Archive", "99-Meta"]

[classifier]
use_frontmatter = true
use_content = true
use_graph_similarity = true
confidence_threshold = 0.8
manual_below = 0.6

[duplicates]
hash_check = true
version_suffix = true
keep_newest = true

[logging]
log_dir = "99-Meta"
retention_days = 90
format = "markdown"

[git]
auto_commit = true
commit_message = "inbox: organize {count} files ({date})"
```

## 品質基準
- **内容ベース**: ファイル名だけでなく中身で判断
- **学習**: 手動修正をフィードバックし精度向上
- **履歴**: 全操作ログ保持・ロールバック可能
- **Git連携**: 整理前にコミット・セーブポイント作成
- **人間介入最小化**: 信頼度≥0.8は自動・それ未満のみ確認
