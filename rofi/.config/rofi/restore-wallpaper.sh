#!/bin/bash

wall_dir=$HOME/Pictures/wall

mkdir -p "$wall_dir"
prev_wallpaper="$wall_dir/current_wallpaper"

if ! awww query >/dev/null 2>&1; then
  awww-daemon &
  sleep 0.3
fi

if [ -f "$prev_wallpaper" ]; then
  awww img "$prev_wallpaper"
fi
