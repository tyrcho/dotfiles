# Changelog

## 2026-04-28

- Updated `rules/Software Architecture.md`: replaced generic hexagonal `core/adapters` folder structure with a concrete three-folder layout — `domains/` (pure logic + interfaces), `repositories/` (DB/service implementations), `main/` (entrypoints such as API, CLI, GSheet functions)
- Created `rules/Claude Plugins.md`: extracted Claude plugins folder organization from `Software Architecture.md` into its own rule; added reference in `CLAUDE.md`
- Updated `rules/Software Architecture.md`: removed "Bad" folder structure columns, keeping only the "Good" examples
- Updated `rules/Software Architecture.md`: resolved two contradictions — folder structure now shows domain-first hexagonal layout; port naming aligned between key rules and code examples
- Created `rules/Software Architecture.md`: consolidated "Folder Organization - Domain Over Layer" and "Hexagonal Architecture (Ports & Adapters)" sections moved from `coding-style.md`
- Updated `rules/coding-style.md`: removed "Folder Organization" and "Hexagonal Architecture" sections (moved to `Software Architecture.md`)
- Updated `CLAUDE.md`: added `Software Architecture` reference under Code Quality section
- Updated `rules/coding-style.md`: added "Hexagonal Architecture (Ports & Adapters)" section covering ports/adapters pattern, folder structure, TypeScript example, and testing with in-memory fakes
- Updated `rules/git-workflows.md`: added `--draft` flag to all `gh pr create` commands so PRs are always opened as drafts
- Added `rules/Google Workspace MCP.md`: actionable rule for Docs MCP covering tool selection, known gaps (nested lists, tables, HRs), index stability, and Docs vs. Slides disambiguation
- Updated `CLAUDE.md`: added references to Google Workspace MCP, Confluence Writing, and Jira Writing rules under MCP & Integrations / Writing sections
- Updated `rules/writing-style.md`: added Slack links and Datadog incident reference sections
- Updated `commands/code-review.md`: fixed formatting of per-violation template blocks
- Updated `settings.json`: added `faq@cloud-observability` plugin, fixed marketplace path for `cloud-observability` to use absolute path, reordered plugin entries
- Deleted `scripts/common-mistakes.py` (already moved to `hooks/` in a prior commit; removed stale copy)

## 2026-04-14

- Added `post-push-check.sh` hook to verify TODO/CHANGELOG files stay synchronized with code changes after each push
- Updated `git-workflows.md`: added PR body template (Goals / Implementation / Next steps) and rule to never add `Co-Authored-By` trailers to commits
- Added `.claude/hooks/readme-check.sh` PostToolUse hook that reminds Claude to update existing README sections after file edits
- Moved `common-mistakes.py` from `.claude/scripts/` to `.claude/hooks/` and updated the reference in `settings.json`
