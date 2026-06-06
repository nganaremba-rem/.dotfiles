#!/bin/bash

if pgrep -x swayidle >/dev/null; then
  exit 0
fi

lock_cmd='pgrep -x hyprlock >/dev/null || hyprlock'

swayidle \
  timeout 300 "$lock_cmd" \
  timeout 310 "wlr-randr --output eDP-1 --off && wlr-randr --output DP-2 --off && wlr-randr --output DP-3 --off" \
  before-sleep "$lock_cmd"
