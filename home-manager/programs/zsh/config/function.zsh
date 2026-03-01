# uuid generate and yank
function ugen() {
    uuidgen | tr 'A-Z' 'a-z' | tr -d '\n' | pbcopy
}

# start and stop VPN
function vpn() {
    if [[ "$1" == "connect" || "$1" == "-c" ]]; then
        _trigger_vpn "$2" "connect"
    elif [[ "$1" == "disconnect" || "$1" == "-d" ]]; then
        _trigger_vpn "$2" "disconnect"
    elif [[ "$1" == "list" || "$1" == "-l" ]]; then
        echo "state\t\tname"
        scutil --nc list | awk 'NR>1{gsub(/[\(\)\"]/,""); print tolower($2)"\t"$5}'
        osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get name of configurations" -e "end tell" | awk '{gsub(",", "\n"); print $0}' | while read -r f;do osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get state of configurations where name = \"$f\"" -e "end tell" | xargs -I% echo %,$f;done | awk -F, '{gsub(/EXITING/, "disconnected"); print tolower($1)"\t"$2}'
    else;
        echo  "\
Usage: $0 [command] [arg]
    -h, help: display available commands
    -c, connect: connect to the specified it
    -d, disconnect: disconnect the specified it
    -l, list: display the state of each connection\
"
    fi
}

function _trigger_vpn() {
    if [[ "$2" != "connect" && "$2" != "disconnect" ]]; then
        echo "trigger must be connect or disconnect"
        return
    fi

    if [[ `scutil --nc list | grep "\"$1\"" | wc -l` -ne 0  ]]; then
      if [[ "$2" == "connect" ]]; then
        scutil --nc start $1
      elif [[ "$2" == "disconnect" ]]; then
        scutil --nc stop $1
      fi
    elif [[ `osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get name of configurations" -e "end tell" | wc -l` -ne 0 ]]; then
        osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "$2 \"$1\"" -e "end tell"
    else;
        echo "no found: $1"
    fi
}
