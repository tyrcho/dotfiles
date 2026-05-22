#!/usr/bin/env bash
# Fires after Edit/Write — checks syntax, types, and lint for common languages.
#
# Supported per extension:
#   .py                  — python3 -m py_compile
#   .ts .tsx .vue        — tsc/vue-tsc --noEmit  +  eslint (if configured)
#   .js .jsx .mjs .cjs   — eslint (if configured)
#   .go                  — go vet ./... in the package directory
#   .sh .bash            — shellcheck

if ! command -v jq &>/dev/null; then exit 0; fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then exit 0; fi

EXT="${FILE_PATH##*.}"

# Walk up from $1 looking for a file/dir named $2; echo the dir that contains it.
find_up() {
  local dir="$1"
  local marker="$2"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -e "$dir/$marker" ]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

# Echo the directory of the closest ESLint config (flat or legacy).
find_eslint_root() {
  local start="$1"
  local marker
  for marker in eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts \
                .eslintrc.js .eslintrc.cjs .eslintrc.json .eslintrc.yml .eslintrc.yaml; do
    if find_up "$start" "$marker"; then return 0; fi
  done
  return 1
}

# Truncate output to N lines for readable hook feedback.
truncate_output() {
  echo "$1" | head -"$2"
}

check_python() {
  if ! command -v python3 &>/dev/null; then return; fi
  local out
  out=$(python3 -m py_compile "$FILE_PATH" 2>&1)
  if [ $? -ne 0 ]; then
    echo "Python syntax error in $FILE_PATH:" >&2
    echo "$out" >&2
  fi
}

# Pick a TypeScript checker for the project at $1.
# Prefers vue-tsc (handles .vue + .ts), then local tsc, then global tsc, then npx tsc.
pick_tsc() {
  local root="$1"
  if [ -x "$root/node_modules/.bin/vue-tsc" ]; then
    echo "$root/node_modules/.bin/vue-tsc"
  elif [ -x "$root/node_modules/.bin/tsc" ]; then
    echo "$root/node_modules/.bin/tsc"
  elif command -v tsc &>/dev/null; then
    echo "tsc"
  elif command -v npx &>/dev/null; then
    echo "npx --no-install tsc"
  else
    return 1
  fi
}

check_typescript() {
  local tsconfig_dir tsc_cmd out status
  tsconfig_dir=$(find_up "$(dirname "$FILE_PATH")" tsconfig.json) || return
  tsc_cmd=$(pick_tsc "$tsconfig_dir") || return

  out=$(cd "$tsconfig_dir" && timeout 15 $tsc_cmd --noEmit --pretty false 2>&1)
  status=$?
  if [ $status -ne 0 ] && [ $status -ne 124 ]; then
    echo "TypeScript errors ($tsconfig_dir):" >&2
    truncate_output "$out" 15 >&2
  fi
}

check_go() {
  if ! command -v go &>/dev/null; then return; fi
  local pkg_dir out status
  pkg_dir=$(dirname "$FILE_PATH")
  out=$(cd "$pkg_dir" && timeout 15 go vet ./... 2>&1)
  status=$?
  if [ $status -ne 0 ] && [ $status -ne 124 ]; then
    echo "go vet errors ($pkg_dir):" >&2
    truncate_output "$out" 20 >&2
  fi
}

check_shellcheck() {
  if ! command -v shellcheck &>/dev/null; then return; fi
  local out
  out=$(shellcheck -f gcc "$FILE_PATH" 2>&1)
  if [ $? -ne 0 ]; then
    echo "shellcheck warnings in $FILE_PATH:" >&2
    truncate_output "$out" 20 >&2
  fi
}

# Pick an ESLint binary for the project at $1.
pick_eslint() {
  local root="$1"
  if [ -x "$root/node_modules/.bin/eslint" ]; then
    echo "$root/node_modules/.bin/eslint"
  elif command -v eslint &>/dev/null; then
    echo "eslint"
  else
    return 1
  fi
}

check_eslint() {
  local eslint_root eslint_cmd out status
  eslint_root=$(find_eslint_root "$(dirname "$FILE_PATH")") || return
  eslint_cmd=$(pick_eslint "$eslint_root") || return

  out=$(cd "$eslint_root" && timeout 15 $eslint_cmd "$FILE_PATH" 2>&1)
  status=$?
  # eslint: 0 = clean, 1 = lint errors, 2 = config/runtime error
  if [ $status -ne 0 ] && [ $status -ne 124 ]; then
    echo "ESLint findings in $FILE_PATH:" >&2
    truncate_output "$out" 25 >&2
  fi
}

case "$EXT" in
  py)
    check_python
    ;;
  ts|tsx|vue)
    check_typescript
    check_eslint
    ;;
  js|jsx|mjs|cjs)
    check_eslint
    ;;
  go)
    check_go
    ;;
  sh|bash)
    check_shellcheck
    ;;
esac
