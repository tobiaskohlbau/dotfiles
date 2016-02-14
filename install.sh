#!/bin/bash
EXEC_PATH=$(cd "$( dirname "$0")" && pwd)

#############################################
#               PROGRAM SPECIFIC            #
#############################################

if [ ! -f /usr/bin/git ]; then
    echo "Git required"
    exit 0
fi

# BASE16
if [ -d "$HOME/.config/base16-shell" ]; then
    cd "$HOME/.config/base16-shell"
    git fetch
    DIFF=$(git rev-list HEAD...origin/master --count)
    if [ $DIFF -ne 0 ]; then
        git pull origin master
        echo "BASE16 updated"
    fi
    cd "$EXEC_PATH"
else
    git clone -q https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell
    echo "BASE16 installed"
fi

# BASHRC
if [ -f "$HOME/.bashrc" ]; then
    $(diff -q "$EXEC_PATH/.bashrc" "$HOME/.bashrc")
    if [ $? -ne 0 ]; then
        rm -rf "$HOME/.bashrc.bak"
        mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
        echo "$HOME/.bashrc already exists moved to $HOME/.bashrc.bak"
        cp "$EXEC_PATH/.bashrc" "$HOME/"
        source "$HOME/.bashrc"
    fi
else
    cp "$EXEC_PATH/.bashrc" "$HOME/"
    source "$HOME/.bashrc"
    echo "BASHRC installed"
fi

# VIM
if [ -f "$HOME/.vimrc" ]; then
    LINES=$(sed -n '$=' "$EXEC_PATH/.vimrc.vundle")
    $(diff -q <(head -n $LINES "$EXEC_PATH/.vimrc.vundle") <(head -n $LINES "$HOME/.vimrc"))
    if [ $? -ne 0 ]; then
        rm -rf "$HOME/.vimrc.bak"
        mv -f "$HOME/.vimrc" "$HOME/.vimrc.bak"
        echo "$HOME/.vimrc already exists moved to $HOME/.vimrc.bak"
        cp -R "$EXEC_PATH/.vim" "$HOME/.vim"
        cp "$EXEC_PATH/.vimrc.vundle" "$HOME/.vimrc"
        vim +PluginInstall +qall
        echo -e "" >> "$HOME/.vimrc"
        cat "$EXEC_PATH/.vimrc" >> "$HOME/.vimrc"
        echo "VIM updated"
    fi
else
    git clone -q https://github.com/gmarik/Vundle.vim.git "$HOME/.vim/bundle/Vundle"
    cp -R ".vim" "$HOME/.vim"
    cp "$EXEC_PATH/.vimrc.vundle" "$HOME/.vimrc"
    vim +PluginInstall +qall
    echo -e "" >> "$HOME/.vimrc"
    cat "$EXEC_PATH/.vimrc" >> "$HOME/.vimrc"
    echo "VIM installed"
fi

# TMUX
if [ -f "$HOME/.tmux.conf" ]; then
    $(diff -q "$EXEC_PATH/.tmux.conf" "$HOME/.tmux.conf")
    if [ $? -ne 0 ]; then
        rm -rf "$HOME/.tmux.conf.bak"
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
        echo "$HOME/.tmux.conf already exists moved to $HOME/.tmux.conf.bak"
        echo "TMUX updated"
    fi
else
    cp "$EXEC_PATH/.tmux.conf" "$HOME/"
    echo "TMUX installed"
fi

# FONTS
if [ -d fonts ]; then
    cd fonts
    git fetch
    DIFF=$(git rev-list HEAD...origin/master --count)
    if [ $DIFF -ne 0 ]; then
        git pull origin master
        $(uname -o | grep Msys &> /dev/null)
        if [ $? -eq 0 ]; then
            powershell -ExecutionPolicy ByPass -File fonts/install.ps1
        else
            sh fonts/install.sh
        fi
        echo "FONTS updated"
    fi
    cd "$EXEC_PATH"
else
    git clone -q https://github.com/powerline/fonts.git fonts
    $(uname -o | grep Msys &> /dev/null)
    if [ $? -eq 0 ]; then
        powershell -ExecutionPolicy ByPass -File fonts/install.ps1
    else
        sh fonts/install.sh
    fi
    echo "FONTS installed"
fi

# DOCKER
if [ -f "$HOME/.dockerfunc" ]; then
    $(diff -q "$EXEC_PATH/.dockerfunc" "$HOME/.dockerfunc")
    if [ $? -ne 0 ]; then
        rm -rf "$HOME/.dockerfunc.bak"
        mv "$HOME/.dockerfunc" "$HOME/.dockerfunc"
        echo "$HOME/.dockerfunc already exists moved to $HOME/.dockerfunc"
        echo "DOCKER updated"
    fi
else
    cp "$EXEC_PATH/.dockerfunc" "$HOME/"
    echo "DOCKER installed"
fi

#############################################
#               GENERAL                     #
#############################################

# GIT
git config --global user.email "tobias.kohlbau@gmail.com"
git config --global user.name "Tobias Kohlbau"
git config --global core.editor "vim"
git config --global diff.tool vimdiff
git config --global difftool.prompt false
if [ -f /usr/bin/gitg ]; then
    git config --global alias.visual '!gitg'
fi
git config --global alias.cs 'commit -s'
git config --global alias.last 'log -1 HEAD'
git config --global alias.d difftool

# GNOME-TERMINAL
if [ -f /usr/bin/gsettings ]; then
    DEFAULT=$(gsettings get org.gnome.Terminal.ProfilesList default | grep -oE "[^']+")
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ font 'Hack 9'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ use-system-font 'false'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ allow-bold 'false'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ audible-bell 'false'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ scrollbar-policy 'never'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ default-show-menubar 'false'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ use-custom-command 'true'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$DEFAULT/ custom-command 'tmux'
    gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar 'false'
fi
