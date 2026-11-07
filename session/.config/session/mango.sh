#!/bin/bash
# Idle handling for mango: same policy as niri.sh, only the monitor on/off differs.

if pgrep -x swayidle >/dev/null; then
  exit 0
fi

# Shell panel in use: its own idle timer locks the screen, swayidle only locks before sleep.
if [[ -f $HOME/.local/state/omarchy/toggles/shell-panel ]]; then
  exec swayidle -w before-sleep 'oq omarchy-system-sleep-lock'
fi

lock_cmd='pgrep -x hyprlock >/dev/null || hyprlock'
outputs_off='for o in $(wlr-randr --json | jq -r ".[].name"); do wlr-randr --output "$o" --off; done'
outputs_on='for o in $(wlr-randr --json | jq -r ".[].name"); do wlr-randr --output "$o" --on; done'

swayidle \
  timeout 300 "$lock_cmd" \
  timeout 310 "$outputs_off" resume "$outputs_on" \
  before-sleep "$lock_cmd"
