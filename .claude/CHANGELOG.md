# Changelog

## 2026-04-28

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
