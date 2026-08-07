# hooks サンプル

> ⚠️ **Hooks はエージェント固有のしくみです。**
> ここに示す hooks は Claude Code の `.claude/settings.json` に書く形式です。Copilot CLI / Codex / Cursor では独自のフック機構を使います（設定項目名・イベント名が異なる）。

## このサンプルが含むもの

唯一の実動例として、**`lint-secrets`（公開前の秘密漏洩チェック）** を用意しています。これはエージェント非依存の安全ゲートとして汎用的に価値があります。

- `scripts/lint-secrets.sh` — 実キー・絶対パス・固有名の混入を検出（ここが実体）
- 配線方法 → `.claude/settings.example.json`（下記参照）

## 設定例（Claude Code）

`.claude/settings.example.json` を `.claude/settings.local.json` にコピーし、必要なら有効化する。

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/lint-secrets.sh"
          }
        ]
      }
    ]
  }
}
```

## 方針

- 本リポジトリの hooks は**サンプル・無効**が原則。実設定をコミットしない。
- 実キー・個人パスを hooks や設定に埋め込まない（`${ENV_VAR}` 参照のみ）。
- 具体的なエージェント固有のフック追加は、各エージェントの公式ドキュメントを参照する。
