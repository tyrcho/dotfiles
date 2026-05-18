#!/bin/zsh
# Daily 1:1 prep — invoke Claude headlessly with the work-analyzer prompt.
# Triggered by ~/Library/LaunchAgents/com.michel.daviot.work-analyzer-daily.plist
# on weekday mornings (10:03 AM Mon-Fri).

# Pull in user PATH + API tokens. Don't `set -e` — the user's zshrc has
# interactive-mode side-effects (oh-my-zsh setup, iterm2 integration, etc.)
# that exit non-zero in a non-interactive shell and would kill the script
# before reaching claude.
[[ -f "${HOME}/.zprofile" ]] && source "${HOME}/.zprofile" 2>/dev/null || true
[[ -f "${HOME}/.zshrc"    ]] && source "${HOME}/.zshrc"    2>/dev/null || true

PROMPT_FILE="${HOME}/.claude/scripts/daily-work-analyzer/prompt.md"
# Real Anthropic Claude CLI — bypass the cmux wrapper which hangs without a
# live cmux socket (launchd has no cmux integration).
CLAUDE_BIN="${HOME}/.local/bin/claude"

# Unset cmux env so the binary doesn't try to phone home to a non-running session.
unset CMUX_SURFACE_ID CMUX_SESSION_ID CMUX_SOCKET_PATH CLAUDECODE

ts="$(date '+%Y-%m-%d %H:%M:%S %z')"
echo "[${ts}] starting daily work-analyzer prep"

# Pass the prompt as a positional arg (stdin-redirect form silently no-ops).
"${CLAUDE_BIN}" --print "$(cat "${PROMPT_FILE}")"

echo "[${ts}] done (exit $?)"
