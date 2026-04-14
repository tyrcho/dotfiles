#!/usr/bin/env bash
# Fires after Bash tool use — if git push was run and TODO/CHANGELOG exist at
# the repo root, instructs Claude to spawn a background subagent to verify they
# are up to date. Silently exits if neither file is present.

if ! command -v jq &>/dev/null; then exit 0; fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only trigger on git push commands
if [[ "$COMMAND" != *"git push"* ]]; then exit 0; fi

# Resolve repo root
REPO_ROOT=$(echo "$INPUT" | jq -r '.tool_input.workingDirectory // empty')
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
fi
if [ -z "$REPO_ROOT" ]; then exit 0; fi

# Find which tracked files exist — silent exit if none
FOUND_FILES=()
for NAME in TODO CHANGELOG; do
  for EXT in "" ".md" ".txt"; do
    FILE="$REPO_ROOT/$NAME$EXT"
    if [ -f "$FILE" ]; then
      FOUND_FILES+=("$FILE")
      break
    fi
  done
done

if [ ${#FOUND_FILES[@]} -eq 0 ]; then exit 0; fi

FILES_LIST=$(printf '%s\n' "${FOUND_FILES[@]}")

cat >&2 <<EOF
[post-push-check] git push detected. The following tracked files exist in the repo root:
$FILES_LIST

Spawn a background subagent (run_in_background: true) to verify:
1. Were these files updated to reflect the code changes included in this push?
   - Compare the diff of the pushed commits against the last update to each file.
   - Flag significant code changes (new features, bug fixes, API changes) not reflected.
2. If any file is outdated, report a concise warning listing what is missing.
Do NOT block or interrupt the current task — run this check fully in the background.
EOF
