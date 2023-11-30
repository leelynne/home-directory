#/bin/bash

mkdir $HOME/.history.d

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for file in .aliases* .environment* .bashrc .bash_profile .tmux.conf .xprofile .Xresources .gitconfig
do
    ln -sf $DIR/$file $HOME
done

plat="$(uname -s)"
case "${plat}" in
    Linux*)
        ;;
    Darwin*)
        # On osx directly create 'ec' as an executable
        sudo cp darwin_ec /usr/local/bin/ec
        sudo chmod +x /usr/loca/bin/ec
        ;;
esac
