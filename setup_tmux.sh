#!/bin/bash -x

sudo apt install -y git
git clone git://github.com/drmad/tmux-git.git ~/.tmux/tmux-git

command -v tmux
if [ $? -eq 0 ]; then
    echo "tmux already installed"
    exit 1
fi

sudo apt install -y automake build-essential pkg-config libevent-dev libncurses5-dev
rm -fr /tmp/tmux
git clone https://github.com/tmux/tmux.git /tmp/tmux
cd /tmp/tmux
sh autogen.sh
./configure && make
sudo make install
cd -
rm -fr /tmp/tmux
