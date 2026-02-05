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

## Skills Available

- `github`: GitHub operations
- `jira-to-prs`: Find PRs from Jira tickets
- `analyze-engineer-work`: Cross-platform work analysis
- `commit-commands:commit-push-pr`: Atomic commit+push+PR
- `commit-commands:clean_gone`: Clean up gone branches
- `c4-diagram`: Generate PlantUML C4 diagrams
