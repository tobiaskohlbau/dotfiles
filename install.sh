for i in "$@"
do
case $i in
	--force)
	FORCE=YES
	shift
	;;
    *)
    ;;
esac
done

if [ "$FORCE" == "YES" ]; then
    rm -rf $HOME/.vim.bak
    rm -rf $HOME/.vim.bak
    rm -rf $HOME/.vimrc.bak
    rm -rf $HOME/.tmux.conf.bak
    rm -rf $HOME/.solarized.bak
    rm -rf $HOME/.dir_colors.bak
    rm -rf $HOME/.Xresources.bak
    rm -rf $HOME/.bashrc.bak
    rm -rf $HOME/.minttyrc.bak
    rm -rf $HOME/.dockerfunc.bak
    rm -rf $HOME/.config/i3/config.bak
    mv -f $HOME/.vim $HOME/.vim.bak
    mv -f $HOME/.vimrc $HOME/.vimrc.bak
    mv -f $HOME/.tmux.conf $HOME/.tmux.conf.bak
    mv -f $HOME/.solarized $HOME/.solarized.bak
    mv -f $HOME/.dir_colors $HOME/.dir_colors.bak
    mv -f $HOME/.Xresources $HOME/.Xresources.bak
    mv -f $HOME/.bashrc $HOME/.bashrc.bak
    mv -f $HOME/.minttyrc $HOME/.minttyrc.bak
    mv -f $HOME/.dockerfunc $HOME/.dockerfunc.bak
    sudo rm -f /etc/X11/xinit/xinitrc.d/60-modmap.sh
    mv -f $HOME/.config/i3/config $HOME/.config/i3/config.bak
    if [ ! -f fonts ]; then
        rm -rf fonts
    fi
fi

#!/bin/bash
EXEC_PATH=$(cd "$( dirname "$0")" && pwd)

#############################################
#               PROGRAM SPECIFIC            #
#############################################

if [ ! -f /usr/bin/git ]; then
    echo "Git required"
    exit 0
fi

# SOLARIZED
if [ ! -d $HOME/.solarized ]; then
    mkdir $HOME/.solarized
fi

# SOLARIZED DIRCOLORS
if [ -d $HOME/.solarized/solarized-dirs ]; then
    cd $HOME/.solarized/solarized-dirs
    git fetch
    DIFF=$(git rev-list HEAD...origin/master --count)
    if [ $DIFF -ne 0 ]; then
        git pull origin master
        eval `dircolors $HOME/.solarized/solarized-dirs/dircolors.256dark`
        echo "SOLARIZED-DIRS updated"
    else
        echo "SOLARIZED-DIRS up to date"
    fi
    cd "$EXEC_PATH"
else
    git clone https://github.com/seebi/dircolors-solarized.git $HOME/.solarized/solarized-dirs
    eval `dircolors $HOME/.solarized/solarized-dirs/dircolors.256dark`
    ln -s $HOME/.solarized/solarized-dirs/dircolors.256dark $HOME/.dir_colors
    echo "SOLARIZED-DIRS installed"
fi

# XRESOURCES
if [ -f "$HOME/.Xresources" ]; then
    $(diff -q "$EXEC_PATH/.Xresources" "$HOME/.Xresources")
    if [ $? -ne 0 ]; then
        rm -rf "$HOME/.Xresources.bak"
        mv "$HOME/.Xresources" "$HOME/.Xresources.bak"
        echo "$HOME/.Xresources already exists moved to $HOME/.Xresources.bak"
        cp "$EXEC_PATH/.Xresources" "$HOME/"
        xrdb $HOME/.Xresources
    else
        echo "XRESOURCES up to date"
    fi
else
    cp "$EXEC_PATH/.Xresources" "$HOME/"
    xrdb $HOME/.Xresources
    echo "XRESOURCES installed"
fi

# BASHRC
if [ -f "$HOME/.bashrc" ]; then
    $(diff -q "$EXEC_PATH/.bashrc" "$HOME/.bashrc")
    if [ $? -ne 0 ]; then
        rm -rf "$HOME/.bashrc.bak"
        mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
        echo "$HOME/.bashrc already exists moved to $HOME/.bashrc.bak"
        cp "$EXEC_PATH/.bashrc" "$HOME/.bashrc"
        source "$HOME/.bashrc"
    else
        echo "BASHRC up to date"
    fi
