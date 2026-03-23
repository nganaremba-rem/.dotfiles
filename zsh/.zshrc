# ---- SUPER FAST .zshrc ----
[[ -z "$P10K_NERDFETCH_DONE" ]] && {
  export P10K_NERDFETCH_DONE=1
  nitch
}

# Powerlevel10k instant prompt (keep first; silence warnings)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export OPENROUTER_API_KEY="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"

# ── Environment you already use
# export LANG=en_IN.UTF-8
# export LC_ALL=en_IN.UTF-8
export CHROME_DEVEL_SANDBOX=/usr/local/bin/chrome-sandbox
export NVM_DIR="$HOME/.nvm"
export PYENV_ROOT="$HOME/.pyenv"
export SDKMAN_DIR="$HOME/.sdkman"
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_AVD_HOME="$HOME/.config/.android/avd"
export PNPM_HOME="$HOME/.local/share/pnpm"
# export TERM=xterm-kitty
export TERM=xterm-256color
export SUDO_EDITOR=/usr/bin/nvim
export EDITOR=/usr/bin/nvim
export VISUAL=/usr/bin/nvim
# export MOZ_ENABLE_WAYLAND=1
export GDK_SCALE=1
export LIBVIRT_DEFAULT_URI=qemu:///system
export CHROME_EXECUTABLE=chromium
# export XDG_CURRENT_DESKTOP=niri
# export XDG_SESSION_DESKTOP=niri
export QT_QPA_PLATFORM=xcb
export FLUTTER_ENGINE_SWITCH_1=--enable-vulkan


# Japanese keyboard setup
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS=@im=fcitx



# PATH helper (append only if the dir exists)
path_prepend() { [[ -d "$1" ]] && PATH="$1:$PATH"; }
path_prepend "$HOME/.console-ninja/.bin"
path_prepend "$HOME/bin/nvim/bin"
path_prepend "$HOME/bin/arch"
path_prepend "$PYENV_ROOT/bin"
path_prepend "$ANDROID_HOME/emulator"
path_prepend "$ANDROID_HOME/platform-tools"
path_prepend "$HOME/bin/thunderbird"
path_prepend "$HOME/bin/Postman/app"
path_prepend "$HOME/bin"
path_prepend "/opt/mssql-tools18/bin"
path_prepend "$PNPM_HOME"
path_prepend "/home/rem/bin/idea-IC-252.25557.131/bin"
path_prepend "$HOME/.local/bin"
path_prepend "/usr/local/go/bin"
path_prepend "$HOME/develop/flutter/bin"
path_prepend "$ANDROID_SDK_ROOT/platform-tools"
path_prepend "$ANDROID_SDK_ROOT/emulator"
path_prepend "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
path_prepend "$HOME/.local/share/omarchy/bin/"
path_prepend "$PYENV_ROOT/shims"
path_prepend "$HOME/.pub-cache/bin"
export PATH

# ── Zsh options
setopt promptsubst autocd interactivecomments
unsetopt beep

# ── Fast completion (cached; no repeated security scans)
autoload -Uz compinit
compinit -C -d ~/.zcompdump

# ── Lazy-load nvm (dominant cost in your profile)
if [[ -d "$NVM_DIR" ]]; then
  _lazy_nvm(){ unset -f node npm npx nvm; [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"; }
  node(){ _lazy_nvm; command node "$@"; }
  npm(){  _lazy_nvm; command npm  "$@"; }
  npx(){  _lazy_nvm; command npx  "$@"; }
  nvm(){  _lazy_nvm; command nvm  "$@"; }
fi

# ── Lazy-load SDKMAN only when "sdk" is used (optional)
if [[ -d "$SDKMAN_DIR" ]]; then
  sdk(){ source "$SDKMAN_DIR/bin/sdkman-init.sh"; sdk "$@"; }
fi

# ── Zinit (fast plugin manager). Remove OMZ entirely.
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit; (( ${+_comps} )) && _comps[zinit]=_zinit

# Theme first (instant-prompt friendly)
zinit ice depth=1
# zinit light romkatv/powerlevel10k
# [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Core plugins (deferred so prompt shows instantly)
zinit lucid wait"1" for \
  zdharma-continuum/fast-syntax-highlighting \
  zsh-users/zsh-autosuggestions \
  Aloxaf/fzf-tab

# Defer noisy emoji plugin to avoid instant-prompt console output (optional)
load_emoji(){ local p="$ZSH/plugins/emoji/emoji.plugin.zsh"; [[ -f "$p" ]] && source "$p" 2>/dev/null; }
autoload -Uz add-zsh-hook; add-zsh-hook -Uz precmd load_emoji



# Omarchy part
# source ~/.local/share/omarchy/default/bash/rc


# ---- end ----

nv() {
  if [ -z "$1" ]; then
    nvim
    return
  fi

  case "$1" in
    */)
      cd "${1%/}" || return
      nvim .
      ;;
    */*)
      if [ -d "$1" ]; then
        cd "${1%/}" || return
        nvim .
      else 
        cd "${1%/*}" || return
        nvim "${1##*/}"
      fi
      ;;
    *)
      nvim "$1"
      ;;
  esac
}


# yazi config
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}


# Open buffer line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# autocomplete !! and other things
bindkey ' ' magic-space

bindkey -v


# chpwd hook
# chpwd() {
#   ls
# }



# alias ls='ls --color=auto'
# alias ll='ls -lh --color=auto'
# alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias nhc='nv ~/.config/hypr'
alias noc='nv ~/.local/share/omarchy'
alias nnc='nv ~/.config/nvim'
alias cf='cd ~/Coding/flutter/'
alias nrc='nv ~/.config/niri/config.kdl'
alias nvc="nv ~/.config/nvim"
alias cr='cargo run'
alias nwc='nv ~/.config/waybar'
alias nsc='nv ~/.config/swaync/'
alias dc="/home/rem/Downloads/discord-0.0.125/Discord/Discord"

alias ls="eza --icons --git"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lg="lazygit"

function prevent_danger() {
  [[ $1 == "rm -rf /"* ]] && return 1
}

# Prevent dangerous command
add-zsh-hook preexec prevent_danger 

# opencode
export PATH=/home/rem/.opencode/bin:$PATH

bindkey '^?' backward-delete-char

eval "$(zoxide init zsh --cmd cd)"

precmd() { 
  update-shell-pwd 
}

sonar completion zsh > "${fpath[1]}/_sonar"   # zsh

eval "$(starship init zsh)"

