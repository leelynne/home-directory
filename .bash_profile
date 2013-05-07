source ~/.bashrc
export HISTFILE="${HOME}/.history.d/history-"`tty | cut -d'/' -f 4`"."`date +"%s"`
