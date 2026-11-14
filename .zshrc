# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=50000
HISTFILESIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY


# Avoid duplicate entries
export HISTCONTROL=ignoredups:erasedups

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  alias-tips
  docker
  docker-compose
  fzf-tab
  git
  git-auto-fetch
  history
  jq # https://github.com/reegnz/jq-zsh-plugin?tab=readme-ov-file#usage
  kubectl
  sbt
  scala
  zsh-autosuggestions
)


GIT_AUTO_FETCH_INTERVAL=1800 # in seconds


### Fix slowness of pastes with zsh-syntax-highlighting.zsh
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
### Fix slowness of pastes


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_INSECURE_REDIRECT=1

# Language managers (only if installed)
command -v pyenv >/dev/null && eval "$(pyenv init - --no-rehash)"
command -v rbenv >/dev/null && eval "$(rbenv init - --no-rehash)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# Prefer GNU binaries to Macintosh binaries.
[ -d /opt/homebrew/opt/coreutils/libexec/gnubin ] && export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$HOME/.local/bin:$PATH"

source $ZSH/oh-my-zsh.sh

alias vi="nvim"
alias vim="nvim"
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# google-cloud-sdk brew caveat
[ -f /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ] && source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ] && source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc

[ -f ~/z.sh ] && source ~/z.sh
[ -f ~/F-Sy-H/F-Sy-H.plugin.zsh ] && source ~/F-Sy-H/F-Sy-H.plugin.zsh
[ -f ~/fzf-git.sh ] && source ~/fzf-git.sh # https://github.com/junegunn/fzf-git.sh

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
alias code="/Applications/Visual\ Studio\ Code.app/contents/Resources/app/bin/code"
[ -f ~/.secrets-env.sh ] && source ~/.secrets-env.sh

ulimit -n 32768

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.zsh-copilot/zsh-copilot.plugin.zsh ] && source ~/.zsh-copilot/zsh-copilot.plugin.zsh
command -v zoxide >/dev/null && [[ -z $CLAUDECODE ]] && eval "$(zoxide init zsh --cmd cd)"
command -v starship >/dev/null && eval "$(starship init zsh)"

# bun
export BUN_INSTALL="$HOME/.bun"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$PATH:$HOME/Library/Application Support/Coursier/bin"
export ANTHROPIC_MODEL="opus[1m]"

# obsidian <path>: open a vault folder or note in Obsidian; anything else goes to the Obsidian CLI
obsidian() {
  if [[ $# -eq 1 && -e "$1" ]]; then
    local p="${1:A}"
    open "obsidian://open?path=$(printf %s "$p" | jq -sRr @uri)"
  else
    command obsidian "$@"
  fi
}
