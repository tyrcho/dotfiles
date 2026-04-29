# Git & GitHub Workflows

## Critical Rules

### Branch Naming
- Branch names must start with `michel.daviot/` (e.g. `michel.daviot/my-feature`)

### Directory Navigation
- ✅ **ALWAYS**: `builtin cd /path/to/repo; git status`
- ❌ **NEVER**: `git -C /path/to/repo status`

### GitHub Integration
- Always use `gh` CLI for GitHub operations
- Always create PRs as **draft** (`gh pr create --draft`)
- Examples:
  - `gh pr view 123`
  - `gh issue list`
  - `gh pr create --draft --title "..." --body "..."`

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
3. Create PR as **draft** using the template below (`gh pr create --draft ...`)

**PR body template:**

```markdown
# New features

## <Feature name>

### Goal
<User-facing description — what it does and why, no technical details>

### Implementation
- [`filename`](<diff link>): <what changed and key decisions>

# Fixes

## <Bug description>

### Goal
<What was broken and what the correct behavior is>

### Implementation
- [`filename`](<diff link>): <what changed>
```

**Implementation diff links:** use PR file diff anchors, not blob permalinks.

The anchor hash is `sha256(filepath)` where `filepath` is the path from the repo root. Generate with:

```bash
python3 -c "import hashlib; print(hashlib.sha256('path/to/file'.encode()).hexdigest())"
```

Link format: `https://github.com/{owner}/{repo}/pull/{number}/files#diff-{hash}`

**Notes:**
- Omit `# Fixes` section if there are no bug fixes, and vice versa for features
- Each feature/fix gets its own `##` subsection
- `### Goal` is user-facing (no implementation details); `### Implementation` is for contributors
- **Never** add the `🤖 Generated with Claude Code` footer to PR descriptions

### Cleaning Up Branches
- Use skill: `commit-commands:clean_gone`
- Removes all [gone] branches and associated worktrees
