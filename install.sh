#!/usr/bin/env bash
# Bootstrap this setup on a fresh Arch install:
#   git clone https://github.com/nganaremba-rem/.dotfiles ~/.dotfiles && ~/.dotfiles/install.sh
#
# Steps: native packages (pkglist.txt) -> yay + AUR packages (pkglist-aur.txt)
#        -> zinit -> stow every package in packages.txt (existing files are backed up).
# Safe to re-run. Env: SKIP_PACKAGES=1 to only stow, TARGET=dir to stow somewhere else (testing).
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$HOME}"
cd "$DOT"

list() { grep -v '^\s*#' "$1" | grep -v '^\s*$'; }

if [[ -z "${SKIP_PACKAGES:-}" ]]; then
  # Needed by the dotfiles themselves even when only pulled in as deps on the reference PC
  # (zenity: askpass-zenity, python-gobject: vimb-tabs AT-SPI, libnotify: vimb-pick notify-send).
  sudo pacman -Syu --needed git base-devel stow zenity python-gobject libnotify

  # Install what the repos still carry; report the rest instead of aborting the transaction.
  mapfile -t avail < <(comm -12 <(list pkglist.txt | sort -u) <(pacman -Slq | sort -u))
  mapfile -t gone < <(comm -23 <(list pkglist.txt | sort -u) <(pacman -Slq | sort -u))
  sudo pacman -S --needed "${avail[@]}"
  if ((${#gone[@]})); then
    echo "!! Not in the enabled repos (enable [multilib] in /etc/pacman.conf if needed): ${gone[*]}"
  fi

  if ! command -v yay >/dev/null; then
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
  fi
  # Interactive on purpose: review AUR PKGBUILDs.
  list pkglist-aur.txt | yay -S --needed -
fi

zinit_dir="$TARGET/.local/share/zinit/zinit.git"
[[ -d "$zinit_dir" ]] || git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$zinit_dir"

# Stow, moving any pre-existing file that blocks a link into a timestamped backup.
backup="$TARGET/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
while read -r pkg; do
  # systemd ignores a drop-in dir that is itself a symlink; pre-create *.d dirs so
  # stow links the files inside instead of folding the whole dir.
  while read -r d; do mkdir -p "$TARGET/${d#"$pkg"/}"; done \
    < <(find "$pkg" -type d -path '*/systemd/*' -name '*.d')
  while read -r rel; do
    mkdir -p "$backup/$(dirname "$rel")"
    mv "$TARGET/$rel" "$backup/$rel"
    echo "   backed up ~/$rel"
  done < <(stow -n -d "$DOT" -t "$TARGET" "$pkg" 2>&1 | sed -n 's/.* over existing target \(.*\) since .*/\1/p')
  stow -d "$DOT" -t "$TARGET" "$pkg"
  echo "stowed $pkg"
done < <(list packages.txt)
[[ -d "$backup" ]] && echo "Replaced files saved in $backup"

cat <<'EOF'

Done. Manual follow-ups:
  - chsh -s /usr/bin/zsh, then open a new shell (zinit fetches plugins on first start)
  - cp ~/.config/zsh/secrets.zsh.example ~/.config/zsh/secrets.zsh and fill it in
  - mise install                 # node/python/go/bun... from ~/.config/mise/config.toml
  - nvim                         # lazy.nvim + mason install plugins/LSPs on first launch
  - remtube (Mod+Alt+Y) is its own project: build/install it from its repo
  - DMS plugins (quickCapture, wallpaperCarousel): reinstall from DMS settings
  - log out and back in so niri, environment.d and the systemd user units pick everything up
EOF
