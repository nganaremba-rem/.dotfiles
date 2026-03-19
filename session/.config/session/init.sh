#!/bin/bash

case "$XDG_CURRENT_DESKTOP" in
Hyprland)
  source ~/.config/session/hyprland.sh
  ;;
niri)
  source ~/.config/session/niri.sh
  ;;
esac
