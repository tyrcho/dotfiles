# Changelog

## 2026-05-22

- Updated `skills/find-session/scripts/find_session.py` and `skills/find-session/SKILL.md`: flipped the active-session filter so past sessions now include the running session by default; opt-out via `--exclude-active` (the skill itself always passes the flag, since you almost never want the running session back). Default `--limit` lowered from 10 → 3. Match snippet preserves newlines and shows up to 3 lines with aligned continuation (was a single `re.sub`-collapsed line; pad widened from 25 to 80 chars). `--project` accepts paths: a needle containing `/` is normalised (lowercased, `/` and `.` → `-`, trailing `-` stripped) and anchored to exact `cwd` equality, so `--project ~/` (= `/Users/michel.daviot/`) matches only the home folder, not its subfolders; bare names without `/` still substring-match the folder name and its decoded form

## 2026-05-18

- Updated `commands/code-review.md`: replaced the vague "reread relevant principles" step with an explicit **Principle Coverage Checklist** that walks every general principle by category (Clean Code, Architecture, Reliability, language-specific). Reworded step 1 to make clear that all general principles are already loaded via `@`-directives and the `code-review:...` Skill entries are progressive disclosure (selective loading was the failure mode that caused entire categories — SOLID, Parse-Don't-Validate, Separation of Concerns, Idempotency, Resilience, Observability — to be skipped). Require every finding to carry a `[GEN]` / `[<LANG>]` tag
- Added tracked `.finicky.js` (force-added past the home-repo `*` gitignore): routes `docs.google.com`, `drive.google.com`, `sheets.google.com`, `slides.google.com`, `mail.google.com`, `gmail.com`, `*.new`, `login.microsoftonline.com`, and `portal.azure.com` to the Datadog Chrome profile. These hostnames were previously declared but never referenced, so Google Docs links fell through to `defaultBrowser` with no profile and opened in whichever Chrome instance was focused — including test-automation profiles. Dropped unused govcloud + ninja config (`ChromeProfiles.DatadogGov`/`DatadogNinja`, `GoogleIdp.DdGov`/`DdGovVault`/`DdNinja`, `AWSFedDirectoryId`, gov-routing handlers) and salesforce config. Switched to ESM `export default` per Finicky's v4 deprecation warning, used profile names (`Datadog`, `Michel`) instead of paths (`Default`, `Profile 1`), converted top-level identifiers to `const`

## 2026-05-11

- Reorganised `rules/` into topic subfolders: `code/` (coding-style, Software Architecture, Claude Plugins), `tools/` (mcp-integrations, Google Workspace MCP, Jira Writing, dev-tools, user-lookup, visualization), `process/` (git-workflows, dev-process, Confluence Writing), `datadog/` (datadog-patterns, team-context, direct-reports); `writing-style.md` stays at root. Updated all `@~/.claude/rules/...` references in `CLAUDE.md` and feature agents
- Added language-specific code-review principles under `commands/code-review/Languages/`: 5 files each for Python (Pythonic Idioms, Style and Naming, Type Hints, Error Handling and Resources, Data Structures), TypeScript (Strict Mode and Compiler Flags, Type System Discipline, Modern Syntax and Async, Type Definitions, Naming and Style), and Go (Code Style and Formatting, Error Handling, Interfaces and APIs, Concurrency, Testing). Sources: PEP 8/20/484, TypeScript Handbook, Effective Go, Go Code Review Comments, Datadog Cloud Platform Golang wiki, internal PR-review patterns
- Updated `commands/code-review.md`: added language-detection step (file extensions + config files), on-demand `Read` of the matching `Languages/<lang>/` folder, new "Part IV: Language-Specific Practices" section, and a Language-Specific Diagnostics table
- Added `commands/code-review/Reliability/Maintainability and Operations/Alphabetical Ordering.md`: general (language-agnostic) principle covering const blocks, registries, switch cases, dependency lists; where it does NOT apply (pipelines, precedence, external schemas); how to mechanize with `goimports`/`isort`/ESLint
- Added `commands/code-review/Languages/Go/Logging and Observability.md`: structured logging rules — static message + variable data in fields (never `Warnf`-style interpolation), context-attached logger so request-scoped fields propagate, typed field values, error helpers, wrap-and-return over log-and-return, levels, no-secrets rule
- Activated `compile-check.sh` in PostToolUse hooks (`settings.json`) so Python and TypeScript files are syntax/compile-checked after every Edit/Write. Removed the now-redundant "Python Projects - Hooks" section from `coding-style.md`
- Updated `rules/process/git-workflows.md`: added README structure convention — only `## Usage` and `## Implementation details / Architecture` top-level sections for code-project READMEs

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
