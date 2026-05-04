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

# Remove broken fnm runtime paths
PATH=$(printf "%s\n" $PATH | grep -v "/run/user/.*/fnm_multishells" | paste -sd:)

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
export ATAC_KEY_BINDINGS="$HOME/.config/atac/vim_key_bindings.toml"


# Japanese keyboard setup
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS=@im=fcitx



# PATH helper (append only if the dir exists)
path_prepend() { [[ -d "$1" ]] && PATH="$1:$PATH"; }
path_prepend "$HOME/.console-ninja/.bin"
path_prepend "$HOME/.opencode/bin"
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
path_prepend "$HOME/go/bin"
export PATH


pyenv() {
  unset -f pyenv
  eval "$(command pyenv init -)"
  pyenv "$@"
}

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
alias nrm='nv ~/.config/mango/config.conf'
alias nvc="nv ~/.config/nvim"
alias cr='cargo run'
alias nwc='nv ~/.config/waybar'
alias nsc='nv ~/.config/swaync/'
alias dc="/home/rem/Downloads/discord-0.0.125/Discord/Discord"

alias ls="eza --icons --git"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lg="lazygit"
alias t="tmux"
alias i="sudo pacman -S --needed --noconfirm --overwrite='*'"
alias ia="paru -S --needed --noconfirm --overwrite='*'"

function prevent_danger() {
  [[ $1 == "rm -rf /"* ]] && return 1
}

# Prevent dangerous command
add-zsh-hook preexec prevent_danger 

bindkey '^?' backward-delete-char

eval "$(zoxide init zsh --cmd cd)"

precmd() { 
  update-shell-pwd 
}

sonar completion zsh > "${fpath[1]}/_sonar"   # zsh

eval "$(starship init zsh)"


# simutil
export PATH="/home/rem/.local/lib/simutil:$PATH"
export FZF_DEFAULT_COMMAND="fd --hidden"

# fnm
FNM_PATH="/home/rem/.local/share/fnm"

fnm() {
  unset -f fnm
  export PATH="$FNM_PATH:$PATH"
  eval "$(command fnm env --shell zsh)"
  fnm "$@"
}


alias swapmine="mv ~/.config/nvim ~/.config/nvim-gg; mv ~/.config/nvim-mine ~/.config/nvim"
alias swapgg="mv ~/.config/nvim ~/.config/nvim-mine; mv ~/.config/nvim-gg ~/.config/nvim"


# Deduplication PATH 
typeset -U PATH path

#compdef netbird
compdef _netbird netbird

# zsh completion for netbird                              -*- shell-script -*-

__netbird_debug()
{
    local file="$BASH_COMP_DEBUG_FILE"
    if [[ -n ${file} ]]; then
        echo "$*" >> "${file}"
    fi
}

