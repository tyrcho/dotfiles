# Git & GitHub Workflows

## Critical Rules

### Branch Naming
- Branch names must start with `michel.daviot/` (e.g. `michel.daviot/my-feature`)

### Directory Navigation
- ✅ **ALWAYS**: `builtin cd /path/to/repo; git status`
- ❌ **NEVER**: `git -C /path/to/repo status`

### GitHub Integration
- Always use `gh` CLI for GitHub operations
- Examples:
  - `gh pr view 123`
  - `gh issue list`
  - `gh pr create --title "..." --body "..."`

## Git Worktrees

- Always verify the current working directory before making edits when a worktree is active.
- Never edit files in the main checkout when a worktree is active.

## Common Workflows

### README Updates

A `PostToolUse` hook automatically checks for a nearby README.md after each file edit and reminds Claude to review it.

- ✅ Update **existing sections** silently when content is outdated
- ❌ **Never** create a new `README.md` without asking the user
- ❌ **Never** add a new section to an existing README without asking the user

### Commit Messages
- **Never** add `Co-Authored-By` trailers to commit messages

### Creating PRs
1. Ensure changes are committed
2. Push to remote: `git push -u origin branch-name`
3. Create PR using the template below

**PR body template:**

```markdown
## Goals

<user-facing bullet points — what changed and why, no technical details>

## Implementation

<bullet points for contributors — how it was made, key decisions>

## Next steps (optional)

<todo ideas, rollout plan, or testing instructions>
```

### Cleaning Up Branches
- Use skill: `commit-commands:clean_gone`
- Removes all [gone] branches and associated worktrees
