# MAP — リポジトリ構造索引

> このリポジトリ（ai-agent-starter）の単一索引。各領域の役割・入口をここで一元管理する。

## 領域一覧

| 領域 | 役割 | 入口 | エージェント |
|------|------|------|--------------|
| **AGENTS.md** | エージェント共通の動作規範（品質・git・安全・コミュニケーション） | 実行時自動読込 | 全エージェント |
| **CLAUDE.md** | Claude Code 固有レイヤ（ロード順序・使い方） | 実行時自動読込 | Claude Code |
| **README.md** | 概要・インストール手順・ライセンス | 人間用 | — |
| **.claude/rules/** | 汎用ルール（n-<topic>.md） | 実行時自動読込（条件付き） | Claude Code |
| **skills/** | スキル正本（`<name>/SKILL.md`、単一情報源） | `Skill` ツール / `/name` | ほぼ全エージェント |
| **.claude/skills/** | install.sh で生成（Claude 用配置先） | `Skill` ツール | Claude Code |
| **.github/skills/** | install.sh で生成（Copilot 用配置先） | `Skill` ツール | GitHub Copilot CLI |
| **templates/** | 新規 skill / rule 作成テンプレート | 手動 | 全エージェント |
| **examples/** | MCP / hooks 設定サンプル（無効・{ENV}参照のみ） | 手動 | 全エージェント |
| **optional/** | セッションワークフロー・Inbox整理・Obsidianリファレンス（Claude Code 個人運用・既定展開なし） | 手動（cp） | Claude Code |
| **scripts/** | install.sh / lint-secrets.sh | CLI | 全エージェント |
| **.github/workflows/** | CI（秘密漏洩チェック） | push 時 | CI |

## 参照マップ（誰が何を参照するか）

- **AGENTS.md** → CLAUDE.md（Claude 固有）、skills/、templates/、scripts/
- **CLAUDE.md** → AGENTS.md（規範実体）、.claude/rules/、.claude/skills/
- **README.md** → scripts/install.sh、AGENTS.md、MAP.md、optional/
- **scripts/install.sh** → skills/<name>/SKILL.md → .claude/skills/ または .github/skills/（optional/ は対象外）
- **scripts/lint-secrets.sh** → リポジトリ全体（秘密検出）+ CI
- **optional/** → 個人運用セッションワークフロー・Inbox整理・Obsidianリファレンス（`{USER}` / `${OBSIDIAN_VAULT}` プレースホルダ。手動コピーで導入）

## 秘密・個人情報ポリシー

- 実APIキー・`{USER}` 固有名・絶対パス・機種依存のモデルIDは**このリポジトリに置かない**。
- 設定は `${ENV_VAR}` 参照のみ（`.env.example` 形式）。
- 公開前は必ず `./scripts/lint-secrets.sh`（ゼロ件）を確認する。

## 拡張時の注意

- スキルは `skills/`（正本）だけを編集し、`.claude/skills` / `.github/skills` は install.sh で再生成する（手動編集禁止）。
- 新規カタログを乱立させない。索引はこの1枚に集約する。
