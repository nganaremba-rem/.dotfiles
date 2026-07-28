# ════════════════════════════════════════════════════════════════════════════
#  ~/.zshrc
#  Profiling: uncomment both zmodload lines, open shell, run: zprof | head -20
# ════════════════════════════════════════════════════════════════════════════
# zmodload zsh/zprof

# ── Sysinfo ──────────────────────────────────────────────────────────────────
# Greet once per shell tree: the first shell shows it; nested subshells inherit
# the marker and skip it (and each new terminal/tmux pane greets fresh).
if [[ -z "$_NITCH_SHOWN" ]]; then
  nitch
  export _NITCH_SHOWN=1
fi

# ── Environment ──────────────────────────────────────────────────────────────
export EDITOR=nvim VISUAL=nvim SUDO_EDITOR=/usr/bin/nvim
# Let each terminal set its own TERM (foot=foot, kitty=xterm-kitty) so neovim
# gets full capability info. Fall back only when the terminal hasn't set one.
[[ -z "$TERM" || "$TERM" == "dumb" ]] && export TERM=xterm-256color
export CHROME_DEVEL_SANDBOX=/usr/local/bin/chrome-sandbox
export CHROME_EXECUTABLE=chromium
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_AVD_HOME="$HOME/.config/.android/avd"
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"
export PYENV_ROOT="$HOME/.pyenv"
export SDKMAN_DIR="$HOME/.sdkman"
export GDK_SCALE=1
export LIBVIRT_DEFAULT_URI=qemu:///system
export FLUTTER_ENGINE_SWITCH_1=--enable-vulkan
export ATAC_KEY_BINDINGS="$HOME/.config/atac/vim_key_bindings.toml"
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline --bind=ctrl-k:up,ctrl-j:down"
export SUDO_ASKPASS=~/.local/bin/askpass-zenity

# Secrets (API keys, tokens) live in a gitignored, 0600 file — never in this
# dotfile. Put `export ANTHROPIC_API_KEY=sk-ant-...` (for avante.nvim) there.
[[ -f ~/.config/zsh/secrets.zsh ]] && source ~/.config/zsh/secrets.zsh

[[ -d "$SDKMAN_DIR/candidates/java/current" ]] && export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"

# ── PATH ─────────────────────────────────────────────────────────────────────
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/bin/nvim/bin"
  "$HOME/bin/arch"
  "$HOME/.local/share/omarchy/bin"
  "$HOME/.local/lib/simutil"
  "$HOME/.console-ninja/.bin"
  "$HOME/.opencode/bin"
  "/usr/local/go/bin"
  "$HOME/go/bin"
  "$HOME/.pub-cache/bin"
  "$HOME/.bun/bin"
  "$PNPM_HOME"
  "$PYENV_ROOT/bin"
  "$PYENV_ROOT/shims"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/emulator"
  "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
  "$HOME/develop/flutter/bin"
  "$HOME/bin/thunderbird"
  "$HOME/bin/Postman/app"
  "$HOME/bin/idea-IC-252.25557.131/bin"
  "/opt/mssql-tools18/bin"
  "$HOME/.lmstudio/bin"
  $path
)

# ── Zsh options ──────────────────────────────────────────────────────────────
setopt autocd interactivecomments promptsubst extendedglob nocaseglob numericglobsort
setopt nobeep noflowcontrol

# ── History ──────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt histignoredups histignorespace histreduceblanks sharehistory incappendhistory

# ── Completion ───────────────────────────────────────────────────────────────
fpath=("$HOME/.zsh/completions" $fpath)
autoload -Uz compinit

