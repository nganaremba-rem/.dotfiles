#!/usr/bin/env bash
# Bootstrap this setup on a fresh Arch install:
#   git clone https://github.com/nganaremba-rem/.dotfiles ~/.dotfiles && ~/.dotfiles/install.sh
#
# Steps: native packages (setup/pacman.txt) -> yay + AUR packages (setup/aur.txt)
#        -> zinit -> stow every package in setup/stow-packages.txt (existing files are backed up)
#        -> desktop shell checkout (setup/shell-checkout/) -> system files (setup/system/, only with WITH_SYSTEM=1).
# Safe to re-run. Env: SKIP_PACKAGES=1 to only stow, TARGET=dir to stow somewhere else (testing),
#                      WITH_SYSTEM=1 to also run setup/system/apply.sh (sudo; read setup/system/reference/ first).
# README.md explains the layout.
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
  mapfile -t avail < <(comm -12 <(list setup/pacman.txt | sort -u) <(pacman -Slq | sort -u))
  mapfile -t gone < <(comm -23 <(list setup/pacman.txt | sort -u) <(pacman -Slq | sort -u))
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
  list setup/aur.txt | yay -S --needed -
fi

zinit_dir="$TARGET/.local/share/zinit/zinit.git"
[[ -d "$zinit_dir" ]] || git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$zinit_dir"

# Folders that other programs write into must be real folders, or stow links the
# whole folder into this repo and their files land here (uv, mise shims, enabled units).
mkdir -p "$TARGET/.local/bin" "$TARGET/.local/share" "$TARGET/.config/systemd/user" "$TARGET/.config"

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
done < <(list setup/stow-packages.txt)
[[ -d "$backup" ]] && echo "Replaced files saved in $backup"

if [[ "$TARGET" == "$HOME" ]]; then
  # Desktop shell behind Mod+Space, the pickers and the bar: upstream + the niri patches.
  "$DOT/setup/shell-checkout/setup.sh"
  fc-cache -f >/dev/null 2>&1 || true
  # sysctl, zram, resolved, udev, keyd, own units, enabled services. Asks for sudo.
  if [[ -n "${WITH_SYSTEM:-}" ]]; then
    "$DOT/setup/system/apply.sh"
  fi
fi

cat <<'EOF'

Done. Manual follow-ups:
  - chsh -s /usr/bin/zsh, then open a new shell (zinit fetches plugins on first start)
  - cp ~/.config/zsh/secrets.zsh.example ~/.config/zsh/secrets.zsh and fill it in
  - mise install                 # node/python/go/bun... from ~/.config/mise/config.toml
  - nvim                         # lazy.nvim + mason install plugins/LSPs on first launch
  - remtube (Mod+Alt+Y) is its own project: build/install it from its repo
  - DMS plugins (quickCapture, wallpaperCarousel): reinstall from DMS settings
  - system half, if not done: WITH_SYSTEM=1 ~/.dotfiles/install.sh (or setup/system/apply.sh), then
    merge setup/system/reference/ by hand (pacman.conf repos, grub, greetd, ufw rules, Caddyfile)
  - not in this repo, set up again: WireGuard/Tailscale/ZeroTier/WARP logins, DuckDNS token
    (setup/system/reference/ddns-update.sh.example), espanso matches, browser profiles, ~/.claude
  - rembrowser and heliscroll are their own projects: build/install them from their repos
  - the WARP proxy container: setup/system/reference/docker-warp2.txt
  - ~/.config/omarchy/README.md explains how to change the bar and the menu
  - log out and back in so niri, environment.d and the systemd user units pick everything up
EOF
