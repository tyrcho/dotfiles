# Git & GitHub Workflows

## Critical Rules

### Branch Naming
- Branch names must start with `michel.daviot/` (e.g. `michel.daviot/my-feature`)

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

**Structure for code project READMEs:**

```markdown
## Usage
<how to install, configure, and run the project>

## Implementation details / Architecture
<design decisions, key components, how it works internally>
```

Only these two top-level sections. No intro blurb, no badges section, no contributing section unless explicitly requested.

### Commit Messages
- **Never** add `Co-Authored-By` trailers to commit messages

### Before every commit

Before creating a commit, verify that the following files are up to date with the changes being committed:
- **CHANGELOG** (if present): add an entry for the change
- **TODO** (if present): remove completed items, add new ones if relevant
- **README.md** (if present): update affected sections
- **docs/** (if present): update any affected documentation files
- **Makefile** (if present): update targets if new scripts or workflows were added

If any of these are stale, update them before creating the commit and include them in the same commit.

### Pushing to an existing PR branch

After every `git push` to a branch that already has an open PR:
1. Run `gh pr view --json title,body,commits` to read the current PR state and all commits on the branch.
2. Rewrite the PR description from scratch using the template below, treating the entire branch as one coherent changeset — do not list individual commits or surface commit history in the description.
3. Update with `gh pr edit --title "..." --body "..."` even if the changes seem minor — the description must always reflect the full current state of the branch.

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
