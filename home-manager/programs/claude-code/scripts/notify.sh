#!/bin/bash
set -u

MESSAGE="${1:-Claude Codeが待機中}"
TITLE="${2:-Claude Code}"

[[ -z "${TMUX:-}" ]] && exit 0

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-code"
STATE_FILE="${STATE_DIR}/waiting-panes"
mkdir -p "$STATE_DIR"

PANE_INFO=$(tmux display-message -p '#{pane_id}	#{session_name}	#{window_index}	#{pane_index}') || exit 0
PANE_ID=$(printf '%s' "$PANE_INFO" | cut -f1)
SESSION=$(printf '%s' "$PANE_INFO" | cut -f2)
WIN_IDX=$(printf '%s' "$PANE_INFO" | cut -f3)
PANE_IDX=$(printf '%s' "$PANE_INFO" | cut -f4)
TARGET="${SESSION}:${WIN_IDX}.${PANE_IDX}"
TIMESTAMP=$(date +%s)

# タブと改行を除去してTSVフォーマットを壊さないようにする
SANITIZED_MESSAGE=$(printf '%s' "$MESSAGE" | tr '\t\n' '  ')

TMP="${STATE_FILE}.tmp.$$"
if [[ -f "$STATE_FILE" ]]; then
  awk -v p="$PANE_ID" -F '\t' '$1 != p' "$STATE_FILE" > "$TMP"
else
  : > "$TMP"
fi
printf '%s\t%s\t%s\t%s\n' "$PANE_ID" "$TARGET" "$TIMESTAMP" "$SANITIZED_MESSAGE" >> "$TMP"
mv "$TMP" "$STATE_FILE"

tmux select-pane -t "$PANE_ID" -P 'bg=red,fg=yellow' 2>/dev/null || true
tmux display-message "[${TITLE}] ${SANITIZED_MESSAGE}" 2>/dev/null || true
tmux refresh-client -S 2>/dev/null || true