# Rebuild dump at most once per day
() {
  local dump="$HOME/.zcompdump"
  if [[ -n "$dump"(#qN.mh+24) ]]; then
    compinit -d "$dump"
  else
    compinit -C -d "$dump"
  fi
}

mkdir -p "$HOME/.zsh/cache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{green}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{red}no matches%f'
zstyle ':completion::complete:*' use-cache yes
zstyle ':completion::complete:*' cache-path "$HOME/.zsh/cache"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --icons --color=always $realpath 2>/dev/null | head -20'
zstyle ':fzf-tab:*' switch-group '<' '>'

# ── Zinit ────────────────────────────────────────────────────────────────────
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
((${+_comps})) && _comps[zinit]=_zinit

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

zinit lucid wait for \
  atload'
    # Flip default weights: thin when the command is wrong, bold when correct
    FAST_HIGHLIGHT_STYLES[unknown-token]="fg=red"
    for k in command builtin alias suffix-alias global-alias function \
             precommand hashed-command reserved-word subcommand; do
      FAST_HIGHLIGHT_STYLES[$k]="fg=green,bold"
    done
    unset k
  ' \
  zdharma-continuum/fast-syntax-highlighting \
  zsh-users/zsh-autosuggestions \
  Aloxaf/fzf-tab

# pyenv — shims already in PATH handle python/pip; this adds shell integration
pyenv() {
  unset -f pyenv
  eval "$(command pyenv init -)"
  pyenv "$@"
}

# sdkman
sdk() {
  unset -f sdk
  source "$SDKMAN_DIR/bin/sdkman-init.sh" 2>/dev/null
  sdk "$@"
}

# ── Cache slow evals (regenerate only when binary changes) ───────────────────
_eval_cache() {
  local name="$1" cmd cache
  shift
  cmd="$(command -v "$1" 2>/dev/null)" || return
  cache="$HOME/.cache/zsh/${name}.zsh"
  [[ -f "$cache" && "$cache" -nt "$cmd" ]] || {
    mkdir -p "${cache%/*}"
    "$@" >"$cache" 2>/dev/null
  }
  source "$cache"
}

_eval_cache starship starship init zsh
_eval_cache direnv direnv hook zsh
# zoxide is initialized at the very end of this file — it wants to be last
# (otherwise `zoxide`'s self-check prints a configuration warning).

# fzf shell integration
source /usr/share/fzf/key-bindings.zsh 2>/dev/null
source /usr/share/fzf/completion.zsh 2>/dev/null

# Bun completions
[[ -s "$HOME/.oh-my-zsh/completions/_bun" ]] && source "$HOME/.oh-my-zsh/completions/_bun"

# ── Vi mode ──────────────────────────────────────────────────────────────────
bindkey -v
KEYTIMEOUT=1

# Cursor: block in both modes — steady block in normal, blinking block in insert
_zsh_set_cursor() {
  case "$KEYMAP" in
  vicmd) print -n '\e[2 q' ;;
  viins | main | '') print -n '\e[1 q' ;;
  esac
}
zle -N zle-keymap-select _zsh_set_cursor
zle -N zle-line-init _zsh_set_cursor

# Restore expected insert-mode bindings that vi mode breaks
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^k' kill-line
bindkey ' ' magic-space # expand !!, !$
bindkey '^r' history-incremental-search-backward

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line # edit current line in $EDITOR

# ── Hooks ────────────────────────────────────────────────────────────────────
autoload -Uz add-zsh-hook

# Update niri window title and PWD tracker
add-zsh-hook precmd _precmd_hooks
_precmd_hooks() {
  update-shell-pwd 2>/dev/null
  print -Pn '\e]2;%~\a' # set terminal title to cwd
}

# Soft guard against obvious foot-guns
add-zsh-hook preexec _preexec_safety
_preexec_safety() { [[ "$1" == 'rm -rf /'* || "$1" == 'rm -fr /'* ]] && echo '[warn] that looks dangerous'; }

# ── Aliases ──────────────────────────────────────────────────────────────────
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Listing (eza)
alias ls='eza --icons --git'
alias ll='eza -l  --icons --git --time-style=relative'
alias la='eza -la --icons --git --time-style=relative'
alias lt='eza --tree --icons --git -L 3'
alias l='eza -1 --icons'

# Core tools
# alias cat='bat'
alias grep='grep --color=auto'
alias lg='lazygit'
alias t='tmux'
alias g='git'
alias tt='taskwarrior-tui'

# Git shortcuts
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpl='git pull --rebase'
alias gst='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gb='git branch'
alias gsw='git switch'

# Pacman / AUR
alias i='sudo pacman -S --needed --noconfirm --overwrite="*"'
alias ia='yay -S --needed --noconfirm --overwrite="*"'
alias up='yay -Syu --noconfirm'
alias orphans='sudo pacman -Rns $(pacman -Qtdq)'

# Cargo
alias cr='cargo run'
alias cb='cargo build --release'
alias ct='cargo test'
alias cl='cargo clippy'

# Flutter / Dart
alias cf='cd ~/Coding/flutter'
alias fr='flutter run'
alias fb='flutter build'
alias fp='flutter pub get'

# Nvim config shortcuts
alias nvc='nv ~/.config/nvim'
alias nrc='nv ~/.config/niri/config.kdl'
alias nwc='nv ~/.config/waybar'
alias nswc='nv ~/.config/swaync'
alias nhc='nv ~/.config/hypr'
alias noc='nv ~/.local/share/omarchy'
alias nss='nv ~/.config/starship.toml'
alias nzc='nv ~/.zshrc'

# Shell
alias reload='exec zsh'
alias path='print -l $path'

# Misc
alias dc='/home/rem/Downloads/discord-0.0.125/Discord/Discord'
alias swapmine='mv ~/.config/nvim ~/.config/nvim-gg && mv ~/.config/nvim-mine ~/.config/nvim'
alias swapgg='mv ~/.config/nvim ~/.config/nvim-mine && mv ~/.config/nvim-gg ~/.config/nvim'

# ── Functions ────────────────────────────────────────────────────────────────
# nv: smart nvim wrapper — cd + open
nv() {
  command -v nvim >/dev/null || {
    echo 'nv: nvim not found in PATH' >&2
    return 1
  }
  if [[ $# -eq 0 ]]; then
    nvim
    return
  fi
  case "$1" in
  */) cd "${1%/}" && nvim . ;;
  */*) [[ -d "$1" ]] && { cd "${1%/}" && nvim .; } || { cd "${1%/*}" && nvim "${1##*/}"; } ;;
  *) nvim "$1" ;;
  esac
}

