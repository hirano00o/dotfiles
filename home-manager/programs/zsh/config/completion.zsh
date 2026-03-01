# 1password
if command -v op 1>/dev/null 2>&1; then
    eval "$(op completion zsh)"; compdef _op op
fi

# gh
if command -v gh 1>/dev/null 2>&1; then
    eval "$(gh completion -s zsh)"; compdef _gh gh
fi

# kubectl
if command -v kubectl 1>/dev/null 2>&1; then
    eval "$(kubectl completion zsh)"; compdef _kubectl kubectl
fi

# completion of VPN connection destination
_vpncomp() {
    local -a val
    val=($(scutil --nc list | awk 'NR > 1 {print $5"["toupper(substr($2, 2, length($2)-2))"]"}' | xargs echo))
    IFS="," TN_KEY=($(osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get name of configurations" -e "end tell" | sed "s/ //g"))
    IFS="," TN_STATE=($(osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get state of configurations" -e "end tell" | sed "s/ //g"))
    for ((i=1;i<=$#TN_KEY;i++));do val=($val ${TN_KEY[$i]}"["${TN_STATE[$i]}"]"); done

    _arguments '2: :->destination'

    case "$state" in
        destination)
            _values $state $val
            ;;
    esac
}

compdef _vpncomp vpn
