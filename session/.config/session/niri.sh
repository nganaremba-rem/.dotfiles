#!/bin/bash

if pgrep -x swayidle >/dev/null; then
  exit 0
fi

lock_cmd='pgrep -x hyprlock >/dev/null || hyprlock'

swayidle \
  timeout 10 "$lock_cmd" \
  timeout 15 "niri msg action power-off-monitors"
