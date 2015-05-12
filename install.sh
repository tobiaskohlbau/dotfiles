#!/bin/sh


# delete old files
rm -Rf ~/.vimrc
rm -Rf ~/.bashrc
rm -Rf ~/.vim
rm -Rf ~/.config/base16-shell

# copy new files
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
cp .vimrc ~/
cp .bashrc ~/
source ~/.bashrc
cp -R .vim ~/
vim +BundleInstall +qall 2&> /dev/null
