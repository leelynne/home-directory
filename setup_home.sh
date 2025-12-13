#/bin/bash

mkdir -p $HOME/.history.d
mkdir -p $HOME/tools

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for file in .aliases* .environment* .bashrc .bash_profile .tmux.conf .xprofile .Xresources .gitconfig .npmrc
do
    ln -sf $DIR/$file $HOME
done

plat="$(uname -s)"
case "${plat}" in
    Linux*)
        ;;
    Darwin*)
        ;;
esac
