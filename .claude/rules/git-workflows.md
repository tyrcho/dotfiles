# Git & GitHub Workflows

## Critical Rules

### Directory Navigation
- ✅ **ALWAYS**: `builtin cd /path/to/repo; git status`
- ❌ **NEVER**: `git -C /path/to/repo status`

### GitHub Integration
- Always use `gh` CLI for GitHub operations
- Examples:
  - `gh pr view 123`
  - `gh issue list`
  - `gh pr create --title "..." --body "..."`

## Common Workflows

### Before Every Commit
- If a `README.md` exists in the repo, review it and update it to reflect the changes being committed.

### Creating PRs
1. Ensure changes are committed
2. Push to remote: `git push -u origin branch-name`
3. Create PR: `gh pr create --title "..." --body "..."`

### Cleaning Up Branches
- Use skill: `commit-commands:clean_gone`
- Removes all [gone] branches and associated worktrees
