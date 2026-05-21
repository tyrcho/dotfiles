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

```
~/.claude/skills/find-session/scripts/find_session.py QUERY
    [--since DATE] [--until DATE]
    [--project SUBSTR]
    [--limit N]
    [--include-active]
```

- `QUERY` — space-separated tokens, all of which must appear (in any order). Each token matches case-insensitively as a substring against messages, tool inputs, tool results, and tool-call file paths. Required.
- `--since` / `--until` — ISO date (`YYYY-MM-DD`), or shorthand `today`, `yesterday`, `Nd` (last N days). Filters by **last-activity** time (JSONL mtime).
- `--project` — substring filter on the project folder name.
- `--limit` — max results (default 10).
- `--include-active` — don't auto-skip the session this script is running inside.

To search by file path, just pass the filename as a token (e.g. `find_session.py "recommendations.md"`).

See [README.md](README.md) for scan-set allowlist, TF-IDF ranking, snippet selection, and output format details.

## Output handling

The script writes a ranked markdown report to stdout. **Relay it to the user verbatim.** Do not re-rank, summarise, or trim — the user wants the resume commands.

Exit code 1 + `No sessions matched.` on stderr means zero hits; tell the user and suggest broadening the query (drop tokens, widen `--since`, remove `--project`).

## Important caveat

`claude --resume <id>` only works from the original working directory of that session. The script's output already wraps the resume in `cd "<cwd>" && claude --resume <id>` — preserve that form when relaying to the user.

## Example

User: "find the session where I worked on `common/concepts/recommendations.md`"

Run:

```bash
~/.claude/skills/find-session/scripts/find_session.py "recommendations.md"
```

Then paste the script's output verbatim in your reply.
