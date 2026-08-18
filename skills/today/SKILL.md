---
name: today
description: 毎日のTODO・ルーティン作成（read-and-suggest） — 学びゴール・日記・過去TODOを自然言語から読み、優先順位付きの今日TODO（午前=頭/午後=雑用）を提案
---

# /today — 毎日のTODO・ルーティン作成

## 概要

毎朝、**日記を書くだけで**今日のTODOを自動生成する。ユーザーにスキーマ管理を強制しない **read-and-suggest** 型。
（旧 `/life-todo` の structure-and-commit［スキーマ強制・コマンド管理］とは設計思想が逆。こちらは**提案のみ・自由に書き換え可**）

> 出典: `/session-kickoff`（自然言語→柔軟な優先順位変換）の良い部分を毎日用に専用化したもの。
> `/session-kickoff` は体系作り・大きな計画に、`/today` は毎日のTODOに、と役割分担する。

## 毎日フロー（決め打ち・起動時指示不要）

`/today` 起動 → 以下を自動実行する（ユーザーは追加指示を出さなくてよい）:

1. **学びゴールを読む** — `${OBSIDIAN_VAULT}/30-Resources/Learn-Goals.md`（主格）+ mnemonミラー
   → 締切が近いもの・重要度で重み付け
2. **昨日の日記を読む** — `${OBSIDIAN_VAULT}/00-Inbox/<前日>_日記.md` → 未達成・発生タスク・体調・気分を拾う
3. **過去のTODOを読む** — `${OBSIDIAN_VAULT}/00-Inbox/<前日>_TODO.md` → 未完了の前倒し・繰り越しを拾う
4. **優先順位付きTODOへ変換** — 締切 > 目的への結びつき > 前日からの持ち越し
5. **午前/午後に分割** — 午前=頭を使う作業（勉強・計画） / 午後=雑用（環境整備・軽作業）
6. **今日のTODOを提案** — `${OBSIDIAN_VAULT}/00-Inbox/YYYY-MM-DD_TODO.md`（新規）へ提案を出力

## 参照元 / 出力先

| 種別 | 場所 |
|------|------|
| 学びゴール（読み・時々書き） | `${OBSIDIAN_VAULT}/30-Resources/Learn-Goals.md`（主格）+ mnemon |
| 昨日の日記（読み） | `${OBSIDIAN_VAULT}/00-Inbox/YYYY-MM-DD_日記.md` |
| 過去のTODO（読み） | `${OBSIDIAN_VAULT}/00-Inbox/YYYY-MM-DD_TODO.md` |
| 今日のTODO（出力・新規） | `${OBSIDIAN_VAULT}/00-Inbox/YYYY-MM-DD_TODO.md` |

## 優先順位ルール

- **締切が最も硬いもの**（卒業研究・試験・TOEIC等）→ 最上位・午前
- **学びゴールで締切が近い/重要** → 毎日のルーティン枠（英語・Python等）
- **前日の未完了** → 今日へ前倒し
- **環境整備**（Obsidian最適化・ブラウザ拡張等）→ 午後・雑用枠

## 出力フォーマット

`skills/today/_TEMPLATE.md` を参照。frontmatter（title/date/tags 最低3タグ）+ `☀️午前 / 🌤️午後 / 🌙夜 / 🔁ルーティン / 📝メモ` の構成。

## DO / DON'T

**DO:**
- 日記・学びゴールを読んで**提案**する（強制しない）
- 前日の未達成を前倒し、発生タスクを追加する
- ユーザーパターン（午前=頭 / 午後=雑用）を内蔵する
- 既存 `${OBSIDIAN_VAULT}/00-Inbox/` の日記・やりたいことの**本文は改変しない**（読み取りのみ）

**DON'T:**
- スキーマ管理をユーザーに強制しない（life-todo方式に戻らない）
- ルーティンを「毎日同じものを並べる」固定で再生産しない（締切で重みが変動する）
- 新規TODOページ以外の既存ファイルを上書きしない
- `/session-kickoff` の全フェーズを再実行しない（ここではTODO作成のみ）