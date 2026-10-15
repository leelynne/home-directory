source ~/.bashrc

if [[ "$OSTYPE" =~ ^darwin ]];then
    plat='darwin'
else
    plat='linux'
    ttyname=`tty | cut -d'/' -f 4`
    export HISTFILE="${HOME}/.history.d/history-$ttyname.`date +"%s"`"
fi



[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Hermes Agent command
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
