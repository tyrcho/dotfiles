## Usage

Find a past Claude Code session and print the `claude --resume` command for it.

Invoked as the `find-session` skill, or run directly:

```bash
~/.claude/skills/find-session/scripts/find_session.py QUERY
    [--since DATE] [--until DATE]
    [--project SUBSTR]
    [--limit N]
    [--include-active]
```

See [SKILL.md](SKILL.md) for full flag documentation.

## Implementation details

Scans a static allowlist of project folders under `~/.claude/projects/`. No external dependencies, no MCP, no claude-mem.

### Static project allowlist

The scan set is defined by two module-level globs:

- `PROJECT_INCLUDE_GLOB = "-Users-michel-daviot*"` — only folders whose encoded cwd starts with `~`.
- `PROJECT_EXCLUDE_GLOB = "*--claude-mem-*"` — subtracts claude-mem's `observer-sessions`. Those JSONLs ingest the transcripts of every other session for memory-building; their text contains nearly every term you might search for, so they swamp substring queries with false positives and dominate raw hit-count rankings.

The allowlist also drops ephemeral cwds (`-private-tmp*`, the bare `-` for root) as a side effect. Edit the constants at the top of `scripts/find_session.py` if the home folder name changes or if other paths become relevant.

### Ranking

TF-IDF over the scanned corpus:

```
score = Σ_t  (1 + log tf_t) · log(N / df_t)
```

- `tf_t` — occurrences of token `t` within this session (across messages, tool inputs, and tool-call file paths)
- `df_t` — number of scanned sessions where `t` appears at least once
- `N` — total scanned session count after filtering

Log-damped TF prevents very long transcripts (e.g. an "all source code" dump) from outranking the actual topic session just by repeating common words. A session ranks only if every query token appears at least once. Tiebreakers: entry-hit count, then last-activity time.

### File-path matches

File paths from `Read`/`Write`/`Edit`/notebook tool calls are folded into the per-entry searchable text, so token queries match them just like message text. When a query token appears in a path string, the file is recorded in `file_counts` (per-occurrence) and surfaced in the `Files:` line of the result.

### Snippet selection

Per session, each transcript entry is scored as `(distinct tokens hit, total occurrences)`; the highest-scoring entry wins. Inside that entry, `make_cluster_snippet` finds the tightest contiguous window covering at least one occurrence of every token present using a sliding window over sorted hit positions, capped at 200 chars and padded by 25 chars on each side. If no all-tokens window fits, falls back to a 25-char window around the first hit.

### Topic extraction

The first user message becomes the "Topic" line. If the session started with a slash command, the `<command-args>` payload is used; otherwise `<command-*>`, `<system-reminder>`, and `<local-command-stdout>` wrappers are stripped and whitespace is collapsed. Truncated to 120 chars.

### Resume command

`claude --resume <id>` only works from the original working directory of that session, so each result wraps the resume with `cd "<cwd>" && claude --resume <id>`. The cwd is read from the first `cwd` field present in the JSONL.

### Date filtering

`--since` / `--until` filter by JSONL **mtime** (last-activity), not start time, so sessions started earlier but resumed inside the window still appear.

### Output

Each result reports `matched N/M entries` — `N` is the count of transcript records (user messages, assistant messages, tool results) in which at least one query token appeared; `M` is the total entries in the session. The ratio is a density signal: small `N/M` means the topic was incidental, large `N/M` means the session was largely on-topic. The `Files:` line, when present, lists the up to three most-touched tool-call file paths whose path string contained a query token, with per-file occurrence counts. The `Topic:` line is the first user message (slash-command args preferred); the `Match:` line is the tightest snippet for the best-scoring entry.
