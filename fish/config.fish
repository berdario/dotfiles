if [ -z "$DISPLAY" -a -z "$BYOBU_WINDOWS" ] ;
   if test $TERM != "dumb";
     exec byobu-launcher;
   end
end

set -gx WORKON_HOME ~/.virtualenvs/
. ~/.config/fish/workon_funcs.fish
. ~/.config/fish/prompt.fish

set -x EDITOR "emacs -nw"
set -x EMAIL berdario@gmail.com

set -x DEBFULLNAME 'Dario Bertini'
set -x DEBEMAIL 'berdario@gmail.com'
set -x GPGKEY F8C98EFE
set -x VIMINIT "so $HOME/.config/vim/vimrc"

set -x CLOJURESCRIPT_HOME "$HOME/Projects/clojurescript"

which java > /dev/null ; and set -x JAVA_HOME (readlink -f (echo (dirname (readlink -f (which java)))"/../../."))

mkdir -p ~/Applications/bin ~/.cabal/bin ~/Applications/depot_tools
set -x PATH $PATH ~/Applications/bin ~/.cabal/bin ~/Applications/depot_tools

function e; emacs -nw $argv; end