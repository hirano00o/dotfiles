#!/bin/bash
# Claude Code statusLine スクリプト
# 制限使用率 + 残り時間 + コンテキスト使用率 + Git状態 + ディレクトリ（絵文字・色付き）
# ref. https://gist.github.com/wmoto-ai/fd27193632a8b612edaf6d94410901c1

# ANSIカラーコード
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
GRAY='\033[90m'
BOLD='\033[1m'
RESET='\033[0m'

# 使用率に応じた色を返す関数（ベースカラー指定可能）
# $1: パーセント, $2: ベースカラー（低使用率時）
get_color() {
    local pct=$1
    local base=${2:-$CYAN}
    if [ "$pct" -ge 80 ]; then
        echo "$RED"
    elif [ "$pct" -ge 50 ]; then
        echo "$YELLOW"
    else
        echo "$base"
    fi
}

# 入力JSON読み取り
input=$(cat)

# モデル名取得
model=$(echo "$input" | jq -r '.model.display_name')

# CWD取得
cwd=$(echo "$input" | jq -r '.cwd // empty')

# コスト取得
cost=$(echo "$input" | jq -r '.cost.total_cost_usd | if . then (. * 100 | round / 100 | tostring) else empty end')

# エージェント
agent=$(echo "$input" | jq -r '.agent.name // empty')

# コスト取得(1ヶ月)
cost_per_month=$(ccusage -s "$(date -v -1m +%Y%m%d)" -j | jq -r '.totals.totalCost | if . then (. * 100 | round / 100 | tostring) else empty end')

