#!/usr/bin/env bash
# PreToolUse hook: バージョン指定チェック
# stdin から Claude Code の JSON を受け取り、古いバージョン指定を block する。
#
# 判定ルール:
#   最新版のリリース日が現在から7日以内 → 推奨 = 1つ前のバージョン
#   それ以外 → 推奨 = 最新版
#   指定バージョンが推奨より古い、または最新版かつ7日以内 → block
#
# API 呼び出し失敗時は allow（フック障害でブロックしない）

set -euo pipefail

CACHE_DIR="/tmp/claude-version-check"
CACHE_TTL=3600  # 1時間
CURL_TIMEOUT=3

mkdir -p "$CACHE_DIR"

# キャッシュ付き curl: キャッシュが有効なら返す、なければ取得して保存
cached_curl() {
  local key="$1"
  local url="$2"
  local cache_file="$CACHE_DIR/$(printf '%s' "$key" | shasum -a 256 | cut -d' ' -f1)"

  if [[ -f "$cache_file" ]]; then
    local age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file") ))
    if (( age < CACHE_TTL )); then
      cat "$cache_file"
      return 0
    fi
  fi

  local body
  body=$(curl -sf --max-time "$CURL_TIMEOUT" -H "Accept-Encoding: identity" "$url") || return 1
  printf '%s\n' "$body" > "$cache_file"
  printf '%s\n' "$body"
}

# セマンティックバージョンを整数に変換（比較用）
ver_to_int() {
  local v="${1#v}"
  local major minor patch
  IFS='.' read -r major minor patch <<< "${v%%[-+]*}"
  printf '%d%06d%06d' "${major:-0}" "${minor:-0}" "${patch:-0}"
}

# yyyymmdd を Unix タイムスタンプに変換
date_to_ts() {
  local clean="${1%Z}"      # 末尾 Z を除去
  clean="${clean%.*}"       # 小数秒を除去
  date -j -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null \
    || date -d "$1" "+%s" 2>/dev/null \
    || echo 0
}

NOW=$(date +%s)
SEVEN_DAYS=$(( 7 * 86400 ))

# block メッセージを出力して exit 2
block() {
  local pkg="$1" current="$2" recommended="$3" reason="$4"
  local msg="[version-check] $pkg: $current を指定しています。推奨バージョン: $recommended ($reason)"
  jq -n --arg m "$msg" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"block",permissionDecisionReason:$m}}'
  exit 2
}

# npm チェック
check_npm() {
  local pkg="$1" ver="$2"
  local data
  data=$(cached_curl "npm:$pkg" "https://registry.npmjs.org/$pkg") || return 0

  local latest
  latest=$(printf '%s' "$data" | jq -r '."dist-tags".latest // empty')
  [[ -z "$latest" ]] && return 0

  local latest_time
  latest_time=$(printf '%s' "$data" | jq -r --arg v "$latest" '.time[$v] // empty')
  [[ -z "$latest_time" ]] && return 0

  local latest_ts
  latest_ts=$(date_to_ts "$latest_time")

  local recommended
  if (( NOW - latest_ts <= SEVEN_DAYS )); then
    recommended=$(printf '%s' "$data" | jq -r '
      .time | to_entries | map(select(.key | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))) | sort_by(.value) | .[-2].key // empty')
    [[ -z "$recommended" ]] && return 0
    local reason="最新版 $latest はリリースから7日以内のため"
  else
    recommended="$latest"
    local reason="最新版"
  fi

  local cur_int rec_int
  cur_int=$(ver_to_int "$ver")
  rec_int=$(ver_to_int "$recommended")

  if (( cur_int < rec_int )); then
    block "$pkg" "$ver" "$recommended" "$reason"
  elif [[ "$ver" == "$latest" ]] && (( NOW - latest_ts <= SEVEN_DAYS )); then
    block "$pkg" "$ver" "$recommended" "最新版 $latest はリリースから7日以内のため"
  fi
}

