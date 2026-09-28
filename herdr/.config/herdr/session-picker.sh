#!/bin/sh
# Herdr session picker, opened as a popup by prefix+shift+s (see config.toml).
#   enter   jump to the session's window, or open one; type an unknown name to create it
#   ctrl-x  stop session (refuses the one you are in)
#   ctrl-d  delete a stopped session
# Herdr can't switch a client between sessions, so each session gets its own window.
bin=${HERDR_BIN_PATH:-herdr}
here=${HERDR_SOCKET_PATH:-}

sock() { "$bin" session list --json | jq -r --arg n "$1" '.sessions[] | select(.name == $n).socket_path'; }

case $1 in
list)
  "$bin" session list --json | jq -r --arg here "$here" '.sessions[] |
    [.name, (if .running then "● running" else "○ stopped" end)
      + (if .socket_path == $here then "  (here)" else "" end)] | @tsv'
  exit ;;
stop)
  [ "$(sock "$2")" = "$here" ] || "$bin" session stop "$2" >/dev/null 2>&1
  exit ;;
delete)
  "$bin" session delete "$2" >/dev/null 2>&1
  exit ;;
open)  # niri Mod+Ctrl+Return: session-picker.sh open default
  name=${2:-default} ;;
*)
  # Exit 1 = no match: the query becomes a new session name. Esc (130) cancels.
  out=$("$0" list | fzf --delimiter='\t' --print-query --reverse --prompt 'session> ' \
    --header 'enter open/new · ctrl-x stop · ctrl-d delete' \
    --bind "ctrl-x:execute-silent($0 stop {1})+reload($0 list)" \
    --bind "ctrl-d:execute-silent($0 delete {1})+reload($0 list)") || [ $? -eq 1 ] || exit 0
  name=$(printf '%s\n' "$out" | sed -n 2p | cut -f1)
  [ -n "$name" ] || name=$(printf '%s\n' "$out" | sed -n 1p)
  [ -n "$name" ] || exit 0 ;;
esac

# Windows are tagged app-id "herdr.<session>", so an already-open session
# is focused instead of getting a second window.
app="herdr.$name"
id=$(niri msg -j windows | jq -r --arg a "$app" 'first(.[] | select(.app_id == $a) | .id) // empty')
[ -n "$id" ] && exec niri msg action focus-window --id "$id"

set --
[ "$name" = default ] || set -- --session "$name"
# Drop the popup's HERDR_* context so the new client doesn't target this session's socket.
for v in $(env | sed -n 's/^\(HERDR_[A-Za-z0-9_]*\)=.*/\1/p'); do unset "$v"; done
setsid -f footclient -a "$app" -e "$bin" "$@" >/dev/null 2>&1
