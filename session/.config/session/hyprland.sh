#!/bin/bash

if pgrep -x swayidle >/dev/null; then
  exit 0
fi

lock_cmd='pgrep -x hyprlock >/dev/null || hyprlock'

swayidle \
  timeout 300 "$lock_cmd" \
  timeout 310 "hyprctl dispatch dpms off"
