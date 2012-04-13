# Set up the prompt

hgBranch(){
if [ -d .hg ]; then
        printf "$1" "$(hg branch)"
fi
}

refresh_path(){
export PATH=${PATH}
return 1
}

setopt PROMPT_SUBST

autoload colors; colors
#autoload -Uz promptinit
#promptinit
#prompt walters

PS1='%{$fg_bold[green]%}%n@%m%{$reset_color%}:%{$fg_bold[blue]%}%~%(?..[%?])$(hgBranch " %%{$fg_bold[red]%%}(%s)")%{$reset_color%}%(!.#.$) '

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
setopt HIST_IGNORE_DUPS
HISTSIZE=20000
SAVEHIST=20000
HISTFILE=~/.zsh_history

setopt sharehistory

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer refresh_path _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'



source /etc/zsh_command_not_found
#source /etc/bash_completion.d/virtualenvwrapper
source /home/dario/Projects/virtualenvwrapper/virtualenvwrapper.sh

export EDITOR="emacs -nw"
export EMAIL=berdario@gmail.com
export PATH=${PATH}:/sbin:/usr/sbin:/usr/local/sbin
export PATH=${PATH}:~/Applications/bin

export DEBFULLNAME='Dario Bertini'
export DEBEMAIL='berdario@gmail.com'
export GPGKEY=F8C98EFE
export VIMINIT="so $HOME/.config/vim/vimrc"

export JAVA_HOME=$(readlink -f "`dirname \`readlink -f  \\\`which java\\\`\``""/../../.")

export PATH=${PATH}:$HOME/.cabal/bin
export PATH="$PATH":$HOME/Applications/depot_tools

alias ls="ls --color=auto"

alias duh="dulwich"
alias history="history 1"
alias e="emacs -nw"
alias sudo="sudo " # A trailing space in value causes the next word to be checked for alias substitution when the alias is expanded
