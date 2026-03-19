#!/bin/bash

wall_dir=$HOME/Pictures/wall

mkdir -p "$wall_dir"
prev_wallpaper="$wall_dir/current_wallpaper"

if ! swww query >/dev/null 2>&1; then
  swww-daemon &
  sleep 0.3
fi

if [ -f "$prev_wallpaper" ]; then
  swww img "$prev_wallpaper"
fi
