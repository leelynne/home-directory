#!/bin/sh

cat > /usr/local/bin/emacs <<EOF
#!/bin/sh
/Applications/Emacs.app/Contents/MacOS/Emacs "$@"
EOF

chmod +x /usr/local/bin/emacs

ln -s /Applications/Emacs.app/Contents/MacOS/bin/emacsclient /usr/local/bin

cat > /usr/local/bin/ec <<EOF
#!/bin/sh
emacsclient -a '' -c "$@"
EOF

chmod +x /usr/local/bin/ec

# Java
brew install openjdk
# Binary used for markdown previews
brew install cmark-gfm
# Spell check
brew install aspell
# dot for org-roam
brew install graphviz
# plantuml-mode support
brew install plantuml
# org-mode needs to know where the jar is
ln -s `find /opt/homebrew -name "plantuml.jar" 2>/dev/null | head -1` ~/.emacs.d/plantuml.jar
brew install languagetool
# languagetool
ln -s `find /opt/homebrew -name "languagetool-server.jar" 2>/dev/null | head -1` ~/.emacs.d/languagetool-server.jar
