Michel's dotfiles: shell and tool config for the Mac, plus the agent rules, skills and settings shared by Claude Code and Codex on the Mac and on a Linux Datadog workspace. Branch `datadog` is the one in use.

## Usage

**Mac:** the home folder is the checkout. New laptop: follow [`migration/Laptop Setup.md`](migration/Laptop%20Setup.md) (packages from [`migration/Brewfile`](migration/Brewfile), repos from [`migration/repos.tsv`](migration/repos.tsv)).

**Linux workspace:** the repo is cloned to `~/dotfiles` and linked into the home folder. See [`migration/Workspace Setup.md`](migration/Workspace%20Setup.md):

```bash
git clone -b datadog https://github.com/tyrcho/dotfiles ~/dotfiles
~/dotfiles/.agents/scripts/install-agent-links.sh --dry-run   # preview
~/dotfiles/.agents/scripts/install-agent-links.sh
```

**Adding a file:** `.gitignore` ignores everything (`*`), so track a new file with `git add -f <path>`.

**Changing agent rules:** edit under `.claude/`, add an entry to [`.claude/CHANGELOG.md`](.claude/CHANGELOG.md), then open a draft PR against `datadog`.

## Implementation details / Architecture

- `.claude/CLAUDE.md`: global agent instructions. It imports the rule files under `.claude/rules/` (`code/`, `process/`, `tools/`, `datadog/`). Codex reads the same file as `~/.codex/AGENTS.md`.
- `.claude/skills/`, `agents/`, `commands/`, `hooks/`: shared Claude Code extensions. `.agents/skills/` holds the Codex user skills.
- `.claude/settings/`: `shared.json`, plus `mac.json` or `linux.json`. [`install-agent-links.sh`](.agents/scripts/install-agent-links.sh) merges them into `~/.claude/settings.json` (on the workspace, on top of the workspace-managed file) and links every rule, skill and hook entry by entry, so local plugins stay next to them.
- Shell and tool config: `.zshrc`, `.bashrc`, `.profile`, `.tmux.conf`, `.vimrc`, `.gitconfig`, `.config/` (gh, git, nvim, zed, fish, topgrade), `.ssh/config`, `.finicky.js`, `Library/LaunchAgents/` (work-analyzer jobs).
- `migration/`: laptop and workspace rebuild checklists, Brewfile, repo list, app prefs.
