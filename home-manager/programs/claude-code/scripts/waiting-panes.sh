#!/bin/bash
set -u

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-code"
STATE_FILE="${STATE_DIR}/waiting-panes"
TAB=$'\t'
# メニューに出す待機メッセージの最大文字数
MESSAGE_MAX_LEN=40

# display-menu のアクション文字列に埋め込むため $0 は絶対パスでなければならない。
# tmux からは絶対パスで呼ばれるが、手元で相対パス実行しても壊れないようにしておく。
SCRIPT_PATH="$0"
case "$SCRIPT_PATH" in
  /*) ;;
  *) SCRIPT_PATH="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd)/$(basename -- "$0")" ;;
esac

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
  tmux set-option -p -u -t "$pane" pane-border-style 2>/dev/null || true
  tmux select-pane -t "$pane" -P '' 2>/dev/null || true
}

# tmux のフォーマット展開に食われる '#' をエスケープする。
# display-menu の name と command はどちらもフォーマット展開されるため、
# 外部由来の文字列 (通知メッセージ・セッション名・パス) は必ずこれを通すこと。
# bash 3.2 では ${s//"#"/"##"} と書くと引用符がリテラルとして残るので、引用しない形で書く。
escape_format() {
  printf '%s' "${1//#/##}"
}

# claude プロセスを実行中のペイン ID を改行区切りで出力する。
# 第1引数は "pane_id \t pane_pid \t ..." 形式のペイン一覧。
# pane_current_command はツール実行中に前面プロセスが入れ替わるうえ、
# claude 終了後もウィンドウ名に痕跡が残るため判定に使えない。
# ps のスナップショットから claude を探し、ppid を遡って所属ペインを特定する。
# claude-worktree.sh 経由だと間に bash が挟まるので、直の子だけを見るのでは足りない。
list_running_panes() {
  awk -F "$TAB" '
    FNR == NR { if (NF >= 2) pane_of[$2] = $1; next }
    {
      # comm はパスに空白を含みうるので、先頭2フィールドだけ削って残りを実行ファイル名とする
      if (match($0, /^[ \t]*[0-9]+[ \t]+[0-9]+[ \t]+/) == 0) next
      split(substr($0, 1, RLENGTH), hf, " ")
      cmd = substr($0, RLENGTH + 1)
      ppid[hf[1]] = hf[2]
      sub(/.*\//, "", cmd)
      if (cmd == "claude" || cmd == ".claude-wrapped") claude[hf[1]] = 1
    }
    END {
      for (pid in claude) {
        p = pid
        # ppid の循環や到達不能に備えて遡る段数を制限する
        for (hop = 0; hop < 16 && p != "" && p != "0" && p != "1"; hop++) {
          if (p in pane_of) { print pane_of[p]; break }
          p = ppid[p]
        }
      }
    }
  ' <(printf '%s\n' "$1") <(ps -axo pid=,ppid=,comm= 2>/dev/null)
}

# 一覧に載せるエントリを TSV で出力する
#   waiting_flag \t pane_id \t target \t path \t message
# 待機中(1) を先に、それ以外(0) を後に並べる。
collect_entries() {
  local panes running
  panes="$(tmux list-panes -a \
    -F "#{pane_id}${TAB}#{pane_pid}${TAB}#{session_name}:#{window_index}.#{pane_index}${TAB}#{pane_current_path}" \
    2>/dev/null)"
  [[ -n "$panes" ]] || return 0
  running=" $(list_running_panes "$panes" | tr '\n' ' ') "

  # bash 3.2 に連想配列がないため、待機状態は 2 本の並列配列で持つ
  local -a wait_ids=() wait_msgs=()
  if [[ -f "$STATE_FILE" ]]; then
    local wp _wt _wts wmsg
    while IFS="$TAB" read -r wp _wt _wts wmsg; do
      [[ -n "$wp" ]] || continue
      wait_ids+=( "$wp" )
      wait_msgs+=( "$wmsg" )
    done < "$STATE_FILE"
  fi

  local want pane_id _pane_pid target path i msg flag
  for want in 1 0; do
    while IFS="$TAB" read -r pane_id _pane_pid target path; do
      [[ -n "$pane_id" ]] || continue
      flag=0
      msg=""
      # 空配列を "${arr[@]}" で展開すると bash 3.2 + set -u では致命的エラーになるため添字で回す
      i=0
      while (( i < ${#wait_ids[@]} )); do
        if [[ "${wait_ids[$i]}" == "$pane_id" ]]; then
          flag=1
          msg="${wait_msgs[$i]}"
          break
        fi
        i=$((i + 1))
      done
      (( flag == want )) || continue
      # 待機中でないペインは claude が実際に動いているものだけ載せる
      (( flag )) || [[ "$running" == *" $pane_id "* ]] || continue
      printf '%s\t%s\t%s\t%s\t%s\n' "$flag" "$pane_id" "$target" "$path" "$msg"
    done <<< "$panes"
  done
}

cmd_count() {
  local waiting=0 total=0 flag _rest
  while IFS="$TAB" read -r flag _rest; do
    total=$((total + 1))
    (( flag )) && waiting=$((waiting + 1))
  done < <(collect_entries)

  (( total == 0 )) && return 0
  if (( waiting > 0 )); then
    printf '#[fg=red,bold][待機 %d/%d]#[default] ' "$waiting" "$total"
  else
    printf '[待機 0/%d] ' "$total"
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

  local -a menu_args=()
  local idx=0 prev_flag=""
  local flag pane_id target path msg key action label disp safe_script

  safe_script="$(escape_format "$SCRIPT_PATH")"

  while IFS="$TAB" read -r flag pane_id target path msg; do
    # 待機中グループとそれ以外の境目に区切り線を入れる (空の name が区切り線になる)
    if [[ -n "$prev_flag" && "$prev_flag" != "$flag" ]]; then
      menu_args+=( "" )
    fi
    prev_flag="$flag"

    idx=$((idx + 1))
    disp="${path/#$HOME/~}"
    # 数字キーは tmux が (1) のように右寄せで自動描画するので、ラベル側には付けない
    if (( flag )); then
      label="#[fg=red,bold]●#[default] $(escape_format "$target")  $(escape_format "$disp")"
      # 切り詰めてからエスケープする。逆順だと '##' が途中で切れて注入経路になる
      [[ -n "$msg" ]] && label="${label} - $(escape_format "${msg:0:$MESSAGE_MAX_LEN}")"
    else
      label="  $(escape_format "$target")  $(escape_format "$disp")"
    fi

    key=""
    (( idx <= 9 )) && key="$idx"
    # pane_id は "%" + 数字で空白も引用符も '#' も含まないため、そのまま埋め込める。
    # target ではなく pane_id を渡すのは、セッション名の前方一致や glob による誤解決を
    # 避けるため (man tmux: ':' '.' '%' を含む target はペインとして解決される)。
    action="run-shell '${safe_script} clear-pane ${pane_id}' ; switch-client -t \"${pane_id}\""
    menu_args+=( "$label" "$key" "$action" )
  done < <(collect_entries)

  if (( ${#menu_args[@]} == 0 )); then
    tmux display-message "Claude Code: 起動中のセッションはありません"
    return 0
  fi

  tmux display-menu -T " Claude Code セッション (● 待機中) " "${menu_args[@]}"
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
