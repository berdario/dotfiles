if [ -z "$DISPLAY" -a -z "$BYOBU_WINDOWS" ] ;
   if $TERM != "dumb";
     exec byobu-launcher;
   end
end

set config_dir (dirname (readlink -f (pwd)"/config.fish"))
echo $_

set -gx WORKON_HOME ~/.virtualenvs/
. ~/.config/fish/workon_funcs.fish
. ~/.config/fish/prompt.fish

set -x EDITOR "emacs -nw"
set -x EMAIL berdario@gmail.com

set -x DEBFULLNAME 'Dario Bertini'
set -x DEBEMAIL 'berdario@gmail.com'
set -x GPGKEY F8C98EFE
set -x VIMINIT "so $HOME/.config/vim/vimrc"

which java > /dev/null ; and set -x JAVA_HOME (readlink -f (echo (dirname (readlink -f (which java)))"/../../."))

set -x PATH $PATH ~/Applications/bin ~/.cabal/bin ~/Applications/depot_tools

function e; emacs -nw $argv; end