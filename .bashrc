[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# BEGIN SCFW MANAGED BLOCK
alias npm="scfw run npm"
alias pip="scfw run pip"
alias poetry="scfw run poetry"
export SCFW_DD_AGENT_LOG_PORT="10365"
export SCFW_DD_LOG_LEVEL="ALLOW"
export SCFW_HOME="/Users/michel.daviot/.scfw"
# END SCFW MANAGED BLOCK

alias claude-mem='/Users/michel.daviot/.bun/bin/bun "/Users/michel.daviot/.claude/plugins/cache/thedotmack-claude-mem/claude-mem/10.6.2/scripts/worker-service.cjs"'
. "$HOME/.cargo/env"

[ -f "/opt/dogbrew/share/etc/dogbrew/init.bash" ] && . "/opt/dogbrew/share/etc/dogbrew/init.bash"
