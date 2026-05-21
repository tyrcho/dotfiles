## Usage

Find a past Claude Code session and print the `claude --resume` command for it.

Invoked as the `find-session` skill, or run directly:

```bash
~/.claude/skills/find-session/scripts/find_session.py [QUERY]
    [--path PATH]
    [--since DATE] [--until DATE]
    [--project SUBSTR]
    [--limit N]
    [--include-observer] [--include-active]
```

See [SKILL.md](SKILL.md) for full flag documentation.

## Implementation details

Walks `~/.claude/projects/*/*.jsonl`. No external dependencies, no MCP, no claude-mem.

### Why claude-mem observer-sessions are skipped by default

The `~/.claude-mem/observer-sessions/` JSONLs ingest the transcripts of every other session for memory-building. Their text contains nearly every term you might search for, so they swamp substring queries with false positives and dominate raw hit-count rankings. They're filtered by project folder substring; `--include-observer` opts back in.

### Ranking

Token queries use TF-IDF over the scanned corpus:

```
score = Σ_t  (1 + log tf_t) · log(N / df_t)
```

- `tf_t` — occurrences of token `t` within this session
- `df_t` — number of scanned sessions where `t` appears at least once
- `N` — total scanned session count after filtering

Log-damped TF prevents very long transcripts (e.g. an "all source code" dump) from outranking the actual topic session just by repeating common words. A session ranks only if every query token appears at least once across its messages or tool calls.

Path-only queries (`--path` without a query string) are sorted by path-hit count. Tiebreakers throughout: path-hits, total entry hits, last-activity time.

### Snippet selection

Per session, each transcript entry is scored as `(distinct tokens hit, total occurrences)`; the highest-scoring entry wins. Inside that entry, `make_cluster_snippet` finds the tightest contiguous window covering at least one occurrence of every token present using a sliding window over sorted hit positions, capped at 200 chars and padded by 25 chars on each side. If no all-tokens window fits, falls back to a 40-char window around the first hit.

### Topic extraction

The first user message becomes the "Topic" line. If the session started with a slash command, the `<command-args>` payload is used; otherwise `<command-*>`, `<system-reminder>`, and `<local-command-stdout>` wrappers are stripped and whitespace is collapsed. Truncated to 120 chars.

### Resume command

`claude --resume <id>` only works from the original working directory of that session, so each result wraps the resume with `cd "<cwd>" && claude --resume <id>`. The cwd is read from the first `cwd` field present in the JSONL.

### Date filtering

`--since` / `--until` filter by JSONL **mtime** (last-activity), not start time, so sessions started earlier but resumed inside the window still appear.
