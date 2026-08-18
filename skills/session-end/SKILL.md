---
name: session-end
description: セッション終了儀式 — Gitコミット・プッシュ + memory保存 + auto-memory更新 を自動化
when_to_use: When the user says they're done for the session, mentions "終わる", asks for oreport, or naturally wraps up work
---

# session-end — セッション終了儀式（30秒で完結）

## 概要

セッション終了時に **Gitコミット・プッシュ + Memonic capture + Auto Memory更新 + Obsidianハンドオフ更新** を30秒で完了する。
memory/ が充実した今、構造化された記憶保存が基本。セッション状態は Obsidian `sessions/<topic>.md` へ分散管理（並列混在防止）。

## トリガー

- ユーザーが「session-end」「セッション終了」「終わった」「まとめて」等と発言
- 自然な区切りで自律判断しても可

---

## フロー（5 Phase / 30秒）

```
session-endトリガー
    │
    ├─ Phase 0: Git状態確認 (2秒)
    ├─ Phase 1: コミット・プッシュ (5秒) — 変更があれば
    ├─ Phase 2: Memonic capture（5秒）— 構造化セッションサマリー
    ├─ Phase 3: Auto Memory更新（2秒）— Claude Code自動記憶に記録
    └─ Phase 4: Obsidianハンドオフ更新（10秒）— session-router + sessions/<topic>.md
    └─ Phase 5: スナップショット保存（1秒）— JSON状態保存
```

---

## Phase 0: Git状態確認

```bash
git status --porcelain
git log --oneline -1
git branch --show-current
```

**Output**: ブランチ名、未コミット数、直近コミットハッシュ

---

## Phase 1: コミット・プッシュ

未コミット変更がある場合のみ実行。

### 1-1: Prefix自動推定

| 変更内容 | Prefix |
|---------|--------|
| 新規ファイル (`??`) | feat |
| 既存ファイル修正 (` M`) | fix |
| リネーム (`R`) | refactor |
| 削除 (`D`) | refactor |
| その他 | chore |

### 1-2: コミットメッセージ

```
<prefix>: <理由>
```

理由はユーザー入力優先。空なら「セッション成果をコミット」。

### 1-3: プッシュ

upstream設定済みなら自動push。未設定・競合時は記録のみ。

### 1-4: 完了確認

```bash
CLEAN=$(git status --porcelain | wc -l)
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
```

---

## Phase 2: Memonic capture（必須）

**Memonic Level 3** でセッションサマリーを `_episodic/sessions` に構造化保存。

過去セッションの記憶が消える問題を根本解決する。

### capture パラメータ

- **namespace**: `_episodic/sessions`
- **title**: `Session YYYY-MM-DD HH:MM`
- **tags**: `session, ClaudeCode, session-end`
- **confidence**: 0.9
- **half_life**: `P365D`（1年間保持）
- **content**: 構造化サマリー（下記テンプレート）

### content テンプレート

```markdown
## セッションサマリー: <YYYY-MM-DD HH:MM>

### 完了したこと
- <item>

### 未完了のこと
- <item>

### 次セッションでやること
- <item>

### 発見・学習事項
- <item>
```

### 実行方法

```bash
# Memonic MCP経由
mcp__cmdc-mnemonic__capture(
    namespace="_episodic/sessions",
    title="Session 2026-07-28 17:30",
    tags="session,ClaudeCode,session-end",
    confidence=0.9,
    half_life="P365D",
    content="<サマリーテキスト>"
)
```

capture失敗時は Phase 3-5 を実施、Memonicはスキップ（エラー出力するが失敗ではない）。

---

## Phase 3: Auto Memory更新（新規追加）

Claude Codeの **Auto Memory** にセッション成果を記録。
Auto Memoryは `~/.claude/projects/<project>/memory/MEMORY.md` と `memory/*.md` に保存される。

Memonic（構造化記録）とは異なり、Auto Memoryは**CLAUDE.md的な永続指示**として機能する。
例えば:
- 「このプロジェクトのビルドコマンドは `make build`」
- 「テストは `npm run test:ci` で実行」
- 「APIハンドラは `src/api/handlers/` ディレクトリにある」

### 更新方法

```bash
# Auto MemoryのMEMORY.mdを読み取り
cat ~/.claude/projects/$(git rev-parse --show-toplevel 2>/dev/null)/memory/MEMORY.md 2>/dev/null || echo "no auto-memory yet"
```

セッションで学習した永続知識を `memory/<topic>.md` に追記するか、既存ファイルに更新する。

---

## Phase 4: Obsidianハンドオフ更新（並列セッション分離・単一情報源）

**連動先**: `${OBSIDIAN_VAULT}/20-Areas/Claude-Code/`
（`session-router.md` + `sessions/<topic>.md`）。

