# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
. "$HOME/.cargo/env"

# simutil
export PATH="/home/rem/.local/lib/simutil:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/rem/.lmstudio/bin"
# End of LM Studio CLI section

