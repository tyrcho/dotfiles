#!/usr/bin/env bash
# Fires after Edit/Write — reminds Claude to update existing README sections.

if ! command -v jq &>/dev/null; then exit 0; fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then exit 0; fi

DIR=$(dirname "$FILE_PATH")
for CHECK_DIR in "$DIR" "$(dirname "$DIR")" "$(dirname "$(dirname "$DIR")")"; do
  if [ -f "$CHECK_DIR/README.md" ]; then
    echo "README.md found at $CHECK_DIR/README.md — review existing sections and update any that are outdated due to changes in $(basename "$FILE_PATH"). Do NOT create a new README or add new sections without asking the user first." >&2
    exit 0
  fi
done
