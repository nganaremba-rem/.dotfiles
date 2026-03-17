#!/bin/bash

WALL="$HOME/.config/wallpaper/current.jpg"

# start daemon if needed
pgrep swww-daemon >/dev/null || swww-daemon &

sleep 0.3
swww img "$WALL" --transition-type grow --transition-fps 60
