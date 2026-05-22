# Development Tools & Commands

## Makefile First Approach

**CRITICAL**: Always check for Makefile before running commands.

### Workflow
1. Check: `ls -la Makefile`
2. View targets: `make help` or `grep '^[a-zA-Z_-]*:' Makefile`
3. Use Makefile target instead of direct commands

### Common Mappings
- ✅ `make build` instead of `npm run build`
- ✅ `make test` instead of `npm test`
- ✅ `make deploy` instead of custom deployment commands
- ✅ `make push` instead of `clasp push`

## Searching DataDog repositories

**Prefer local checkouts in `~/dd/` over `gh api`/`gh search`.**

Most DataDog repos used in daily work are sparse-cloned or fully cloned under `~/dd/<repo>` (e.g. `~/dd/dd-source`, `~/dd/dogweb`, `~/dd/cloud-inventory`). Local file reads and `grep`/`find` are orders of magnitude faster than the GitHub REST API, work offline, and do not consume API rate limit.

### Workflow
1. Check whether the repo is checked out: `[ -d ~/dd/<repo> ] && echo present`.
2. If present: `grep -rn`, `find`, or Read directly under `~/dd/<repo>/<path>`.
3. If absent or the local copy is stale: fall back to `gh api repos/DataDog/<repo>/...` or a sparse clone into `/tmp`.

When a memory or wiki page cites a specific commit SHA, run `git -C ~/dd/<repo> log -1 --format=%H` to confirm the local copy is at or past that revision before trusting `grep` results; otherwise sync with `git -C ~/dd/<repo> pull`.

## Search Tools

### Recollq (Priority #1)
Use `recollq` BEFORE Grep/Glob for documentation/architecture questions.

**Common patterns:**
```bash
recollq <search terms>                    # Basic search
recollq -n 5 -A <terms>                  # Top 5 with abstracts
recollq mime:application/pdf <terms>     # PDFs only
recollq dir:"<path>" <terms>             # Specific directory
```

### When to use each tool
1. **recollq**: Documentation, architecture, "where is X handled?"
2. **Explore agent**: Codebase structure, non-needle queries
3. **Grep/Glob**: Specific class/function names after narrowing scope

## MCP Servers

Authorized to use without requesting permission.
