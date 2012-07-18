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
if ! /usr/kerberos/bin/klist -s; then 
    if [ -t 0 ]; then
        stty -echo;/usr/kerberos/bin/kinit -f; stty echo;
    fi
fi

source ~/.environment
source ~/.aliases
