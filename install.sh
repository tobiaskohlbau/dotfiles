#!/bin/bash

#FUNCTIONS
diff_file ()
{
    if [ -e /usr/bin/md5sum ]
    then
        file1=($(md5sum $1))
        file2=($(md5sum $2))
        if [ "$file1" = "$file2" ]
        then
            return 0
        else
            return 1
        fi
    else
        echo -e "Please install md5..."
        return 1
    fi

}

diff_folder ()
{
    if [ -e /usr/bin/diff ]
    then
        $(diff -rq $1 $2 &> /dev/null)
        return $?
    else
        echo -e "Please install diff..."
        return 1
    fi
}

diff_git ()
{
    if [ ! -d $1 ]
    then
        return 1
    fi

    if [ -e /usr/bin/git ]
    then
        $(git --git-dir $1/.git fetch)
        DIFF=$(git --git-dir $1/.git rev-list HEAD...origin/master --count)
        if [ $DIFF -ne 0 ]
        then
            return 1
        else
            return 0
        fi
    else
        echo -e "Please install git..."
        return 1
    fi
}

backup ()
{
    if [ -e $1.bak ] || [ -d $1.bak ]
    then
        $2 rm -rf $1.bak
    fi

    if [ -e $1 ] || [ -d $1 ]
    then
        $2 mv $1 $1.bak
        echo -e "$1 already exists moved to $1.bak"
    fi
}

install_file ()
{
    if [ "$FORCE" == "YES" ]
    then
        backup $2 $3
    fi

    if [ -f $2 ]
    then
        diff_file $1 $2
        if [ $? -ne 0 ]
        then
            backup $2 $3
            $3 cp $1 $2
            echo -e "$2 updated\r\n"
        else
            echo -e "$2 up to date\r\n"
        fi
    else
        $3 cp $1 $2
        echo -e "$2 installed\r\n"
    fi
}

install_folder ()
{
    $(mkdir -p `dirname $2`)

    if [ "$FORCE" == "YES" ]
    then
        backup $2 $3
    fi

    if [ -d $2 ]
    then
        diff_folder $1 $2
        if [ $? -ne 0 ]
        then
            backup $2 $3
            $3 cp -r $1 $2
            echo -e "$2 updated\r\n"
        else
            echo -e "$2 up to date\r\n"
        fi
    else
        $3 cp -r $1 $2
        echo -e "$2 installed\r\n"
    fi
}

install_git ()
{
    if [ "$FORCE" == "YES" ]
    then
        backup $2 $3
    fi

    if [ -d $2 ]
    then
        diff_git $2
        if [ $? -ne 0 ]
        then
            backup $2 $3
            $3 git clone $1 $2 &> /dev/null
            echo -e "$2 updated\r\n"
        else
            echo -e "$2 up to date\r\n"
        fi
    else
        $3 git clone $1 $2 &> /dev/null
        echo -e "$2 installed\r\n"
    fi
}

###############


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

#!/bin/bash
EXEC_PATH=$(cd "$( dirname "$0")" && pwd)

#############################################
#               PROGRAM SPECIFIC            #
#############################################

################### FILES ###################
# XRESOURCES
install_file $EXEC_PATH/.Xresources $HOME/.Xresources
xrdb $HOME/.Xresources

# XINITRC
install_file $EXEC_PATH/.xinitrc $HOME/.xinitrc

# BASHRC
install_file $EXEC_PATH/.bash_profile $HOME/.bash_profile

# BASHRC
install_file $EXEC_PATH/.bashrc $HOME/.bashrc
source $HOME/.bashrc

# TMUX
install_file $EXEC_PATH/.tmux.conf $HOME/.tmux.conf

# MODMAP
install_file $EXEC_PATH/60-modmap.sh /etc/X11/xinit/xinitrc.d/60-modmap.sh sudo

# DOCKER
install_file $EXEC_PATH/.dockerfunc $HOME/.dockerfunc

# I3
install_file $EXEC_PATH/.i3-config $HOME/.config/i3/config
rm -rf $HOME/.i3/config &> /dev/null

# I3LOCK
install_file $EXEC_PATH/lock.sh /usr/bin/lock.sh sudo
install_file $EXEC_PATH/lock.service /etc/systemd/system/lock.service sudo
sudo systemctl enable lock.service

################### FILES ###################

################### GIT ###################
# SOLARIZED DIRCOLORS
install_git https://github.com/seebi/dircolors-solarized.git $HOME/.solarized-dirs
SOLARIZED_FILE=$HOME/.solarized-dirs/dircolors.256dark
diff_file $HOME/.dir_colors $SOLARIZED_FILE
if [ $? -ne 0 ]
then
    rm -rf $HOME/.dir_colors
    ln -s $SOLARIZED_FILE $HOME/.dir_colors
fi

# FONTS
diff_git $HOME/.fonts
NEED_INSTALL=$?
install_git https://github.com/powerline/fonts.git $HOME/.fonts
if [ $NEED_INSTALL -ne 0 ]
then
    sh $HOME/.fonts/install.sh
fi
################### GIT ###################

# VIM
install_folder $EXEC_PATH/.vim/templates $HOME/.vim/templates
install_git https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim

if [ "$FORCE" == "YES" ]
then
    backup $HOME/.vimrc
    $(find $HOME/.vim/bundle/ -maxdepth 1 -mindepth 1 -type d | grep ".*\.bak" | xargs -i rm -rf {})
fi

if [ -f "$HOME/.vimrc" ]
then
    LINES=$(sed -n '$=' "$EXEC_PATH/.vimrc.vundle")
    $(diff -q <(head -n $LINES "$EXEC_PATH/.vimrc.vundle") <(head -n $LINES "$HOME/.vimrc") &> /dev/null)
    DIFF_VUNDLE=$?
    LINES_TAIL="+$((LINES + 2))"
    $(diff -q <(tail -n +0 "$EXEC_PATH/.vimrc") <(tail -n $LINES_TAIL "$HOME/.vimrc") &> /dev/null)
    DIFF_VIMRC=$?
    if [ $DIFF_VUNDLE -ne 0 ]
    then
        install_file $EXEC_PATH/.vimrc.vundle $HOME/.vimrc
        vim +PluginInstall +qall
        echo -e "" >> "$HOME/.vimrc"
        cat "$EXEC_PATH/.vimrc" >> "$HOME/.vimrc"
        echo -e "$EXEC_PATH/.vimrc updated"
    fi
    if [ $DIFF_VIMRC -ne 0 ]
    then
        $(head -n $LINES $HOME/.vimrc > $HOME/.vimrc)
        echo -e -e "" >> "$HOME/.vimrc"
        cat "$EXEC_PATH/.vimrc" >> "$HOME/.vimrc"
        echo -e "$EXEC_PATH/.vimrc updated"
    fi
    if [ $DIFF_VUNDLE -eq 0 ] && [ $DIFF_VIMRC -eq 0 ]
    then
        echo -e "$EXEC_PATH/.vimrc up to date"
    fi
else
    install_file $EXEC_PATH/.vimrc.vundle $HOME/.vimrc
    vim +PluginInstall +qall
    echo -e "" >> "$HOME/.vimrc"
    cat "$EXEC_PATH/.vimrc" >> "$HOME/.vimrc"
    echo -e "$HOME/.vimrc installed"
fi



#############################################
#               GENERAL                     #
#############################################

# GIT
if [ ! -f /usr/bin/git ]; then
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
fi
