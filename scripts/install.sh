#!/usr/bin/env bash
#
# install.sh — スキル正本 skills/<name>/SKILL.md を各エージェントの配置先へコピー
#
# 使い方:
#   scripts/install.sh claude             # .claude/skills/ へ配置（Claude Code）
#   scripts/install.sh copilot            # .github/skills/ へ配置（GitHub Copilot CLI: プロジェクト用）
#   scripts/install.sh copilot-personal   # ~/.copilot/skills/ へ配置（Copilot CLI: 個人用）
#   scripts/install.sh --dry-run claude   # 何が配置されるか確認のみ
#
# 方針: 正本 skills/ は単一情報源。.claude/skills と .github/skills はコピーで再生成する（手動編集禁止）。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DRY=0
[ "${1:-}" = "--dry-run" ] && { DRY=1; shift; }

TARGET_ARG="${1:-}"
case "$TARGET_ARG" in
  claude)           DEST=".claude/skills" ;;
  copilot)          DEST=".github/skills" ;;
  copilot-personal) DEST="$HOME/.copilot/skills" ;;
  *)
    echo "usage: $0 [--dry-run] <claude|copilot|copilot-personal>" >&2
    exit 2
    ;;
esac

# 対象スキル一覧（正本あり・サブディレクトリに SKILL.md を持つもの）
SKILLS=()
for d in skills/*/; do
  name="$(basename "$d")"
  [ -f "$d/SKILL.md" ] || continue
  SKILLS+=("$name")
done

[ ${#SKILLS[@]} -eq 0 ] && { echo "⚠️  skills/*/SKILL.md が見つかりません" >&2; exit 1; }

echo "▶ 配置先: $DEST/（$([ "$DRY" = 1 ] && echo DRY-RUN || echo 実行)）"
for name in "${SKILLS[@]}"; do
  src="skills/$name/SKILL.md"
  dst="$DEST/$name/SKILL.md"
  extra=("$src")   # 正本に付随ファイル（_schema.md / references/ 等）があれば同梱
  for f in skills/$name/_schema.md skills/$name/references; do
    [ -e "$f" ] && extra+=("$f")
  done
  if [ "$DRY" = 1 ]; then
    echo "  [dry] $src -> $dst ${extra[*]:1}"
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  for f in "${extra[@]:1}"; do
    cp -r "$f" "$(dirname "$dst")/" 2>/dev/null || true
  done
  echo "  ✔ $name"
done

echo "完了。$([ "$DRY" = 1 ] && echo '（DRY-RUN — 実ファイル未作成）' || echo '正本を再編集しても再実行で再配置できます。')"