# Copilot Instructions

> GitHub Copilot CLI 用の入口。動作規範の実体はリポジトリ直下の [AGENTS.md](../AGENTS.md) にあり、ここはそれを指す薄いポインタ。

GitHub Copilot CLI（および AGENTS.md を読む他のエージェント）は、リポジトリ直下の **`AGENTS.md`** を参照してください。そこに品質・git・安全・コミュニケーションの規範と、各領域（CLAUDE.md / rules / skills / templates / scripts）へのポインタがあります。

- 動作規範（義務）: `AGENTS.md`
- スキル配置: `./scripts/install.sh copilot` で `.github/skills/<name>/SKILL.md` へ
- 公開前ゲート: `./scripts/lint-secrets.sh`

> もし本ファイルを適用したいプロジェクトが、他エージェント専用なら `AGENTS.md` だけをルートに配置してください（15+ ツールが読める汎用形式）。