else
    cp "$EXEC_PATH/.bashrc" "$HOME/.bashrc"
    source "$HOME/.bashrc"
    echo "BASHRC installed"
fi

# MINTTYRC
if [ -f "$HOME/.minttyrc" ]; then
    $(diff -q "$EXEC_PATH/.minttyrc" "$HOME/.minttyrc")
    if [ $? -ne 0 ]; then
        rm -rf "$HOME/.minttyrc.bak"
        mv "$HOME/.minttyrc" "$HOME/.minttyrc.bak"
        echo "$HOME/.minttyrc already exists moved to $HOME/.mintty.bak"
        cp "$EXEC_PATH/.minttyrc" "$HOME/"
    else
        echo "MINTTYRC up to date"
    fi
else
    cp "$EXEC_PATH/.minttyrc" "$HOME/"
    echo "MINTTYRC installed"
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
    else
        echo "VIM up to date"
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
    else
        echo "TMUX up to date"
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
    else
        echo "FONTS up to date"
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
        mv "$HOME/.dockerfunc" "$HOME/.dockerfunc.bak"
        echo "$HOME/.dockerfunc already exists moved to $HOME/.dockerfunc.bak"
        echo "DOCKER updated"
    else
        echo "DOCKER up to date"
    fi
else
    cp "$EXEC_PATH/.dockerfunc" "$HOME/"
    echo "DOCKER installed"
fi

# MODMAP
if [ -f "/etc/X11/xinit/xinitrc.d/60-xmodmap.sh" ]; then
    $(diff -q "$EXEC_PATH/60-modmap.sh" "/etc/X11/xinit/xinitrc.d/60-modmap.sh")
    if [ $? -ne 0 ]; then
        sudo rm -f "/etc/X11/xinit/xinitrc.d/60-modmap.sh"
        echo "MODMAP updated"
    else
        echo "MODMAP up to date"
    fi
else
    sudo cp "$EXEC_PATH/60-modmap.sh" "/etc/X11/xinit/xinitrc.d/60-modmap.sh"
    echo "MODMAP installed"
fi

# SSHAGENT
if [ -f "$HOME/.config/systemd/user/ssh-agent.service" ]; then
    rm -rf "$HOME/.config/systemd/user/ssh-agent.service"
    mkdir -p $HOME/.config/systemd/user
    cp ssh-agent.service $HOME/.config/systemd/user/ssh-agent.service
    systemctl --user enable ssh-agent
else
    mkdir -p $HOME/.config/systemd/user
    cp ssh-agent.service $HOME/.config/systemd/user/ssh-agent.service
    systemctl --user enable ssh-agent
fi

# SSHASKPASS
if [ -f "$HOME/config/autostart-scripts/ssh-add.sh" ]; then
    rm -rf "$HOME/config/autostart-scripts/ssh-add.sh"
    cp ssh-add.sh $HOME/.config/autostart-scripts/ssh-add.sh
else
    cp ssh-add.sh $HOME/.config/autostart-scripts/ssh-add.sh
fi

# I3
if [ -f "$HOME/.config/i3/config" ]; then
    $(diff -q "$EXEC_PATH/.i3-config" "$HOME/.config/i3/config")
    if [ $? -ne 0 ]; then
        rm -f "$HOME/.config/i3/config"
        mkdir -p $HOME/.config/i3
        cp "$EXEC_PATH/.i3-config" "$HOME/.config/i3/config"
        echo "I3 updated"
    else
        echo "I3 up to date"
    fi
else
    mkdir -p $HOME/.config/i3
    cp "$EXEC_PATH/.i3-config" "$HOME/.config/i3/config"
    echo "I3 installed"
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
git config --global push.default simple
if [ -f /usr/bin/gitg ]; then
    git config --global alias.visual '!gitg'
fi
git config --global alias.cs 'commit -s'
git config --global alias.last 'log -1 HEAD'
git config --global alias.d difftool
