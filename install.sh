#!/bin/sh

# BASE16
if [ -d ~/.config/base16-shell ]; then
    rm -rf ~/.config/base16-shell
fi
git clone -q https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# BASHRC
if [ -f ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc.bak
    echo ".bashrc already exists moved to ~/.bashrc.bak"
fi
cp .bashrc ~/
source ~/.bashrc

# VIM
if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ~/.vimrc.bak
    echo ".vimrc already exists moved to ~/.vimrc.bak"
fi
if [ -d ~/.vim ]; then
    rm -rf ~/.vim.bak
    mv ~/.vim ~/.vim.bak
    echo ".vim already exists moved to ~/.vim.bak"
fi
git clone -q https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle
cp -R .vim ~/
cp .vimrc.vundle ~/.vimrc
vim +PluginInstall +qall
echo -e "" >> ~/.vimrc
cat .vimrc >> ~/.vimrc

# TMUX
if [ -f ~/.tmux.conf ]; then
    mv ~/.tmux.conf ~/.tmux.conf.bak
    echo ".tmux.conf already exists moved to ~/.tmux.conf.bak"
fi
cp .tmux.conf ~/

# GIT
git config --global user.email "tobias.kohlbau@gmail.com"
git config --global user.name "Tobias Kohlbau"
git config --global core.editor "vim"

# FONTS
if [ -d /tmp/fonts ]; then
    rm -rf /tmp/fonts
fi
git clone https://github.com/powerline/fonts.git /tmp/fonts
sh /tmp/fonts/install.sh

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
