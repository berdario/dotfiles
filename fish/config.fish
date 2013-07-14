if [ -z "$DISPLAY" -a -z "$BYOBU_WINDOWS" ] ;
   if test $TERM != "dumb";
     exec byobu-launcher;
   end
end

complete -c workon -a "(cd ~/.virtualenvs; ls -d *)"
. ~/.config/fish/prompt.fish

set -x EDITOR "emacs -nw"
set -x EMAIL berdario@gmail.com

set -x DEBFULLNAME 'Dario Bertini'
set -x DEBEMAIL 'berdario@gmail.com'
set -x GPGKEY F8C98EFE
set -x VIMINIT "so $HOME/.config/vim/vimrc"

set -x CLOJURESCRIPT_HOME "$HOME/Projects/clojurescript"

which java > /dev/null ; and set -x JAVA_HOME (readlink -f (echo (dirname (readlink -f (which java)))"/../../."))

set OCAMLVERSION 4.00.1
set -x CAML_LD_LIBRARY_PATH ~/.opam/$OCAMLVERSION/lib/stublibs /usr/lib/ocaml/stublibs
set -x OCAML_TOPLEVEL_PATH ~/.opam/$OCAMLVERSION/lib/toplevel
set -x MANPATH ~/.opam/$OCAMLVERSION/man:$MANPATH

set -l additional_paths ~/.opam/$OCAMLVERSION/bin ~/Applications/bin ~/.rbenv/shims ~/.cabal/bin ~/Applications/depot_tools
mkdir -p $additional_paths
set -x PATH $additional_paths $PATH

function e; emacs -nw $argv; end