# Go proxy のエンコーディング: 大文字 X → !x（パスの / はそのまま）
go_encode_module() {
  local mod="$1"
  local result=""
  local i char lower
  for (( i=0; i<${#mod}; i++ )); do
    char="${mod:$i:1}"
    if [[ "$char" =~ [A-Z] ]]; then
      lower=$(printf '%s' "$char" | tr '[:upper:]' '[:lower:]')
      result+="!${lower}"
    else
      result+="$char"
    fi
  done
  printf '%s' "$result"
}

# Go チェック
check_go() {
  local module="$1" ver="$2"
  local enc_module
  enc_module=$(go_encode_module "$module")

  local list
  list=$(cached_curl "go:$module" "https://proxy.golang.org/$enc_module/@v/list") || return 0
  [[ -z "$list" ]] && return 0

  local latest
  latest=$(printf '%s' "$list" | tr ' ' '\n' \
    | { grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' || true; } \
    | sed 's/^v//' | sort -t. -k1,1n -k2,2n -k3,3n | sed 's/^/v/' | tail -1)
  [[ -z "$latest" ]] && return 0

  local info
  info=$(cached_curl "go:$module:$latest" "https://proxy.golang.org/$enc_module/@v/$latest.info") || return 0

  local latest_time
  latest_time=$(printf '%s' "$info" | jq -r '.Time // empty')
  [[ -z "$latest_time" ]] && return 0

  local latest_ts
  latest_ts=$(date_to_ts "$latest_time")

  local recommended reason
  if (( NOW - latest_ts <= SEVEN_DAYS )); then
    recommended=$(printf '%s' "$list" | tr ' ' '\n' \
      | { grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' || true; } \
      | sed 's/^v//' | sort -t. -k1,1n -k2,2n -k3,3n | sed 's/^/v/' | tail -2 | head -1)
    [[ -z "$recommended" ]] && return 0
    reason="最新版 $latest はリリースから7日以内のため"
  else
    recommended="$latest"
    reason="最新版"
  fi

  local cur_int rec_int
  cur_int=$(ver_to_int "$ver")
  rec_int=$(ver_to_int "$recommended")

  if (( cur_int < rec_int )); then
    block "$module" "$ver" "$recommended" "$reason"
  elif [[ "$ver" == "$latest" ]] && (( NOW - latest_ts <= SEVEN_DAYS )); then
    block "$module" "$ver" "$recommended" "最新版 $latest はリリースから7日以内のため"
  fi
}

# PyPI チェック
check_pypi() {
  local pkg="$1" ver="$2"
  local data
  data=$(cached_curl "pypi:$pkg" "https://pypi.org/pypi/$pkg/json") || return 0

  local latest
  latest=$(printf '%s' "$data" | jq -r '.info.version // empty')
  [[ -z "$latest" ]] && return 0

  local latest_time
  latest_time=$(printf '%s' "$data" | jq -r --arg v "$latest" '.releases[$v][0].upload_time // empty')
  [[ -z "$latest_time" ]] && return 0

  local latest_ts
  latest_ts=$(date_to_ts "$latest_time")

  local recommended reason
  if (( NOW - latest_ts <= SEVEN_DAYS )); then
    recommended=$(printf '%s' "$data" | jq -r '
      .releases | to_entries
      | map(select(.key | test("^[0-9]+\\.[0-9]+\\.[0-9]+.*$")))
      | map({key:.key, ts:(.value[0].upload_time // "")})
      | sort_by(.ts) | .[-2].key // empty')
    [[ -z "$recommended" ]] && return 0
    reason="最新版 $latest はリリースから7日以内のため"
  else
    recommended="$latest"
    reason="最新版"
  fi

  local cur_int rec_int
  cur_int=$(ver_to_int "$ver")
  rec_int=$(ver_to_int "$recommended")

  if (( cur_int < rec_int )); then
    block "$pkg" "$ver" "$recommended" "$reason"
  elif [[ "$ver" == "$latest" ]] && (( NOW - latest_ts <= SEVEN_DAYS )); then
    block "$pkg" "$ver" "$recommended" "最新版 $latest はリリースから7日以内のため"
  fi
}

# Cargo チェック
check_cargo() {
  local pkg="$1" ver="$2"
  local data
  data=$(cached_curl "cargo:$pkg" "https://crates.io/api/v1/crates/$pkg") || return 0

  local latest
  latest=$(printf '%s' "$data" | jq -r '.crate.newest_version // empty')
  [[ -z "$latest" ]] && return 0

  local latest_time
  latest_time=$(printf '%s' "$data" | jq -r --arg v "$latest" '.versions[] | select(.num==$v) | .created_at // empty' | head -1)
  [[ -z "$latest_time" ]] && return 0

  local latest_ts
  latest_ts=$(date_to_ts "$latest_time")

  local recommended reason
  if (( NOW - latest_ts <= SEVEN_DAYS )); then
    recommended=$(printf '%s' "$data" | jq -r '
      [.versions[] | select(.yanked==false) | {num:.num, ts:.created_at}]
      | sort_by(.ts) | .[-2].num // empty')
    [[ -z "$recommended" ]] && return 0
    reason="最新版 $latest はリリースから7日以内のため"
  else
    recommended="$latest"
    reason="最新版"
  fi

  local cur_int rec_int
  cur_int=$(ver_to_int "$ver")
  rec_int=$(ver_to_int "$recommended")

  if (( cur_int < rec_int )); then
    block "$pkg" "$ver" "$recommended" "$reason"
  elif [[ "$ver" == "$latest" ]] && (( NOW - latest_ts <= SEVEN_DAYS )); then
    block "$pkg" "$ver" "$recommended" "最新版 $latest はリリースから7日以内のため"
  fi
}

# GitHub Actions チェック
check_gh_action() {
  local owner_repo="$1" ver="$2"
  local data
  data=$(cached_curl "ghaction:$owner_repo" "https://api.github.com/repos/$owner_repo/releases") || return 0

  local latest
  latest=$(printf '%s' "$data" | jq -r '[.[] | select(.prerelease==false and .draft==false)] | .[0].tag_name // empty')
  [[ -z "$latest" ]] && return 0

  local latest_time
  latest_time=$(printf '%s' "$data" | jq -r '[.[] | select(.prerelease==false and .draft==false)] | .[0].published_at // empty')
  [[ -z "$latest_time" ]] && return 0

  local latest_ts
  latest_ts=$(date_to_ts "$latest_time")

  local recommended reason
  if (( NOW - latest_ts <= SEVEN_DAYS )); then
    recommended=$(printf '%s' "$data" | jq -r '[.[] | select(.prerelease==false and .draft==false)] | .[1].tag_name // empty')
    [[ -z "$recommended" ]] && return 0
    reason="最新版 $latest はリリースから7日以内のため"
  else
    recommended="$latest"
    reason="最新版"
  fi

  local cur_int rec_int
  cur_int=$(ver_to_int "$ver")
  rec_int=$(ver_to_int "$recommended")

  if (( cur_int < rec_int )); then
    block "$owner_repo" "$ver" "$recommended" "$reason"
  elif [[ "$ver" == "$latest" ]] && (( NOW - latest_ts <= SEVEN_DAYS )); then
    block "$owner_repo" "$ver" "$recommended" "最新版 $latest はリリースから7日以内のため"
  fi
}

# Bash ツールのコマンドからパッケージ+バージョンを検査
check_bash_command() {
  local cmd="$1"

  # npm install/add, yarn add, pnpm add/install
  if echo "$cmd" | grep -qE '\b(npm\s+(install|add)|yarn\s+add|pnpm\s+(add|install))\b'; then
    while IFS= read -r token; do
      if [[ "$token" =~ ^(@[^@]+/[^@]+)@(.+)$ ]] || [[ "$token" =~ ^([^@][^@]*)@(.+)$ ]]; then
        local pkg="${BASH_REMATCH[1]}" ver="${BASH_REMATCH[2]}"
        check_npm "$pkg" "$ver"
      fi
    done < <(echo "$cmd" | tr ' ' '\n' | grep '@')
    return 0
  fi

  # go get
  if echo "$cmd" | grep -qE '\bgo\s+get\b'; then
    while IFS= read -r token; do
      if [[ "$token" =~ ^(.+)@(v[0-9]+\..+)$ ]]; then
        check_go "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
      fi
    done < <(echo "$cmd" | grep -oE '[^[:space:]]+@v[0-9]+\.[^[:space:]]+')
    return 0
  fi

  # pip install
  if echo "$cmd" | grep -qE '\bpip3?\s+install\b'; then
    while IFS= read -r token; do
      if [[ "$token" =~ ^([A-Za-z0-9_.-]+)==(.+)$ ]]; then
        check_pypi "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
      fi
    done < <(echo "$cmd" | tr ' ' '\n' | grep '==')
    return 0
  fi

  # cargo add
  if echo "$cmd" | grep -qE '\bcargo\s+add\b'; then
    # cargo add pkg@ver or --version ver
    local cargo_pkg cargo_ver
    cargo_pkg=$(echo "$cmd" | grep -oE '\bcargo\s+add\s+[A-Za-z0-9_-]+' | awk '{print $NF}')
    if [[ "$cmd" =~ @([0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*) ]]; then
      cargo_ver="${BASH_REMATCH[1]}"
    elif [[ "$cmd" =~ --version[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*) ]]; then
      cargo_ver="${BASH_REMATCH[1]}"
    fi
    [[ -n "$cargo_pkg" && -n "$cargo_ver" ]] && check_cargo "$cargo_pkg" "$cargo_ver"
    return 0
  fi
}

# ファイルの内容からバージョン記述を検査
check_dep_file() {
  local file_path="$1" content="$2"
  local base
  base=$(basename "$file_path")

  case "$base" in
    package.json)
      # jq で "pkg: ^X.Y.Z" 形式に展開してから検査
      while IFS= read -r line; do
        # "pkg: ^1.2.3" or "pkg: ~1.2.3" or "pkg: 1.2.3"
        if [[ "$line" =~ ^([^:]+):[[:space:]]*[~^]?([0-9]+\.[0-9]+\.[0-9]+.*)$ ]]; then
          local pkg="${BASH_REMATCH[1]}" ver="${BASH_REMATCH[2]}"
          check_npm "$pkg" "$ver"
        fi
      done < <(printf '%s' "$content" | jq -r '
        ((.dependencies // {}) + (.devDependencies // {}))
        | to_entries[] | "\(.key): \(.value)"' 2>/dev/null || echo "")
      ;;

    go.mod)
      while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*(require[[:space:]]+)?([^[:space:]]+)[[:space:]]+(v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*)$ ]]; then
          check_go "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
        fi
      done <<< "$content"
      ;;

    requirements.txt)
      while IFS= read -r line; do
        if [[ "$line" =~ ^([A-Za-z0-9_.-]+)==([0-9]+\.[0-9]+(\.[0-9]+)?)$ ]]; then
          check_pypi "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
      done <<< "$content"
      ;;

    Cargo.toml)
      while IFS= read -r line; do
        if [[ "$line" =~ ^([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*\"([0-9]+\.[0-9]+\.[0-9]+[^\"]*)\" ]]; then
          check_cargo "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
      done <<< "$content"
      ;;

    pyproject.toml)
      while IFS= read -r line; do
        local pyproject_re='"([a-zA-Z0-9_-]+)[[:space:]]*>=[[:space:]]*([0-9]+\.[0-9]+(\.[0-9]+)?)"'
        if [[ "$line" =~ $pyproject_re ]]; then
          check_pypi "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
      done <<< "$content"
      ;;
  esac
}

# GitHub Actions ワークフローから uses を検査
check_workflow_file() {
  local content="$1"
  while IFS= read -r line; do
    if [[ "$line" =~ uses:[[:space:]]+([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)@(v[0-9]+(\.[0-9]+)*) ]]; then
      check_gh_action "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    fi
  done <<< "$content"
}

# ---------- メイン ----------

input=$(cat)
tool_name=$(printf '%s' "$input" | jq -r '.tool_name // empty')

case "$tool_name" in
  Bash)
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
    [[ -z "$cmd" ]] && exit 0
    check_bash_command "$cmd"
    ;;

  Write|Edit)
    file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
    [[ -z "$file_path" ]] && exit 0

    base=$(basename "$file_path")

    # 依存ファイル判定
    if [[ "$base" =~ ^(package\.json|go\.mod|requirements\.txt|Cargo\.toml|pyproject\.toml)$ ]]; then
      if [[ "$tool_name" == "Write" ]]; then
        content=$(printf '%s' "$input" | jq -r '.tool_input.content // empty')
      else
        content=$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty')
      fi
      [[ -z "$content" ]] && exit 0
      check_dep_file "$file_path" "$content"

    # GitHub Actions ワークフロー判定
    elif [[ "$file_path" =~ \.github/workflows/.*\.ya?ml$ ]]; then
      if [[ "$tool_name" == "Write" ]]; then
        content=$(printf '%s' "$input" | jq -r '.tool_input.content // empty')
      else
        content=$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty')
      fi
      [[ -z "$content" ]] && exit 0
      check_workflow_file "$content"
    fi
    ;;
esac

exit 0
