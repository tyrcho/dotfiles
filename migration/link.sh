#!/usr/bin/env bash
# Symlink dotfiles from this repo into $HOME. Existing files are moved to ~/.dotfiles-backup/<timestamp>/.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

paths=(
  .zshrc .bashrc .bash_profile .vimrc .tmux.conf .editorconfig fzf-git.sh
  .gitconfig .config/git .config/gh/config.yml .ssh/config
  .config/nvim .config/zed/settings.json .config/zed/tasks.json .config/topgrade.toml .config/duti
  .claude/CLAUDE.md .claude/settings.json .claude/statusline.sh
  .claude/rules .claude/hooks .claude/skills .claude/agents .claude/commands
)

for p in "${paths[@]}"; do
  src="$REPO/$p"; dst="$HOME/$p"
  [ -e "$src" ] || { echo "skip (not in repo): $p"; continue; }
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then continue; fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "$p")"; mv "$dst" "$BACKUP/$p"; echo "backed up: $p"
  fi
  ln -s "$src" "$dst"; echo "linked: $p"
done
# Zed CLI on PATH, Zed as default for text/code files
[ -x /Applications/Zed.app/Contents/MacOS/cli ] && mkdir -p "$HOME/.local/bin" && ln -sf /Applications/Zed.app/Contents/MacOS/cli "$HOME/.local/bin/zed"
# Obsidian CLI on PATH (enable it in Obsidian: Settings > General > Advanced)
[ -x /Applications/Obsidian.app/Contents/MacOS/obsidian-cli ] && ln -sf /Applications/Obsidian.app/Contents/MacOS/obsidian-cli "$HOME/.local/bin/obsidian"
# gitlab-to-github migration script on PATH
mkdir -p "$HOME/.local/bin" && ln -sf "$REPO/gitlab-to-github/gitlab-to-github.sh" "$HOME/.local/bin/gitlab-to-github"
command -v duti >/dev/null && duti "$REPO/.config/duti/zed.duti" 2>/dev/null || true
chmod 700 "$HOME/.ssh" 2>/dev/null || true
