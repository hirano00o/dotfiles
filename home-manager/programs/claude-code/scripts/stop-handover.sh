#!/usr/bin/env bash
HANDOVER_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/handovers"
if [ -d "$HANDOVER_DIR" ]; then
  recent=$(find "$HANDOVER_DIR" -name '*.md' -mmin -5 -print -quit 2>/dev/null)
  if [ -n "$recent" ]; then
    exit 0
  fi
fi
echo '{"decision":"block","reason":"セッション終了前に /handover を実行して引き継ぎノートを生成してください。"}'
exit 0
