#!/bin/bash
MESSAGE="${1:-Claude Codeが待機中}"
TITLE="${2:-Claude Code}"

TMUX_TARGET=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')

terminal-notifier \
  -title "$TITLE" \
  -message "$MESSAGE" \
  -execute "/bin/bash -l -c '/usr/bin/open -a Ghostty && sleep 0.2 && tmux switch-client -t \"${TMUX_TARGET}\"'"
