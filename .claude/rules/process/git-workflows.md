# Git & GitHub Workflows

## Git `index.lock` collisions are expected

Several agents often run in the same folder, so this error is normal:

`fatal: Unable to create '<path>/index.lock': File exists.`

Handle it silently. Do not mention it to the user unless something unexpected happens (see below).

### Procedure

1. **Wait and retry.** Another agent is probably mid-operation. Retry after a few seconds, up to about 5 times with a growing delay (2s, 4s, 8s...). Most locks clear on their own.
2. **If it persists, inspect the exact lock path from the error message.**
   - Age and size: `ls -la <lock>`
   - Holder: `lsof <lock>` and `pgrep -fl git`
3. **Remove it only if it is stale**: older than about 2 minutes, and no holder, and no running git process for this repo. Remove that exact file only (`rm <lock>`). Never use globs or `rm -rf` on `.git`. Then retry once.
4. **A young or held lock is live.** Keep waiting, up to about 2 minutes. Never remove it: that corrupts the other agent's operation.

Where the lock lives:
- Main checkout: `<repo>/.git/index.lock`
- Worktree: `<repo>/.git/worktrees/<name>/index.lock` (worktrees have their own lock, so they do not collide with the main checkout)

### Reduce collisions

- Chain add and commit in one command: `git add <paths> && git commit -m "..."`.
- Use `git --no-optional-locks status` and `git --no-optional-locks diff` for read-only checks.
- Do not poll `git status` in loops.

### When to tell the user

Only for something unexpected:
- A live lock that does not clear after about 2 minutes.
- A lock that is non-empty, or keeps coming back right after removal.
- Index corruption errors (`index file corrupt`, `bad signature`, `unable to read tree`).
- A removal that would risk another agent's work.

### Suggest a worktree when it gets in the way

If collisions slow the task noticeably (about 3 or more waits in one task), suggest once, in one line, moving the work to a worktree (`EnterWorktree`). Do not move the work without the user's agreement.

## Critical Rules

### GitHub Integration
- Always use `gh` CLI for GitHub operations
- Always create PRs as **draft** (`gh pr create --draft`)
- Examples:
  - `gh pr view 123`
  - `gh issue list`
  - `gh pr create --draft --title "..." --body "..."`

### Replying to PR/Issue Comments

**Never post a reply to a review comment, issue comment, or discussion unsupervised.** Draft the reply and show it to the user for approval first; only post after they confirm. Same principle as draft PRs — visible-to-others actions default to review-before-publish.

**Exception: bot comments.** When pushing a fix to a PR that addresses an issue a bot reported (e.g. CI bots, linters, review bots like CodeRabbit/Copilot/Sourcery), Claude may reply directly to that bot's comment confirming the fix, without waiting for approval. This exception applies only to comments authored by bots, never to human reviewers or collaborators — those always go through the draft-and-approve flow above. Sign these replies clearly as Claude (e.g. "Fixed by Claude:") so it's obvious the reply was not written by the user.

### Stacked PRs

Use `git rebase --update-refs` to keep a stack of branches in sync, instead of hand-rolling `git rebase --onto` per branch or reaching for the `gh stack` extension.

Enable it globally once so every rebase updates the whole stack automatically:

```
git config --global --add --bool rebase.updateRefs true
```

Common flows:

- **Lower branch in the stack got new commits (e.g. PR feedback):** checkout the top branch and rebase onto the changed one — every branch in between is force-updated in place.
  ```
  git checkout <top-branch>
  git rebase <changed-branch> --update-refs
  ```
- **Whole stack needs to catch up with the base branch:** checkout the top branch and rebase onto the base — all local branches pointing at rebased commits move with it.
  ```
  git checkout <top-branch>
  git rebase <base-branch> --update-refs
  ```
- **Move/insert a commit into an earlier branch in the stack:** interactive rebase against the base branch. The todo list gets extra `update-ref refs/heads/<branch>` lines marking where each branch's tip should land after reordering — move commits above/below these lines as needed.
  ```
  git rebase <base-branch> -i --update-refs
  ```

After any of these, still checkout and force-push each branch that moved (`--update-refs` only rewrites local refs). Branches currently checked out in another worktree are not updated by `--update-refs` — rebase those separately.

Source: [Working with stacked branches in Git is easier with --update-refs](https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/)

### Stacked PR descriptions

Every PR that is part of a stack must list the full stack in its description, so a reviewer landing on any one PR can see the whole chain without hunting through branch names. Add a `## Stack` section **at the very top of the description**, above the template's `# Features`/`# Fixes` sections, listing every PR in the stack in order, base first, marking the current one:

```markdown
## Stack
1. #<n>
2. #<n> (this PR)
3. #<n>
```

Don't repeat the PR title after the number — GitHub already renders it inline next to the link, so `1. #70207` is enough; adding `— <title>` duplicates text GitHub shows for free.

Don't restate the stack (or list other PRs) inside `### Goal` — that's what the `## Stack` section is for. `### Goal` may still reference one *specific* PR by number in prose when its content is genuinely why this PR exists (e.g. "now that #71215's generator is verified, this expands it to..."), but never as a repeat of the full stack list.

Update the `## Stack` list on every PR in the stack whenever a new one is added to the chain — not just the newest one — so it never goes stale mid-stack.

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

### After creating a PR

Whenever a PR is created, even as a draft, suggest scheduling a follow-up task (e.g. via `/loop` or a cron-style check) for Claude to come back and check for new review comments to address. Don't schedule it automatically — just offer, and let the user opt in. If the user opts in, schedule the check for no more than 1 hour out.

### Cleaning Up Branches
- Use skill: `commit-commands:clean_gone`
- Removes all [gone] branches and associated worktrees
