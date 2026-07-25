When spawning an `Agent` (or Workflow `agent()`) call that will **write or edit files**, not just read/search, pass `isolation: "worktree"` if other agents may run concurrently against the same repo. This avoids silent overwrite collisions when multiple agents touch the same checkout at once.

Read-only agents (`Explore`, research, `Plan`) do not need worktree isolation.

## Reducing worktree setup cost

- Add a `worktree.symlinkDirectories` entry (in `~/.claude/settings.json` or a project's `.claude/settings.json`) for heavy dependency directories (e.g. `node_modules`, `.venv`, `target`) so each new worktree doesn't reinstall dependencies from scratch.
- For large monorepos (e.g. `dd-source`, `dd-go`), set `worktree.sparsePaths` in that repo's project-level `.claude/settings.json` to the subdirectories actually needed, so worktree creation doesn't clone the entire repo.

## When not to bother

For a single agent working alone, or for a quick one-off edit, worktree isolation is unnecessary overhead. Reserve it for genuine concurrent write scenarios (e.g. multi-agent workflows, parallel subagent fan-out that edits code).
