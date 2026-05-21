---
name: find-session
description: Find a past Claude Code session and print the `claude --resume` command for it. Use when the user wants to resume, locate, or look up a previous conversation — phrases like "which session was that", "find the session where I edited X", "resume the session about Y", "what was yesterday's session ID", "find past conversation about Z".
allowed-tools: Bash, Read
---

## When to invoke

The user is asking to locate or resume a past Claude Code conversation. Triggers include:

- "find the session where I worked on `<file>`"
- "which session was that"
- "what was yesterday's session ID"
- "resume the session about `<topic>`"
- "find past conversation about `<topic>`"

## How to run

The script lives at `~/.claude/skills/find-session/scripts/find_session.py`. It walks `~/.claude/projects/*/*.jsonl` (no external services, no MCP, no claude-mem dependency).

```
~/.claude/skills/find-session/scripts/find_session.py [QUERY]
    [--path PATH]
    [--since DATE] [--until DATE]
    [--project SUBSTR]
    [--limit N]
    [--include-observer] [--include-active]
```

- `QUERY` — space-separated tokens, all of which must appear (in any order) somewhere in the session. Each token is matched case-insensitively as a substring against messages, tool inputs, and tool results. Use a single token (e.g. `"black-games"`) when you want exact-substring behavior. Optional if `--path` is given.
- `--path` — substring matched against tool-call file paths (Read/Write/Edit). When set, drives the primary ranking (sorted by path-hit count).
- `--since` / `--until` — ISO date (`YYYY-MM-DD`), or shorthand `today`, `yesterday`, `Nd` (last N days). Filters by **last-activity** time (JSONL mtime), so sessions started earlier but resumed inside the window still match.
- `--project` — substring filter on the project folder name (e.g. `cloud-obs-wiki`).
- `--limit` — max results (default 10).
- `--include-observer` — opt in to claude-mem `observer-sessions` (excluded by default; their transcripts contain noisy memory dumps that swamp substring searches).
- `--include-active` — don't auto-skip the session this script is running inside.

If the user mentions a file path, prefer `--path` over `QUERY` so that file-path hits drive ranking.

## Ranking

- **Token queries** (any `QUERY`): TF-IDF over the scanned corpus, with log-damped TF (`(1 + log(tf)) · log(N/df)`). Sessions where the rarest tokens appear most prominently rank first; bulk-hit sessions that merely happen to contain common words sink. Path-hit count is a tiebreaker, then last-activity.
- **Path-only queries** (`--path` without `QUERY`): sorted by path-hit count, then last-activity.

## Output handling

The script writes a ranked markdown report to stdout. **Relay it to the user verbatim.** Do not re-rank, summarise, or trim — the user wants the resume commands.

Exit code 1 + `No sessions matched.` on stderr means zero hits; tell the user and suggest broadening the query (drop `--path`, widen `--since`, remove `--project`).

## Important caveat

`claude --resume <id>` only works from the original working directory of that session. The script's output already wraps the resume in `cd "<cwd>" && claude --resume <id>` — preserve that form when relaying to the user.

## Example

User: "find the session where I worked on `common/concepts/recommendations.md`"

Run:

```bash
~/.claude/skills/find-session/scripts/find_session.py --path common/concepts/recommendations.md
```

Then paste the script's output verbatim in your reply.
