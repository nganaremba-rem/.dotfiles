#!/bin/bash

WALL_DIR="$HOME/Pictures/wallpapers"

IMG=$(fd -e png -e jpg -e webp . ${WALL_DIR} -x basename |
  fuzzel --dmenu \
    prompt="Pick Wallpaper")

IMG="$WALL_DIR/$IMG"

[ -z "$IMG" ] && exit 0

# to make the wallpaper persistent on boot
cp "$IMG" ~/.config/wallpaper/current.jpg

# Set wallpaper
swww img "$IMG" --transition-fps 60 --transition-step 1 --transition-type grow

# Generate theme
matugen image "$IMG" --mode dark

# Reload UI
pkill swaync && swaync &
pkill waybar && waybar &
