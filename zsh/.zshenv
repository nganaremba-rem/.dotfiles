. "$HOME/.cargo/env"

# mise shims — for NON-interactive contexts (scripts, systemd units, IDEs) that
# never source ~/.zshrc and so never run `mise activate`. Interactive shells get
# the faster `mise activate` in ~/.zshrc, which prepends real install paths and
# therefore wins over these shims. Appended late in ~/.zshrc's `path=(... $path)`.
export PATH="$PATH:$HOME/.local/share/mise/shims"
