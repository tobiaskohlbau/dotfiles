# Start ssh agent
eval `ssh-agent -s`


export TERM="xterm-256color"

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-default.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
