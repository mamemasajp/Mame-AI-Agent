# optional/ — Claude Code 個人運用セッションワークフロー

`optional/` は **Claude Code 固有 + 個人運用特化** のセッション運用スキル群です。
`skills/`（エージェント中立・install.sh で全エージェントへ展開）とは異なり、**既定ではインストールされません**。自分の環境へ合わせて手動で使います。

> 本領域は「秘密ゼロ・個人情報なし」方針に従い、個人パス・固有名をプレースホルダ化して収録しています。値の埋め方は後述の [プレースホルダ](#プレースホルダ) を参照。

## 収録スキル

| スキル | 役割 |
|--------|------|
| [`session-kickoff/`](session-kickoff/) | セッション冒頭のキックオフ（ゴール設定→WBS→並列リサーチ→プラン策定→引継ぎ→Go待ち） |
| [`mid-point/`](mid-point/) | 調査→実装を別セッションへ分ける中継保存。コンテキスト圧迫時の引き継ぎ |
| [`session-end/`](session-end/) | セッション終了儀式（git commit/push + 記憶保存 + セッション状態更新） |

## 依存（任意・Claude Code 前提）

- 3スキルは **Claude Code** 固有（`claude -n`、`/rename`、`AskUserQuestion`、Task 並列等を参照）。
- `session-kickoff` / `mid-point` は並列リサーチに **サブエージェント**（`research` 等）と、状態管理に **Obsidian** の `sessions/` + `session-router.md` を想定。
- `session-end` は記憶保存に **MCP**（例: `mnemon` / `cmdc-mnemonic`）を任意依存として利用（無ければスキップ）。
- すべて **必須ではない**。使わない連携は該当フェーズをスキップして動作します。

## プレースホルダ

サニタイズのため、個人情報を以下のプレースホルダに置き換えて収録しています。自分の環境で使う前に実値へ置き換えてください。

| プレースホルダ | 意味 | 設定例 |
|---------------|------|--------|
| `{USER}` | ユーザー名 | 自分のアカウント名（例: `yourname`） |
| `${OBSIDIAN_VAULT}` | Obsidian Vault のルート絶対パス | `/mnt/c/Users/<you>/ObsidianVault`・`/Users/<you>/ObsidianVault` 等 |

例（`optional/session-end/SKILL.md`）:
```
**連動先**: ${OBSIDIAN_VAULT}/20-Areas/Claude-Code/
```
→ 自分の環境なら:
```
**連動先**: /mnt/c/Users/<you>/ObsidianVault/20-Areas/Claude-Code/
```

## 導入（手動）

汎用 `skills/` とは別管理です。自分の Claude Code へ配置するには、スキルごとコピーします。

```bash
# 例: session-end を配置
cp -r optional/session-end ~/.claude/skills/

# 例: 3つまとめて配置
cp -r optional/session-kickoff optional/mid-point optional/session-end ~/.claude/skills/
```

配置後、`--` 冒頭のプレースホルダ（`{USER}` / `${OBSIDIAN_VAULT}`）を自分の実値へ置き換えてください。

## 秘密・個人情報ポリシー

本領域に実キー・固有名・絶対パスは**含めません**（`lint-secrets.sh` の検出対象）。追加・編集時も同様にプレースホルダ方式を守ってください。

```bash
./scripts/lint-secrets.sh   # ゼロ件を確認してからコミット
```
