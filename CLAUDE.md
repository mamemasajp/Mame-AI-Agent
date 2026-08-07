# CLAUDE.md — Claude Code 固有レイヤ

> Claude Code でこのリポジトリ（または配布した内容）を運用する場合に読むファイル。
> **他エージェント（Copilot CLI / Codex / Cursor 等）は [AGENTS.md](AGENTS.md) を参照**してください。
> 構造索引は [MAP.md](MAP.md)。

## 役割

- `CLAUDE.md` は「ルーター」: ロード順序・基本ワークフロー・設計思想を定義。
- 動作規範（品質・git・安全・コミュニケーション）の実体は **`AGENTS.md`** に置き、ここから参照する（重複を避ける: SKILL.md に手順があるならここには書かない）。

## ロード順序（Claude Code）

```
AGENTS.md (共通規範 — こちらが実体)
  → CLAUDE.md (このファイル — Claude 固有の約束事)
    → .claude/rules/*.md (条件付き・トピック別ルール)
      → .claude/skills/*/SKILL.md (オンデマンド手順 — 必要時のみロード)
```

## このリポジトリの Claude Code での使い方

1. プロジェクトに本リポジトリの内容を配布 or 参照。
2. 実体ルールは `AGENTS.md` → 重複させずに Claude 固有の差分だけここに追記する。
3. スキルは `skills/<name>/SKILL.md` を正本とし、`./scripts/install.sh claude` で `.claude/skills/` へ配置。
4. ルールは `.claude/rules/` に置く（`templates/rule.md` 参照）。

## 原則（Claude Code 運用時）

- **日本語応答・敬体**などは環境設定（settings.local.json / rules）で一元化し、このファイルには書かない。
- **スキルは減らすことが大事**: 3 週間使わないスキルは削除 or 作り直しを検討する。
- セッション終了時は `session-end` 系スキルで記憶保存・コミットを自動化する（あれば）。
