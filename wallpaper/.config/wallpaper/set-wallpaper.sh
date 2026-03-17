#!/bin/bash

wall_dir="$HOME/Pictures/wallpapers"
cache_file="$HOME/.cache/current_wallpaper"

selected=$(find "$wall_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | while read -r img; do
  name=$(basename "$img" | sed 's/\.[^.]*$//')
  echo -en "$name\x00icon\x1f$img\n"
done | rofi -dmenu \
  -theme "$HOME/.config/rofi/launchers/type-2/style-2.rasi" \
  -show-icons \
  -p "Wallpapers" \
  -theme-str '
window {
    width: 70%;
    height: 70%;
}
listview {
    columns: 3;
    lines: 3;
    spacing: 15;
}
element {
    orientation: vertical;
    padding: 10;
}
element-icon {
    size: 220px;
}
element-text {
    horizontal-align: 0.5;
}')

[ -z "$selected" ] && exit

img_path=$(find "$wall_dir" -type f -iname "$selected.*" | head -n 1)

swww img "$img_path" --transition-type grow --transition-duration 1

echo "$img_path" >"$cache_file"
