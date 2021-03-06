export LANG=ja_JP.UTF-8
# ${fg[blue]}等で色が利用できるようにする
autoload -Uz colors
colors
# 補完を利用
autoload -Uz compinit
compinit
bindkey -v # vimキーバインド
setopt share_history # 他ターミナルとヒストリを共有
setopt histignorealldups # ヒストリを重複表示しない
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HISTTIMEFORMAT="[%Y/%M/%D %H:%M:%S] "

setopt auto_param_slash # ディレクトリ名の補完で末尾に / を付加
setopt magic_equal_subst # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる

setopt auto_pushd # 遷移したディレクトリをスタックする
setopt pushd_ignore_dups # 重複したディレクトリはスタックしない

# backspace,deleteキーを使えるように
# stty erase ^H
# bindkey "^[[3~" delete-char

# 区切り文字の設定
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars "_-./;@"
zstyle ':zle:*' word-style unspecified

PROMPT="
%{${fg_bold[green]}%}>%{${fg_bold[yellow]}%}>%{${fg_bold[red]}%}>%{${reset_color}%} "

local DEFAULT=$'%{^[[m%}'$
local RED=$'%{^[[1;31m%}'$
local YELLOW=$'%{^[[1;33m%}'$

zstyle ':completion:*:default' menu select=2 # 補完後、メニュー選択モードになり左右キーで移動が出来る
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 補完で大文字にもマッチ
zstyle ':completion:*' verbose true # 補完を詳細に表示
zstyle ':completion:*' use-cache true # キャッシュによる補完の高速化
zstyle ':completion:*' completer _expand _complete _history _prefix # 補完の出し方
zstyle ':completion:*:messages' format '%F{YELLOW}%d%F{DEFAULT}'
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d%F{DEFAULT}'
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b%F{DEFAULT}'
zstyle ':completion:*:corrections' format '%F{YELLOW}%B%d ''%F{RED}(errors: %e)%b%F{DEFAULT}'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' group-name ''

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # 補完候補に色を付ける
case ${OSTYPE} in
    darwin*)
        export LSCOLORS=gxfxcxdxbxegedabagacad
        alias ls='ls -FG'
        ;;
    Linux*)
        export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
        alias ls='ls --color'
        ;;
esac

alias c='clear'
alias d='docker'
alias dc='docker-compose'
alias dated='date +%Y%m%d'
alias datef='date +%Y%m%d%H%M%S'
alias datet='date +%H%M%S'
alias m='make'
alias mk='mkdir -p'
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gba='git branch -a'
alias gc='git commit'
alias gco='git checkout'
alias gn='git checkout -b'
alias gd='git diff'
alias gf='git fetch'
alias gm='git merge'
alias gmm='git merge master'
alias gps='git push'
alias gpl='git pull'
alias gs='git status'
alias ll='ls -ltr'
alias v='vim'
alias vm='vim ~/.vimrc'
alias vz='vim ~/.zshrc'
alias y='yarn'
# 複数ファイルのmv 例　zmv *.txt *.txt.bk
autoload -Uz zmv
alias zmv='noglob zmv -W'

alias -g A='| awk'
alias -g C='| pbcopy'
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g X='| xargs'

bindkey -M viins '^j' vi-cmd-mode

# git設定
RPROMPT="%{${fg[cyan]}%}[%~]%{${reset_color}%}"
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%{${fg_bold[yellow]}%}!"
zstyle ':vcs_info:git:*' unstagedstr "%{${fg_bold[red]}%}+"
zstyle ':vcs_info:*' formats "%{${fg_bold[green]}%}%c%u[%b]%f%{${reset_color}%}"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'

# hyper用設定
title() { export TITLE_OVERRIDDEN=1; echo -en "\e]0;$*\a"}
autotitle() { export TITLE_OVERRIDDEN=0 }; autotitle
overridden() { [[ $TITLE_OVERRIDDEN == 1 ]]; }
gitDirty() { [[ $(git status 2> /dev/null | grep -o '\w\+' | tail -n1) != ("clean"|"") ]] && echo "*" }

tabtitle_precmd() {
   if overridden; then return; fi
   pwd=$(pwd) # Store full path as variable
   cwd=${pwd##*/} # Extract current working dir only
   print -Pn "\e]0;$cwd$(gitDirty)\a" # Replace with $pwd to show full path
}
[[ -z $precmd_functions ]] && precmd_functions=()
precmd_functions=($precmd_functions tabtitle_precmd)

tabtitle_preexec() {
   if overridden; then return; fi
   printf "\033]0;%s\a" "${1%% *} | $cwd$(gitDirty)" # Omit construct from $1 to show args
}
[[ -z $preexec_functions ]] && preexec_functions=()
preexec_functions=($preexec_functions tabtitle_preexec)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

