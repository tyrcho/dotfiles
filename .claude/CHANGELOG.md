# Changelog

## 2026-04-14

- Added `post-push-check.sh` hook to verify TODO/CHANGELOG files stay synchronized with code changes after each push
- Updated `git-workflows.md`: added PR body template (Goals / Implementation / Next steps) and rule to never add `Co-Authored-By` trailers to commits
- Added `.claude/hooks/readme-check.sh` PostToolUse hook that reminds Claude to update existing README sections after file edits
- Moved `common-mistakes.py` from `.claude/scripts/` to `.claude/hooks/` and updated the reference in `settings.json`
