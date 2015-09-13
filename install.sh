#!/bin/sh

# BASE16
if [ -d ~/.config/base16-shell ]; then
    rm -rf ~/.config/base16-shell
fi
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# BASHRC
if [ -f ~/.bashrc ]; then
    cat .bashrc >> ~/.bashrc
else
    cp .bashrc ~/
fi
source ~/.bashrc

# VIM
if [ -f ~/.vimrc ]; then
    rm -f ~/.vimrc
fi
if [ -d ~/.vim ]; then
    rm -rf ~/.vim
fi
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle
cp -R .vim ~/
cp .vimrc.vundle ~/.vimrc
echo -e "" >> ~/.vimrc
vim +BundleInstall +qall
cat .vimrc >> ~/.vimrc

# TMUX
if [ -f ~/.tmux.conf ]; then
    rm -f ~/.tmux.conf
fi
cp .tmux.conf ~/

# I3
if [ -d ~/.i3 ]; then
    rm -f ~/.i3/config
else
    mkdir ~/.i3
fi
cp .i3 ~/.i3/config

# GIT
git config --global user.email "tobias.kohlbau@gmail.com"
git config --global user.name "Tobias Kohlbau"
git config --global core.editor "vim"



