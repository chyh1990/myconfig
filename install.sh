#!/bin/bash

cp -i tmux.conf ~/.tmux.conf
cp -i vimrc ~/.vimrc
if [[ -d ~/.vim ]]; then
  mv ~/.vim ~/.vim.old
fi
cp -r vimdir ~/.vim
