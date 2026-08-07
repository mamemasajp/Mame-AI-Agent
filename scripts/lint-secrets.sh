#!/usr/bin/env bash
#
# lint-secrets.sh — 公開前の秘密情報・個人情報漏洩チェック（安全ゲート）
#
# 使い方:
#   scripts/lint-secrets.sh                 # 追跡対象を検査（一致で exit 1）
#   LINT_PERSONAL_MARKERS=soyak scripts/lint-secrets.sh
#       # 追加の個人マーカー（カンマ区切り）を指定して検査（例: 自分のユーザー名・絶対パス）
#
# 検出対象:
#   1. 実APIキー / 秘密鍵の形式（sk-or-v1-*, ghp_*, AKIA*等）
#   2. 秘密鍵ブロック（BEGIN ... PRIVATE KEY）
#   3. ローカル絶対パス（/home/<user>, /Users/<user>, /mnt/c/Users/<user>）
#   4. LINT_PERSONAL_MARKERS で指定された固有名（空ならスキップ）
#
# 設計: このスクリプト自身は固有名をハードコードしない（汎用）。
#       自身のリポジトリ検査時は LINT_PERSONAL_MARKERS で自分の名前/パスを渡す。

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# --- 検出パターン ---
SECRET_PATTERNS=(
  'sk-[A-Za-z0-9]{20,}'                  # OpenAI/OpenRouter 等
  'sk-or-v1-[A-Za-z0-9]{10,}'
  'gh[pousr]_[A-Za-z0-9]{20,}'           # GitHub tokens
  'AKIA[0-9A-Z]{16}'                     # AWS
  'xox[bap]-[A-Za-z0-9]{10,}'            # Slack
  'tvly-[A-Za-z0-9]{10,}'                # Tavily
  'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'  # JWT
)
PRIVATE_KEY_PATTERN='-----BEGIN (RSA |EC |OPENSSH |PGP |ENCRYPTED )?PRIVATE KEY'
HOME_PATH_PATTERN='/home/[A-Za-z0-9_.-]+|/Users/[A-Za-z0-9_.-]+|/mnt/c/Users/[A-Za-z0-9_.-]+'

# --- 検査対象: git追跡ファイル（gitignore済みは除外）.gitignore対象も含める ---
# 注: 本スクリプト自身を除外（自ソースのパターン文字列に自己一致するため）
SELF="scripts/lint-secrets.sh"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  FILES="$(git ls-files | grep -v '^\.git' | grep -v "^$SELF$")"
fi
# 未コミット/非git: find フォールバック（空のまま grep が stdin を読むのを防ぐ）
if [ -z "${FILES:-}" ]; then
  FILES="$(find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path "./$SELF")"
fi

FAIL=0
report() { # msg file line
  echo "❌ $1: $2"
  echo "   $3"
  FAIL=1
}

# 1) 実キー形式
for pat in "${SECRET_PATTERNS[@]}"; do
  while IFS=: read -r f line rest; do
    [ -z "$f" ] && continue
    report "実キー可能性 ($pat)" "$f:$line" "$rest"
  done < <(grep -rnE "$pat" $FILES 2>/dev/null)
done

# 2) 秘密鍵ブロック
while IFS=: read -r f line rest; do
  [ -z "$f" ] && continue
  report "秘密鍵ブロック" "$f:$line" "$rest"
done < <(grep -rnE "$PRIVATE_KEY_PATTERN" $FILES 2>/dev/null)

# 3) ローカル絶対パス（候補）
while IFS=: read -r f line rest; do
  [ -z "$f" ] && continue
  report "絶対パス(WSL/macOS)の可能性" "$f:$line" "$rest"
done < <(grep -rnE "$HOME_PATH_PATTERN" $FILES 2>/dev/null)

# 4) 個人マーカー（環境で指定された場合のみ）
if [ -n "${LINT_PERSONAL_MARKERS:-}" ]; then
  IFS=',' read -ra MARKERS <<< "$LINT_PERSONAL_MARKERS"
  for m in "${MARKERS[@]}"; do
    [ -z "$m" ] && continue
    while IFS=: read -r f line rest; do
      [ -z "$f" ] && continue
      report "個人マーカー「$m」" "$f:$line" "$rest"
    done < <(grep -rnF "$m" $FILES 2>/dev/null)
  done
fi

if [ "$FAIL" = 0 ]; then
  echo "✅ 秘密・個人情報の混入なし（$(echo "$FILES" | grep -c . || true) ファイル検査）"
  exit 0
else
  echo ""
  echo "⚠️  公開前にセキュリティリスクを検出しました。修正 or 対象除外（.gitignore）してから再実行してください。"
  exit 1
fi