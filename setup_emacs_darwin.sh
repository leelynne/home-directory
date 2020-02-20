#!/bin/sh

cat > /usr/local/bin/emacs <<EOF
#!/bin/sh
/Applications/Emacs.app/Contents/MacOS/Emacs "$@"
EOF

chmod +x /usr/local/bin/emacs

ln -s /Applications/Emacs.app/Contents/MacOS/bin/emacsclient /usr/local/bin

cat > /usr/local/bin/ec <<EOF
#!/bin/sh
which osascript > /dev/null 2>&1 && osascript -e 'tell application "Emacs" to activate'
emacsclient -c "$@"
EOF
