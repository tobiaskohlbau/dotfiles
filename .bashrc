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
if [ -e "/usr/bin/xmodmap" ]
then
    xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
fi

for file in ~/.{exports,dockerfunc}; do
    [[ -r "$file" ]] && [[ -f "$file" ]] && source "$file"
done
unset file
