#!/bin/bash
EXEC_PATH=$(cd "$( dirname "$0")" && pwd)

#############################################
#               PROGRAM SPECIFIC            #
#############################################

if [ ! -f /usr/bin/git ]; then
    echo "Git required"
    exit 0
fi

# BASHRC
if [ -f $HOME/.bashrc ]; then
    $(diff -q $EXEC_PATH/.bashrc ~/.bashrc)
    if [ $? -ne 0 ]; then
        rm -rf ~/.bashrc.bak
        mv ~/.bashrc ~/.bashrc.bak
        echo "~/.bashrc already exists moved to ~/.bashrc.bak"
        cp $EXEC_PATH/.bashrc ~/
        source ~/.bashrc
    fi
else
    cp $EXEC_PATH/.bashrc ~/
    source ~/.bashrc
    echo "BASHRC installed"
fi

# VIM
if [ -f ~/.vimrc ]; then
    LINES=$(sed -n '$=' $EXEC_PATH/.vimrc.vundle)
    $(diff -q <(head -n $LINES $EXEC_PATH/.vimrc.vundle) <(head -n $LINES ~/.vimrc))
    if [ $? -ne 0 ]; then
        rm -rf ~/.vimrc.bak
        mv -f ~/.vimrc ~/.vimrc.bak
        echo "~/.vimrc already exists moved to ~/.vimrc.bak"
        cp -R $EXEC_PATH/.vim ~/.vim
        cp $EXEC_PATH/.vimrc.vundle ~/.vimrc
        vim +PluginInstall +qall
        echo -e "" >> ~/.vimrc
        cat $EXEC_PATH/.vimrc >> ~/.vimrc
        echo "VIM updated"
    fi
else
    git clone -q https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle
    cp -R .vim ~/.vim
    cp $EXEC_PATH/.vimrc.vundle ~/.vimrc
    vim +PluginInstall +qall
    echo -e "" >> ~/.vimrc
    cat $EXEC_PATH/.vimrc >> ~/.vimrc
    echo "VIM installed"
fi

# TMUX
if [ -f ~/.tmux.conf ]; then
    $(diff -q $EXEC_PATH/.tmux.conf ~/.tmux.conf)
    if [ $? -ne 0 ]; then
        rm -rf ~/.tmux.conf.bak
        mv ~/.tmux.conf ~/.tmux.conf.bak
        echo "~/.tmux.conf already exists moved to ~/.tmux.conf.bak"
        echo "TMUX updated"
    fi
else
    cp $EXEC_PATH/.tmux.conf ~/
    echo "TMUX installed"
fi

# FONTS
if [ -d fonts ]; then
    cd fonts
    git fetch
    DIFF=$(git rev-list HEAD...origin/master --count)
    if [ $DIFF -ne 0 ]; then
        git pull origin master
        sh fonts/install.sh
        echo "FONTS updated"
    fi
    cd $EXEC_PATH
else
    git clone -q https://github.com/powerline/fonts.git fonts
    sh fonts/install.sh
    echo "FONTS installed"
fi

# DOCKER
if [ -f ~/.dockerfunc ]; then
    $(diff -q $EXEC_PATH/.dockerfunc ~/.dockerfunc)
    if [ $? -ne 0 ]; then
        rm -rf ~/.dockerfunc.bak
        mv ~/.dockerfunc ~/.dockerfunc
        echo "~/.dockerfunc already exists moved to ~/.dockerfunc"
        echo "DOCKER updated"
    fi
else
    cp $EXEC_PATH/.dockerfunc ~/
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
