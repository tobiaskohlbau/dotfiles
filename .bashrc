[[ $- != *i* ]] && return
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Start ssh agent
eval `ssh-agent -s`

# Enable 256 color
export TERM="xterm-256color"

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-default.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL


# Environmentment settings
export DEV=~/Development
export GOPATH=$DEV/Go
export PATH=$PATH:$GOPATH/bin

# Alias settings
alias dev='cd $DEV'
