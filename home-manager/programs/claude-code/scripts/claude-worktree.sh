#!/bin/bash
WORKTREE_NAME="${1:-}"

if [[ -z "$WORKTREE_NAME" ]]; then
  exec claude
fi

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  printf '\033[0;31m[claude-worktree] gitリポジトリではありません\033[0m\n'
  printf 'Enterを押して閉じる: '
  read -r
  exit 1
fi

claude -w "$WORKTREE_NAME"
STATUS=$?

if [[ $STATUS -ne 0 ]]; then
  printf '\033[0;31m[claude-worktree] 失敗しました (exit %d)\033[0m\n' "$STATUS"
  printf 'Enterを押して閉じる: '
  read -r
fi
