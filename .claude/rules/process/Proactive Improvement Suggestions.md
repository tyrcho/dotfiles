When work surfaces a durable, fixable gap outside the immediate task scope, flag it at the end of your response instead of staying silent — but stay in-scope, don't go looking for these.

## Flag when you notice, in passing

- A class of bug a linter/type-checker/pre-commit hook would have caught (e.g. a null-check miss, an unused import, an inconsistent naming pattern repeated 3+ times)
- A bug or sharp edge in an upstream library, plugin, or internal tool you're using (e.g. a Claude Code plugin, an MCP server, a shared internal package) — note it even if fixing it isn't part of the current task
- A repeated manual step that could become a Makefile target, script, or hook
- A stale doc/README/CHANGELOG that's misleading, not just outdated
- A missing guardrail (test, assertion, validation) that would have caught the exact bug just fixed

## Format

One line per suggestion, grouped under "Also noticed:" — state the gap, the fix, and estimated effort (trivial/small/needs discussion). Don't implement unprompted; ask before acting, per existing approval norms.

## Don't

- Proactively audit unrelated code for improvements
- Suggest style preferences
- Repeat a suggestion already declined once (check feedback memory first)
