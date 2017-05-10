source ~/.bashrc

if [[ "$OSTYPE" =~ ^darwin ]];then
    plat='darwin'
else
    plat='linux'
    ttyname=`tty | cut -d'/' -f 4`
    export HISTFILE="${HOME}/.history.d/history-$ttyname.`date +"%s"`"
fi


