# mid-point — 雛形一式（FORMS）

`/mid-point` が生成・更新するファイルの雛形。コピーして使う。

---

## 1. 調査レポート（Obsidian 00-Inbox/YYYY-MM-DD_<topic>_調査レポート.md）

```markdown
---
title: "<topic> 調査レポート"
date: YYYY-MM-DD
tags:
  - type/report
  - area/<カテゴリ>
  - status/active
---
> `/mid-point` で自動作成。`/inbox-organize` で整理するまでの Raw RAM。
> 生詳細は調査エージェントの一時ファイル（~/.claude/tmp/research/<topic>/）から統合済み。

## 調査目的
<この調査で明らかにしたかったこと。検証可能な問いの形で>

## 調査項目
- <項目1>
- <項目2>

## チャネル別サマリー
### official-docs / github / reddit / x
- **結論**: <1-2文>
- **根拠**: <URL>
- **詳細**: <一時ファイル名 or 補足>

## 重要な発見（設計に影響する事実）
- <事実1>（出典: URL）
- <事実2>（未検証）

## 判断過程・トレードオフ
- <案A vs 案B の比較と採用理由>

## 未解決の疑問（open questions）
- <次セッションで解決すべき疑問>

## 出典一覧
- [タイトル](URL) — <1行メモ>
```

---

## 2. プラン（機械読取の正: ~/.claude/plans/<task>.md）

```markdown
# <task> 実装プラン（生きた文書）

作成: YYYY-MM-DD | 状態: 進行中（調査完了・実装待ち）
種別: 調査→実装（調査は前セッションで完了。実装は新セッション）

## 変更履歴（changelog）
| version | 日付 | 変更内容 |
|---------|------|---------|
| 0.1.0 | YYYY-MM-DD | 初版（調査結果を統合） |

## 新事実・決定ログ
- YYYY-MM-DD: <調査で判明した重要事実・採用判断>

---

## 1. ゴールと合格条件（検証可能）

### ゴール
<何を達成するか1文>

### 合格条件
- [ ] <検証可能な条件1>
- [ ] <検証可能な条件2>

## 2. 改善案（Best of N 比較・採用理由）

### 案A: <概要>
- 利点: / 欠点:
### 案B: <概要>
- 利点: / 欠点:
**採用**: 案A（理由: <…>）

## 3. WBS
| # | タスク | cost | 依存 | 完了 |
|---|--------|------|------|------|
| 1 | <タスク> | S | - | ☐ |

## 4. セッション分割
- Session A（調査）: 完了（前セッション）
- Session B（実装）: 本プランに沿って実行

## 5. 懸念・未決定
- <未解決の疑問・次セッション冒頭で確認する点>

---

## 参考: 調査レポート
Obsidian `00-Inbox/YYYY-MM-DD_<topic>_調査レポート.md`（根拠URL・未検証マーク含む）
```

---

## 3. プラン複製（Obsidian 00-Inbox/YYYY-MM-DD_<topic>_プラン.md）

```markdown
---
title: "<topic> プラン（閲覧用）"
date: YYYY-MM-DD
tags:
  - type/plan
  - area/<カテゴリ>
  - status/active
---
> **正は `~/.claude/plans/<task>.md`**（機械読取・生きた文書）。本ノートは閲覧用スナップショット。
> `/mid-point` 実行時に再同期（トピック名で検索→インプレース更新 or 新規作成）。
> `/inbox-organize` で移動しても、次の /mid-point がトピック名で探し直す。

## ゴール・合格条件
<プラン正の Section 1 を転記>

## 改善案（要約）
<採用案1行>

## WBS（要約）
<表 or 一覧>

## changelog
- YYYY-MM-DD: <今回の同期内容>
```

---

## 4. ハンドオフ（sessions/<topic>.md。既存 _TEMPLATE.md 準拠）

`sessions/_TEMPLATE.md` をコピーして使う。`/mid-point` はこれをインプレース更新する。

```markdown
---
title: "<topic> セッションハンドオフ"
date: YYYY-MM-DD
tags:
  - type/session
  - status/active
  - area/claude-code
session-name: "<topic>"
status: waiting            # active | waiting | done
next-action: "<新セッションで最初にすること>"
priority: high
---
> 運用専用（自動更新）。この `sessions/` フォルダ内のみ本文更新可。

## ゴール
<セッション/タスクのゴールを1文で>

## 進捗（完了）
- 調査完了（前セッション）: <実施した調査>

## 未完了
- 実装（新セッションで）

## 次アクション
- 再開パクトの「最初の命令」を実行

## 決定事項
- <確定した・開いたままの決定>

## changelog
- YYYY-MM-DD: /mid-point で中継完了。調査→実装の引き継ぎ
```

---

## 5. 再開パクト（画面出力のみ・ファイル化しない）

```
# 再開パクト: <topic>

## 開始コマンド
claude -n <topic>

## 最初の命令（貼り付ける）
「~/.claude/plans/<task>.md と Obsidian 00-Inbox/<YYYY-MM-DD>_<topic>_調査レポート.md を読んで、実装タスクを開始して」

## 参照
- 調査レポート: 00-Inbox/<YYYY-MM-DD>_<topic>_調査レポート.md
- プラン正: ~/.claude/plans/<task>.md
- プラン複製: 00-Inbox/<YYYY-MM-DD>_<topic>_プラン.md
- ハンドオフ: 20-Areas/Claude-Code/sessions/<topic>.md
```