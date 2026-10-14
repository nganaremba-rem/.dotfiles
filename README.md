# dotfiles

My Arch Linux desktop: niri, a Quickshell bar and menu, foot, Neovim, and the system settings under them. Clone it on a fresh install, run one script, and the desktop comes back.

- [The one rule](#the-one-rule)
- [Layout](#layout)
- [Install on a new machine](#install-on-a-new-machine)
- [Day to day](#day-to-day)
- [Where is what](#where-is-what)
- [The desktop shell](#the-desktop-shell)
- [System files](#system-files)
- [Not in this repo](#not-in-this-repo)
- [Names that look odd](#names-that-look-odd)
- [When something is off](#when-something-is-off)

## The one rule

**Every top-level folder is one program, except `setup/` and `archive/`.**

A program's folder mirrors the home folder. Whatever is inside it gets linked to the same path under `~`:

```
foot/.config/foot/foot.ini        →  ~/.config/foot/foot.ini
bin/.local/bin/oq                 →  ~/.local/bin/oq
bash/.bashrc                      →  ~/.bashrc
swayosd/.config/systemd/user/swayosd-server.service
                                  →  ~/.config/systemd/user/swayosd-server.service
```

The links are made by [GNU Stow](https://www.gnu.org/software/stow/). So `~/.config/foot` *is* `~/.dotfiles/foot/.config/foot`: edit either path, it is the same file. A service that belongs to a program lives in that program's folder, next to its config.

## Layout

```
~/.dotfiles
├── README.md            this file
├── install.sh           sets up a new machine
├── <program>/           64 folders, one per program, linked into ~
├── setup/               what install.sh uses; nothing in here is linked into ~
│   ├── stow-packages.txt    which program folders get linked
│   ├── pacman.txt           packages from the Arch repos
│   ├── aur.txt              packages from the AUR
│   ├── shell-checkout/      how to rebuild the desktop shell (see below)
│   └── system/              files for /etc and /usr/local (see below)
└── archive/             old configs kept for reference; not installed
```

## Install on a new machine

```bash
git clone https://github.com/nganaremba-rem/.dotfiles ~/.dotfiles
~/.dotfiles/install.sh                    # packages, links, desktop shell
WITH_SYSTEM=1 ~/.dotfiles/install.sh      # the same, plus system files (asks for sudo)
```

What `install.sh` does, in order:

1. Installs the packages in `setup/pacman.txt`, then `yay` and `setup/aur.txt`.
2. Links every folder named in `setup/stow-packages.txt` into `~`. A file that is in the way is moved to `~/.dotfiles-backup/<date>/`, never deleted.
3. Rebuilds the desktop shell in `~/.local/share/omarchy-quattro`.
4. Only with `WITH_SYSTEM=1`: copies `setup/system/files/` to `/` and enables the services that were enabled here.

It is safe to run again. It ends with a list of things to do by hand (default shell, secrets, logins). `SKIP_PACKAGES=1` skips step 1.

Before step 4 on a different machine, read `setup/system/reference/`: those files are tied to this laptop and are not copied.

## Day to day

**Change a config.** Edit it where the program reads it (`~/.config/foot/foot.ini`). Then commit:

```bash
cd ~/.dotfiles && git status && git add -A && git commit -m "foot: bigger font"
```

**Start tracking a new program.** Example for `~/.config/mpv`:

```bash
cd ~/.dotfiles
mkdir -p mpv/.config
mv ~/.config/mpv mpv/.config/mpv          # move the real folder into the repo
stow mpv                                  # link it back
echo mpv >> setup/stow-packages.txt       # so a new machine links it too
```

**Stop tracking one.** `stow -D mpv`, move the folder back, delete the line from `setup/stow-packages.txt`.

**After installing or removing packages**, refresh the lists:

```bash
pacman -Qqen > ~/.dotfiles/setup/pacman.txt
pacman -Qqem | grep -vx rembrowser > ~/.dotfiles/setup/aur.txt
```

**Check for secrets before pushing.** The repo is public. `git diff --cached` and read it.

## Where is what

### Desktop

| I want to change… | Folder | Notes |
|---|---|---|
| Window manager: keys, rules, layout, animations, startup | `niri/` | Split into `settings/`, `rules/`, `binds/`, `scripts/`. It has its own `README.md`. |
| Bar and menu (Mod+Space) contents | `omarchy/` | `shell.json` is the bar, `extensions/omarchy-menu.jsonc` is the menu. Guide: `~/.config/omarchy/README.md`. |
| What starts with the session | `niri/` (`settings/startup.kdl`), `session/`, `autostart/`, `uwsm/` | `session/` picks the idle/lock setup per compositor. |
| Environment variables for the session | `environment/` | `~/.config/environment.d/` |
| Lock screen, idle | `hyprlock/`, `swayidle/`, `swaylock/` | |
| The other panel (DankMaterialShell) | `dms/`, `dms-shell/` | Still installed; `oq panel-switch dms` brings it back. |
| Launchers and pickers | `fuzzel/`, `rofi/`, `wlogout/` | |
| Wallpapers | `wallpaper/` | `~/Pictures/wallpapers` lives here (about 1 GB). |
| Colours and themes | `matugen/`, `qt/`, `gtk/`, `omarchy/` (`current/theme`) | |
| Fonts | `fontconfig/` | Sets the monospace font the bar and menu use. |
| Volume/brightness pop-up, night light | `swayosd/`, `gammastep/` | |
| Screen sharing | `xdg-desktop-portal/`, `hyprland-preview-share-picker/` | |
| Typing: input method, compose key, key remaps | `fcitx5/`, `xcompose/`, `input-remapper/` | keyd's config is a system file. |
| Default apps, user folders | `xdg/` | `mimeapps.list`, `user-dirs.dirs` |
| Other compositors | `mango/`, `waybar/` | Hyprland's old config is in `archive/`. |

### Programs

| Kind | Folders |
|---|---|
| Terminals | `foot/` (main), `kitty/`, `alacritty/`, `wezterm/` |
| Shells and prompt | `zsh/`, `bash/`, `starship/`, `tmux/`, `herdr/` |
| Editors | `nvim-kickstart/` (the main Neovim, `~/.config/nvim`), `nvim-gg/`, `nvim-new/` (extra setups: `NVIM_APPNAME=nvim-gg nvim`) |
| Browsers | `vimb/`, `rembrowser/`, `browser-flags/` |
| Git | `git/`, `lazygit/` |
| Files, viewers | `yazi/`, `imv/`, `zathura/`, `swappy/` |
| Monitors and fetch | `btop/`, `bottom/`, `cava/`, `fastfetch/` |
| Language tools | `mise/`, `npm/`, `pacman/` (my `makepkg.conf`) |
| Clipboard, OCR, dictation, API client | `cliphist/`, `ocr/`, `manga-ocr/`, `voxtype/`, `atac/` |
| Smooth scrolling helper | `heliscroll/` |
| Video/audio downloader (`Mod+Alt+D`) | `ytdl/` (popup, `ytdl-*` scripts, the YouTube cookie-export extension) |

### My own commands

`bin/.local/bin/` holds scripts that are commands of their own. The ones the desktop relies on:

| Command | Does |
|---|---|
| `oq <command>` | Runs a command with the desktop shell's environment. Used in keybinds. |
| `askpass-zenity` | Password prompt for `sudo -A` when there is no terminal. |
| `ocr`, `screen-translate` | Read or translate text from a screen region. |
| `niri-curve-pick` | Tune niri's animation springs. |
| `mic-toggle`, `camera-toggle`, `bt-callmode` | Hardware toggles bound to keys. |

Scripts that only niri uses are in `niri/.config/niri/scripts/`: `scratchpad`, `uclip` (Mod+C / Mod+V everywhere), `toggle-split`.

## The desktop shell

The menu, pickers and bar are one Quickshell program. It has two halves, kept in two places:

| Half | Where | In this repo as |
|---|---|---|
| **Settings**: bar layout, menu rows, themes | `~/.config/omarchy/` | `omarchy/` (a normal program folder) |
| **Code**: the shell itself | `~/.local/share/omarchy-quattro/` | `setup/shell-checkout/` (a recipe, not the code) |

The code is someone else's project plus my changes for niri. Storing a full copy would be large and would go stale, so the repo keeps only:

- `UPSTREAM`: where the original lives
- `BASE`: the exact upstream commit my changes sit on
- `patches/`: my changes, one file per commit

`setup/shell-checkout/setup.sh` clones upstream at `BASE` and applies the patches. The result is a normal git checkout on branch `niri`.

**After changing the shell's code**, commit in the checkout, then refresh the patches or the repo falls behind:

```bash
cd ~/.local/share/omarchy-quattro
rm ~/.dotfiles/setup/shell-checkout/patches/*.patch
git format-patch --no-signature -o ~/.dotfiles/setup/shell-checkout/patches \
  "$(cat ~/.dotfiles/setup/shell-checkout/BASE)"..niri
```

Useful commands:

```bash
oq omarchy-restart-shell                 # restart the shell
oq panel-switch shell|dms|toggle         # which bar is on screen
journalctl --user -b -t omarchy-shell    # its log
```

## System files

`setup/system/` holds what lives outside the home folder. Stow cannot link these (they belong to root), so they are copied.

| Folder | What | How it gets applied |
|---|---|---|
| `files/` | Mirrors `/`. Swap tuning (`etc/sysctl.d/`, `zram-generator.conf`), DNS (`etc/systemd/resolved.conf.d/`), NetworkManager, udev rules, keyd, kernel module options, pacman hooks, my own services and their scripts. | `setup/system/apply.sh` copies them. An existing file that differs is kept as `<name>.pre-dotfiles`. |
| `reference/` | Tied to this laptop or my setup: `pacman.conf`, GRUB, `mkinitcpio.conf`, the login manager, firewall rules, the web server. | **Not copied.** Read and merge by hand. |
| `units-system.txt`, `units-user.txt` | Services that were enabled. | `apply.sh` enables the ones that exist. |

**After changing a system file**, copy it into the repo so the two stay equal:

```bash
sudo cat /etc/sysctl.d/99-zram.conf > ~/.dotfiles/setup/system/files/etc/sysctl.d/99-zram.conf
```

## Not in this repo

Left out on purpose. Set these up again by hand on a new machine.

| What | Why |
|---|---|
| `~/.config/zsh/secrets.zsh` | API keys. A template is tracked: `secrets.zsh.example`. |
| `~/.config/espanso` | The text expansions contain passwords. |
| `/usr/local/bin/ddns-update.sh` | Holds the DuckDNS token. Template: `setup/system/reference/ddns-update.sh.example`. |
| WireGuard, Tailscale, ZeroTier, WARP | Keys and logins. |
| Browser profiles, app data, `~/.claude` | Large, private, or their own repo. |
| `~/bin` | Downloaded programs and installers, not config. |
| `rembrowser`, `heliscroll`, `remtube` | My own projects: build them from their repos. Their *configs* are here. |

`.gitignore` blocks the files that are easy to add by accident.

## Names that look odd

| Name | Why |
|---|---|
| `omarchy/`, `~/.local/share/omarchy-quattro`, `oq omarchy-…` | The shell's upstream project uses that name for its folders and commands, and the code looks for them there. Nothing on screen carries the name. |
| `nvim-kickstart/` | Links to `~/.config/nvim`. Named after the config it started from. |
| `hyprlock/` links into `~/.config/hypr/` | That is where hyprlock reads its config. |
| `swayidle/` links into `~/.config/sway/` | Same reason. |
| `dms/` vs `dms-shell/` | `dms` is DankMaterialShell's settings. `dms-shell` is a service override that runs my modified copy of it. |

## When something is off

| Symptom | Check |
|---|---|
| A config change does nothing | Is the file still a link? `ls -l ~/.config/<program>`. Some programs replace a link with a plain file when they save. Move the file back into the repo and run `stow <program>`. |
| `stow` reports a conflict | A real file sits where a link should go. Move it into the program's folder (or away), then run `stow <program>` again. |
| A new machine misses a program | Is its folder named in `setup/stow-packages.txt`? |
| niri ignores a config edit | `niri validate` prints the error. |
| Bar or menu looks wrong | `~/.config/omarchy/README.md`, section "If something breaks". |
| A service is missing after install | `systemctl --user status <unit>`; the lists are in `setup/system/units-*.txt`. |
| Which links exist? | `stow -n -v <program>` shows what stow would do without doing it. |
