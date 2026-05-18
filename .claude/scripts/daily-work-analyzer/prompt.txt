Generate fresh work-analyzer reports for every 1:1 with a direct report on my calendar between now and the end of tomorrow, so they're ready by the time each meeting starts.

Steps:

1. List events from my primary calendar between now and the end of tomorrow (local time) via mcp__datadog-google-calendar__list_events. Concretely: `timeMin = now`, `timeMax = start of the day after tomorrow at 00:00 local`. This covers any remaining events today plus all of tomorrow's events.

2. Filter to 1:1s: events with exactly 2 attendees (me + 1 other). Each surviving event yields one attendee email.

3. For each attendee email, locate the direct report's note via grep:
   ```
   grep -lE "^email:\s*\"?<email>\"?" "/Users/michel.daviot/Library/CloudStorage/GoogleDrive-michel.daviot@datadoghq.com/My Drive/Datadog/Private notes/Management/People/"{AWS,GCP,Azure}/*/*.md
   ```
   The matching file is `<Person Folder>/<Person>.md`; read `github_id:` from its frontmatter. If no match, print `⚠ no Management/People folder for <email>` and skip the event.

4. Compute the report period for each matched 1:1:
   - Search calendar history for the previous 1:1 with this same attendee, looking back up to 90 days (mcp__datadog-google-calendar__list_events with `timeMin = now - 90d, timeMax = now`, then filter to events with exactly 2 attendees including this person).
   - Let `gap_days` = days between the previous 1:1 and today (use 7 if no prior 1:1 found).
   - `period_weeks = ceil(max(gap_days - 7, 7) / 7)` — at least 1 week, otherwise the gap minus a buffer so the report only covers work since the previous 1:1.
   - Cap `period_weeks` at 8 (~2 months).
   - `period_label = "{period_weeks} weeks"`.

5. For each matched 1:1, run `/work-analyzer:global-report <github_id> "<period_label>" "<Full Name>" "<person folder absolute path>" --slack` in parallel (one Agent call per person, run_in_background=true).

6. After each agent completes, move the nested dated folder directly under the person folder and remove the empty `work-analysis/{Name}/` parents (Obsidian folder-note convention — see ~/.claude/rules/datadog/direct-reports.md). The skill produces `<person folder>/work-analysis/{Name}/{date}-last-{N}weeks/{date}-last-{N}weeks.md`; target is `<person folder>/{date}-last-{N}weeks/{date}-last-{N}weeks.md`.

7. Once every agent has finished, print one line per meeting:
   `HH:MM — <Name> — <period_label> — <relative path from person folder root to the new folder note>`
   If no 1:1s were found in the window, print `No 1:1s scheduled between now and end of tomorrow` and exit cleanly. Do not run any agents in that case.
