source ~/.bashrc
export HISTFILE="${HOME}/.history.d/history-"`tty | cut -d'/' -f 4`"."`date +"%s"`
export PATH=$HOME/.rbenv/bin:$PATH
export PATH="/home/leef/.rbenv/shims:${PATH}"
source "/usr/lib/rbenv/libexec/../completions/rbenv.bash"
rbenv rehash 2>/dev/null
rbenv() {
    command="$1"
    if [ "$#" -gt 0 ]; then
        shift
    fi

    case "$command" in
        shell)
            eval `rbenv "sh-$command" "$@"`;;
        *)
            command rbenv "$command" "$@";;
    esac
}
