# ai-agent-starter

**どの AI Agent でも・誰でも使える、安心安全な AI エージェント運用スターターキット。**

Claude Code・GitHub Copilot CLI・Codex・Cursor など、エージェントに依存しない「共通規範 + スキル + テンプレート」を収めた公開リポジトリです。実キー・個人情報・絶対パス・機種依存のモデルIDは一切含みません（`.env.example` 形式と `${ENV_VAR}` 参照のみ）。

## これが含むもの

| 領域 | エージェント | 説明 |
|------|-------------|------|
| [`AGENTS.md`](AGENTS.md) | **全エージェント共通** | 動作規範の要約 + 各ファイルへのポインタ（共通方言） |
| [`CLAUDE.md`](CLAUDE.md) | Claude Code | Claude 固有のロード順序・スキル起動方法 |
| [`rules/`](.claude/rules/) | Claude Code | 汎用ルール（安全・git・品質・コミュニケーション） |
| [`skills/`](skills/) | **ほぼ全エージェント** | SKILL.md 形式のスキル正本（単一情報源） |
| [`templates/`](templates/) | 全エージェント | 新規 skill / rule 作成テンプレート |
| [`scripts/`](scripts/) | 全エージェント | インストール・秘密漏洩チェック |
| [`examples/`](examples/) | 全エージェント | MCP / hooks 設定サンプル（無効・{ENV}参照のみ） |
| [`optional/`](optional/) | Claude Code（個人運用） | セッションワークフロー・Inbox整理・Obsidianリファレンス（既定インストール対象外・手動） |

## クイックスタート

### スキルを自分のエージェントへ配置

```bash
# Claude Code 用に .claude/skills/ へ配置
./scripts/install.sh claude

# GitHub Copilot CLI 用に .github/skills/ へ配置
./scripts/install.sh copilot

# dry-run（何が配置されるか確認のみ）
./scripts/install.sh --dry-run claude
```

インストールは「コピー」なので、スキル正本 `skills/<name>/SKILL.md` を編集すれば再実行で再配置できます。

### ルール・規範の取り込み

- **Claude Code**: `CLAUDE.md` と `.claude/rules/*.md` をプロジェクトへコピー。
- **その他のエージェント**（Copilot CLI / Codex / Cursor 等）: `AGENTS.md` をプロジェクト直下へ置く。15+ の主要ツールが読みます。
- リポジトリ自体を「参考資料」として読むだけでも構いません。

### 公開前の安全ゲート

```bash
./scripts/lint-secrets.sh   # 実キー・絶対パス・固有名の混入を検出（なければ何も出力しない）
```

CI 上でも実行されます（`.github/workflows/lint-secrets.yml`）。

## 設計方針

- **AGENTS.md 中心（汎用優先）**: 全エージェントが読む共通方言を主軸に、Claude 固有設定は明示的に分離。
- **スキルはエージェント中立**: `skills/<name>/SKILL.md` を正本とし、各エージェントの配置先（`.claude/skills` / `.github/skills`）へ script で展開。
- **秘密ゼロ**: 実キー・`{USER}` 固有名・絶対パス・機種依存のモデルIDは禁止。設定は `${ENV_VAR}` 参照のみ。
- **個人情報なし**: `templates/` と `MAP.md` だけで自己流に拡張。スターター自体は汎用のまま。

## 注意: エージェント依存のスキル

- **`research` はサブエージェントの並列実行を前提**としています（エージェント横断調査・多視点検証）。その実現方法はAIエージェントごとに異なるため、使用するエージェントの**ベストプラクティスをそのエージェントのドキュメントで確認**し、スキル手順を読み替えて適用してください（例: Claude Code の Task 機能、各エージェントの並列調査プラクティス）。
- その他のスキルは原則エージェント中立です（Markdown 手順としてそのまま機能）。

## カスタマイズ

- スキルを追加: `templates/skill/SKILL.md` を参考に `skills/<name>/SKILL.md` を作成 → `install.sh` で配置。
- ルールを追加: `templates/rule.md` を参考に `.claude/rules/` へ。
- 環境別の設定: `.env` をコピーして実キーを設定（追跡対象外）。

## オプション: Claude Code セッションワークフロー（`optional/`）

`skills/` とは別に、**Claude Code 固有 + 個人運用特化**のセッション運用スキルを `optional/` に収録しています。エージェント汎用の `skills/` とは性質が異なるため**既定ではインストールされません**。

| スキル | 役割 |
|--------|------|
| [`optional/session-kickoff/`](optional/session-kickoff/) | セッション冒頭のキックオフ（ゴール→WBS→並列リサーチ→プラン→引継ぎ→Go待ち） |
| [`optional/mid-point/`](optional/mid-point/) | 調査→実装を別セッションへ分ける中継保存 |
| [`optional/session-end/`](optional/session-end/) | セッション終了儀式（commit/push + 記憶保存 + 状態更新） |
| [`optional/oreport/`](optional/oreport/) | セッション終了レポート（複雑セッションの議事録） |
| [`optional/inbox-organize/`](optional/inbox-organize/) | Obsidian Inbox 整理（00-Inbox → PARA） |
| [`optional/obsidian-notetaking/`](optional/obsidian-notetaking/) | Obsidian 運用方法の抽象化リファレンス（参照ドキュメント） |
| [`optional/arch-design/`](optional/arch-design/) | アーキテクチャ・アルゴリズム設計（決定解決ループ + 低認知負荷文書、汎用RAG設計内蔵） |

詳しい導入・プレースホルダ設定は [`optional/README.md`](optional/README.md) を参照してください。
これらは個人情報（`{USER}`・絶対パス）をプレースホルダ化して収録しており、自分の環境で使う前に実値へ置き換えます。

## ライセンス

MIT（[LICENSE](LICENSE)）。スキル・ルールも自由に利用・改変できます。

## 参照

- 構造索引: [`MAP.md`](MAP.md)
- スキル例: `templates/skill/SKILL.md` を参考に `skills/<name>/SKILL.md` を作成して追加
