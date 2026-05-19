Generate fresh work-analyzer reports for every 1:1 with a direct report on my calendar between now and the end of tomorrow, so they're ready by the time each meeting starts.

Constants:

- `MAX_PERIOD_WEEKS = 8` — hard cap on the report period (~2 months). Also defines how far back to search for the previous 1:1 with the same person, since anything older would be clamped to this cap anyway.
- `FRESHNESS_WINDOW_HOURS = 48` — if an existing report for a person is younger than this, reuse it instead of regenerating.
- `MIN_REPORT_SIZE_KB = 10` — minimum size of a complete synthesis file. Anything smaller is treated as truncated / in-flight and will not be reused. (Observed real reports range 18–35 KB.)

Steps:

1. List events from my primary calendar between now and the end of tomorrow (local time) via mcp__datadog-google-calendar__list_events. Concretely: `timeMin = now`, `timeMax = start of the day after tomorrow at 00:00 local`. This covers any remaining events today plus all of tomorrow's events.

2. Filter to 1:1s: events with exactly 2 attendees (me + 1 other). Each surviving event yields one attendee email.

3. For each attendee email, locate the direct report's note via grep:
   ```
   grep -lE "^email:\s*\"?<email>\"?" "/Users/michel.daviot/Library/CloudStorage/GoogleDrive-michel.daviot@datadoghq.com/My Drive/Datadog/Private notes/Management/People/"{AWS,GCP,Azure}/*/*.md
   ```
   The matching file is `<Person Folder>/<Person>.md`; read `github_id:` from its frontmatter. If no match, print `⚠ no Management/People folder for <email>` and skip the event.

4. Compute the report period for each matched 1:1:
   - Search calendar history for the previous 1:1 with this same attendee, looking back up to `MAX_PERIOD_WEEKS` weeks (mcp__datadog-google-calendar__list_events with `timeMin = now - MAX_PERIOD_WEEKS*7d, timeMax = now`, then filter to events with exactly 2 attendees including this person). **Include past instances of the same recurring event** — do not skip them just because they share a recurrence ID with the upcoming meeting.
   - If a prior 1:1 is found: `gap_days` = days between the previous 1:1 and today; `period_weeks = max(1, ceil(gap_days / 7))`.
   - If no prior 1:1 is found in the lookback window: `period_weeks = MAX_PERIOD_WEEKS` (the gap is at least as long as the lookback).
   - `period_label = "{period_weeks} weeks"`.

5. Check for a fresh **and complete** existing report before running the agent:
   - Look in the person folder for any prior folder note matching `<person folder>/*-last-*weeks/*-last-*weeks.md`. Pick the one with the most recent file mtime.
   - Reuse it (skip the agent run for this person) only if **all** of the following hold:
     1. The file's mtime is within the last `FRESHNESS_WINDOW_HOURS` hours.
     2. The file's size is at least `MIN_REPORT_SIZE_KB` KB (guards against truncated / in-flight reports — see today's Raphael near-miss).
     3. The expected per-source data files exist in the same folder and are non-empty: at minimum `github-data.md` and `jira-data.md`, plus `slack-data.md` if `--slack` was used.
   - If reusing, record the relative path so step 8 can mention it as `reused`.
   - Otherwise (no candidate, stale, undersized, or missing data files), proceed to step 6 and regenerate.

6. For each matched 1:1 that was not skipped in step 5, run `/work-analyzer:global-report <github_id> "<period_label>" "<Full Name>" "<person folder absolute path>" --slack` in parallel (one Agent call per person, run_in_background=true).

7. After each agent completes, move the nested dated folder directly under the person folder and remove the empty `work-analysis/{Name}/` parents (Obsidian folder-note convention — see ~/.claude/rules/datadog/direct-reports.md). The skill produces `<person folder>/work-analysis/{Name}/{date}-last-{N}weeks/{date}-last-{N}weeks.md`; target is `<person folder>/{date}-last-{N}weeks/{date}-last-{N}weeks.md`.

8. Once every agent has finished, print one line per meeting:
   `HH:MM — <Name> — <period_label> — <relative path from person folder root to the folder note> [reused]?`
   Append ` [reused]` for meetings whose report was reused under the freshness rule in step 5. If no 1:1s were found in the window, print `No 1:1s scheduled between now and end of tomorrow` and exit cleanly. Do not run any agents in that case.
