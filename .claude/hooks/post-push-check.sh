#!/usr/bin/env bash
# Fires after Bash tool use — if git push was run and TODO/CHANGELOG exist
# anywhere in the repo, instructs Claude to spawn a background subagent to
# verify they are up to date. Silently exits if neither file is present.

if ! command -v jq &>/dev/null; then exit 0; fi

INPUT=$(cat)
# Debug: log every invocation with the raw input
echo "[$(date)] INPUT: $INPUT" >> /tmp/post-push-hook.log

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
echo "[$(date)] COMMAND: $COMMAND" >> /tmp/post-push-hook.log

# Only trigger on git push commands
if [[ "$COMMAND" != *"git push"* ]]; then
  echo "[$(date)] no git push, exiting" >> /tmp/post-push-hook.log
  exit 0
fi

# Resolve repo root
REPO_ROOT=$(echo "$INPUT" | jq -r '.cwd // empty')
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
fi
echo "[$(date)] REPO_ROOT: $REPO_ROOT" >> /tmp/post-push-hook.log
if [ -z "$REPO_ROOT" ]; then exit 0; fi

# Search tracked files for TODO/CHANGELOG — silent exit if none found
FOUND_FILES=$(git -C "$REPO_ROOT" ls-files | grep -iE '(^|/)(TODO|CHANGELOG)(\.md|\.txt)?$')
echo "[$(date)] FOUND_FILES: $FOUND_FILES" >> /tmp/post-push-hook.log

if [ -z "$FOUND_FILES" ]; then exit 0; fi

cat >&2 <<EOF
[post-push-check] git push detected. The following tracked files exist in the repo:
$FOUND_FILES

Spawn a background subagent (run_in_background: true) to verify:
1. Were these files updated to reflect the code changes included in this push?
   - Compare the diff of the pushed commits against the last update to each file.
   - Flag significant code changes (new features, bug fixes, API changes) not reflected.
2. If any file is outdated, report a concise warning listing what is missing.
Do NOT block or interrupt the current task — run this check fully in the background.
EOF
exit 2
