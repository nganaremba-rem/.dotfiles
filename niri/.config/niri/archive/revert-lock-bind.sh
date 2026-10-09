#!/usr/bin/env bash
# Reverts the Super+Alt+L hyprlock lock keybind added 2026-06-15.
# Usage:  bash ~/.config/niri/revert-lock-bind.sh
set -eu
f="$HOME/.config/niri/keybinds.kdl"
cp -L "$f" "$f.bak.$(date +%s)"
sed -i '/hotkey-overlay-title="Lock screen (hyprlock)"/d' "$f"
if niri validate >/dev/null 2>&1; then
  echo "Lock keybind removed. niri auto-reloads; Super+Alt+L no longer locks."
else
  echo "niri reports an error; restoring backup."
  cp "$(ls -t "$f".bak.* | head -1)" "$f"
fi
