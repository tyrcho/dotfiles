Share the agent rules, skills and guidance from this repo with a Linux workspace (home `/home/bits`), where the home folder is not a checkout of this repo.

1. Clone the `datadog` branch next to the home folder and link it in:
   ```bash
   git clone -b datadog https://github.com/tyrcho/dotfiles ~/dotfiles
   ~/dotfiles/.agents/scripts/install-agent-links.sh --dry-run   # preview
   ~/dotfiles/.agents/scripts/install-agent-links.sh
   ```
2. Anything the script replaced is kept as `<file>.bak.<timestamp>`: merge what is worth keeping into the repo, then delete the backup.
3. To update later: `git -C ~/dotfiles pull`, then run the script again (it only adds new links).

What stays local to the workspace: `~/.claude/settings.json` and `~/.codex/config.toml` (managed by the workspace: plugins, marketplaces, MCP servers, status line), the Mac hooks, and secrets such as `~/.jira.env`.
