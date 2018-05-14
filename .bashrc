#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias vi='vim'

export PROMPT_COMMAND='export H1="`history 1|sed -e "s/^[\ 0-9]*//; s/[\d0\d31\d34\d39\d96\d127]*//g; s/\(.\{1,50\}\).*$/\1/g"`";history -a;echo -e "sgr0\ncnorm\nrmso"|tput -S'
export PS1='\e[1;30m[\e[1;34m\u@\H\e[1;30m] $(__git_ps1 "(%s)") \e[1;37m\w\e[0;37m\[\033]0;[ ${H1}... ] \w - \u@\H +$SHLVL @`tty 2>/dev/null` - [ `uptime` ]\007\]\n\[\]\$ '
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=1
export GIT_PS1_DESCRIBE_STYLE=branch
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

[[ -f ~/.proxy_env ]] && . ~/.proxy_env

source ~/.git-prompt.sh

export JAVA_HOME=/usr/lib/jvm/java-8-jdk/

eval $(thefuck --alias)

