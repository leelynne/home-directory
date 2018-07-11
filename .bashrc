function prompt
  {
      #   How many characters of the $PWD should be kept
      local pwdmaxlen=30
      #   Indicator that there has been directory truncation:
      local trunc_symbol="..."
          if [ ${#PWD} -gt $pwdmaxlen ]
              then
                  local pwdoffset=$(( ${#PWD} - $pwdmaxlen ))
                  newPWD="${trunc_symbol}${PWD:$pwdoffset:$pwdmaxlen}"
          else
              newPWD=${PWD}
          fi
          echo -n $newPWD
  }

export PS1="\u@\h:\$(prompt)> "

source ~/.environment
source ~/.aliases

plat="$(uname -s)"
case "${plat}" in
    Linux*)
        if [ -f ~/.environment.linux ]; then
            source ~/.environment.linux
        fi
        if [ -f ~/.aliases.linux ]; then
            source ~/.aliases.linux
        fi
        ;;
    Darwin*)
        if [ -f ~/.environment.darwin ]; then
            source ~/.environment.darwin
        fi
        if [ -f ~/.aliases.darwin ]; then
            source ~/.aliases.darwin
        fi
        ;;
esac

if [ -f ~/.tmux/tmux-git/tmux-git.sh ]; then
    source ~/.tmux/tmux-git/tmux-git.sh; 
fi

source ~/.local_environment
