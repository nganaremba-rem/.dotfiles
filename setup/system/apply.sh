#!/usr/bin/env bash
# Put the system-level half of this setup in place on a fresh install.
#   ~/.dotfiles/setup/system/apply.sh          # or: WITH_SYSTEM=1 ~/.dotfiles/install.sh
#
# files/      copied to / as they are (sysctl, zram, resolved, NetworkManager, udev,
#             keyd, modprobe, pacman hooks, own systemd units and their scripts).
#             A file that already exists and differs is saved next to itself as *.pre-dotfiles.
# reference/  NOT copied: tied to this machine or site (pacman.conf, grub, mkinitcpio,
#             greetd, Caddyfile, ufw rules, ...). Read and merge by hand.
# units-*.txt services that were enabled here; enabled when the unit exists.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while IFS= read -r -d '' src; do
  dest="/${src#"$here/files/"}"
  if sudo test -e "$dest" && ! sudo cmp -s "$src" "$dest"; then
    sudo cp -a "$dest" "$dest.pre-dotfiles"
    echo "   kept old $dest as $dest.pre-dotfiles"
  fi
  mode=644
  [[ -x $src ]] && mode=755
  sudo install -D -m "$mode" "$src" "$dest"
done < <(find "$here/files" -type f -print0)

sudo systemctl daemon-reload
sudo sysctl --system >/dev/null
sudo udevadm control --reload

enable() { # <systemctl args...> < unit list
  local unit
  while read -r unit; do
    [[ -n $unit ]] || continue
    if systemctl "$@" cat "$unit" >/dev/null 2>&1; then
      systemctl "$@" enable "$unit" >/dev/null 2>&1 || echo "   could not enable $unit"
    else
      echo "   skipped $unit (not installed)"
    fi
  done
}
# shellcheck disable=SC2024 # the list is ours to read; only the enabling needs root
sudo bash -c "$(declare -f enable); enable" <"$here/units-system.txt"
enable --user <"$here/units-user.txt"

cat <<'EOF'

System files applied. By hand, from setup/system/reference/:
  - etc/pacman.conf        extra repos ([multilib], [lizardbyte]) before installing packages
  - etc/default/grub, etc/mkinitcpio.conf   kernel/boot options; do NOT copy blindly (UUIDs, hooks)
  - etc/greetd/            login manager (dms-greeter running niri)
  - etc/ufw/               firewall rules as they were: `ufw` commands are safer than copying
  - etc/caddy/Caddyfile, ddns-update.sh.example (needs the DuckDNS token), docker-warp2.txt
  - WireGuard, Tailscale, ZeroTier, WARP: keys and logins are not in this repo
EOF
