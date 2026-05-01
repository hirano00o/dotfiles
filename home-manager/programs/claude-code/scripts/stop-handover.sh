#!/usr/bin/env bash
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

HANDOVER_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/handovers"

# 短いセッション（assistant メッセージが3件以下）はスキップ
# claude -p やワンショット利用を想定
MSG_COUNT=0
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  MSG_COUNT=$(jq -rs '[.[] | select(.type == "assistant")] | length' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")
  if [ "$MSG_COUNT" -le 3 ]; then
    exit 0
  fi
fi

# 5分以内の handover ファイルがあれば通過
if [ -d "$HANDOVER_DIR" ]; then
  recent=$(find "$HANDOVER_DIR" -name '*.md' -mmin -5 -print -quit 2>/dev/null)
  if [ -n "$recent" ]; then
    exit 0
  fi
fi

# セッション内で既にプロンプト済み＆メッセージ数が増えていなければ通過（ループ防止＋resume対応）
LOCK="/tmp/claude-handover-prompted-${SESSION_ID}"
if [ -n "$SESSION_ID" ] && [ -f "$LOCK" ]; then
  LAST_COUNT=$(cat "$LOCK")
  if [ "$MSG_COUNT" -le "$((LAST_COUNT + 3))" ]; then
    exit 0
  fi
fi

# メッセージ数を記録＆block
if [ -n "$SESSION_ID" ]; then
  echo "$MSG_COUNT" > "$LOCK"
fi

echo '{"decision":"block","reason":"セッション終了前に /handover を実行して引き継ぎノートを生成してください。"}'
exit 0
