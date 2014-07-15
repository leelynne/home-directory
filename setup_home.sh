#/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for file in .aliases .environment .bashrc .bash_profile .tmux.conf .xprofile .Xresources
do
    ln -s $DIR/$file $HOME
done

# Install Prelude
export PRELUDE_URL="https://github.com/leelynne/prelude.git"
curl -L https://github.com/bbatsov/prelude/raw/master/utils/installer.sh | sh
