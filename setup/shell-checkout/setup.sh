#!/usr/bin/env bash
# Rebuild the desktop shell (Mod+Space menu, pickers, bar) used by the niri config.
#
# It is the upstream Quickshell desktop at one known commit (BASE) plus the niri
# port kept as patches here. The result is a normal git checkout on branch
# "niri" in ~/.local/share/omarchy-quattro, which `oq` points at.
#
# Refresh the patches after committing more work in that checkout:
#   cd ~/.local/share/omarchy-quattro && rm ~/.dotfiles/setup/shell-checkout/patches/*.patch &&
#     git format-patch --no-signature -o ~/.dotfiles/setup/shell-checkout/patches "$(cat ~/.dotfiles/setup/shell-checkout/BASE)"..niri
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="${SHELL_CHECKOUT:-$HOME/.local/share/omarchy-quattro}"
upstream="${SHELL_UPSTREAM:-$(<"$here/UPSTREAM")}"
base="$(<"$here/BASE")"

if [[ -d $dest/.git ]]; then
  echo "shell checkout already at $dest, left as it is"
else
  git clone --filter=blob:none --no-checkout "$upstream" "$dest"
  git -C "$dest" checkout -q -B niri "$base"
  git -C "$dest" \
    -c "user.name=$(git config user.name || echo dotfiles)" \
    -c "user.email=$(git config user.email || echo dotfiles@localhost)" \
    am -q "$here"/patches/*.patch
  echo "shell checkout built at $dest ($(git -C "$dest" rev-list --count "$base"..niri) patches on ${base:0:9})"
fi

# Which compositor and which panel the shell runs as (see niri/bin/panel-switch).
mkdir -p "$HOME/.local/state/omarchy/toggles"
touch "$HOME/.local/state/omarchy/toggles/niri" "$HOME/.local/state/omarchy/toggles/shell-panel"
