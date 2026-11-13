Share the agent rules, skills and guidance from this repo with a Linux workspace (home `/home/bits`), where the home folder is not a checkout of this repo.

1. Clone the `datadog` branch next to the home folder and link it in:
   ```bash
   git clone -b datadog https://github.com/tyrcho/dotfiles ~/dotfiles
   ~/dotfiles/.agents/scripts/install-agent-links.sh --dry-run   # preview
   ~/dotfiles/.agents/scripts/install-agent-links.sh
   ```
2. Anything the script replaced is kept as `<file>.bak.<timestamp>`: merge what is worth keeping into the repo, then delete the backup.
3. To update later: `git -C ~/dotfiles pull`, then run the script again (it only adds new links).

`~/.claude/settings.json` stays managed by the workspace (plugins, marketplaces, status line). The script layers `.claude/settings/shared.json` and `linux.json` on top of it: keys are merged, lists (permissions, hook groups) are joined without duplicates, and the diff is printed before writing. Put workspace-only settings in `linux.json`, Mac-only ones in `mac.json`. A key removed from `shared.json` is not removed from the workspace file: delete it there by hand.

What stays local to the workspace: `~/.codex/config.toml`, the Mac hooks (iTerm2 `cc-status`) and secrets such as `~/.jira.env`.
