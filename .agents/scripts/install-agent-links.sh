#!/usr/bin/env bash
# Symlink the agent rules, skills and guidance tracked in this repo into $HOME,
# so Claude Code and Codex read the same files on the Mac and on a Linux workspace.
#
# Usage: install-agent-links.sh [--dry-run]
#
# Safe to run again: links that are already in place are left alone, and any
# other file or link found at a target is moved to <target>.bak.<timestamp>.
# On the Mac the repo is checked out in $HOME itself, so most targets are the
# repo files already and only the missing links get created.
#
# Linked everywhere:
#   ~/.claude/CLAUDE.md                <- .claude/CLAUDE.md
#   ~/.claude/{rules,skills,agents,commands}/<entry>
#                                      <- .claude/{rules,skills,agents,commands}/<entry>
#   ~/.agents/skills/<entry>           <- .agents/skills/<entry>  (Codex user skills)
#   ~/.codex/AGENTS.md                 <- .claude/CLAUDE.md       (Codex global instructions)
#   ~/.claude/hooks/<entry>            <- .claude/hooks/<entry>   (used by the shared settings)
# macOS only (its command only exists on the Mac):
#   ~/.claude/statusline.sh
#
# ~/.claude/settings.json is generated, not linked (needs jq):
#   macOS:  .claude/settings/shared.json + mac.json
#   Linux:  the existing (workspace-managed) settings.json + shared.json + linux.json,
#           so keys the workspace sets (plugins, status line) stay.
# The diff is printed before writing, and the old file is backed up.
#
# Directories are linked entry by entry, so skills or rules installed locally
# (by plugins or by hand) stay next to the shared ones.

set -euo pipefail

usage() { sed -n '2,/^$/s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"; }

DRY_RUN=0
case "${1:-}" in
  -n | --dry-run) DRY_RUN=1 ;;
  -h | --help) usage; exit 0 ;;
  "") ;;
  *) usage >&2; exit 2 ;;
esac

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
STAMP="$(date +%Y%m%d-%H%M%S)"

run() {
  if [ "$DRY_RUN" = 1 ]; then echo "  (dry run) $*"; else "$@"; fi
}

backup_path() {
  local bak="$1.bak.$STAMP" n=1
  while [ -e "$bak" ] || [ -L "$bak" ]; do bak="$1.bak.$STAMP.$n"; n=$((n + 1)); done
  echo "$bak"
}

# link SRC DST: make DST a symlink to SRC, backing up whatever DST was.
link() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then echo "missing $src (not in the repo, skipped)"; return; fi
  if [ -e "$dst" ] && [ "$src" -ef "$dst" ]; then echo "ok      $dst"; return; fi
  run mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local bak
    bak="$(backup_path "$dst")"
    echo "backup  $dst -> $bak"
    run mv "$dst" "$bak"
  fi
  echo "link    $dst -> $src"
  run ln -s "$src" "$dst"
}

# link_entries SRC_DIR DST_DIR: link each top-level entry of SRC_DIR into DST_DIR.
# Symlinks inside the repo are skipped (e.g. the self-referencing commands/commands).
link_entries() {
  local src_dir="$1" dst_dir="$2" entry
  [ -d "$src_dir" ] || { echo "missing $src_dir (not in the repo, skipped)"; return; }
  for entry in "$src_dir"/*; do
    if [ -L "$entry" ]; then echo "skip    $entry (symlink in the repo)"; continue; fi
    [ -e "$entry" ] || continue
    link "$entry" "$dst_dir/$(basename "$entry")"
  done
}

# install_settings: build ~/.claude/settings.json from the split files in .claude/settings/.
install_settings() {
  local dst="$HOME/.claude/settings.json" dir="$REPO/.claude/settings" os=linux base=() tmp
  [ "$(uname -s)" = Darwin ] && os=mac
  [ "$os" = linux ] && [ -f "$dst" ] && base=("$dst")
  tmp="$(mktemp)"
  jq -s -f "$REPO/.agents/scripts/merge-settings.jq" ${base[@]+"${base[@]}"} "$dir/shared.json" "$dir/$os.json" >"$tmp"
  if [ -f "$dst" ] && diff -q <(jq -S . "$dst") <(jq -S . "$tmp") >/dev/null; then
    echo "ok      $dst"; rm -f "$tmp"; return
  fi
  [ -f "$dst" ] && diff -u <(jq -S . "$dst") <(jq -S . "$tmp") || true
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local bak
    bak="$(backup_path "$dst")"
    echo "backup  $dst -> $bak"
    run cp -P "$dst" "$bak"
    run rm -f "$dst"
  fi
  echo "write   $dst ($os)"
  run mv "$tmp" "$dst"
  rm -f "$tmp"
}

echo "Linking agent config from $REPO into $HOME"

link "$REPO/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
for dir in rules skills agents commands; do
  link_entries "$REPO/.claude/$dir" "$HOME/.claude/$dir"
done
link_entries "$REPO/.agents/skills" "$HOME/.agents/skills"
link "$REPO/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"
link_entries "$REPO/.claude/hooks" "$HOME/.claude/hooks"

if [ "$(uname -s)" = Darwin ]; then
  link "$REPO/.claude/statusline.sh" "$HOME/.claude/statusline.sh"
fi
install_settings

echo "Done."
