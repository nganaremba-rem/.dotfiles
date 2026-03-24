#!/bin/bash

desktop="${XDG_CURRENT_DESKTOP:-}"

case "$desktop" in
  *Hyprland*|*hyprland*)
    exec "$HOME/.config/session/hyprland.sh"
    ;;
  *niri*)
    exec "$HOME/.config/session/niri.sh"
    ;;
  *)
    if pgrep -x Hyprland >/dev/null; then
      exec "$HOME/.config/session/hyprland.sh"
    elif pgrep -x niri >/dev/null; then
      exec "$HOME/.config/session/niri.sh"
    fi
    ;;
esac
