#!/usr/bin/env bash
# session-end — セッション終了儀式 (30秒で完結)
# 使い方: bash ~/.claude/skills/session-end/run.sh

set -euo pipefail

# ============================================
# 最初に全stdinを読み取り保存（パイプ/ヒアドック/対話 すべて対応）
# ============================================
# stdinが端末でなければ全行読み取り、端末なら空配列
if [ ! -t 0 ]; then
    mapfile -t STDIN_LINES
else
    STDIN_LINES=()
fi
STDIN_IDX=0

# stdinから1行取り出すヘルパー（なければ空文字）
stdin_pop() {
    STDIN_POP_RESULT=""
    if [ $STDIN_IDX -lt ${#STDIN_LINES[@]} ]; then
        STDIN_POP_RESULT="${STDIN_LINES[$STDIN_IDX]}"
        STDIN_IDX=$((STDIN_IDX + 1))
    fi
}

# プロンプト付き読み取り（stdinにデータがあればそれを使う、なければ対話式）
prompt_read() {
    local prompt="$1"
    local var_name="$2"
    stdin_pop
    if [ -n "$STDIN_POP_RESULT" ]; then
        echo "$prompt$STDIN_POP_RESULT"
        printf -v "$var_name" "%s" "$STDIN_POP_RESULT"
    else
        read -p "$prompt" "$var_name"
    fi
}

echo "=== session-end: セッション終了儀式 ==="
echo ""

# Phase 0: Git状態確認
echo "--- Phase 0: Git状態確認 ---"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "N/A")
echo "ブランチ: $BRANCH"
echo "未コミット: $UNCOMMITTED ファイル"
echo "直近コミット: $LAST_COMMIT"
echo ""

# Phase 1: コミット・プッシュ（変更があれば）
echo "--- Phase 1: コミット・プッシュ ---"
PHASE1_COMMIT="変更なし"
PHASE1_PUSH="未実行"

if [ "$UNCOMMITTED" -gt 0 ]; then
    echo "未コミット変更を検出。コミットします..."
    git status --short

    # 変更種別から prefix 推定
    CHANGES=$(git status --short)
    if echo "$CHANGES" | grep -q "^??"; then
        PREFIX="feat"
    elif echo "$CHANGES" | grep -q "^ M"; then
        PREFIX="fix"
    elif echo "$CHANGES" | grep -q "^R"; then
        PREFIX="refactor"
    elif echo "$CHANGES" | grep -q "^ D"; then
        PREFIX="refactor"
    else
        PREFIX="chore"
    fi

    # 簡易的な理由生成（ユーザーに確認・stdinから取得）
    echo ""
    echo "推定 prefix: $PREFIX"
    prompt_read "コミットメッセージの理由を入力（空なら自動）: " USER_REASON

    if [ -n "$USER_REASON" ]; then
        REASON="$USER_REASON"
    else
        REASON="セッション成果をコミット"
    fi

    MSG="${PREFIX}: ${REASON}"
    git add -A
    if git commit -m "$MSG"; then
        PHASE1_COMMIT="完了 ($MSG)"
        echo "コミット完了: $MSG"
    else
        PHASE1_COMMIT="失敗"
        echo "コミット失敗"
        exit 1
    fi
else
    echo "未コミット変更なし - スキップ"
fi

# Push
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")

if [ -n "$UPSTREAM" ]; then
    if git push -u origin "$CURRENT_BRANCH" 2>/dev/null; then
        PHASE1_PUSH="完了"
        echo "プッシュ完了"
    else
        PHASE1_PUSH="失敗/競合 (手動解決必要)"
        echo "プッシュ失敗 - 手動で解決してください"
    fi
else
    PHASE1_PUSH="upstream未設定"
    echo "upstream未設定 - 手動push必要"
fi

# 完了確認
CLEAN=$(git status --porcelain 2>/dev/null | wc -l)
AHEAD=0
[ -n "$UPSTREAM" ] && AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
echo "Phase 1完了: コミット=$PHASE1_COMMIT, プッシュ=$PHASE1_PUSH"
echo ""

# Phase 2: CONTEXT.md 更新（必須）
echo "--- Phase 2: CONTEXT.md 更新 ---"
CONTEXT_FILE=".claude/context.md"
mkdir -p "$(dirname "$CONTEXT_FILE")"

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

# 完了・未完了・次やること の入力（保存済みstdinから取得）
prompt_read "完了したこと: " DONE
prompt_read "未完了のこと: " UNDONE
echo "次セッションでやること（改行区切り、空行で終了）:"

NEXT_THINGS=""
while true; do
    stdin_pop
    if [ -z "$STDIN_POP_RESULT" ]; then
        # stdin枯渇 → 対話式で続行（EOFでもエラーにしない）
        while IFS= read -r line || [ -n "$line" ]; do
            [ -z "$line" ] && break
            NEXT_THINGS="${NEXT_THINGS}${line}"$'\n'
        done
        break
    fi
    NEXT_THINGS="${NEXT_THINGS}${STDIN_POP_RESULT}"$'\n'
done

# 次やることを配列化
NEXT_LIST=""
if [ -n "$NEXT_THINGS" ]; then
    IFS=$'\n' read -r -d '' -a NEXT_ARRAY <<< "$NEXT_THINGS" || true
    for item in "${NEXT_ARRAY[@]}"; do
        [ -n "$item" ] && NEXT_LIST="${NEXT_LIST}- $item"$'\n'
    done
fi

cat > "$CONTEXT_FILE" << EOF
## 現在の状態 ($DATE $TIME 更新)
- **ブランチ**: $BRANCH
- **直近コミット**: $LAST_COMMIT
- **完了**: ${DONE:-なし}
- **未完了**: ${UNDONE:-なし}
- **次セッションでやること**:
${NEXT_LIST:-  (未入力)}

---
*前回セッション終了時刻: $DATE $TIME*
*次回は \`cat .claude/context.md\` を読んでから「続きをやって」で再開*
EOF

echo "CONTEXT.md 更新完了: $CONTEXT_FILE"
echo ""

# Phase 3: 終了
echo "=== セッション終了 ==="
echo ""
echo "次回開始時:"
echo "  1. cat .claude/context.md  # 状態把握（3秒）"
echo "  2. \"続きをやって\" と伝えるだけで再開"
echo ""

# PR作成確認（upstreamありかつ先行コミットがある場合）
if [ -n "$UPSTREAM" ] && [ "$AHEAD" -gt 0 ]; then
    prompt_read "PRを作成しますか？ (y/N): " REPLY
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v gh &>/dev/null; then
            gh pr create --fill
        else
            echo "gh CLIが見つかりません。手動でPR作成してください。"
        fi
    fi
fi

echo "完了。お疲れさまでした。"