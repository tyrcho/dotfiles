#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias vi='vim'

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

[[ -f ~/.proxy_env ]] && . ~/.proxy_env

source ~/.git-prompt.sh

export JAVA_HOME=/usr/lib/jvm/java-9-jdk/

eval $(thefuck --alias)


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