# ディレクトリ表示（最深部2階層まで）
dir_str=""
if [ -n "$cwd" ]; then
    # 最後の2階層を取得
    parent=$(basename "$(dirname "$cwd")")
    current=$(basename "$cwd")
    if [ "$parent" = "/" ] || [ "$parent" = "." ]; then
        short_cwd="$current"
    else
        short_cwd="${parent}/${current}"
    fi
    # それでも長すぎる場合は末尾24文字に省略
    if [ ${#short_cwd} -gt 24 ]; then
        short_cwd="…${short_cwd: -23}"
    fi
    dir_str="${GRAY}${short_cwd}${RESET}"
fi

# Git状態取得
git_str=""
if [ -n "$cwd" ]; then
    # gitリポジトリかチェック
    if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
        branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
        if [ -z "$branch" ]; then
            # detached HEAD
            branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
        fi
        if [ -n "$branch" ]; then
            # dirty check (変更あり)
            if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
                git_str="${MAGENTA}⎇ ${branch}${YELLOW}*${RESET}"
            else
                git_str="${GREEN}⎇ ${branch}${RESET}"
            fi
        fi
    fi
fi

# プログレスバー生成関数
make_progress_bar() {
    local pct=$1
    local width=${2:-10}
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

# コンテキスト使用率計算（四捨五入）- ベースカラー: 緑
ctx_str=""
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    ctx_pct=$(( (current * 100 + size / 2) / size ))
    ctx_color=$(get_color $ctx_pct "$GREEN")
    ctx_bar=$(make_progress_bar $ctx_pct 10)
    ctx_str="📊 Ctx [${ctx_color}${ctx_bar}${RESET}] ${ctx_color}${ctx_pct}%${RESET}"
fi

# OAuth API使用率取得（キャッシュ付き）
CACHE_FILE="/tmp/claude_oauth_usage_cache.json"
CACHE_TTL=60  # 1分

# キャッシュチェック
fetch_usage=false
if [ -f "$CACHE_FILE" ]; then
    cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ "$cache_age" -ge "$CACHE_TTL" ]; then
        fetch_usage=true
    fi
else
    fetch_usage=true
fi

# キャッシュが古いか存在しない場合、バックグラウンドで更新
if [ "$fetch_usage" = true ]; then
    (
        CREDS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$CREDS" ]; then
            TOKEN=$(echo "$CREDS" | jq -r '.claudeAiOauth.accessToken' 2>/dev/null)
            if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
                USAGE=$(curl -s --max-time 3 "https://api.anthropic.com/api/oauth/usage" \
                    -H "Authorization: Bearer ${TOKEN}" \
                    -H "anthropic-beta: oauth-2025-04-20" \
                    -H "User-Agent: claude-code/2.0.31" \
                    -H "Accept: application/json" 2>/dev/null)
                if [ -n "$USAGE" ] && ! echo "$USAGE" | jq -e '.error' >/dev/null 2>&1; then
                    echo "$USAGE" > "$CACHE_FILE"
                fi
            fi
        fi
    ) &
fi

# キャッシュから使用率を読み取り
if [ -f "$CACHE_FILE" ]; then
    five_hour=$(jq -r '.five_hour.utilization // empty' "$CACHE_FILE" 2>/dev/null)
    five_hour_reset=$(jq -r '.five_hour.resets_at // empty' "$CACHE_FILE" 2>/dev/null)
    seven_day=$(jq -r '.seven_day.utilization // empty' "$CACHE_FILE" 2>/dev/null)

    # 5時間リミット - ベースカラー: シアン
    five_hour_str=""
    if [ -n "$five_hour" ]; then
        five_hour_int=$(printf "%.0f" "$five_hour" 2>/dev/null)
        hour_color=$(get_color $five_hour_int "$CYAN")
        hour_bar=$(make_progress_bar $five_hour_int 10)

        # 残り時間計算
        time_left=""
        if [ -n "$five_hour_reset" ]; then
            reset_clean=$(echo "$five_hour_reset" | sed 's/\.[0-9]*//; s/+00:00$/Z/; s/Z$//')
            reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$reset_clean" "+%s" 2>/dev/null)
            if [ -n "$reset_epoch" ]; then
                now_epoch=$(date -u "+%s")
                diff=$((reset_epoch - now_epoch))
                if [ "$diff" -gt 0 ]; then
                    hours=$((diff / 3600))
                    mins=$(((diff % 3600) / 60))
                    time_left=" ${GRAY}(${hours}h${mins}m)${RESET}"
                fi
            fi
        fi

        five_hour_str="⏱️ 5h [${hour_color}${hour_bar}${RESET}] ${hour_color}${five_hour_int}%${RESET}${time_left}"
    fi

    # 7日リミット - ベースカラー: マゼンタ
    seven_day_str=""
    if [ -n "$seven_day" ]; then
        seven_day_int=$(printf "%.0f" "$seven_day" 2>/dev/null)
        week_color=$(get_color $seven_day_int "$MAGENTA")
        week_bar=$(make_progress_bar $seven_day_int 10)
        seven_day_str="📅 7d [${week_color}${week_bar}${RESET}] ${week_color}${seven_day_int}%${RESET}"
    fi
fi

# 出力組み立て（複数行表示）
# モデル | NORMAL | ⎇ branch | dir | ⏱️ 5h [████░░░░░░] X% (Xh Xm) | 📅 7d [██░░░░░░░░] Y% | 📊 Ctx [█░░░░░░░░░] Z% | 💰 $12.34 | 💰 $123.0/mon | 🤖 エージェント

line1="${CYAN}${model}${RESET}"
[ -n "$git_str" ] && line1="$line1 ${GRAY}| $git_str"
[ -n "$dir_str" ] && line1="$line1 ${GRAY}| $dir_str"
[ -n "$five_hour_str" ] && line1="$line1 | $five_hour_str"
[ -n "$seven_day_str" ] && line1="$line1 | $seven_day_str"
[ -n "$ctx_str" ] && line1="$line1 | $ctx_str"
[ -n "$cost" ] && line1="$line1 | 💰 \$$cost"
[ -n "$cost_per_month" ] && line1="$line1 | 💰 \$${cost_per_month}/mon"
[ -n "$agent" ] && line1="$line1 | 🤖 $agent"

echo -e "$line1"
