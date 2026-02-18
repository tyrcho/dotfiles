#!/bin/bash
set -o pipefail

# Read input from Claude
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // ""')

# --- Parse Claude context data ---
model=$(echo "$input" | jq -r '.model.display_name // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Cache configuration ---
CACHE_DIR="$HOME/.claude/statusline_cache"
CACHE_TTL=600 # 10 minutes
mkdir -p "$CACHE_DIR"

# Check if a cache file is fresh (< TTL seconds old)
is_fresh() {
    local file="$1"
    [ -f "$file" ] || return 1
    local now mtime age
    now=$(date +%s)
    mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo 0)
    age=$(( now - mtime ))
    [ "$age" -lt "$CACHE_TTL" ]
}

# --- Fetchers removed (temperature and stock) ---

# --- Repository name (basename of git toplevel) ---
repo_name=""
if cd "$cwd" 2>/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
    branch_name=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
fi

# --- Format cost ---
cost_fmt=""
if [ -n "$cost" ]; then
    cost_fmt=$(printf '$%.2f' "$cost")
fi

# --- Context percentage bar ---
ctx_bar=""
if [ -n "$ctx_pct" ]; then
    # Build a 10-char bar: ████░░░░░░ 42%
    filled=$(( ctx_pct / 10 ))
    empty=$(( 10 - filled ))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    ctx_bar="${bar} ${ctx_pct}%"
fi

# --- Colors ---
c_temp=$(printf '\033[38;5;39m')    # cyan
c_stock=$(printf '\033[38;5;178m')  # gold
c_repo=$(printf '\033[38;5;75m')    # light blue
c_git=$(printf '\033[38;5;197m')    # magenta/pink
c_model=$(printf '\033[38;5;141m')  # purple
c_cost=$(printf '\033[38;5;114m')   # green
c_ctx=$(printf '\033[38;5;223m')    # warm yellow
c_sep=$(printf '\033[38;5;243m')    # gray
reset=$(printf '\033[0m')

# --- Build output ---
parts=()
[ -n "$repo_name" ]    && parts+=("$(printf '%b%s%b' "$c_repo" "$repo_name" "$reset")")
[ -n "$branch_name" ]  && parts+=("$(printf '%b%s%b' "$c_git" "$branch_name" "$reset")")
[ -n "$model" ]        && parts+=("$(printf '%b%s%b' "$c_model" "$model" "$reset")")
[ -n "$cost_fmt" ]     && parts+=("$(printf '%b%s%b' "$c_cost" "$cost_fmt" "$reset")")
[ -n "$ctx_bar" ]      && parts+=("$(printf '%b%s%b' "$c_ctx" "$ctx_bar" "$reset")")

sep=$(printf ' %b|%b ' "$c_sep" "$reset")
output=""
for i in "${!parts[@]}"; do
    [ "$i" -gt 0 ] && output+="$sep"
    output+="${parts[$i]}"
done

printf '%s\n' "$output"
