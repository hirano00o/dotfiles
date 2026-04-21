#!/bin/bash
set -u

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-code"
STATE_FILE="${STATE_DIR}/waiting-panes"
SCRIPT_PATH="$0"

ensure_state_dir() {
  mkdir -p "$STATE_DIR"
}

remove_pane_from_state() {
  local pane="$1"
  [[ ! -f "$STATE_FILE" ]] && return 0
  local tmp="${STATE_FILE}.tmp.$$"
  awk -v p="$pane" -F '\t' '$1 != p' "$STATE_FILE" > "$tmp"
  mv "$tmp" "$STATE_FILE"
}

reset_pane_border() {
  local pane="$1"
  tmux select-pane -t "$pane" -P '' 2>/dev/null || true
}

cmd_count() {
  local n=0
  if [[ -f "$STATE_FILE" ]]; then
    n=$(wc -l < "$STATE_FILE" | tr -d ' ')
  fi
  if (( n > 0 )); then
    printf '#[fg=red,bold][待機 %d]#[default] ' "$n"
  fi
}

cmd_clear() {
  [[ -z "${TMUX:-}" ]] && return 0
  local pane_id
  pane_id="$(tmux display-message -p '#{pane_id}')" || return 0
  remove_pane_from_state "$pane_id"
  reset_pane_border "$pane_id"
  tmux refresh-client -S 2>/dev/null || true
}

cmd_clear_pane() {
  local pane_id="${1:-}"
  [[ -z "$pane_id" ]] && return 1
  remove_pane_from_state "$pane_id"
  reset_pane_border "$pane_id"
  tmux refresh-client -S 2>/dev/null || true
}

cmd_menu() {
  [[ -z "${TMUX:-}" ]] && return 0
  if [[ ! -f "$STATE_FILE" ]] || [[ ! -s "$STATE_FILE" ]]; then
    tmux display-message "Claude Code: 待機中のペインはありません"
    return 0
  fi

  local -a alive_panes=()
  while IFS= read -r p; do
    [[ -n "$p" ]] && alive_panes+=( "$p" )
  done < <(tmux list-panes -a -F '#{pane_id}' 2>/dev/null)

  local -a menu_args=()
  local idx=0
  local pane_id target _timestamp message
  while IFS=$'\t' read -r pane_id target _timestamp message; do
    [[ -z "$pane_id" ]] && continue
    local found=0 p
    for p in "${alive_panes[@]}"; do
      if [[ "$p" == "$pane_id" ]]; then
        found=1
        break
      fi
    done
    (( found )) || continue

    idx=$((idx + 1))
    local short="${message:0:60}"
    local label="${idx}: ${target} - ${short}"
    local key=""
    if (( idx <= 9 )); then
      key="$idx"
    fi
    local action="run-shell '${SCRIPT_PATH} clear-pane ${pane_id}' ; switch-client -t \"${target}\""
    menu_args+=( "$label" "$key" "$action" )
  done < "$STATE_FILE"

  if (( ${#menu_args[@]} == 0 )); then
    tmux display-message "Claude Code: 待機中のペインはありません"
    return 0
  fi

  tmux display-menu -T " Claude Code 待機中 " "${menu_args[@]}"
}

main() {
  local sub="${1:-count}"
  shift || true
  case "$sub" in
    count)      cmd_count "$@" ;;
    clear)      ensure_state_dir; cmd_clear "$@" ;;
    clear-pane) ensure_state_dir; cmd_clear_pane "$@" ;;
    menu)       cmd_menu "$@" ;;
    *)
      echo "usage: $0 {count|clear|clear-pane <pane_id>|menu}" >&2
      exit 2
      ;;
  esac
}

main "$@"
