# Start ssh agent
SSH_AGENT="/usr/bin/gnome-keyring-daemon"
if [ -e "$SSH_AGENT" ]
then
    eval $($SSH_AGENT --start --components=pkcs11,secrets,ssh)
    export SSH_AUTH_SOCK
fi

# Environmentment settings
export DEV=~/Development
export GOPATH=$DEV/Go
export PATH=$PATH:$GOPATH/bin

# Alias settings
alias dev='cd $DEV'
alias ls='ls --color=auto'

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

# Compiler settings
if [ -e "/usr/bin/clang" ]
then
    export CC="/usr/bin/clang"
    export CXX="/usr/bin/clang++"
fi
if [ -e "/usr/local/bin/lld" ]
then
    export LD="/usr/local/bin/lld"
fi

# Caps as Esc
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'

for file in ~/.{exports,dockerfunc}; do
    [[ -r "$file" ]] && [[ -f "$file" ]] && source "$file"
done
unset file
