#!/bin/bash

if pgrep -x swayidle >/dev/null; then
  exit 0
fi

# Shell panel in use (panel-switch sets this flag): its own idle timer locks
# and blanks the screen, so swayidle only locks before sleep. Running both
# idle lockers at once makes them race for the session lock. sleep-lock waits
# until the lock screen is really up, so the desktop never shows on wake.
if [[ -f $HOME/.local/state/omarchy/toggles/shell-panel ]]; then
  exec swayidle -w before-sleep 'oq omarchy-system-sleep-lock'
fi

lock_cmd='pgrep -x hyprlock >/dev/null || hyprlock'

swayidle \
  timeout 300 "$lock_cmd" \
  timeout 310 "niri msg action power-off-monitors" \
  before-sleep "$lock_cmd"
