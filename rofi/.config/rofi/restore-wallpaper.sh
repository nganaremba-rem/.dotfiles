#!/bin/bash

cache_file="$HOME/.cache/current_wallpaper"

if ! swww query >/dev/null 2>&1; then
  swww-daemon &
  sleep 0.3
fi

if [ -f "$cache_file" ]; then
  swww img "$(cat "$cache_file")"
fi