`~/.claude/context.md` への単一更新・共有メモリへのセッション状態書き込みは**廃止**。
並列セッションの状態混在を防ぐため、状態は **トピック別ハンドオフ + ルーター索引** に分散管理する。

### 4-1: セッション名 / トピック特定
- 優先順: `/rename` 名 → ブランチ名 → 未確定なら {USER} に確認。
- topic = セッション名 = Obsidianノートキー（1トピック=1ノート、日付散乱させない）。

### 4-2: ハンドオフ更新
- 対象: `sessions/<topic>.md`。無ければ `sessions/_TEMPLATE.md` から作成。
- **インプレース更新**（新ハンドオフを乱造しない）: ゴール/進捗/未完了/次アクション/決定/changelog を追記。

### 4-3: ルーター索引更新
- `session-router.md` の該当行を更新（status flip / 行追加 / done なら「終了・done」へ移動）。

### 4-4: 耐久の横断的事実のみ mnemon / auto-memory へ
- セッション状態は共有メモリに書かない（混在防止）。
- トピックに依存しない耐久知識のみ、トピックタグ付きで保存。

### ハンドオフ記入テンプレート

```markdown
## ゴール
<セッション/タスクのゴールを1文で>
## 進捗（完了）
- <完了したこと>
## 未完了
- <未完了のこと>
## 次アクション
- <次セッションの最初のアクション>
## 決定事項
- <開いたまま/確定した決定>
## changelog
- YYYY-MM-DD: <今回の変更>
```

- Memonic（`_episodic/sessions`）は**履歴の完全保存**。複数セッションから検索可能
- Auto Memoryは**永続指示の保存**。次セッションで自動読み込み
- Obsidianハンドオフは**セッション状態の単一情報源**。session-router でどのトピックを再開するかを即答

---

## 次セッション開始方法（3つの選択肢）

### 方法A: `claude --resume`（公式推奨 ★）

```bash
claude --resume
```

会話履歴を復元。Memonic auto-reloadでプロジェクトの記憶も復活。

### 方法B: Obsidianルーター読込（ハンドオフ）

`20-Areas/Claude-Code/session-router.md` を開き、再開したいトピックの `sessions/<topic>.md` を確認 →「続きをやって」で再開。

### 方法C: Memonic検索（完全履歴）

```bash
mnemon search sessions 2026-07-28  # 完全履歴（構造化記録）
```

---

## PR作成

upstreamありかつ先行コミットがある場合のみ、ユーザー確認の上で実行。

```
PRを作成しますか？ (y/N)
```

自動化しない（個人リポジトリのため）。

---

## OBSIDIAN連携（ハンドオフ更新のみ）

**セッション状態のハンドオフ**は `20-Areas/Claude-Code/sessions/<topic>.md` + `session-router.md` へ書く（Phase 4）。
**00-Inbox 等の知識ノートは一切変更しない**（本文改変一律禁止）。週次サマリーの 00-Inbox 出力は従来通り行わない。

**00-Inbox への新規ノート作成は `/mid-point` 専用**: 中継時のみ `mid-point` スキルが調査レポート・プラン複製の
新規ノートを 00-Inbox/ に**作成**する（**既存ノートの改変ではなく新規作成**なので本文改変禁止ルールと矛盾しない）。
`session-end` 自身は 00-Inbox への書き込みを行わない。

---

## DO / DON'T

**DO:**
- Phase 2（Memonic capture）を必ず実行する
- Memonic + Auto Memoryの両方を更新する（構造化記録 + 永続指示）
- 次セッションで即再開できる粒度で書く
- 機密情報を除外する

**DON'T:**
- Phase 2〜4 をスキップする
- 検証フェーズを各セッション終了前に追加しない（実装中にL1都度実行で十分。hooks + CI gatesがコミュニティ標準）
- oreportを毎回実行しない（複雑なセッションのみ）
- 00-Inbox 等の知識ノートへの書き出しを入れない（`sessions/` 運用フォルダのみ更新可）

---

## 品質基準

- [ ] 実行時間 30秒以内
- [ ] Memonic capture 完了（セッションサマリー保存）
- [ ] Auto Memory 更新（永続記憶保存）
- [ ] git clean 状態で終了（未コミット残さない）
- [ ] 機密情報なし

---

## カスタマイズ

`.claude/settings.local.json` で調整可能:

```json
{
  "session-end": {
    "context_path": ".claude/context.md",
    "skip_push": false,
    "auto_prefix": true,
    "skip_mnemonic": true,
    "skip_context_md": true
  }
}
```

`skip_mnemonic: true` を設定すると Phase 2 をスキップ。
`skip_context_md: true` を設定すると Phase 4 をスキップ。
デフォルトは両方 `false`。
