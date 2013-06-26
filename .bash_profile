source ~/.bashrc
export HISTFILE="${HOME}/.history.d/history-"`tty | cut -d'/' -f 4`"."`date +"%s"`

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
