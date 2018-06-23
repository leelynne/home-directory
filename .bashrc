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

if [[ \$TMUX ]]; then source ~/.tmux/tmux-git/tmux-git.sh; fi

source ~/.environment
source ~/.aliases
source ~/.local_environment
