set -x SHELL fish

set -x NIX_LINK ~/.nix-profile

set -x EDITOR "emacs -nw"
set -x EMAIL berdario@gmail.com

set -x DEBFULLNAME 'Dario Bertini'
set -x DEBEMAIL 'berdario@gmail.com'
set -x GPGKEY F8C98EFE
set -x VIMINIT "so $HOME/.config/vim/vimrc"

set -x CLOJURESCRIPT_HOME "$HOME/Projects/clojurescript"

which greadlink > /dev/null ; and alias readlink greadlink

which java > /dev/null ; and set -x JAVA_HOME (readlink -f (echo (dirname (readlink -f (which java)))"/../../."))

if [ -e /usr/libexec/java_home ] ;
    set -x JAVA_HOME (/usr/libexec/java_home)
end

set -x ANSIBLE_NOCOWS 1

set -l additional_paths ~/.local/bin ~/Applications/bin ~/.rbenv/shims ~/.cabal/bin ~/Applications/depot_tools
mkdir -p $additional_paths

set -x NIX_PATH $NIX_PATH nixtrunk=$HOME/nixpkgs

set -l additional_paths $additional_paths /opt/ghc/7.8.3/bin/
set -x PATH $additional_paths $PATH $NIX_LINK/bin

. ~/.config/fish/prompt.fish

function e; emacs -nw $argv; end

if [ (which hub) ]
   alias git hub
end

alias nix-install "nix-env -f '<nixpkgs>' -iA"

# OPAM configuration
. /home/dario/.opam/opam-init/init.fish > /dev/null 2> /dev/null or true

# added by Pew
source (pew shell_config)
