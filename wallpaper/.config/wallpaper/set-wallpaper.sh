#!/bin/bash

wall_dir="$HOME/Pictures/wallpapers"
cache_dir="$HOME/Pictures/wall"
mkdir -p "$cache_dir"
cache_file="$cache_dir/current_wallpaper"

selected=$(fd --absolute-path -t f -i -e jpg -e png -e jpeg -e webp . "$wall_dir" | while read -r img; do
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

img_path=$(fd --absolute-path -t f -i -e jpg -e png -e jpeg -e webp --glob "$selected.*" "$wall_dir" | head -n 1)

awww img "$img_path" --transition-type grow --transition-duration 1

cp "$img_path" "$cache_file"

# echo "$img_path" >"$cache_file"