# y: yazi — cd into last visited directory on exit
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  rm -f -- "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
}

# mkcd: create directory and cd into it
mkcd() { mkdir -p "$@" && cd "${@: -1}"; }

# x: universal archive extractor
x() {
  [[ ! -f "$1" ]] && {
    echo "not a file: $1"
    return 1
  }
  case "$1" in
  *.tar.bz2 | *.tbz2) tar xjf "$1" ;;
  *.tar.gz | *.tgz) tar xzf "$1" ;;
  *.tar.xz) tar xJf "$1" ;;
  *.tar.zst) tar --zstd -xf "$1" ;;
  *.tar) tar xf "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *.gz) gunzip "$1" ;;
  *.zip) unzip "$1" ;;
  *.7z) 7z x "$1" ;;
  *.zst) unzstd "$1" ;;
  *) echo "unknown format: $1" ;;
  esac
}

# zmodload zsh/zprof  # uncomment paired with the top line to see profiling

# pnpm — PNPM_HOME is exported in the Environment section and added to PATH in the
# PATH section above. pnpm installs global binaries directly into $PNPM_HOME (not
# $PNPM_HOME/bin), so no extra path entry is needed. (Removed a duplicate,
# inconsistent `$PNPM_HOME/bin` block that the pnpm installer had appended.)

# ── zoxide (initialized LAST, on purpose — see note in the eval-cache section) ─
_eval_cache zoxide zoxide init zsh --cmd cd

# nub
export PATH="$HOME/.nub/bin:$PATH"

# fnm
FNM_PATH="/home/rem/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# Adguard auto completion
# [ -s "/opt/adguardvpn_cli/bash-completion.sh" ] && \. "/opt/adguardvpn_cli/bash-completion.sh"