_netbird()
{
    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16
    local shellCompDirectiveKeepOrder=32

    local lastParam lastChar flagPrefix requestComp out directive comp lastComp noSpace keepOrder
    local -a completions

    __netbird_debug "\n========= starting completion logic =========="
    __netbird_debug "CURRENT: ${CURRENT}, words[*]: ${words[*]}"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CURRENT location, so we need
    # to truncate the command-line ($words) up to the $CURRENT location.
    # (We cannot use $CURSOR as its value does not work when a command is an alias.)
    words=("${=words[1,CURRENT]}")
    __netbird_debug "Truncated words[*]: ${words[*]},"

    lastParam=${words[-1]}
    lastChar=${lastParam[-1]}
    __netbird_debug "lastParam: ${lastParam}, lastChar: ${lastChar}"

    # For zsh, when completing a flag with an = (e.g., netbird -n=<TAB>)
    # completions must be prefixed with the flag
    setopt local_options BASH_REMATCH
    if [[ "${lastParam}" =~ '-.*=' ]]; then
        # We are dealing with a flag with an =
        flagPrefix="-P ${BASH_REMATCH}"
    fi

    # Prepare the command to obtain completions
    requestComp="${words[1]} __complete ${words[2,-1]}"
    if [ "${lastChar}" = "" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go completion code.
        __netbird_debug "Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __netbird_debug "About to call: eval ${requestComp}"

    # Use eval to handle any environment variables and such
    out=$(eval ${requestComp} 2>/dev/null)
    __netbird_debug "completion output: ${out}"

    # Extract the directive integer following a : from the last line
    local lastLine
    while IFS='\n' read -r line; do
        lastLine=${line}
    done < <(printf "%s\n" "${out[@]}")
    __netbird_debug "last line: ${lastLine}"

    if [ "${lastLine[1]}" = : ]; then
        directive=${lastLine[2,-1]}
        # Remove the directive including the : and the newline
        local suffix
        (( suffix=${#lastLine}+2))
        out=${out[1,-$suffix]}
    else
        # There is no directive specified.  Leave $out as is.
        __netbird_debug "No directive found.  Setting do default"
        directive=0
    fi

    __netbird_debug "directive: ${directive}"
    __netbird_debug "completions: ${out}"
    __netbird_debug "flagPrefix: ${flagPrefix}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        __netbird_debug "Completion received error. Ignoring completions."
        return
    fi

    local activeHelpMarker="_activeHelp_ "
    local endIndex=${#activeHelpMarker}
    local startIndex=$((${#activeHelpMarker}+1))
    local hasActiveHelp=0
    while IFS='\n' read -r comp; do
        # Check if this is an activeHelp statement (i.e., prefixed with $activeHelpMarker)
        if [ "${comp[1,$endIndex]}" = "$activeHelpMarker" ];then
            __netbird_debug "ActiveHelp found: $comp"
            comp="${comp[$startIndex,-1]}"
            if [ -n "$comp" ]; then
                compadd -x "${comp}"
                __netbird_debug "ActiveHelp will need delimiter"
                hasActiveHelp=1
            fi

            continue
        fi

        if [ -n "$comp" ]; then
            # If requested, completions are returned with a description.
            # The description is preceded by a TAB character.
            # For zsh's _describe, we need to use a : instead of a TAB.
            # We first need to escape any : as part of the completion itself.
            comp=${comp//:/\\:}

            local tab="$(printf '\t')"
            comp=${comp//$tab/:}

            __netbird_debug "Adding completion: ${comp}"
            completions+=${comp}
            lastComp=$comp
        fi
    done < <(printf "%s\n" "${out[@]}")

    # Add a delimiter after the activeHelp statements, but only if:
    # - there are completions following the activeHelp statements, or
    # - file completion will be performed (so there will be choices after the activeHelp)
    if [ $hasActiveHelp -eq 1 ]; then
        if [ ${#completions} -ne 0 ] || [ $((directive & shellCompDirectiveNoFileComp)) -eq 0 ]; then
            __netbird_debug "Adding activeHelp delimiter"
            compadd -x "--"
            hasActiveHelp=0
        fi
    fi

    if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
        __netbird_debug "Activating nospace."
        noSpace="-S ''"
    fi

    if [ $((directive & shellCompDirectiveKeepOrder)) -ne 0 ]; then
        __netbird_debug "Activating keep order."
        keepOrder="-V"
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local filteringCmd
        filteringCmd='_files'
        for filter in ${completions[@]}; do
            if [ ${filter[1]} != '*' ]; then
                # zsh requires a glob pattern to do file filtering
                filter="\*.$filter"
            fi
            filteringCmd+=" -g $filter"
        done
        filteringCmd+=" ${flagPrefix}"

        __netbird_debug "File filtering command: $filteringCmd"
        _arguments '*:filename:'"$filteringCmd"
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        subdir="${completions[1]}"
        if [ -n "$subdir" ]; then
            __netbird_debug "Listing directories in $subdir"
            pushd "${subdir}" >/dev/null 2>&1
        else
            __netbird_debug "Listing directories in ."
        fi

        local result
        _arguments '*:dirname:_files -/'" ${flagPrefix}"
        result=$?
        if [ -n "$subdir" ]; then
            popd >/dev/null 2>&1
        fi
        return $result
    else
        __netbird_debug "Calling _describe"
        if eval _describe $keepOrder "completions" completions $flagPrefix $noSpace; then
            __netbird_debug "_describe found some completions"

            # Return the success of having called _describe
            return 0
        else
            __netbird_debug "_describe did not find completions."
            __netbird_debug "Checking if we should do file completion."
            if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
                __netbird_debug "deactivating file completion"

                # We must return an error code here to let zsh know that there were no
                # completions found by _describe; this is what will trigger other
                # matching algorithms to attempt to find completions.
                # For example zsh can match letters in the middle of words.
                return 1
            else
                # Perform file completion
                __netbird_debug "Activating file completion"

                # We must return the result of this command, so it must be the
                # last command, or else we must store its result to return it.
                _arguments '*:filename:_files'" ${flagPrefix}"
            fi
        fi
    fi
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_netbird" ]; then
    _netbird
fi

# bun completions
[ -s "/home/rem/.oh-my-zsh/completions/_bun" ] && source "/home/rem/.oh-my-zsh/completions/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
