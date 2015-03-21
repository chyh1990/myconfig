#!/bin/bash


cp -i tmux.conf ~/.tmux.conf
cp -i vimrc ~/.vimrc
if [[ -d ~/.vim ]]; then
  mv ~/.vim ~/.vim.old
fi
#cp -r vimdir ~/.vim
ln -s `pwd`/vimdir ~/.vim
ln -s ~/prog/myconfig/oh-my-zsh ~/.oh-my-zsh

git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
