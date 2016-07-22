# Windows path
$(uname -o | grep Msys > /dev/null)
if [ $? -eq 0 ]; then
    cd /c/Development
fi

# Environmentment settings
export DEV=~/Development
export GOPATH=$DEV/Go
export PATH=$PATH:$GOPATH/bin

# Alias settings
alias dev='cd $DEV'
alias ls='ls --color=auto'
alias vim='emacs'

eval `dircolors ~/.dir_colors`

# PS1 modified
if [ -e "/usr/share/git/completion/git-prompt.sh" ]
then
    source /usr/share/git/completion/git-prompt.sh
    export PS1="\[\033[00m\]\u@\h\[\033[01;33m\] \w \[\033[31m\]\$(__git_ps1)\[\033[00m\]$\[\033[00m\] "
fi

# Git autocomplete
if [ -e "/usr/share/git/completion/git-completion.bash" ]
then
    source /usr/share/git/completion/git-completion.bash
fi

# SSH-AGENT
$(pgrep -u $USER ssh-agent > /dev/null)
if [ $? -ne 0 ]; then
    ssh-agent > ~/.ssh-agent-thing
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval $(<~/.ssh-agent-thing) &> /dev/null
fi
ssh-add -l >/dev/null || alias ssh='ssh-add -l >/dev/null || ssh-add && unalias ssh; ssh'

# DIRCOLORS
eval `dircolors $HOME/.dir_colors`

# XHOST
xhost + &> /dev/null

# DOCKER
for file in ~/.{exports,dockerfunc}; do
    [[ -r "$file" ]] && [[ -f "$file" ]] && source "$file"
done
unset file
