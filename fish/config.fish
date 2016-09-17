set -x SHELL fish

set -x NIX_LINK ~/.nix-profile

set -x EDITOR nvim
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

set -l additional_paths ~/Applications/bin ~/.rbenv/shims ~/.cabal/bin
mkdir -p $additional_paths
mkdir -p ~/.local/bin

set -x NIX_PATH "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs:nixtrunk=$HOME/nixpkgs"

set -x GUIX_LOCPATH $HOME/.guix-profile/lib/locale
set -x LC_ALL en_US.UTF-8 # needed by guix

set -l additional_paths $additional_paths /opt/ghc/7.8.3/bin/
set -x PATH $additional_paths $PATH ~/.local/bin $NIX_LINK/bin

. ~/.config/fish/prompt.fish

function e; emacs -nw $argv; end

if [ (which hub) ]
   alias git hub
end

if [ (which keychain) ]
   eval (keychain --eval --quiet)
end

alias nix-install "nix-env -f '<nixpkgs>' -iA"

# OPAM configuration
. /home/dario/.opam/opam-init/init.fish > /dev/null 2> /dev/null or true

# added by Pew
source (pew shell_config)

if [ -e ~/.config/fish/local.fish ] ;
  . ~/.config/fish/local.fish
end
