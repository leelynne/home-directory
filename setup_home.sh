#/bin/bash

mkdir $HOME/.history.d

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for file in .aliases .environment .bashrc .bash_profile .tmux.conf .xprofile .Xresources
do
    ln -sf $DIR/$file $HOME
done
