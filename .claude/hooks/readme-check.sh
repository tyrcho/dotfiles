#!/usr/bin/env bash
# Fires after Edit/Write — reminds Claude to update nearby docs when source files change.

if ! command -v jq &>/dev/null; then exit 0; fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then exit 0; fi

BASENAME=$(basename "$FILE_PATH")
DIR=$(dirname "$FILE_PATH")
DIRS=("$DIR" "$(dirname "$DIR")" "$(dirname "$(dirname "$DIR")")")

reminders=()

for CHECK_DIR in "${DIRS[@]}"; do
  if [ -f "$CHECK_DIR/README.md" ]; then
    reminders+=("README.md found at $CHECK_DIR/README.md — review existing sections and update any that are outdated. Do NOT create a new README or add new sections without asking the user first.")
    break
  fi
done

for CHECK_DIR in "${DIRS[@]}"; do
  for name in CHANGELOG.md CHANGELOG; do
    if [ -f "$CHECK_DIR/$name" ]; then
      reminders+=("$name found at $CHECK_DIR/$name — consider adding an entry if this change is user-facing.")
      break 2
    fi
  done
done

for CHECK_DIR in "${DIRS[@]}"; do
  for name in TODO.md TODO; do
    if [ -f "$CHECK_DIR/$name" ]; then
      reminders+=("$name found at $CHECK_DIR/$name — check whether any items are now resolved or new ones should be added.")
      break 2
    fi
  done
done

for CHECK_DIR in "${DIRS[@]}"; do
  for docdir in doc docs; do
    if [ -d "$CHECK_DIR/$docdir" ]; then
      reminders+=("$docdir/ directory found at $CHECK_DIR/$docdir/ — check whether any documentation files there need updating due to changes in $BASENAME.")
      break 2
    fi
  done
done

if [ ${#reminders[@]} -gt 0 ]; then
  echo "Documentation check for $BASENAME:" >&2
  for msg in "${reminders[@]}"; do
    echo "  • $msg" >&2
  done
fi
